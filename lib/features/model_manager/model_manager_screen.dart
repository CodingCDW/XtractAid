import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:drift/drift.dart' show Value;

import '../../core/l10n/generated/app_localizations.dart';
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
  Map<String, List<String>> _discovered = const {};
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
        final grouped = registryService.getModelsByProvider();
        final providerKeys = grouped.keys.toList()..sort();

        if (providerKeys.isEmpty) {
          return Center(child: Text(t.modelsNoRegistry));
        }

        return ListView.builder(
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
                    return ListTile(
                      title: Text(modelId),
                    );
                  }
                  return ListTile(
                    title: Text(info.displayName),
                    subtitle: Text(
                      'ID: ${info.id} | Context: ${info.contextWindow} | '
                      'USD/M in/out: ${info.pricing.inputPerMillion}/${info.pricing.outputPerMillion}',
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
        );
      },
    );
  }

  Widget _buildCustomTab() {
    final t = S.of(context)!;
    final db = ref.watch(databaseProvider);
    return StreamBuilder(
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
                      tooltip: 'Bearbeiten',
                      onPressed: () => _showEditOverrideDialog(row.modelId, row.overrideJson),
                      icon: const Icon(Icons.edit),
                    ),
                    IconButton(
                      tooltip: 'Loeschen',
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
                              .map((m) => ListTile(title: Text(m)))
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
    final chips = <Widget>[];
    if (info.capabilities.chat) {
      chips.add(const Chip(label: Text('chat')));
    }
    if (info.capabilities.vision) {
      chips.add(const Chip(label: Text('vision')));
    }
    if (info.capabilities.functionCalling) {
      chips.add(const Chip(label: Text('fn')));
    }
    if (info.capabilities.jsonMode) {
      chips.add(const Chip(label: Text('json')));
    }
    if (info.capabilities.reasoning) {
      chips.add(const Chip(label: Text('reason')));
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
                    'Pricing (USD/M in,out): ${info.pricing.inputPerMillion}, ${info.pricing.outputPerMillion}',
                  ),
                  const Divider(height: 20),
                  Text(t.modelsCapabilities),
                  Text(
                    'chat=${info.capabilities.chat}, vision=${info.capabilities.vision}, '
                    'functionCalling=${info.capabilities.functionCalling}, jsonMode=${info.capabilities.jsonMode}, '
                    'streaming=${info.capabilities.streaming}, reasoning=${info.capabilities.reasoning}, '
                    'extendedThinking=${info.capabilities.extendedThinking}',
                  ),
                  const Divider(height: 20),
                  Text(t.modelsParameters),
                  ...info.parameters.entries.map(
                    (entry) => Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Text(
                        '${entry.key}: supported=${entry.value.supported}, '
                        'type=${entry.value.type}, min=${entry.value.min}, max=${entry.value.max}, '
                        'default=${entry.value.defaultValue}, values=${entry.value.values}',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(t.actionClose),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showEditOverrideDialog(String modelId, String currentJson) async {
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
                        labelText: 'overrideJson',
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
                        throw const FormatException('JSON muss ein Objekt sein.');
                      }
                      Navigator.of(context).pop(true);
                    } catch (e) {
                      setStateDialog(() {
                        errorText = 'Ungueltiges JSON: $e';
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
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(t.modelsOverrideDeleted)));
    }
  }

  Future<void> _discoverModels() async {
    setState(() {
      _isDiscovering = true;
      _discoverError = null;
    });

    try {
      final db = ref.read(databaseProvider);
      final encryption = ref.read(encryptionProvider);
      final providers = await db.providersDao.getEnabled();

      final discovered = <String, List<String>>{};

      for (final provider in providers) {
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
            options: Options(headers: headers, receiveTimeout: const Duration(seconds: 12)),
          );

          final models = _extractDiscoveredModelNames(provider.type, response.data);
          discovered[provider.type] = models;
        } catch (e) {
          discovered[provider.type] = ['Discovery fehlgeschlagen: $e'];
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
        _discoverError = 'Discovery fehlgeschlagen: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isDiscovering = false;
        });
      }
    }
  }

  List<String> _extractDiscoveredModelNames(String providerType, dynamic payload) {
    if (providerType == 'ollama') {
      if (payload is Map && payload['models'] is List) {
        final list = payload['models'] as List;
        return list
            .whereType<Map>()
            .map((m) => m['name']?.toString() ?? '')
            .where((s) => s.isNotEmpty)
            .toList();
      }
      return const [];
    }

    if (payload is Map && payload['data'] is List) {
      final list = payload['data'] as List;
      return list
          .whereType<Map>()
          .map((m) => m['id']?.toString() ?? '')
          .where((s) => s.isNotEmpty)
          .toList();
    }

    return const [];
  }
}
