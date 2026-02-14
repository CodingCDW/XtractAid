import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/batch_config.dart';
import '../../data/models/batch_stats.dart';
import '../../data/models/item.dart';
import '../../providers/batch_execution_provider.dart';
import '../../providers/database_provider.dart';
import '../../providers/encryption_provider.dart';
import '../../services/file_parser_service.dart';
import '../../services/prompt_service.dart';
import '../../services/project_file_service.dart';
import '../../services/report_generator_service.dart';
import '../../shared/widgets/log_viewer.dart';
import '../../shared/widgets/progress_bar.dart';
import '../../workers/worker_messages.dart';

class BatchExecutionScreen extends ConsumerStatefulWidget {
  const BatchExecutionScreen({
    super.key,
    required this.projectId,
    required this.batchId,
  });

  final String projectId;
  final String batchId;

  @override
  ConsumerState<BatchExecutionScreen> createState() => _BatchExecutionScreenState();
}

class _BatchExecutionScreenState extends ConsumerState<BatchExecutionScreen> {
  final _fileParserService = FileParserService();
  final _promptService = PromptService();
  final _projectFileService = ProjectFileService();
  final _reportGenerator = ReportGeneratorService();

  bool _isPreparing = false;
  String? _batchName;
  String? _infoText;
  String? _lastPersistedDbStatus;
  BatchConfig? _activeConfig;
  String? _activeProjectPath;
  Map<String, String> _activePromptContents = const {};
  bool _reportsGenerated = false;

