import 'dart:convert';
import 'dart:typed_data';

import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' hide Provider;
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../core/l10n/generated/app_localizations.dart';
import '../../core/utils/provider_helpers.dart';
import '../../data/database/app_database.dart';
import '../../providers/database_provider.dart';
import '../../providers/encryption_provider.dart';
import '../../providers/settings_provider.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  static const _providerDefaults = <String, String>{
    'openai': 'https://api.openai.com/v1',
    'anthropic': 'https://api.anthropic.com/v1',
    'google': 'https://generativelanguage.googleapis.com/v1beta',
    'openrouter': 'https://openrouter.ai/api/v1',
    'ollama': 'http://localhost:11434',
    'lmstudio': 'http://localhost:1234/v1',
  };

  String _language = 'de';
  bool _strictLocalMode = false;
  int _checkpointInterval = 10;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final db = ref.read(databaseProvider);
    final all = await db.settingsDao.getAll();

    if (!mounted) return;
    setState(() {
      _language = all['language'] ?? 'de';
      _strictLocalMode = all['strict_local_mode'] == 'true';
      _checkpointInterval =
          int.tryParse(all['checkpoint_interval'] ?? '') ?? 10;
      _isLoading = false;
    });
  }

  Future<void> _saveSetting(String key, String value) async {
    final db = ref.read(databaseProvider);
    await db.settingsDao.setValue(key, value);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = S.of(context)!;

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text(t.settingsTitle)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(t.settingsTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionHeader(theme, Icons.settings, t.settingsSectionGeneral),
          _buildLanguageTile(t),
          const Divider(height: 32),
          _buildSectionHeader(theme, Icons.security, t.settingsSectionSecurity),
          _buildChangePasswordTile(t),
          _buildManageProvidersTile(t),
          const Divider(height: 32),
          _buildSectionHeader(theme, Icons.shield, t.settingsSectionPrivacy),
          _buildStrictLocalModeTile(t),
          const Divider(height: 32),
          _buildSectionHeader(theme, Icons.tune, t.settingsSectionAdvanced),
          _buildCheckpointIntervalTile(t),
          const Divider(height: 32),
          _buildSectionHeader(theme, Icons.warning_amber, t.settingsSectionReset),
          _buildResetTile(t),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(ThemeData theme, IconData icon, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: theme.colorScheme.primary),
          const SizedBox(width: 8),
          Text(title, style: theme.textTheme.titleMedium?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.w600,
          )),
        ],
      ),
    );
  }

  Widget _buildLanguageTile(S t) {
    return ListTile(
      title: Text(t.labelLanguage),
      subtitle: Text(_language == 'de' ? t.labelGerman : t.labelEnglish),
      trailing: DropdownButton<String>(
        value: _language,
        underline: const SizedBox.shrink(),
        items: [
          DropdownMenuItem(value: 'de', child: Text(t.labelGerman)),
          DropdownMenuItem(value: 'en', child: Text(t.labelEnglish)),
        ],
        onChanged: (value) {
          if (value == null) return;
          setState(() => _language = value);
          _saveSetting('language', value);
          ref.read(localeProvider.notifier).state = Locale(value);
        },
      ),
    );
  }

  Widget _buildChangePasswordTile(S t) {
    return ListTile(
      title: Text(t.settingsChangePassword),
      subtitle: Text(t.settingsChangePasswordDesc),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => _showChangePasswordDialog(),
    );
  }

  Widget _buildManageProvidersTile(S t) {
    return ListTile(
      title: Text(t.settingsManageProviders),
      subtitle: Text(t.settingsManageProvidersDesc),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => _showManageProvidersDialog(),
    );
  }

  Widget _buildStrictLocalModeTile(S t) {
    return SwitchListTile(
      title: Text(t.settingsStrictLocalMode),
      subtitle: Text(t.settingsStrictLocalModeDesc),
      value: _strictLocalMode,
      onChanged: (value) {
        setState(() => _strictLocalMode = value);
        _saveSetting('strict_local_mode', value.toString());
      },
    );
  }

  Widget _buildCheckpointIntervalTile(S t) {
    return ListTile(
      title: Text(t.settingsCheckpointInterval),
      subtitle: Text(t.settingsCheckpointIntervalDesc(_checkpointInterval)),
      trailing: SizedBox(
        width: 200,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              child: Slider(
                value: _checkpointInterval.toDouble(),
                min: 1,
                max: 50,
                divisions: 49,
                label: '$_checkpointInterval',
                onChanged: (value) {
                  setState(() => _checkpointInterval = value.round());
                },
                onChangeEnd: (value) {
                  _saveSetting('checkpoint_interval', value.round().toString());
                },
              ),
            ),
            SizedBox(
              width: 32,
              child: Text(
                '$_checkpointInterval',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResetTile(S t) {
    return ListTile(
      title: Text(
        t.settingsResetApp,
        style: TextStyle(color: Theme.of(context).colorScheme.error),
      ),
      subtitle: Text(t.settingsResetAppDesc),
      trailing: Icon(Icons.delete_forever,
          color: Theme.of(context).colorScheme.error),
      onTap: () => _showResetDialog(),
    );
  }

  Future<void> _showChangePasswordDialog() async {
    final currentController = TextEditingController();
    final newController = TextEditingController();
    final confirmController = TextEditingController();
    String? errorText;

    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        final t = S.of(dialogContext)!;
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(t.settingsChangePassword),
              content: SizedBox(
                width: 400,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: currentController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: t.labelCurrentPassword,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: newController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: t.labelNewPassword,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: confirmController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: t.labelConfirmNewPassword,
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
                  onPressed: () async {
                    final enc = ref.read(encryptionProvider);
                    final db = ref.read(databaseProvider);

                    if (newController.text.length < 8) {
                      setDialogState(() {
                        errorText = t.settingsMinPasswordLength;
                      });
                      return;
                    }
                    if (newController.text != confirmController.text) {
                      setDialogState(() {
                        errorText = t.settingsPasswordMismatch;
                      });
                      return;
                    }

                    final saltB64 =
                        await db.settingsDao.getValue('password_salt');
                    final storedHash =
                        await db.settingsDao.getValue('password_hash');
                    if (saltB64 == null || storedHash == null) return;

                    final salt = base64Decode(saltB64);
                    if (!enc.verifyPassword(
                        currentController.text, salt, storedHash)) {
                      setDialogState(() {
                        errorText = t.settingsWrongPassword;
                      });
                      return;
                    }

                    // Transactional re-encryption:
                    // 1. Decrypt all keys with old password
                    enc.unlock(currentController.text, salt);
                    final providers = await db.providersDao.getAll();
                    final decryptedKeys = <String, String>{};
                    try {
                      for (final p in providers) {
                        if (p.encryptedApiKey != null) {
                          decryptedKeys[p.id] =
                              enc.decryptData(p.encryptedApiKey!);
                        }
                      }
                    } catch (e) {
                      setDialogState(() {
                        errorText = t.settingsDecryptKeysFailed;
                      });
                      return;
                    }

                    // 2. Set new password
                    final newSalt = enc.generateSalt();
                    final newHash =
                        enc.hashPassword(newController.text, newSalt);

                    // 3. Re-encrypt all keys with new password
                    enc.unlock(newController.text, newSalt);
                    final reEncrypted = <String, Uint8List>{};
                    try {
                      for (final entry in decryptedKeys.entries) {
                        reEncrypted[entry.key] =
                            enc.encryptData(entry.value);
                      }
                    } catch (e) {
                      // Rollback: restore old encryption state
                      enc.unlock(currentController.text, salt);
                      setDialogState(() {
                        errorText = t.settingsReEncryptionFailed;
                      });
                      return;
                    }

                    // 4. Persist atomically: hash first, then keys
                    await db.settingsDao.setValue('password_hash', newHash);
                    await db.settingsDao
                        .setValue('password_salt', base64Encode(newSalt));
                    for (final entry in reEncrypted.entries) {
                      await db.providersDao.updateProvider(
                        entry.key,
                        ProvidersCompanion(
                            encryptedApiKey: Value(entry.value)),
                      );
                    }

                    if (context.mounted) Navigator.of(context).pop(true);
                  },
                  child: Text(t.actionChange),
                ),
              ],
            );
          },
        );
      },
    );

    currentController.dispose();
    newController.dispose();
    confirmController.dispose();

    if (result == true && mounted) {
      final t = S.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t.settingsPasswordChanged)),
      );
    }
  }

  Future<void> _showManageProvidersDialog() async {
    final db = ref.read(databaseProvider);
    final providers = await db.providersDao.getAll()
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

    if (!mounted) return;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        final t = S.of(dialogContext)!;
        return StatefulBuilder(
          builder: (context, setDialogState) {
            Future<void> reloadProviders() async {
              final updated = await db.providersDao.getAll()
                ..sort(
                  (a, b) =>
                      a.name.toLowerCase().compareTo(b.name.toLowerCase()),
                );
              setDialogState(
                () => providers
                  ..clear()
                  ..addAll(updated),
              );
            }

            return AlertDialog(
              title: Text(t.settingsProviderTitle),
              content: SizedBox(
                width: 500,
                height: 400,
                child: Column(
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton.icon(
                        onPressed: () async {
                          final payload = await _showProviderEditorDialog();
                          if (payload == null) {
                            return;
                          }
                          final saved = await _saveProvider(payload);
                          if (!saved) {
                            return;
                          }
                          await reloadProviders();
                        },
                        icon: const Icon(Icons.add),
                        label: Text(t.settingsProviderAdd),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: providers.isEmpty
                          ? Center(child: Text(t.settingsNoProviders))
                          : ListView.separated(
                              itemCount: providers.length,
                              separatorBuilder: (_, _) => const Divider(),
                              itemBuilder: (context, index) {
                                final p = providers[index];
                                final hasKey = p.encryptedApiKey != null;
                                final providerType = providerDisplayName(
                                  p.type,
                                );
                                final keyStatus = hasKey
                                    ? t.settingsProviderKeyStored
                                    : t.settingsProviderKeyMissing;
                                return ListTile(
                                  dense: true,
                                  visualDensity: VisualDensity.compact,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 4,
                                  ),
                                  leading: Icon(
                                    hasKey ? Icons.vpn_key : Icons.link,
                                    color: p.isEnabled
                                        ? Theme.of(context).colorScheme.primary
                                        : Colors.grey,
                                  ),
                                  title: Text(p.name),
                                  subtitle: Text('$providerType • $keyStatus\n${p.baseUrl}'),
                                  trailing: Wrap(
                                    spacing: 2,
                                    crossAxisAlignment: WrapCrossAlignment.center,
                                    children: [
                                      IconButton(
                                        tooltip: t.actionChange,
                                        visualDensity: VisualDensity.compact,
                                        constraints: const BoxConstraints.tightFor(
                                          width: 32,
                                          height: 32,
                                        ),
                                        icon: const Icon(Icons.edit_outlined),
                                        onPressed: () async {
                                          final payload =
                                              await _showProviderEditorDialog(
                                            existing: p,
                                          );
                                          if (payload == null) {
                                            return;
                                          }
                                          final saved = await _saveProvider(
                                            payload,
                                            existing: p,
                                          );
                                          if (!saved) {
                                            return;
                                          }
                                          await reloadProviders();
                                        },
                                      ),
                                      Tooltip(
                                        message: t.settingsProviderEnabled,
                                        child: Switch(
                                          value: p.isEnabled,
                                          onChanged: (enabled) async {
                                            await db.providersDao.updateProvider(
                                              p.id,
                                              ProvidersCompanion(
                                                isEnabled: Value(enabled),
                                              ),
                                            );
                                            await reloadProviders();
                                          },
                                        ),
                                      ),
                                      IconButton(
                                        tooltip: t.actionDelete,
                                        visualDensity: VisualDensity.compact,
                                        constraints: const BoxConstraints.tightFor(
                                          width: 32,
                                          height: 32,
                                        ),
                                        icon: Icon(
                                          Icons.delete_outline,
                                          color: Theme.of(context).colorScheme.error,
                                        ),
                                        onPressed: () async {
                                          final confirm = await showDialog<bool>(
                                            context: context,
                                            builder: (ctx) {
                                              final t2 = S.of(ctx)!;
                                              return AlertDialog(
                                                title: Text(
                                                  t2.settingsDeleteProvider,
                                                ),
                                                content: Text(
                                                  t2.settingsDeleteProviderDesc(
                                                    p.name,
                                                  ),
                                                ),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () =>
                                                        Navigator.of(
                                                      ctx,
                                                    ).pop(false),
                                                    child: Text(
                                                      t2.actionCancel,
                                                    ),
                                                  ),
                                                  FilledButton(
                                                    onPressed: () =>
                                                        Navigator.of(
                                                      ctx,
                                                    ).pop(true),
                                                    child: Text(
                                                      t2.actionDelete,
                                                    ),
                                                  ),
                                                ],
                                              );
                                            },
                                          );
                                          if (confirm == true) {
                                            await db.providersDao.deleteProvider(
                                              p.id,
                                            );
                                            await reloadProviders();
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
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
      },
    );
  }

  Future<_ProviderEditPayload?> _showProviderEditorDialog({
    Provider? existing,
  }) async {
    final providerTypes = _providerDefaults.keys.toList();
    final initialType = existing?.type ?? providerTypes.first;
    final initialBaseUrl = existing?.baseUrl ?? _providerDefaults[initialType]!;

    final nameController = TextEditingController(
      text: existing?.name ?? providerDisplayName(initialType),
    );
    final baseUrlController = TextEditingController(text: initialBaseUrl);
    final apiKeyController = TextEditingController();
    var selectedType = initialType;
    var isEnabled = existing?.isEnabled ?? true;
    var clearApiKey = false;
    String? errorText;
    final hasExistingKey = existing?.encryptedApiKey != null;

    final payload = await showDialog<_ProviderEditPayload>(
      context: context,
      builder: (dialogContext) {
        final t2 = S.of(dialogContext)!;
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final isLocal = isLocalProviderType(selectedType);
            final helperText = isLocal
                ? t2.settingsProviderApiKeyLocalOptional
                : hasExistingKey
                    ? t2.settingsProviderApiKeyKeepHint
                    : t2.settingsProviderApiKeyRequiredHint;

            return AlertDialog(
              title: Text(
                existing == null
                    ? t2.settingsProviderAddTitle
                    : t2.settingsProviderEditTitle(existing.name),
              ),
              content: SizedBox(
                width: 520,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: t2.settingsProviderName,
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: selectedType,
                      decoration: InputDecoration(
                        labelText: t2.settingsProviderType,
                        border: const OutlineInputBorder(),
                      ),
                      items: providerTypes
                          .map(
                            (type) => DropdownMenuItem<String>(
                              value: type,
                              child: Text(providerDisplayName(type)),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value == null) {
                          return;
                        }
                        final previousDefault =
                            _providerDefaults[selectedType] ?? '';
                        final nextDefault = _providerDefaults[value] ?? '';
                        setDialogState(() {
                          selectedType = value;
                          final current = baseUrlController.text.trim();
                          if (current.isEmpty || current == previousDefault) {
                            baseUrlController.text = nextDefault;
                          }
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: baseUrlController,
                      decoration: InputDecoration(
                        labelText: t2.settingsProviderBaseUrl,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: apiKeyController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: t2.settingsProviderApiKey,
                        helperText: helperText,
                      ),
                    ),
                    if (hasExistingKey) ...[
                      const SizedBox(height: 4),
                      CheckboxListTile(
                        contentPadding: EdgeInsets.zero,
                        value: clearApiKey,
                        onChanged: (value) {
                          setDialogState(() {
                            clearApiKey = value ?? false;
                          });
                        },
                        title: Text(t2.settingsProviderClearApiKey),
                      ),
                    ],
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      value: isEnabled,
                      onChanged: (value) {
                        setDialogState(() {
                          isEnabled = value;
                        });
                      },
                      title: Text(t2.settingsProviderEnabled),
                    ),
                    if (errorText != null)
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          errorText!,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(t2.actionCancel),
                ),
                FilledButton(
                  onPressed: () {
                    final name = nameController.text.trim();
                    final baseUrl = baseUrlController.text.trim();
                    final apiKey = apiKeyController.text.trim();
                    final isLocal = isLocalProviderType(selectedType);
                    final isCreate = existing == null;

                    if (name.isEmpty) {
                      setDialogState(() {
                        errorText = t2.settingsProviderNameRequired;
                      });
                      return;
                    }
                    if (baseUrl.isEmpty) {
                      setDialogState(() {
                        errorText = t2.settingsProviderBaseUrlRequired;
                      });
                      return;
                    }
                    if (!isLocal && isCreate && apiKey.isEmpty) {
                      setDialogState(() {
                        errorText = t2.settingsProviderApiKeyRequired;
                      });
                      return;
                    }

                    Navigator.of(context).pop(
                      _ProviderEditPayload(
                        name: name,
                        type: selectedType,
                        baseUrl: baseUrl,
                        apiKey: apiKey,
                        clearApiKey: clearApiKey,
                        isEnabled: isEnabled,
                      ),
                    );
                  },
                  child: Text(existing == null ? t2.actionCreate : t2.actionSave),
                ),
              ],
            );
          },
        );
      },
    );

    nameController.dispose();
    baseUrlController.dispose();
    apiKeyController.dispose();
    return payload;
  }

  Future<bool> _saveProvider(
    _ProviderEditPayload payload, {
    Provider? existing,
  }) async {
    final t = S.of(context)!;
    final db = ref.read(databaseProvider);
    final enc = ref.read(encryptionProvider);
    final hasNewApiKey = payload.apiKey.isNotEmpty;

    Uint8List? encryptedApiKey;
    if (hasNewApiKey) {
      if (!enc.isUnlocked) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(content: Text(t.settingsProviderEncryptionLocked)),
          );
        return false;
      }
      encryptedApiKey = enc.encryptData(payload.apiKey);
    }

    try {
      if (existing == null) {
        await db.providersDao.insertProvider(
          ProvidersCompanion(
            id: Value(const Uuid().v4()),
            name: Value(payload.name),
            type: Value(payload.type),
            baseUrl: Value(payload.baseUrl),
            encryptedApiKey: hasNewApiKey
                ? Value(encryptedApiKey)
                : const Value.absent(),
            isEnabled: Value(payload.isEnabled),
            updatedAt: Value(DateTime.now()),
          ),
        );
      } else {
        await db.providersDao.updateProvider(
          existing.id,
          ProvidersCompanion(
            name: Value(payload.name),
            type: Value(payload.type),
            baseUrl: Value(payload.baseUrl),
            encryptedApiKey: hasNewApiKey
                ? Value(encryptedApiKey)
                : payload.clearApiKey
                    ? const Value(null)
                    : const Value.absent(),
            isEnabled: Value(payload.isEnabled),
            updatedAt: Value(DateTime.now()),
          ),
        );
      }
    } catch (e) {
      if (!mounted) {
        return false;
      }
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text(t.settingsProviderSaveError('$e'))),
        );
      return false;
    }

    if (mounted) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              existing == null
                  ? t.settingsProviderAdded
                  : t.settingsProviderUpdated,
            ),
          ),
        );
    }
    return true;
  }

  Future<void> _showResetDialog() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        final t = S.of(context)!;
        return AlertDialog(
          title: Text(t.settingsResetTitle),
          content: Text(t.settingsResetDesc),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(t.actionCancel),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(t.actionReset),
            ),
          ],
        );
      },
    );

    if (confirm != true || !mounted) return;

    final db = ref.read(databaseProvider);
    final enc = ref.read(encryptionProvider);

    final providers = await db.providersDao.getAll();
    for (final p in providers) {
      await db.providersDao.deleteProvider(p.id);
    }

    await db.settingsDao.deleteValue('password_hash');
    await db.settingsDao.deleteValue('password_salt');
    await db.settingsDao.deleteValue('setup_complete');
    await db.settingsDao.deleteValue('strict_local_mode');
    await db.settingsDao.deleteValue('checkpoint_interval');

    enc.lock();

    if (mounted) context.go('/setup');
  }
}

class _ProviderEditPayload {
  const _ProviderEditPayload({
    required this.name,
    required this.type,
    required this.baseUrl,
    required this.apiKey,
    required this.clearApiKey,
    required this.isEnabled,
  });

  final String name;
  final String type;
  final String baseUrl;
  final String apiKey;
  final bool clearApiKey;
  final bool isEnabled;
}
