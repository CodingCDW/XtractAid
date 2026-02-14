import 'dart:convert';

import 'package:drift/drift.dart' show Value;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../core/l10n/generated/app_localizations.dart';
import '../../data/database/app_database.dart';
import '../../data/models/batch_config.dart';
import '../../data/models/cost_estimate.dart';
import '../../data/models/item.dart';
import '../../data/models/model_info.dart';
import '../../providers/database_provider.dart';
import '../../providers/model_registry_provider.dart';
import '../../services/file_parser_service.dart';
import '../../services/project_file_service.dart';
import '../../services/prompt_service.dart';
import '../../services/token_estimation_service.dart';
import '../../shared/widgets/privacy_warning_dialog.dart';
import 'steps/step_chunks.dart';
import 'steps/step_confirm.dart';
import 'steps/step_items.dart';
import 'steps/step_model.dart';
import 'steps/step_prompts.dart';

class BatchWizardScreen extends ConsumerStatefulWidget {
  const BatchWizardScreen({super.key, required this.projectId});

  final String projectId;

  @override
  ConsumerState<BatchWizardScreen> createState() => _BatchWizardScreenState();
}

class _BatchWizardScreenState extends ConsumerState<BatchWizardScreen> {
  final _fileParserService = FileParserService();
  final _promptService = PromptService();
  final _projectFileService = ProjectFileService();
  final _tokenEstimationService = TokenEstimationService();

  int _step = 0;
  bool _isBusy = false;

  Project? _project;

  String _inputType = 'excel';
  String? _inputPath;
  String _idColumn = 'ID';
  String _itemColumn = 'Item';
  List<Item> _items = const [];
  List<String> _parseWarnings = const [];
  String? _parseProgressText;

  Map<String, String> _promptMap = const {};
  List<String> _selectedPrompts = const [];
  String? _previewPrompt;

  int _chunkSize = 1;
  int _repetitions = 1;

  List<ModelInfo> _models = const [];
  Map<String, bool> _providerIsLocal = const {};
  String? _selectedModelId;
  Map<String, ModelParameter> _currentParameters = const {};
  Map<String, dynamic> _parameterValues = const {};

  bool _privacyConfirmed = false;
  bool _suppressPrivacyWarning = false;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    setState(() {
      _isBusy = true;
    });

    try {
      final db = ref.read(databaseProvider);
      final project = await db.projectsDao.getById(widget.projectId);
      if (project == null) {
        if (!mounted) {
          return;
        }
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(content: Text(S.of(context)!.projectsNotFound)),
          );
        context.go('/projects');
        return;
      }

      final prompts = await _promptService.loadPrompts(
        _projectFileService.promptsDir(project.path),
      );

      final registry = ref.read(modelRegistryProvider);
      await registry.getMergedRegistry();
      final models =
          registry
              .getModelIds()
              .map(registry.getModelInfo)
              .whereType<ModelInfo>()
              .toList()
            ..sort((a, b) {
              final providerCmp = a.provider.compareTo(b.provider);
              if (providerCmp != 0) {
                return providerCmp;
              }
              return a.displayName.compareTo(b.displayName);
            });

      final providers = registry.getProviders();
      final providerIsLocal = {
        for (final entry in providers.entries) entry.key: entry.value.isLocal,
      };

      String? selectedModelId;
      Map<String, ModelParameter> params = const {};
      Map<String, dynamic> defaults = const {};
      if (models.isNotEmpty) {
        selectedModelId = models.first.id;
        params = registry.getModelParameters(selectedModelId);
        defaults = _defaultParameterValues(params);
      }

      if (!mounted) {
        return;
      }

