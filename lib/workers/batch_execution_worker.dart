import 'dart:async';
import 'dart:isolate';
import 'dart:math';

import '../core/constants/app_constants.dart';
import '../data/models/batch_stats.dart';
import '../data/models/item.dart';
import '../data/models/log_entry.dart';
import '../services/checkpoint_service.dart';
import '../services/json_parser_service.dart';
import '../services/llm_api_service.dart';
import '../services/prompt_service.dart';
import 'worker_messages.dart';

class BatchExecutionWorker {
  BatchExecutionWorker();

  Isolate? _isolate;
  ReceivePort? _eventPort;
  StreamSubscription<dynamic>? _eventSub;
  SendPort? _commandPort;

  final _eventsController = StreamController<WorkerEvent>.broadcast();
  final _errorsController = StreamController<Object>.broadcast();

  Stream<WorkerEvent> get events => _eventsController.stream;
  Stream<Object> get errors => _errorsController.stream;
  bool get isRunning => _isolate != null;

  Future<void> start() async {
    if (isRunning) {
      return;
    }

    final eventPort = ReceivePort();
    final commandPortCompleter = Completer<SendPort>();

    _eventSub = eventPort.listen((message) {
      if (message is SendPort) {
        if (!commandPortCompleter.isCompleted) {
          commandPortCompleter.complete(message);
        }
        return;
      }

      final event = WorkerMessageCodec.decodeEvent(message);
      if (event != null) {
        _eventsController.add(event);
      }
    });

    final isolate = await Isolate.spawn<_WorkerBootstrapMessage>(
      _workerMain,
      _WorkerBootstrapMessage(eventPort.sendPort),
      errorsAreFatal: false,
      debugName: 'batch_execution_worker',
    );

    _eventPort = eventPort;
    _isolate = isolate;

    try {
      _commandPort = await commandPortCompleter.future.timeout(
        const Duration(seconds: 5),
      );
    } on TimeoutException {
      _errorsController.add(
        TimeoutException('Worker startup timed out (command port not received)'),
      );
      await dispose();
      rethrow;
    }
  }

  void sendCommand(WorkerCommand command) {
    final commandPort = _commandPort;
    if (commandPort == null) {
      throw StateError('Worker is not started.');
    }
    commandPort.send(WorkerMessageCodec.encodeCommand(command));
  }

  Future<void> dispose() async {
    _eventSub?.cancel();
    _eventSub = null;
    _eventPort?.close();
    _eventPort = null;
    _commandPort = null;
    _isolate?.kill(priority: Isolate.immediate);
    _isolate = null;
  }

  Future<void> close() async {
    await dispose();
    await _eventsController.close();
    await _errorsController.close();
  }
}

class _WorkerBootstrapMessage {
  _WorkerBootstrapMessage(this.eventPort);

  final SendPort eventPort;
}

class _WorkerRuntime {
  _WorkerRuntime(this.eventPort);

  final SendPort eventPort;

  bool _isPaused = false;
  bool _stopRequested = false;
  Completer<void>? _pauseCompleter;
  Future<void>? _activeRun;

  final _promptService = PromptService();
  final _llmApiService = LlmApiService();
  final _jsonParserService = JsonParserService();
  final _checkpointService = CheckpointService();
  final _random = Random();

  void handleCommand(WorkerCommand command) {
    switch (command) {
      case StartBatchCommand():
        if (_activeRun != null) {
          _emitLog(
            'Batch execution is already running.',
            level: LogLevel.warn,
          );
          return;
        }
        _stopRequested = false;
        _isPaused = false;
        _activeRun = _runBatch(command).whenComplete(() {
          _activeRun = null;
        });
      case PauseBatchCommand():
        _isPaused = true;
        _pauseCompleter ??= Completer<void>();
        _emitLog('Batch execution paused.');
      case ResumeBatchCommand():
        _isPaused = false;
        _pauseCompleter?.complete();
        _pauseCompleter = null;
        _emitLog('Batch execution resumed.');
      case StopBatchCommand():
        _stopRequested = true;
        _isPaused = false;
        _pauseCompleter?.complete();
        _pauseCompleter = null;
        _emitLog('Stop requested for batch execution.', level: LogLevel.warn);
    }
  }

