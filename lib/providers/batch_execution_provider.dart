import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logging/logging.dart';

import '../data/models/batch_stats.dart';
import '../data/models/log_entry.dart';
import '../services/checkpoint_service.dart';
import '../workers/batch_execution_worker.dart';
import '../workers/worker_messages.dart';

final _log = Logger('BatchExecutionNotifier');

enum BatchExecutionStatus {
  idle,
  starting,
  running,
  paused,
  completed,
  failed,
}

class BatchExecutionState {
  const BatchExecutionState({
    required this.status,
    this.progress,
    this.logs = const [],
    this.stats,
    this.results = const [],
    this.errorMessage,
  });

  final BatchExecutionStatus status;
  final BatchProgress? progress;
  final List<LogEntry> logs;
  final BatchStats? stats;
  final List<Map<String, dynamic>> results;
  final String? errorMessage;

  factory BatchExecutionState.initial() {
    return const BatchExecutionState(status: BatchExecutionStatus.idle);
  }

  BatchExecutionState copyWith({
    BatchExecutionStatus? status,
    BatchProgress? progress,
    List<LogEntry>? logs,
    BatchStats? stats,
    List<Map<String, dynamic>>? results,
    String? errorMessage,
  }) {
    return BatchExecutionState(
      status: status ?? this.status,
      progress: progress ?? this.progress,
      logs: logs ?? this.logs,
      stats: stats ?? this.stats,
      results: results ?? this.results,
      errorMessage: errorMessage,
    );
  }
}

class BatchExecutionNotifier extends StateNotifier<BatchExecutionState> {
  BatchExecutionNotifier() : super(BatchExecutionState.initial());

  BatchExecutionWorker? _worker;
  StreamSubscription<WorkerEvent>? _eventSub;
  StreamSubscription<Object>? _errorSub;
  String? _projectPath;
  final _checkpointService = CheckpointService();

  Future<void> startBatch(StartBatchCommand command) async {
    await _disposeWorker();
    _projectPath = command.projectPath;

    state = const BatchExecutionState(status: BatchExecutionStatus.starting);

    final worker = BatchExecutionWorker();
    _worker = worker;

    _eventSub = worker.events.listen(_onWorkerEvent);
    _errorSub = worker.errors.listen((error) {
      state = state.copyWith(
        status: BatchExecutionStatus.failed,
        errorMessage: error.toString(),
      );
    });

    try {
      await worker.start();
      state = state.copyWith(status: BatchExecutionStatus.running);
      worker.sendCommand(command);
    } catch (e) {
      state = state.copyWith(
        status: BatchExecutionStatus.failed,
        errorMessage: e.toString(),
      );
    }
  }

  void pause() {
    final worker = _worker;
    if (worker == null || !worker.isRunning) return;
    worker.sendCommand(PauseBatchCommand());
    state = state.copyWith(status: BatchExecutionStatus.paused);
  }

  void resume() {
    final worker = _worker;
    if (worker == null || !worker.isRunning) return;
    worker.sendCommand(ResumeBatchCommand());
    state = state.copyWith(status: BatchExecutionStatus.running);
  }

  void stop() {
    final worker = _worker;
    if (worker == null || !worker.isRunning) return;
    worker.sendCommand(StopBatchCommand());
    state = state.copyWith(
      status: BatchExecutionStatus.failed,
      errorMessage: 'Batch stopped by user.',
    );
  }

  void reset() {
    state = BatchExecutionState.initial();
  }

  void _onWorkerEvent(WorkerEvent event) {
    switch (event) {
      case ProgressEvent():
        state = state.copyWith(
          status: BatchExecutionStatus.running,
          progress: event.progress,
        );
      case LogEvent():
        state = state.copyWith(logs: [...state.logs, event.entry]);
      case CheckpointSavedEvent():
        final infoLog = LogEntry(
          level: LogLevel.info,
          message: 'Checkpoint saved at call ${event.callCount}.',
          timestamp: DateTime.now(),
        );
        state = state.copyWith(logs: [...state.logs, infoLog]);
      case BatchCompletedEvent():
        state = state.copyWith(
          status: BatchExecutionStatus.completed,
          stats: event.stats,
          results: event.results,
        );
        // F12: Auto-cleanup old checkpoints after successful batch
        final projectPath = _projectPath;
        if (projectPath != null) {
          unawaited(
            _checkpointService.cleanupOldCheckpoints(projectPath).catchError((Object e) {
              _log.warning('Checkpoint cleanup failed: $e');
              return 0;
            }),
          );
        }
      case BatchErrorEvent():
        state = state.copyWith(
          status: BatchExecutionStatus.failed,
          errorMessage: event.message,
        );
    }
  }

  Future<void> _disposeWorker() async {
    await _eventSub?.cancel();
    await _errorSub?.cancel();
    _eventSub = null;
    _errorSub = null;
    await _worker?.dispose();
    _worker = null;
  }

  @override
  void dispose() {
    unawaited(_disposeWorker());
    super.dispose();
  }
}

final batchExecutionProvider =
    StateNotifierProvider<BatchExecutionNotifier, BatchExecutionState>(
  (ref) => BatchExecutionNotifier(),
);