  @override
  Widget build(BuildContext context) {
    ref.listen<BatchExecutionState>(batchExecutionProvider, (previous, next) {
      _persistExecutionStatus(next);
      _maybeGenerateReports(previous, next);
    });

    final execState = ref.watch(batchExecutionProvider);
    final statusLabel = _statusLabel(execState.status);
    final statusColor = _statusColor(execState.status, context);
    final progress = execState.progress;
    final stats = execState.stats;
    final totalCalls = progress?.totalChunks != null &&
            (progress?.totalPrompts ?? 0) > 0 &&
            (progress?.totalRepetitions ?? 0) > 0
        ? (progress!.totalChunks * progress.totalPrompts * progress.totalRepetitions)
        : (stats?.totalApiCalls ?? 0);

    return Scaffold(
      appBar: AppBar(
        title: Text(_batchName == null ? 'Batch Execution' : 'Batch: $_batchName'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 8,
                    runSpacing: 6,
                    children: [
                      const Text('Status:'),
                      Chip(
                        label: Text(statusLabel),
                        backgroundColor: statusColor,
                      ),
                      Text('Batch ID: ${widget.batchId}'),
                    ],
                  ),
                ),
                FilledButton.icon(
                  onPressed: (_isPreparing ||
                          execState.status == BatchExecutionStatus.running ||
                          execState.status == BatchExecutionStatus.starting)
                      ? null
                      : _startExecution,
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Start'),
                ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  onPressed: execState.status == BatchExecutionStatus.running
                      ? () => ref.read(batchExecutionProvider.notifier).pause()
                      : null,
                  icon: const Icon(Icons.pause),
                  label: const Text('Pause'),
                ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  onPressed: execState.status == BatchExecutionStatus.paused
                      ? () => ref.read(batchExecutionProvider.notifier).resume()
                      : null,
                  icon: const Icon(Icons.play_circle),
                  label: const Text('Resume'),
                ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  onPressed: (execState.status == BatchExecutionStatus.running ||
                          execState.status == BatchExecutionStatus.paused ||
                          execState.status == BatchExecutionStatus.starting)
                      ? () => ref.read(batchExecutionProvider.notifier).stop()
                      : null,
                  icon: const Icon(Icons.stop),
                  label: const Text('Stop'),
                ),
              ],
            ),
            const SizedBox(height: 10),
            if (_isPreparing)
              const Padding(
                padding: EdgeInsets.only(bottom: 8),
                child: LinearProgressIndicator(),
              ),
            ProgressBarWidget(
              progressPercent: progress?.progressPercent ?? 0,
              completedCalls: progress?.callCounter ?? stats?.completedApiCalls ?? 0,
              totalCalls: totalCalls,
            ),
            const SizedBox(height: 10),
            if (_infoText != null) Text(_infoText!),
            if (execState.errorMessage != null)
              Text(
                execState.errorMessage!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            const SizedBox(height: 12),
            Expanded(
              child: Row(
                children: [
                  SizedBox(
                    width: 360,
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Ausfuehrung',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 8),
                              Text('Repetition: ${progress?.currentRepetition ?? 0}/${progress?.totalRepetitions ?? 0}'),
                              Text('Prompt: ${progress?.currentPromptIndex ?? 0}/${progress?.totalPrompts ?? 0}'),
                              Text('Chunk: ${progress?.currentChunkIndex ?? 0}/${progress?.totalChunks ?? 0}'),
                              Text('Current Prompt Name: ${progress?.currentPromptName ?? '-'}'),
                              Text('Current Model: ${progress?.currentModelId ?? '-'}'),
                              const Divider(height: 20),
                              Text('Completed Calls: ${stats?.completedApiCalls ?? 0}'),
                              Text('Failed Calls: ${stats?.failedApiCalls ?? 0}'),
                              Text('Input Tokens: ${stats?.totalInputTokens ?? 0}'),
                              Text('Output Tokens: ${stats?.totalOutputTokens ?? 0}'),
                              Text('Results: ${execState.results.length}'),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: LogViewer(entries: execState.logs),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _startExecution() async {
    setState(() {
      _isPreparing = true;
      _infoText = 'Batch-Konfiguration wird geladen...';
    });

    try {
      final db = ref.read(databaseProvider);
      final batch = await db.batchesDao.getById(widget.batchId);
      if (batch == null) {
        _showError('Batch nicht gefunden.');
        return;
      }
      final project = await db.projectsDao.getById(widget.projectId);
      if (project == null) {
        _showError('Projekt nicht gefunden.');
        return;
      }

      setState(() {
        _batchName = batch.name;
        _infoText = 'Konfiguration geladen. Eingabedaten werden vorbereitet...';
      });

      final configMap = jsonDecode(batch.configJson);
      if (configMap is! Map<String, dynamic>) {
        _showError('Ungueltige Batch-Konfiguration.');
        return;
      }
      final config = BatchConfig.fromJson(configMap);
      _activeConfig = config;
      _activeProjectPath = project.path;

      final items = await _loadItems(config);
      if (items.isEmpty) {
        _showError('Keine Items fuer die Ausfuehrung gefunden.');
        return;
      }

      setState(() {
        _infoText = 'Prompts werden geladen...';
      });

      final allPrompts = await _promptService.loadPrompts(
        _projectFileService.promptsDir(project.path),
      );
      final selectedPrompts = <String, String>{};
      for (final promptName in config.promptFiles) {
        final content = allPrompts[promptName];
        if (content != null) {
          selectedPrompts[promptName] = content;
        }
      }

      if (selectedPrompts.isEmpty) {
        _showError('Keine Prompt-Dateien aus der Batch-Konfiguration gefunden.');
        return;
      }
      _activePromptContents = selectedPrompts;
      _reportsGenerated = false;

      final enabledProviders = await db.providersDao.getEnabled();
      final providerBaseUrls = <String, String>{};
      dynamic selectedProvider;
      final providerType = config.models.first.providerId;
      for (final provider in enabledProviders) {
        providerBaseUrls[provider.type] = provider.baseUrl;
        if (provider.type == providerType) {
          selectedProvider = provider;
        }
      }

      final apiKey = _resolveApiKey(selectedProvider);

      await db.batchesDao.updateStatus(widget.batchId, 'running');
      final notifier = ref.read(batchExecutionProvider.notifier);
      notifier.reset();
      await notifier.startBatch(
        StartBatchCommand(
          config: config,
          items: items,
          prompts: selectedPrompts,
          projectPath: project.path,
          apiKey: apiKey,
          providerBaseUrls: providerBaseUrls,
        ),
      );

      setState(() {
        _infoText = 'Batch gestartet.';
      });
    } catch (e) {
      _showError('Start fehlgeschlagen: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isPreparing = false;
        });
      }
    }
  }

  Future<List<Item>> _loadItems(BatchConfig config) async {
    if (config.input.type == 'excel') {
      final lower = config.input.path.toLowerCase();
      if (lower.endsWith('.csv')) {
        final result = await _fileParserService.parseCsv(
          config.input.path,
          idColumn: config.input.idColumn ?? 'ID',
          itemColumn: config.input.itemColumn ?? 'Item',
        );
        return result.items;
      }
      final result = await _fileParserService.parseExcel(
        config.input.path,
        idColumn: config.input.idColumn ?? 'ID',
        itemColumn: config.input.itemColumn ?? 'Item',
      );
      return result.items;
    }

    List<Item> items = const [];
    await for (final _ in _fileParserService.parseFolderStream(
      config.input.path,
      onComplete: (parsedItems, _) {
        items = parsedItems;
      },
    )) {
      // Progress events are currently not surfaced in this screen.
    }
    return items;
  }

  String? _resolveApiKey(dynamic provider) {
    if (provider == null) {
      return null;
    }
    final encrypted = provider.encryptedApiKey;
    if (encrypted is! Uint8List) {
      return null;
    }

    final encryption = ref.read(encryptionProvider);
    if (!encryption.isUnlocked) {
      return null;
    }

    try {
      return encryption.decryptData(encrypted);
    } catch (_) {
      return null;
    }
  }

  void _persistExecutionStatus(BatchExecutionState state) {
    final mapped = switch (state.status) {
      BatchExecutionStatus.idle => null,
      BatchExecutionStatus.starting => 'running',
      BatchExecutionStatus.running => 'running',
      BatchExecutionStatus.paused => 'paused',
      BatchExecutionStatus.completed => 'completed',
      BatchExecutionStatus.failed => 'failed',
    };

    if (mapped == null || mapped == _lastPersistedDbStatus) {
      return;
    }
    _lastPersistedDbStatus = mapped;
    unawaited(_updateBatchStatus(mapped));
  }

  Future<void> _updateBatchStatus(String status) async {
    final db = ref.read(databaseProvider);
    await db.batchesDao.updateStatus(widget.batchId, status);
  }

  String _statusLabel(BatchExecutionStatus status) {
    return switch (status) {
      BatchExecutionStatus.idle => 'IDLE',
      BatchExecutionStatus.starting => 'STARTING',
      BatchExecutionStatus.running => 'RUNNING',
      BatchExecutionStatus.paused => 'PAUSED',
      BatchExecutionStatus.completed => 'COMPLETED',
      BatchExecutionStatus.failed => 'FAILED',
    };
  }

  Color _statusColor(BatchExecutionStatus status, BuildContext context) {
    return switch (status) {
      BatchExecutionStatus.idle => Colors.grey.shade300,
      BatchExecutionStatus.starting => Colors.blue.shade200,
      BatchExecutionStatus.running => Colors.green.shade200,
      BatchExecutionStatus.paused => Colors.amber.shade200,
      BatchExecutionStatus.completed => Colors.teal.shade200,
      BatchExecutionStatus.failed => Theme.of(context).colorScheme.errorContainer,
    };
  }

  void _showError(String message) {
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  void _maybeGenerateReports(
    BatchExecutionState? previous,
    BatchExecutionState next,
  ) {
    final wasCompleted = previous?.status == BatchExecutionStatus.completed;
    final isCompleted = next.status == BatchExecutionStatus.completed;
    if (!isCompleted || wasCompleted || _reportsGenerated) {
      return;
    }

    final config = _activeConfig;
    final projectPath = _activeProjectPath;
    final stats = next.stats;
    if (config == null || projectPath == null || stats == null) {
      return;
    }

    _reportsGenerated = true;
    unawaited(_generateReports(config, projectPath, stats, next));
  }

  Future<void> _generateReports(
    BatchConfig config,
    String projectPath,
    BatchStats stats,
    BatchExecutionState state,
  ) async {
    try {
      final reports = await _reportGenerator.generateReports(
        projectPath: projectPath,
        batchId: config.batchId,
        config: config,
        stats: stats,
        results: state.results,
        logs: state.logs,
        promptContents: _activePromptContents,
      );

      if (!mounted) {
        return;
      }
      setState(() {
        _infoText =
            'Reports erstellt: ${reports.excelPath}, ${reports.markdownPath}, ${reports.htmlPath}';
      });
    } catch (e) {
      if (!mounted) {
        return;
      }
      _showError('Report-Generierung fehlgeschlagen: $e');
    }
  }
}
