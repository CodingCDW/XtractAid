import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:drift/drift.dart' show Value;

import '../../core/l10n/generated/app_localizations.dart';
import '../../core/utils/batch_helpers.dart';
import '../../data/database/app_database.dart';
import '../../data/models/model_info.dart';
import '../../providers/database_provider.dart';
import '../../providers/encryption_provider.dart';
import '../../providers/model_registry_provider.dart';

class ModelManagerScreen extends ConsumerStatefulWidget {
  const ModelManagerScreen({super.key});

  @override
  ConsumerState<ModelManagerScreen> createState() => _ModelManagerScreenState();
}

class _ModelManagerScreenState extends ConsumerState<ModelManagerScreen> {
  final Dio _dio = Dio();
  bool _isDiscovering = false;
  bool _showInactiveRegistryModels = false;
  Map<String, List<DiscoveredModel>> _discovered = const {};
  String? _discoverError;

  @override
  Widget build(BuildContext context) {
    final t = S.of(context)!;
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(t.modelsTitle),
          bottom: TabBar(
            tabs: [
              Tab(text: t.modelsRegistry),
              Tab(text: t.modelsCustom),
              Tab(text: t.modelsDiscovered),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildRegistryTab(),
            _buildCustomTab(),
            _buildDiscoveryTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildRegistryTab() {
    final t = S.of(context)!;
    final registryAsync = ref.watch(mergedRegistryProvider);
    final registryService = ref.watch(modelRegistryProvider);

    return registryAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(child: Text(t.modelsRegistryError('$error'))),
      data: (_) {
        final grouped = <String, List<String>>{};
        final groupedRaw = registryService.getModelsByProvider();
        for (final entry in groupedRaw.entries) {
          final filteredIds = entry.value
              .where((modelId) {
                final info = registryService.getModelInfo(modelId);
                if (info == null) {
                  return false;
                }
                if (info.status == 'deleted') {
                  return false;
                }
                if (_showInactiveRegistryModels) {
                  return true;
                }
                return info.status == 'active';
              })
              .toList(growable: false);
          if (filteredIds.isNotEmpty) {
            grouped[entry.key] = filteredIds;
          }
        }
        final providerKeys = grouped.keys.toList()..sort();

        if (providerKeys.isEmpty) {
          return Center(child: Text(t.modelsNoRegistry));
        }

        return Column(
          children: [
            SwitchListTile(
              title: Text(t.modelsShowInactive),
              value: _showInactiveRegistryModels,
              onChanged: (value) {
                setState(() {
                  _showInactiveRegistryModels = value;
                });
              },
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: providerKeys.length,
                itemBuilder: (context, index) {
                  final provider = providerKeys[index];
                  final modelIds = grouped[provider] ?? const [];
                  modelIds.sort();

                  return Card(
                    child: ExpansionTile(
                      title: Text(provider.toUpperCase()),
                      subtitle: Text(t.modelsCountLabel(modelIds.length)),
                      children: modelIds.map((modelId) {
                        final info = registryService.getModelInfo(modelId);
                        if (info == null) {
                          return ListTile(title: Text(modelId));
                        }
                        return ListTile(
                          title: Text(info.displayName),
                          subtitle: Text(
                            t.modelsRegistryTileSubtitle(
                              info.id,
                              info.contextWindow,
                              info.pricing.inputPerMillion,
                              info.pricing.outputPerMillion,
                            ),
                          ),
                          trailing: Wrap(
                            spacing: 4,
                            children: _capabilityChips(info),
                          ),
                          onTap: () => _showModelDetailDialog(info),
                        );
                      }).toList(),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCustomTab() {
    final t = S.of(context)!;
    final db = ref.watch(databaseProvider);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
          child: Row(
            children: [
              FilledButton.icon(
                onPressed: _showCreateCustomModelDialog,
                icon: const Icon(Icons.add),
                label: Text(t.actionCreate),
              ),
            ],
          ),
        ),
        Expanded(
          child: StreamBuilder(
            stream: db.modelsDao.watchAllUserOverrides(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final rows = snapshot.data ?? const [];
              if (rows.isEmpty) {
                return Center(child: Text(t.modelsNoCustom));
              }

              return ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: rows.length,
                itemBuilder: (context, index) {
                  final row = rows[index];
                  return Card(
                    child: ListTile(
                      title: Text(row.modelId),
                      subtitle: Text(row.overrideJson),
                      isThreeLine: true,
                      trailing: Wrap(
                        spacing: 8,
                        children: [
                          IconButton(
                            tooltip: t.actionChange,
                            onPressed: () =>
                                _editModelOverrideStructured(row.modelId),
                            icon: const Icon(Icons.edit),
                          ),
                          IconButton(
                            tooltip: t.actionDelete,
                            onPressed: () => _deleteOverride(row.modelId),
                            icon: const Icon(Icons.delete_outline),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDiscoveryTab() {
    final t = S.of(context)!;
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              FilledButton.icon(
                onPressed: _isDiscovering ? null : _discoverModels,
                icon: _isDiscovering
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.search),
                label: Text(t.modelsQueryProviders),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (_discoverError != null)
            Text(
              _discoverError!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          const SizedBox(height: 8),
          Expanded(
            child: _discovered.isEmpty
                ? Center(child: Text(t.modelsNoDiscovery))
                : ListView(
                    children: _discovered.entries.map((entry) {
                      final provider = entry.key;
                      final models = entry.value;
                      return Card(
                        child: ExpansionTile(
                          title: Text(provider.toUpperCase()),
                          subtitle: Text(t.modelsCountLabel(models.length)),
                          children: models
                              .map(
                                (m) => ListTile(
                                  title: Text(m.id),
                                  trailing: IconButton(
                                    tooltip: t.actionCreate,
                                    icon: const Icon(Icons.add),
                                    onPressed: m.canAdd
                                        ? () => _addDiscoveredModelToCustom(m)
                                        : null,
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      );
                    }).toList(),
                  ),
          ),
        ],
      ),
    );
  }

  List<Widget> _capabilityChips(ModelInfo info) {
    final t = S.of(context)!;
    final chips = <Widget>[];
    if (info.capabilities.chat) {
      chips.add(Chip(label: Text(t.modelsCapabilityChat)));
    }
    if (info.capabilities.vision) {
      chips.add(Chip(label: Text(t.modelsCapabilityVision)));
    }
    if (info.capabilities.functionCalling) {
      chips.add(Chip(label: Text(t.modelsCapabilityFn)));
    }
    if (info.capabilities.jsonMode) {
      chips.add(Chip(label: Text(t.modelsCapabilityJson)));
    }
    if (info.capabilities.reasoning) {
      chips.add(Chip(label: Text(t.modelsCapabilityReason)));
    }
    return chips;
  }

  Future<void> _showModelDetailDialog(ModelInfo info) async {
    final t = S.of(context)!;
    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(info.displayName),
          content: SizedBox(
            width: 700,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${t.modelsIdLabel} ${info.id}'),
                  Text('${t.modelsProviderLabel} ${info.provider}'),
                  Text('${t.modelsStatusLabel} ${info.status}'),
                  const SizedBox(height: 8),
                  Text('${t.modelsDescriptionLabel} ${info.description}'),
                  const SizedBox(height: 8),
                  Text('${t.modelsContextWindow} ${info.contextWindow}'),
                  Text('${t.modelsMaxOutputTokens} ${info.maxOutputTokens}'),
                  Text(
                    t.modelsPricingLabel(
                      info.pricing.inputPerMillion,
                      info.pricing.outputPerMillion,
                    ),
                  ),
                  const Divider(height: 20),
                  Text(t.modelsCapabilities),
                  Text(
                    t.modelsCapabilitySummary(
                      '${info.capabilities.chat}',
                      '${info.capabilities.vision}',
                      '${info.capabilities.functionCalling}',
                      '${info.capabilities.jsonMode}',
                      '${info.capabilities.streaming}',
                      '${info.capabilities.reasoning}',
                      '${info.capabilities.extendedThinking}',
                    ),
                  ),
                  const Divider(height: 20),
                  Text(t.modelsParameters),
                  ...info.parameters.entries.map(
                    (entry) => Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Text(
                        t.modelsParameterDetails(
                          entry.key,
                          '${entry.value.supported}',
                          '${entry.value.type}',
                          '${entry.value.min}',
                          '${entry.value.max}',
                          '${entry.value.defaultValue}',
                          '${entry.value.values}',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _confirmDeleteRegistryModel(info.id);
              },
              child: Text(
                t.actionDelete,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _editRegistryModelOverride(info.id);
              },
              child: Text(t.actionChange),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(t.actionClose),
            ),
          ],
        );
      },
    );
  }

  Future<void> _confirmDeleteRegistryModel(String modelId) async {
    final t = S.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(t.actionDelete),
          content: Text(
            t.modelsHideRegistryModelConfirm(modelId),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(t.actionCancel),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(dialogContext).colorScheme.error,
              ),
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text(t.actionDelete),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }
    await _softDeleteRegistryModel(modelId);
  }

  Future<void> _softDeleteRegistryModel(String modelId) async {
    final t = S.of(context)!;
    final db = ref.read(databaseProvider);
    final override = <String, dynamic>{
      'status': 'deleted',
      'notes': 'Hidden from registry models by user.',
    };

    await db.modelsDao.upsertOverride(
      ModelsCompanion(
        modelId: Value(modelId),
        overrideJson: Value(jsonEncode(override)),
        isUserAdded: const Value(true),
        updatedAt: Value(DateTime.now()),
      ),
    );

    if (mounted) {
      final registry = ref.read(modelRegistryProvider);
      registry.clearCache();
      ref.invalidate(mergedRegistryProvider);
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text(t.modelsHideRegistryModelDone(modelId))),
        );
    }
  }

  Future<void> _editRegistryModelOverride(String modelId) async {
    await _editModelOverrideStructured(modelId);
  }

  Future<void> _editModelOverrideStructured(
    String modelId, {
    Map<String, dynamic>? seedOverride,
  }) async {
    final db = ref.read(databaseProvider);
    final existing = await db.modelsDao.getByModelId(modelId);
    if (existing != null) {
      try {
        final parsed = jsonDecode(existing.overrideJson);
        if (parsed is Map<String, dynamic>) {
          await _showStructuredOverrideDialog(
            modelId: modelId,
            initialOverride: parsed,
          );
          return;
        }
      } catch (_) {
        // Fall back to raw JSON editor if existing override is malformed.
      }
      await _showEditOverrideDialog(modelId, existing.overrideJson);
      return;
    }

    final raw = seedOverride ?? await _loadRegistryModelRaw(modelId);
    if (raw == null) {
      if (!mounted) {
        return;
      }
      final t = S.of(context)!;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text(t.modelsModelNotFound)),
        );
      return;
    }

    await _showStructuredOverrideDialog(modelId: modelId, initialOverride: raw);
  }

  Future<Map<String, dynamic>?> _loadRegistryModelRaw(String modelId) async {
    final registry = ref.read(modelRegistryProvider);
    await registry.getMergedRegistry();
    final raw = registry.getModelInfoRaw(modelId);
    if (raw == null) {
      return null;
    }
    return jsonDecode(jsonEncode(raw)) as Map<String, dynamic>;
  }

  Future<void> _showStructuredOverrideDialog({
    required String modelId,
    required Map<String, dynamic> initialOverride,
  }) async {
    final t = S.of(context)!;
    final editable =
        jsonDecode(jsonEncode(initialOverride)) as Map<String, dynamic>;
    final contextController = TextEditingController(
      text: '${editable['context_window'] ?? ''}',
    );
    final maxOutputController = TextEditingController(
      text: '${editable['max_output_tokens'] ?? ''}',
    );
    final parameterDefaultControllers = <String, TextEditingController>{};
    String? errorText;

    final saved = await showDialog<bool>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            final media = MediaQuery.of(context);
            final dialogWidth = media.size.width > 1120
                ? 920.0
                : media.size.width * 0.92;
            final dialogHeight = (media.size.height * 0.8).clamp(560.0, 900.0);
            final paramsRaw = editable['parameters'];
            final params = paramsRaw is Map<String, dynamic>
                ? paramsRaw
                : <String, dynamic>{};
            editable['parameters'] = params;
            final sortedKeys = params.keys.toList()..sort();

            return AlertDialog(
              insetPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 16,
              ),
              title: Text('${t.actionChange} $modelId'),
              content: SizedBox(
                width: dialogWidth,
                height: dialogHeight.toDouble(),
                child: Scrollbar(
                  thumbVisibility: true,
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildTopLabeledNumberField(
                          label: t.modelsContextWindowField,
                          controller: contextController,
                        ),
                        const SizedBox(height: 10),
                        _buildTopLabeledNumberField(
                          label: t.modelsMaxOutputTokensField,
                          controller: maxOutputController,
                        ),
                        const SizedBox(height: 14),
                        Text(
                          t.modelsParameters,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        if (sortedKeys.isEmpty)
                          Text(t.modelsNoParameterDefinitions)
                        else
                          ...sortedKeys.map((key) {
                            final value = params[key];
                            if (value is! Map<String, dynamic>) {
                              return const SizedBox.shrink();
                            }
                            return _buildParameterEditorCard(
                              keyName: key,
                              parameter: value,
                              setStateDialog: setStateDialog,
                              defaultControllers: parameterDefaultControllers,
                            );
                          }),
                        if (errorText != null) ...[
                          const SizedBox(height: 10),
                          Text(
                            errorText!,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.error,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text(t.actionCancel),
                ),
                TextButton(
                  onPressed: () {
                    final pretty = const JsonEncoder.withIndent(
                      '  ',
                    ).convert(editable);
                    Navigator.of(context).pop(false);
                    _showEditOverrideDialog(modelId, pretty);
                  },
                  child: Text(t.modelsRawJson),
                ),
                FilledButton(
                  onPressed: () {
                    final contextWindow = int.tryParse(contextController.text);
                    final maxOutput = int.tryParse(maxOutputController.text);
                    if (contextWindow == null || contextWindow <= 0) {
                      setStateDialog(() {
                        errorText = t.modelsContextWindowPositive;
                      });
                      return;
                    }
                    if (maxOutput == null || maxOutput <= 0) {
                      setStateDialog(() {
                        errorText = t.modelsMaxOutputTokensPositive;
                      });
                      return;
                    }
                    editable['context_window'] = contextWindow;
                    editable['max_output_tokens'] = maxOutput;

                    final normalizeError = _normalizeOverrideParameters(
                      editable['parameters'],
                    );
                    if (normalizeError != null) {
                      setStateDialog(() {
                        errorText = normalizeError;
                      });
                      return;
                    }
                    Navigator.of(context).pop(true);
                  },
                  child: Text(t.actionSave),
                ),
              ],
            );
          },
        );
      },
    );

    contextController.dispose();
    maxOutputController.dispose();
    for (final controller in parameterDefaultControllers.values) {
      controller.dispose();
    }

    if (saved != true) {
      return;
    }

    final db = ref.read(databaseProvider);
    await db.modelsDao.upsertOverride(
      ModelsCompanion(
        modelId: Value(modelId),
        overrideJson: Value(jsonEncode(editable)),
        isUserAdded: const Value(true),
        updatedAt: Value(DateTime.now()),
      ),
    );

    if (mounted) {
      final registry = ref.read(modelRegistryProvider);
      registry.clearCache();
      ref.invalidate(mergedRegistryProvider);
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(t.modelsOverrideSaved)));
    }
  }

  Widget _buildTopLabeledNumberField({
    required String label,
    required TextEditingController controller,
  }) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 2, bottom: 6),
          child: Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            isDense: false,
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildParameterEditorCard({
    required String keyName,
    required Map<String, dynamic> parameter,
    required void Function(VoidCallback fn) setStateDialog,
    required Map<String, TextEditingController> defaultControllers,
  }) {
    final t = S.of(context)!;
    final theme = Theme.of(context);
    final supported = parameter['supported'] as bool? ?? false;
    final type = (parameter['type'] as String?)?.toLowerCase();
    final min = _asDouble(parameter['min']);
    final max = _asDouble(parameter['max']);
    final valuesRaw = parameter['values'];
    final enumValues = valuesRaw is List
        ? valuesRaw.map((e) => e.toString()).where((e) => e.isNotEmpty).toList()
        : <String>[];

    final isNumeric = type == 'integer' || type == 'float';
    final sliderEnabled =
        supported && isNumeric && min != null && max != null && max > min;
    final currentNumeric = _asDouble(parameter['default']) ?? min ?? 0.0;
    final clampedNumeric = sliderEnabled
        ? currentNumeric.clamp(min, max).toDouble()
        : currentNumeric;
    const sliderStep = 0.05;
    final sliderDivisions = sliderEnabled
        ? ((max - min) / sliderStep).round().clamp(1, 4000)
        : null;
    final defaultNumericText = _formatDefaultValue(clampedNumeric, type);
    final defaultController = defaultControllers.putIfAbsent(
      keyName,
      () => TextEditingController(text: defaultNumericText),
    );
    _setControllerText(defaultController, defaultNumericText);

    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    keyName,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Switch(
                  value: supported,
                  onChanged: (value) {
                    setStateDialog(() {
                      parameter['supported'] = value;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              t.modelsParameterMeta(
                '${parameter['type'] ?? '-'}',
                '${parameter['min'] ?? '-'}',
                '${parameter['max'] ?? '-'}',
              ),
              softWrap: true,
              style: theme.textTheme.bodyMedium?.copyWith(height: 1.35),
            ),
            const SizedBox(height: 10),
            if (sliderEnabled) ...[
              Row(
                children: [
                  Text(
                    t.modelsDefaultLabel,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _formatDefaultValue(clampedNumeric, type),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontFeatures: const [],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Expanded(
                    child: Slider(
                      value: clampedNumeric,
                      min: min,
                      max: max,
                      divisions: sliderDivisions,
                      onChanged: (value) {
                        final snappedValue = _snapToStep(
                          value,
                          step: sliderStep,
                          min: min,
                          max: max,
                        );
                        setStateDialog(() {
                          final next = type == 'integer'
                              ? snappedValue.round()
                              : snappedValue;
                          parameter['default'] = next;
                          _setControllerText(
                            defaultController,
                            _formatDefaultValue(next, type),
                          );
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  SizedBox(
                    width: 170,
                    child: TextFormField(
                      controller: defaultController,
                      enabled: supported,
                      keyboardType: TextInputType.numberWithOptions(
                        decimal: type != 'integer',
                      ),
                      decoration: InputDecoration(
                        labelText: t.modelsDefaultLabel,
                        floatingLabelBehavior: FloatingLabelBehavior.always,
                        border: OutlineInputBorder(),
                        isDense: false,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                      ),
                      onFieldSubmitted: (raw) {
                        final normalizedInput = raw.replaceAll(',', '.');
                        final parsed = double.tryParse(normalizedInput);
                        if (parsed == null) {
                          _setControllerText(
                            defaultController,
                            _formatDefaultValue(
                              parameter['default'] ?? clampedNumeric,
                              type,
                            ),
                          );
                          return;
                        }
                        final steppedValue = _snapToStep(
                          parsed,
                          step: sliderStep,
                          min: min,
                          max: max,
                        );
                        setStateDialog(() {
                          final next = type == 'integer'
                              ? steppedValue.round()
                              : steppedValue;
                          parameter['default'] = next;
                          _setControllerText(
                            defaultController,
                            _formatDefaultValue(next, type),
                          );
                        });
                      },
                    ),
                  ),
                ],
              ),
            ] else if (supported &&
                type == 'enum' &&
                enumValues.isNotEmpty) ...[
              DropdownButtonFormField<String>(
                initialValue:
                    enumValues.contains(parameter['default']?.toString())
                    ? parameter['default']?.toString()
                    : enumValues.first,
                decoration: InputDecoration(
                  labelText: t.modelsDefaultLabel,
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                  border: const OutlineInputBorder(),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                ),
                items: enumValues
                    .map(
                      (value) => DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      ),
                    )
                    .toList(),
                onChanged: supported
                    ? (value) {
                        setStateDialog(() {
                          parameter['default'] = value;
                        });
                      }
                    : null,
              ),
            ] else ...[
              TextFormField(
                initialValue: parameter['default']?.toString() ?? '',
                enabled: supported,
                decoration: InputDecoration(
                  labelText: t.modelsDefaultLabel,
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                  border: const OutlineInputBorder(),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                ),
                onChanged: (value) {
                  parameter['default'] = value;
                },
              ),
            ],
            const SizedBox(height: 10),
            TextFormField(
              initialValue: parameter['api_name']?.toString() ?? '',
              enabled: supported,
              decoration: InputDecoration(
                labelText: t.modelsApiNameOptional,
                floatingLabelBehavior: FloatingLabelBehavior.always,
                border: const OutlineInputBorder(),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
              ),
              onChanged: (value) {
                final trimmed = value.trim();
                parameter['api_name'] = trimmed.isEmpty ? null : trimmed;
              },
            ),
          ],
        ),
      ),
    );
  }

  String? _normalizeOverrideParameters(dynamic parametersRaw) {
    final t = S.of(context)!;
    if (parametersRaw is! Map<String, dynamic>) {
      return null;
    }
    for (final entry in parametersRaw.entries) {
      final key = entry.key;
      final value = entry.value;
      if (value is! Map<String, dynamic>) {
        continue;
      }

      if (value['supported'] is! bool) {
        value['supported'] = value['supported'] == true;
      }

      final type = (value['type'] as String?)?.toLowerCase();
      if (type == 'integer') {
        final parsedDefault = _asInt(value['default']);
        if (value['default'] != null && parsedDefault == null) {
          return t.modelsInvalidIntegerDefault(key);
        }
        value['default'] = parsedDefault;
      } else if (type == 'float') {
        final parsedDefault = _asDouble(value['default']);
        if (value['default'] != null && parsedDefault == null) {
          return t.modelsInvalidFloatDefault(key);
        }
        value['default'] = parsedDefault;
      } else if (type == 'enum') {
        if (value['values'] is! List && value['values'] != null) {
          final valuesText = value['values'].toString();
          value['values'] = valuesText
              .split(',')
              .map((part) => part.trim())
              .where((part) => part.isNotEmpty)
              .toList();
        }
      }
    }
    return null;
  }

  double? _asDouble(dynamic value) {
    if (value == null) {
      return null;
    }
    if (value is num) {
      return value.toDouble();
    }
    return double.tryParse(value.toString());
  }

  double _snapToStep(
    double value, {
    double step = 0.5,
    required double min,
    required double max,
  }) {
    final clamped = value.clamp(min, max).toDouble();
    final snapped = (clamped / step).round() * step;
    return snapped.clamp(min, max).toDouble();
  }

  String _formatDefaultValue(dynamic value, String? type) {
    final numeric = _asDouble(value);
    if (numeric == null) {
      return value?.toString() ?? '';
    }
    if (type == 'integer') {
      return numeric.round().toString();
    }
    return numeric.toStringAsFixed(2);
  }

  void _setControllerText(TextEditingController controller, String value) {
    if (controller.text == value) {
      return;
    }
    controller.value = controller.value.copyWith(
      text: value,
      selection: TextSelection.collapsed(offset: value.length),
      composing: TextRange.empty,
    );
  }

  int? _asInt(dynamic value) {
    if (value == null) {
      return null;
    }
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    return int.tryParse(value.toString());
  }

  Future<void> _showEditOverrideDialog(
    String modelId,
    String currentJson,
  ) async {
    final t = S.of(context)!;
    final controller = TextEditingController(text: currentJson);
    String? errorText;

    final saved = await showDialog<bool>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: Text('${t.modelsEditOverride} $modelId'),
              content: SizedBox(
                width: 700,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: controller,
                      maxLines: 14,
                      decoration: InputDecoration(
                        border: const OutlineInputBorder(),
                        labelText: t.modelsOverrideJsonLabel,
                        errorText: errorText,
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text(t.actionCancel),
                ),
                FilledButton(
                  onPressed: () {
                    try {
                      final parsed = jsonDecode(controller.text);
                      if (parsed is! Map) {
                        throw FormatException(t.modelsJsonMustBeObject);
                      }
                      Navigator.of(context).pop(true);
                    } catch (e) {
                      setStateDialog(() {
                        errorText = t.modelsInvalidJson('$e');
                      });
                    }
                  },
                  child: Text(t.actionSave),
                ),
              ],
            );
          },
        );
      },
    );

    if (saved != true) {
      return;
    }

    final db = ref.read(databaseProvider);
    await db.modelsDao.upsertOverride(
      ModelsCompanion(
        modelId: Value(modelId),
        overrideJson: Value(controller.text),
        isUserAdded: const Value(true),
        updatedAt: Value(DateTime.now()),
      ),
    );

    if (mounted) {
      final registry = ref.read(modelRegistryProvider);
      registry.clearCache();
      ref.invalidate(mergedRegistryProvider);
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(t.modelsOverrideSaved)));
    }
  }

  Future<void> _deleteOverride(String modelId) async {
    final db = ref.read(databaseProvider);
    await db.modelsDao.deleteOverride(modelId);
    if (mounted) {
      final t = S.of(context)!;
      final registry = ref.read(modelRegistryProvider);
      registry.clearCache();
      ref.invalidate(mergedRegistryProvider);
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(t.modelsOverrideDeleted)));
    }
  }

  Future<void> _discoverModels() async {
    final t = S.of(context)!;
    setState(() {
      _isDiscovering = true;
      _discoverError = null;
    });

    try {
      final db = ref.read(databaseProvider);
      final encryption = ref.read(encryptionProvider);
      final registry = ref.read(modelRegistryProvider);
      await registry.getMergedRegistry();
      final registryProviders = registry.getProviders();
      final providers = await db.providersDao.getEnabled();

      final discovered = <String, List<DiscoveredModel>>{};
      final enabledByType = <String, dynamic>{
        for (final provider in providers) provider.type: provider,
      };

      for (final providerType in const ['ollama', 'lmstudio']) {
        final provider = enabledByType[providerType];
        final fallbackBaseUrl = providerType == 'ollama'
            ? 'http://localhost:11434'
            : 'http://localhost:1234/v1';
        final baseUrl =
            provider?.baseUrl ??
            registryProviders[providerType]?.baseUrl ??
            fallbackBaseUrl;
        discovered[providerType] = await _discoverLocalModels(
          providerType: providerType,
          baseUrl: baseUrl,
        );
      }

      for (final provider in providers) {
        if (provider.type == 'ollama' || provider.type == 'lmstudio') {
          continue;
        }
        try {
          final headers = <String, String>{};
          final keyBytes = provider.encryptedApiKey;
          if (keyBytes != null && encryption.isUnlocked) {
            final apiKey = encryption.decryptData(keyBytes);
            if (apiKey.isNotEmpty) {
              switch (provider.type) {
                case 'anthropic':
                  headers['x-api-key'] = apiKey;
                  headers['anthropic-version'] = '2023-06-01';
                  break;
                case 'google':
                  headers['x-goog-api-key'] = apiKey;
                  break;
                default:
                  headers['Authorization'] = 'Bearer $apiKey';
              }
            }
          }

          final endpoint = provider.type == 'ollama'
              ? '${provider.baseUrl}/api/tags'
              : '${provider.baseUrl}/models';
          final response = await _dio.get(
            endpoint,
            options: Options(
              headers: headers,
              receiveTimeout: const Duration(seconds: 12),
            ),
          );

          final models = extractDiscoveredModels(provider.type, response.data);
          discovered[provider.type] = models;
        } catch (e) {
          discovered[provider.type] = [
            DiscoveredModel(
              provider: provider.type,
              id: t.modelsDiscoveryFailed('$e'),
              canAdd: false,
            ),
          ];
        }
      }

      if (!mounted) {
        return;
      }
      setState(() {
        _discovered = discovered;
      });
    } catch (e) {
      if (!mounted) {
        return;
      }
      setState(() {
        _discoverError = t.modelsDiscoveryFailed('$e');
      });
    } finally {
      if (mounted) {
        setState(() {
          _isDiscovering = false;
        });
      }
    }
  }

  Future<List<DiscoveredModel>> _discoverLocalModels({
    required String providerType,
    required String baseUrl,
  }) async {
    final t = S.of(context)!;
    final normalizedBaseUrl = _normalizeLocalBaseUrl(providerType, baseUrl);
    final endpoint = providerType == 'ollama'
        ? '$normalizedBaseUrl/api/tags'
        : '$normalizedBaseUrl/models';
    final reachable = await _isReachable(endpoint);
    if (!reachable) {
      return [
        DiscoveredModel(
          provider: providerType,
          id: t.modelsDiscoveryNotReachable(normalizedBaseUrl),
          canAdd: false,
        ),
      ];
    }

    try {
      final response = await _dio.get(
        endpoint,
        options: Options(
          connectTimeout: const Duration(seconds: 3),
          sendTimeout: const Duration(seconds: 3),
          receiveTimeout: const Duration(seconds: 12),
        ),
      );
      final models = extractDiscoveredModels(providerType, response.data);
      if (models.isNotEmpty) {
        return models;
      }
      return [
        DiscoveredModel(
          provider: providerType,
          id: t.modelsDiscoveryNoModels(normalizedBaseUrl),
          canAdd: false,
        ),
      ];
    } catch (e) {
      return [
        DiscoveredModel(
          provider: providerType,
          id: t.modelsDiscoveryFailedAt(normalizedBaseUrl, '$e'),
          canAdd: false,
        ),
      ];
    }
  }

  Future<bool> _isReachable(String endpoint) async {
    try {
      await _dio.get(
        endpoint,
        options: Options(
          connectTimeout: const Duration(seconds: 3),
          sendTimeout: const Duration(seconds: 3),
          receiveTimeout: const Duration(seconds: 4),
        ),
      );
      return true;
    } catch (_) {
      return false;
    }
  }

  String _normalizeLocalBaseUrl(String providerType, String baseUrl) {
    var normalized = baseUrl.trim().replaceAll(RegExp(r'/+$'), '');
    if (normalized.isEmpty) {
      return providerType == 'ollama'
          ? 'http://localhost:11434'
          : 'http://localhost:1234/v1';
    }
    if (providerType == 'ollama') {
      final suffixes = <String>[
        '/v1/api/chat',
        '/v1/api/generate',
        '/v1/api',
        '/v1',
        '/api/chat',
        '/api/generate',
        '/api',
      ];
      final lower = normalized.toLowerCase();
      for (final suffix in suffixes) {
        if (lower.endsWith(suffix)) {
          normalized = normalized.substring(
            0,
            normalized.length - suffix.length,
          );
          break;
        }
      }
      return normalized.replaceAll(RegExp(r'/+$'), '');
    }
    return normalized;
  }


  Future<void> _showCreateCustomModelDialog() async {
    final registry = ref.read(modelRegistryProvider);
    await registry.getMergedRegistry();
    if (!mounted) {
      return;
    }
    final t = S.of(context)!;
    final providerIds = registry.getProviders().keys.toList()..sort();
    if (providerIds.isEmpty) {
      return;
    }

    final modelIdController = TextEditingController();
    var selectedProvider = providerIds.first;
    String? errorText;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(t.modelsCreateCustomTitle),
              content: SizedBox(
                width: 520,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: modelIdController,
                      decoration: InputDecoration(
                        labelText: t.modelsCreateCustomModelId,
                        border: const OutlineInputBorder(),
                        errorText: errorText,
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: selectedProvider,
                      decoration: InputDecoration(
                        labelText: t.modelsCreateCustomProvider,
                        border: const OutlineInputBorder(),
                      ),
                      items: providerIds
                          .map(
                            (id) => DropdownMenuItem<String>(
                              value: id,
                              child: Text(id),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value == null) {
                          return;
                        }
                        setDialogState(() {
                          selectedProvider = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text(t.actionCancel),
                ),
                FilledButton(
                  onPressed: () {
                    final modelId = modelIdController.text.trim();
                    if (modelId.isEmpty) {
                      setDialogState(() {
                        errorText = t.modelsModelIdRequired;
                      });
                      return;
                    }
                    Navigator.of(context).pop(true);
                  },
                  child: Text(t.actionCreate),
                ),
              ],
            );
          },
        );
      },
    );

    final modelId = modelIdController.text.trim();
    modelIdController.dispose();

    if (confirmed != true || modelId.isEmpty) {
      return;
    }

    await _upsertCustomModel(modelId: modelId, provider: selectedProvider);
  }

  Future<void> _addDiscoveredModelToCustom(DiscoveredModel model) async {
    await _upsertCustomModel(modelId: model.id, provider: model.provider);
  }

  Future<void> _upsertCustomModel({
    required String modelId,
    required String provider,
  }) async {
    final t = S.of(context)!;
    final db = ref.read(databaseProvider);
    final override = _buildDefaultCustomModelOverride(
      modelId: modelId,
      provider: provider,
    );

    await db.modelsDao.upsertOverride(
      ModelsCompanion(
        modelId: Value(modelId),
        overrideJson: Value(jsonEncode(override)),
        isUserAdded: const Value(true),
        updatedAt: Value(DateTime.now()),
      ),
    );

    if (!mounted) {
      return;
    }

    final registry = ref.read(modelRegistryProvider);
    registry.clearCache();
    ref.invalidate(mergedRegistryProvider);

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(t.modelsOverrideSaved)));
  }

  Map<String, dynamic> _buildDefaultCustomModelOverride({
    required String modelId,
    required String provider,
  }) {
    final t = S.of(context)!;
    return {
      'provider': provider,
      'display_name': modelId,
      'description': t.modelsCustomModelDescription,
      'context_window': 32768,
      'max_output_tokens': 4096,
      'pricing': {
        'input_per_million': 0.0,
        'output_per_million': 0.0,
        'currency': 'USD',
      },
      'capabilities': {
        'chat': true,
        'vision': false,
        'function_calling': false,
        'json_mode': false,
        'streaming': true,
      },
      'parameters': {
        'temperature': {
          'supported': true,
          'type': 'float',
          'min': 0.0,
          'max': 2.0,
          'default': 0.7,
        },
        'max_tokens': {
          'supported': true,
          'type': 'integer',
          'min': 1,
          'max': 32768,
          'default': 4096,
        },
        'top_p': {
          'supported': true,
          'type': 'float',
          'min': 0.0,
          'max': 1.0,
          'default': 1.0,
        },
      },
      'status': 'active',
    };
  }
}