      setState(() {
        _project = project;
        _promptMap = prompts;
        _previewPrompt = prompts.isNotEmpty ? prompts.keys.first : null;
        _models = models;
        _providerIsLocal = providerIsLocal;
        _selectedModelId = selectedModelId;
        _currentParameters = params;
        _parameterValues = defaults;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(S.of(context)!.batchWizardNotLoaded),
          ),
        );
    } finally {
      if (mounted) {
        setState(() {
          _isBusy = false;
        });
      }
    }
  }

  Map<String, dynamic> _defaultParameterValues(
    Map<String, ModelParameter> params,
  ) {
    final result = <String, dynamic>{};
    for (final entry in params.entries) {
      final p = entry.value;
      if (!p.supported) {
        continue;
      }
      if (p.defaultValue != null) {
        result[entry.key] = p.defaultValue;
      } else if (p.type == 'integer') {
        result[entry.key] = (p.min ?? 1).round();
      } else if (p.type == 'enum') {
        final values = p.values;
        if (values != null && values.isNotEmpty) {
          result[entry.key] = values.first;
        }
      } else {
        result[entry.key] = p.min ?? 0.0;
      }
    }
    return result;
  }

  ModelInfo? get _selectedModel {
    final id = _selectedModelId;
    if (id == null) {
      return null;
    }
    for (final model in _models) {
      if (model.id == id) {
        return model;
      }
    }
    return null;
  }

  bool get _requiresPrivacyConfirmation {
    final model = _selectedModel;
    if (model == null) {
      return false;
    }
    return !(_providerIsLocal[model.provider] ?? false);
  }

  int get _totalChunks =>
      _items.isEmpty ? 0 : (_items.length / _chunkSize).ceil();

  int get _totalCalls => _totalChunks * _selectedPrompts.length * _repetitions;

  CostEstimate get _estimatedCost {
    final model = _selectedModel;
    if (model == null || _selectedPrompts.isEmpty || _items.isEmpty) {
      return const CostEstimate();
    }
    final promptTexts = _selectedPrompts
        .map((name) => _promptMap[name] ?? '')
        .where((text) => text.isNotEmpty)
        .toList();
    if (promptTexts.isEmpty) {
      return const CostEstimate();
    }

    final maxTokensDynamic = _parameterValues['max_tokens'];
    final maxTokens = maxTokensDynamic is num
        ? maxTokensDynamic.toInt()
        : model.maxOutputTokens;

    return _tokenEstimationService.estimateBatchCost(
      promptTexts: promptTexts,
      totalItems: _items.length,
      chunkSize: _chunkSize,
      repetitions: _repetitions,
      maxOutputTokens: maxTokens,
      pricing: model.pricing,
      modelId: model.id,
      itemSamples: _items
          .take(50)
          .map((item) => item.text)
          .toList(growable: false),
    );
  }

  Future<void> _pickInputFile() async {
    final picked = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['xlsx', 'xls', 'csv'],
    );
    if (picked == null || picked.files.isEmpty) {
      return;
    }

    setState(() {
      _inputPath = picked.files.single.path;
      _items = const [];
      _parseWarnings = const [];
      _parseProgressText = null;
    });
  }

  Future<void> _pickInputFolder() async {
    final path = await FilePicker.platform.getDirectoryPath();
    if (path == null || path.isEmpty) {
      return;
    }

    setState(() {
      _inputPath = path;
      _items = const [];
      _parseWarnings = const [];
      _parseProgressText = null;
    });
  }

  Future<void> _parseItems() async {
    final inputPath = _inputPath;
    if (inputPath == null || inputPath.isEmpty) {
      _showError(S.of(context)!.batchWizardSelectSource);
      return;
    }

    setState(() {
      _isBusy = true;
      _parseProgressText = null;
    });

    try {
      if (_inputType == 'excel') {
        final lower = inputPath.toLowerCase();
        ParseResult result;
        if (lower.endsWith('.csv')) {
          result = await _fileParserService.parseCsv(
            inputPath,
            idColumn: _idColumn,
            itemColumn: _itemColumn,
          );
        } else {
          result = await _fileParserService.parseExcel(
            inputPath,
            idColumn: _idColumn,
            itemColumn: _itemColumn,
          );
        }
        setState(() {
          _items = result.items;
          _parseWarnings = result.warnings;
        });
      } else {
        List<Item> parsedItems = const [];
        List<String> warnings = const [];

        await for (final event in _fileParserService.parseFolderStream(
          inputPath,
          onComplete: (items, folderWarnings) {
            parsedItems = items;
            warnings = folderWarnings;
          },
        )) {
          setState(() {
            _parseProgressText =
                '${event.filesProcessed}/${event.totalFiles}: ${event.currentFile.isEmpty ? 'Fertig' : event.currentFile}';
          });
        }

        setState(() {
          _items = parsedItems;
          _parseWarnings = warnings;
        });
      }
    } catch (_) {
      _showError(S.of(context)!.batchWizardLoadItems);
    } finally {
      if (mounted) {
        setState(() {
          _isBusy = false;
        });
      }
    }
  }

  Future<void> _continue() async {
    final valid = _validateStep(_step);
    if (!valid) {
      return;
    }

    if (_step < 4) {
      setState(() {
        _step += 1;
      });
      return;
    }

    await _startBatch();
  }

  Future<void> _handlePrivacyChanged(bool value) async {
    if (!value) {
      setState(() {
        _privacyConfirmed = false;
      });
      return;
    }

    if (!_requiresPrivacyConfirmation || _suppressPrivacyWarning) {
      setState(() {
        _privacyConfirmed = true;
      });
      return;
    }

    final model = _selectedModel;
    final provider = model?.provider.toUpperCase() ?? 'CLOUD';
    final result = await showDialog<PrivacyWarningResult>(
      context: context,
      builder: (context) =>
          PrivacyWarningDialog(provider: provider, region: 'Unbekannt'),
    );

    if (!mounted) {
      return;
    }

    final accepted = result?.accepted ?? false;
    setState(() {
      _privacyConfirmed = accepted;
      if ((result?.doNotShowAgain ?? false) && accepted) {
        _suppressPrivacyWarning = true;
      }
    });
  }

  bool _validateStep(int step) {
    if (step == 0) {
      if (_items.isEmpty) {
        _showError(S.of(context)!.batchWizardLoadItems);
        return false;
      }
    }

    if (step == 1) {
      if (_selectedPrompts.isEmpty) {
        _showError(S.of(context)!.batchWizardSelectPrompt);
        return false;
      }
    }

    if (step == 3) {
      if (_selectedModel == null) {
        _showError(S.of(context)!.batchWizardSelectModel);
        return false;
      }
    }

    if (step == 4 && _requiresPrivacyConfirmation && !_privacyConfirmed) {
      _showError(S.of(context)!.batchWizardConfirmPrivacy);
      return false;
    }

    return true;
  }

  Future<void> _startBatch() async {
    final project = _project;
    final model = _selectedModel;
    final inputPath = _inputPath;

    if (project == null || model == null || inputPath == null) {
      _showError(S.of(context)!.batchWizardStartError);
      return;
    }

    setState(() {
      _isBusy = true;
    });

    try {
      final db = ref.read(databaseProvider);
      final batchId = const Uuid().v4();
      final now = DateTime.now();
      final name =
          'Batch ${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')} ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

      final config = BatchConfig(
        batchId: batchId,
        projectId: project.id,
        name: name,
        input: BatchInput(
          type: _inputType,
          path: inputPath,
          idColumn: _inputType == 'excel' ? _idColumn : null,
          itemColumn: _inputType == 'excel' ? _itemColumn : null,
          itemCount: _items.length,
        ),
        promptFiles: _selectedPrompts,
        chunkSettings: ChunkSettings(
          chunkSize: _chunkSize,
          repetitions: _repetitions,
          shuffleBetweenReps: true,
        ),
        models: [
          BatchModelConfig(
            modelId: model.id,
            providerId: model.provider,
            parameters: _parameterValues,
          ),
        ],
        privacyConfirmed: _requiresPrivacyConfirmation
            ? _privacyConfirmed
            : true,
      );

      await db.batchesDao.insertBatch(
        BatchesCompanion(
          id: Value(batchId),
          projectId: Value(project.id),
          name: Value(name),
          configJson: Value(jsonEncode(config.toJson())),
          status: const Value('created'),
          updatedAt: Value(DateTime.now()),
        ),
      );

      if (!mounted) {
        return;
      }

      context.go('/projects/${project.id}/batch/$batchId');
    } catch (_) {
      _showError(S.of(context)!.batchWizardSaveError);
    } finally {
      if (mounted) {
        setState(() {
          _isBusy = false;
        });
      }
    }
  }

  void _showError(String message) {
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final t = S.of(context)!;
    final project = _project;

    if (_isBusy && project == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (project == null) {
      return Scaffold(
        body: Center(child: Text(t.batchWizardProjectNotLoaded)),
      );
    }

    final availablePrompts = _promptMap.keys
        .where((name) => !_selectedPrompts.contains(name))
        .toList();
    final previewPromptName = _previewPrompt;
    final previewPromptContent = previewPromptName == null
        ? ''
        : (_promptMap[previewPromptName] ?? '');
    final promptWarnings = previewPromptContent.isEmpty
        ? null
        : _promptService
              .validatePrompt(previewPromptContent)
              .where((w) => w.contains('placeholder'))
              .join(' ');

    return Scaffold(
      appBar: AppBar(title: Text('Batch Wizard - ${project.name}')),
      body: Stepper(
        currentStep: _step,
        onStepContinue: _isBusy ? null : _continue,
        onStepCancel: _step == 0
            ? null
            : () {
                setState(() {
                  _step -= 1;
                });
              },
        controlsBuilder: (context, details) {
          final isLast = _step == 4;
          return Row(
            children: [
              FilledButton(
                onPressed: _isBusy ? null : details.onStepContinue,
                child: Text(isLast ? t.batchWizardStartBatch : t.actionNext),
              ),
              if (_step > 0) ...[
                const SizedBox(width: 8),
                TextButton(
                  onPressed: _isBusy ? null : details.onStepCancel,
                  child: Text(t.actionBack),
                ),
              ],
            ],
          );
        },
        steps: [
          Step(
            title: Text(t.batchWizardItemsTitle),
            isActive: _step >= 0,
            content: StepItems(
              inputType: _inputType,
              inputPath: _inputPath,
              idColumn: _idColumn,
              itemColumn: _itemColumn,
              onInputTypeChanged: (value) {
                setState(() {
                  _inputType = value;
                  _inputPath = null;
                  _items = const [];
                  _parseWarnings = const [];
                  _parseProgressText = null;
                });
              },
              onPickFile: _pickInputFile,
              onPickFolder: _pickInputFolder,
              onParse: _parseItems,
              onIdColumnChanged: (value) {
                setState(() {
                  _idColumn = value.trim().isEmpty ? 'ID' : value.trim();
                });
              },
              onItemColumnChanged: (value) {
                setState(() {
                  _itemColumn = value.trim().isEmpty ? 'Item' : value.trim();
                });
              },
              isParsing: _isBusy,
              parsedItems: _items,
              warnings: _parseWarnings,
              progressText: _parseProgressText,
            ),
          ),
          Step(
            title: Text(t.batchWizardPromptsTitle),
            isActive: _step >= 1,
            content: StepPrompts(
              availablePrompts: availablePrompts,
              selectedPrompts: _selectedPrompts,
              onAddPrompt: (prompt) {
                setState(() {
                  _selectedPrompts = [..._selectedPrompts, prompt];
                  _previewPrompt = prompt;
                });
              },
              onRemovePrompt: (prompt) {
                setState(() {
                  _selectedPrompts = _selectedPrompts
                      .where((p) => p != prompt)
                      .toList();
                  if (_previewPrompt == prompt) {
                    _previewPrompt = _selectedPrompts.isEmpty
                        ? null
                        : _selectedPrompts.first;
                  }
                });
              },
              onReorderSelected: (oldIndex, newIndex) {
                setState(() {
                  final updated = [..._selectedPrompts];
                  if (newIndex > oldIndex) {
                    newIndex -= 1;
                  }
                  final item = updated.removeAt(oldIndex);
                  updated.insert(newIndex, item);
                  _selectedPrompts = updated;
                });
              },
              previewPromptName: _previewPrompt,
              previewPromptContent: previewPromptContent,
              onPreviewChanged: (value) {
                setState(() {
                  _previewPrompt = value;
                });
              },
              warningText: promptWarnings == null || promptWarnings.isEmpty
                  ? null
                  : promptWarnings,
            ),
          ),
          Step(
            title: Text(t.batchWizardChunksTitle),
            isActive: _step >= 2,
            content: StepChunks(
              chunkSize: _chunkSize,
              repetitions: _repetitions,
              itemCount: _items.length,
              promptCount: _selectedPrompts.length,
              onChunkSizeChanged: (value) {
                setState(() {
                  _chunkSize = value.round();
                });
              },
              onRepetitionsChanged: (value) {
                setState(() {
                  _repetitions = value.round();
                });
              },
            ),
          ),
          Step(
            title: Text(t.batchWizardModelTitle),
            isActive: _step >= 3,
            content: StepModel(
              models: _models,
              selectedModelId: _selectedModelId,
              selectedModelInfo: _selectedModel,
              parameters: _currentParameters,
              parameterValues: _parameterValues,
              onModelChanged: (modelId) {
                if (modelId == null) {
                  return;
                }
                final registry = ref.read(modelRegistryProvider);
                final params = registry.getModelParameters(modelId);
                setState(() {
                  _selectedModelId = modelId;
                  _currentParameters = params;
                  _parameterValues = _defaultParameterValues(params);
                  _privacyConfirmed = false;
                });
              },
              onParameterChanged: (key, value) {
                setState(() {
                  _parameterValues = {..._parameterValues, key: value};
                });
              },
            ),
          ),
          Step(
            title: Text(t.batchWizardConfirmTitle),
            isActive: _step >= 4,
            content: StepConfirm(
              itemCount: _items.length,
              inputPath: _inputPath,
              selectedPrompts: _selectedPrompts,
              chunkSize: _chunkSize,
              repetitions: _repetitions,
              totalCalls: _totalCalls,
              modelLabel: _selectedModel == null
                  ? '-'
                  : '${_selectedModel!.provider.toUpperCase()} / ${_selectedModel!.displayName}',
              costEstimate: _estimatedCost,
              requirePrivacyConfirmation: _requiresPrivacyConfirmation,
              privacyConfirmed: _privacyConfirmed,
              onPrivacyChanged: (value) {
                _handlePrivacyChanged(value ?? false);
              },
            ),
          ),
        ],
      ),
    );
  }
}