  Future<void> _runBatch(StartBatchCommand command) async {
    try {
      final config = command.config;
      if (command.items.isEmpty) {
        _emitError('No items to process.');
        return;
      }
      if (config.promptFiles.isEmpty) {
        _emitError('No prompts configured for batch.');
        return;
      }
      if (config.models.isEmpty) {
        _emitError('No models configured for batch.');
        return;
      }

      final model = config.models.first;
      final providerType = model.providerId;
      final baseUrl =
          command.providerBaseUrls[providerType] ?? _defaultBaseUrl(providerType);

      final totalChunks = (command.items.length / config.chunkSettings.chunkSize).ceil();
      final totalApiCalls =
          totalChunks * config.promptFiles.length * config.chunkSettings.repetitions;

      var stats = BatchStats(
        totalApiCalls: totalApiCalls,
        totalItems: command.items.length,
        startedAt: DateTime.now(),
      );

      final results = <Map<String, dynamic>>[];
      var callCounter = 0;

      for (var rep = 1; rep <= config.chunkSettings.repetitions; rep++) {
        final repItems = List<Item>.of(command.items);
        if (config.chunkSettings.shuffleBetweenReps) {
          repItems.shuffle(_random);
        }

        for (var promptIndex = 0;
            promptIndex < config.promptFiles.length;
            promptIndex++) {
          final promptName = config.promptFiles[promptIndex];
          final promptTemplate = command.prompts[promptName];
          if (promptTemplate == null) {
            _emitLog(
              'Prompt "$promptName" not found in loaded prompt map.',
              level: LogLevel.warn,
            );
            continue;
          }

          final chunks = _promptService.createChunks(
            repItems,
            config.chunkSettings.chunkSize,
          );

          for (var chunkIndex = 0; chunkIndex < chunks.length; chunkIndex++) {
            final shouldContinue = await _waitIfPausedOrStopped();
            if (!shouldContinue) {
              _emitError('Batch execution stopped by user.');
              return;
            }

            final chunk = chunks[chunkIndex];
            final request = _promptService.injectItems(promptTemplate, chunk);

            try {
              final response = await _llmApiService.callLlm(
                providerType: providerType,
                baseUrl: baseUrl,
                modelId: model.modelId,
                messages: [ChatMessage(role: 'user', content: request)],
                apiKey: command.apiKey,
                parameters: model.parameters,
              );

              final parsed = _jsonParserService.parseResponse(
                response.content,
                debugDir:
                    '${command.projectPath}/results/${config.batchId}/debug',
              );
              if (parsed != null) {
                results.addAll(parsed);
              } else {
                _emitLog(
                  'No parseable JSON for prompt "$promptName" in chunk ${chunkIndex + 1}.',
                  level: LogLevel.warn,
                );
              }

              callCounter++;
              stats = stats.copyWith(
                completedApiCalls: callCounter,
                processedItems: min(
                  command.items.length,
                  callCounter * config.chunkSettings.chunkSize,
                ),
                totalInputTokens:
                    stats.totalInputTokens + response.inputTokens,
                totalOutputTokens:
                    stats.totalOutputTokens + response.outputTokens,
              );

              final progressPercent = totalApiCalls == 0
                  ? 100.0
                  : (callCounter / totalApiCalls) * 100.0;

              final progress = BatchProgress(
                currentRepetition: rep,
                totalRepetitions: config.chunkSettings.repetitions,
                currentPromptIndex: promptIndex + 1,
                totalPrompts: config.promptFiles.length,
                currentChunkIndex: chunkIndex + 1,
                totalChunks: chunks.length,
                callCounter: callCounter,
                progressPercent: progressPercent,
                currentModelId: model.modelId,
                currentPromptName: promptName,
              );

              _emitEvent(ProgressEvent(progress));
              _emitLog(
                'Call $callCounter/$totalApiCalls completed '
                '(rep=$rep, prompt=$promptName, chunk=${chunkIndex + 1}/${chunks.length}).',
              );

              if (callCounter % AppConstants.defaultCheckpointInterval == 0) {
                await _checkpointService.saveCheckpoint(
                  projectPath: command.projectPath,
                  batchId: config.batchId,
                  progress: progress,
                  stats: stats,
                  config: config,
                  results: results,
                );
                _emitEvent(CheckpointSavedEvent(callCounter));
              }
            } catch (e) {
              stats = stats.copyWith(failedApiCalls: stats.failedApiCalls + 1);
              _emitError(
                'LLM call failed at rep=$rep, prompt=$promptName, chunk=${chunkIndex + 1}.',
                details: e.toString(),
              );
              return;
            }
          }
        }
      }

      stats = stats.copyWith(completedAt: DateTime.now());
      _emitEvent(BatchCompletedEvent(stats: stats, results: results));
    } catch (e) {
      _emitError('Batch worker crashed unexpectedly.', details: e.toString());
    }
  }

  Future<bool> _waitIfPausedOrStopped() async {
    if (_stopRequested) {
      return false;
    }
    if (_isPaused) {
      _pauseCompleter ??= Completer<void>();
      await _pauseCompleter!.future;
    }
    return !_stopRequested;
  }

  String _defaultBaseUrl(String providerType) {
    return switch (providerType) {
      'openai' => 'https://api.openai.com/v1',
      'anthropic' => 'https://api.anthropic.com/v1',
      'google' => 'https://generativelanguage.googleapis.com/v1',
      'openrouter' => 'https://openrouter.ai/api/v1',
      'ollama' => 'http://localhost:11434',
      'lmstudio' => 'http://localhost:1234/v1',
      _ => 'http://localhost:1234/v1',
    };
  }

  void _emitEvent(WorkerEvent event) {
    eventPort.send(WorkerMessageCodec.encodeEvent(event));
  }

  void _emitLog(
    String message, {
    LogLevel level = LogLevel.info,
    String? details,
  }) {
    _emitEvent(
      LogEvent(
        LogEntry(
          level: level,
          message: message,
          details: details,
          timestamp: DateTime.now(),
        ),
      ),
    );
  }

  void _emitError(String message, {String? details}) {
    _emitLog(message, level: LogLevel.error, details: details);
    _emitEvent(BatchErrorEvent(message: message, details: details));
  }
}

void _workerMain(_WorkerBootstrapMessage bootstrap) {
  final commandPort = ReceivePort();
  bootstrap.eventPort.send(commandPort.sendPort);

  final runtime = _WorkerRuntime(bootstrap.eventPort);
  commandPort.listen((message) {
    final command = WorkerMessageCodec.decodeCommand(message);
    if (command == null) {
      runtime.handleCommand(StopBatchCommand());
      return;
    }
    runtime.handleCommand(command);
  });
}
