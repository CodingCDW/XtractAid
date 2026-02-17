import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/generated/app_localizations.dart';
import '../../core/utils/batch_helpers.dart';
import '../../data/models/batch_config.dart';
import '../../data/models/batch_stats.dart';
import '../../data/models/item.dart';
import '../../providers/batch_execution_provider.dart';
import '../../providers/database_provider.dart';
import '../../providers/encryption_provider.dart';
import '../../providers/model_registry_provider.dart';
import '../../services/file_parser_service.dart';
import '../../services/project_model_access_service.dart';
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
  ConsumerState<BatchExecutionScreen> createState() =>
      _BatchExecutionScreenState();
}

class _BatchExecutionScreenState extends ConsumerState<BatchExecutionScreen> {
  final _fileParserService = FileParserService();
  final _promptService = PromptService();
  final _projectFileService = ProjectFileService();
  final _projectModelAccessService = ProjectModelAccessService();
  final _reportGenerator = ReportGeneratorService();

  bool _isPreparing = false;
  String? _batchName;
  String? _infoText;
  String? _lastPersistedDbStatus;
  BatchConfig? _activeConfig;
  String? _activeProjectPath;
  Map<String, String> _activePromptContents = const {};
  double _activeInputPrice = 0.0;
  double _activeOutputPrice = 0.0;
  bool _reportsGenerated = false;

  @override
  Widget build(BuildContext context) {
    final t = S.of(context)!;

    ref.listen<BatchExecutionState>(batchExecutionProvider, (previous, next) {
      _persistExecutionStatus(next);
      _maybeGenerateReports(previous, next);
    });

    final execState = ref.watch(batchExecutionProvider);
    final statusLabel = batchExecutionStatusLabel(execState.status, t);
    final statusColor = _statusColor(execState.status, context);
    final progress = execState.progress;
    final stats = execState.stats;
    final totalCalls =
        progress?.totalChunks != null &&
            (progress?.totalPrompts ?? 0) > 0 &&
            (progress?.totalRepetitions ?? 0) > 0
        ? (progress!.totalChunks *
              progress.totalPrompts *
              progress.totalRepetitions)
        : (stats?.totalApiCalls ?? 0);

    final canStart =
        !_isPreparing &&
        execState.status != BatchExecutionStatus.running &&
        execState.status != BatchExecutionStatus.starting;

    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.f5): () {
          if (canStart) _startExecution();
        },
      },
      child: Focus(
        autofocus: true,
        child: Scaffold(
          appBar: AppBar(
            title: Text(
              _batchName == null
                  ? t.execBatchTitle
                  : t.execBatchNameTitle(_batchName!),
            ),
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
                          Text(t.labelStatus),
                          Chip(
                            label: Text(statusLabel),
                            backgroundColor: statusColor,
                          ),
                          Text('${t.execBatchId} ${widget.batchId}'),
                        ],
                      ),
                    ),
                    FilledButton.icon(
                      onPressed: canStart ? _startExecution : null,
                      icon: const Icon(Icons.play_arrow),
                      label: Text(t.actionStart),
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton.icon(
                      onPressed:
                          execState.status == BatchExecutionStatus.running
                          ? () => ref
                                .read(batchExecutionProvider.notifier)
                                .pause()
                          : null,
                      icon: const Icon(Icons.pause),
                      label: Text(t.actionPause),
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton.icon(
                      onPressed: execState.status == BatchExecutionStatus.paused
                          ? () => ref
                                .read(batchExecutionProvider.notifier)
                                .resume()
                          : null,
                      icon: const Icon(Icons.play_circle),
                      label: Text(t.actionResume),
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton.icon(
                      onPressed:
                          (execState.status == BatchExecutionStatus.running ||
                              execState.status == BatchExecutionStatus.paused ||
                              execState.status == BatchExecutionStatus.starting)
                          ? () =>
                                ref.read(batchExecutionProvider.notifier).stop()
                          : null,
                      icon: const Icon(Icons.stop),
                      label: Text(t.actionStop),
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
                  completedCalls:
                      progress?.callCounter ?? stats?.completedApiCalls ?? 0,
                  totalCalls: totalCalls,
                ),
                const SizedBox(height: 10),
                if (_infoText != null) Text(_infoText!),
                if (execState.errorMessage != null)
                  Text(
                    execState.errorMessage!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
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
                                    t.execTitle,
                                    style: Theme.of(
                                      context,
                                    ).textTheme.titleMedium,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    '${t.execRepetition} ${progress?.currentRepetition ?? 0}/${progress?.totalRepetitions ?? 0}',
                                  ),
                                  Text(
                                    '${t.execPrompt} ${progress?.currentPromptIndex ?? 0}/${progress?.totalPrompts ?? 0}',
                                  ),
                                  Text(
                                    '${t.execChunk} ${progress?.currentChunkIndex ?? 0}/${progress?.totalChunks ?? 0}',
                                  ),
                                  Text(
                                    '${t.execCurrentPromptName} ${progress?.currentPromptName ?? '-'}',
                                  ),
                                  Text(
                                    '${t.execCurrentModel} ${progress?.currentModelId ?? '-'}',
                                  ),
                                  const Divider(height: 20),
                                  Text(
                                    '${t.execCompletedCalls} ${stats?.completedApiCalls ?? 0}',
                                  ),
                                  Text(
                                    '${t.execFailedCalls} ${stats?.failedApiCalls ?? 0}',
                                  ),
                                  Text(
                                    '${t.execInputTokens} ${stats?.totalInputTokens ?? 0}',
                                  ),
                                  Text(
                                    '${t.execOutputTokens} ${stats?.totalOutputTokens ?? 0}',
                                  ),
                                  Text(
                                    '${t.execResults} ${execState.results.length}',
                                  ),
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
        ),
      ),
    );
  }

  Future<void> _startExecution() async {
    final t = S.of(context)!;
    setState(() {
      _isPreparing = true;
      _infoText = t.execLoadingConfig;
    });

    try {
      final db = ref.read(databaseProvider);
      final batch = await db.batchesDao.getById(widget.batchId);
      if (batch == null) {
        _showError(t.execBatchNotFound);
        return;
      }
      final project = await db.projectsDao.getById(widget.projectId);
      if (project == null) {
        _showError(t.execProjectNotFound);
        return;
      }

      setState(() {
        _batchName = batch.name;
        _infoText = t.execPreparingInput;
      });

      final configMap = jsonDecode(batch.configJson);
      if (configMap is! Map<String, dynamic>) {
        _showError(t.execInvalidConfig);
        return;
      }
      final config = BatchConfig.fromJson(configMap);
      _activeConfig = config;
      _activeProjectPath = project.path;
      final providerType = config.models.first.providerId;
      final projectMode = await _projectModelAccessService
          .getEffectiveProjectMode(db, widget.projectId);
      final providerAllowed = _projectModelAccessService.isProviderAllowed(
        providerType,
        projectMode,
      );
      if (!providerAllowed) {
        _showError(t.settingsStrictLocalModeDesc);
        return;
      }

      final items = await _loadItems(config);
      if (items.isEmpty) {
        _showError(t.execNoItems);
        return;
      }

      setState(() {
        _infoText = t.execLoadingPrompts;
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
        _showError(t.execNoPrompts);
        return;
      }
      _activePromptContents = selectedPrompts;
      _reportsGenerated = false;

      final enabledProviders = await db.providersDao.getEnabled();
      final providerBaseUrls = <String, String>{};
      dynamic selectedProvider;
      for (final provider in enabledProviders) {
        providerBaseUrls[provider.type] = provider.baseUrl;
        if (provider.type == providerType) {
          selectedProvider = provider;
        }
      }

      final apiKey = _resolveApiKey(selectedProvider);

      // Look up model pricing from registry
      final modelId = config.models.first.modelId;
      final registry = ref.read(modelRegistryProvider);
      final pricing = registry.getModelPricing(modelId);
      final inputPrice = pricing.inputPerMillion;
      final outputPrice = pricing.outputPerMillion;
      _activeInputPrice = inputPrice;
      _activeOutputPrice = outputPrice;

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
          inputPricePerMillion: inputPrice,
          outputPricePerMillion: outputPrice,
          allowRemoteProviders:
              projectMode == ProjectModelAccessMode.allowRemote,
        ),
      );

      setState(() {
        _infoText = t.execBatchStarted;
      });
    } catch (e) {
      _showError(t.execStartFailed('$e'));
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

  Color _statusColor(BatchExecutionStatus status, BuildContext context) {
    return switch (status) {
      BatchExecutionStatus.idle => Colors.grey.shade300,
      BatchExecutionStatus.starting => Colors.blue.shade200,
      BatchExecutionStatus.running => Colors.green.shade200,
      BatchExecutionStatus.paused => Colors.amber.shade200,
      BatchExecutionStatus.completed => Colors.teal.shade200,
      BatchExecutionStatus.failed => Theme.of(
        context,
      ).colorScheme.errorContainer,
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
        inputPricePerMillion: _activeInputPrice,
        outputPricePerMillion: _activeOutputPrice,
      );

      if (!mounted) {
        return;
      }
      final t = S.of(context)!;
      setState(() {
        _infoText = t.execReportsCreated(
          '${reports.excelPath}, ${reports.markdownPath}, ${reports.htmlPath}',
        );
      });
    } catch (e) {
      if (!mounted) {
        return;
      }
      final t = S.of(context)!;
      _showError(t.execReportsFailed('$e'));
    }
  }
}
