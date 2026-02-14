import 'dart:convert';

import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n/generated/app_localizations.dart';
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

                    final newSalt = enc.generateSalt();
                    final newHash =
                        enc.hashPassword(newController.text, newSalt);
                    await db.settingsDao.setValue('password_hash', newHash);
                    await db.settingsDao
                        .setValue('password_salt', base64Encode(newSalt));

                    enc.unlock(currentController.text, salt);
                    final providers = await db.providersDao.getAll();

                    enc.unlock(currentController.text, salt);
                    for (final p in providers) {
                      if (p.encryptedApiKey != null) {
                        final plainKey = enc.decryptData(p.encryptedApiKey!);
                        enc.unlock(newController.text, newSalt);
                        final newBlob = enc.encryptData(plainKey);
                        await db.providersDao.updateProvider(
                          p.id,
                          ProvidersCompanion(encryptedApiKey: Value(newBlob)),
                        );
                        enc.unlock(currentController.text, salt);
                      }
                    }

                    enc.unlock(newController.text, newSalt);

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
    final providers = await db.providersDao.getAll();

    if (!mounted) return;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        final t = S.of(dialogContext)!;
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(t.settingsProviderTitle),
              content: SizedBox(
                width: 500,
                height: 400,
                child: providers.isEmpty
                    ? Center(child: Text(t.settingsNoProviders))
                    : ListView.separated(
                        itemCount: providers.length,
                        separatorBuilder: (_, _) => const Divider(),
                        itemBuilder: (context, index) {
                          final p = providers[index];
                          final hasKey = p.encryptedApiKey != null;
                          return ListTile(
                            leading: Icon(
                              hasKey ? Icons.vpn_key : Icons.link,
                              color: p.isEnabled
                                  ? Theme.of(context).colorScheme.primary
                                  : Colors.grey,
                            ),
                            title: Text(p.name),
                            subtitle: Text('${p.type} - ${p.baseUrl}'),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Switch(
                                  value: p.isEnabled,
                                  onChanged: (enabled) async {
                                    await db.providersDao.updateProvider(
                                      p.id,
                                      ProvidersCompanion(
                                        isEnabled: Value(enabled),
                                      ),
                                    );
                                    final updated =
                                        await db.providersDao.getAll();
                                    setDialogState(() => providers
                                      ..clear()
                                      ..addAll(updated));
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline),
                                  onPressed: () async {
                                    final confirm = await showDialog<bool>(
                                      context: context,
                                      builder: (ctx) {
                                        final t2 = S.of(ctx)!;
                                        return AlertDialog(
                                          title: Text(t2.settingsDeleteProvider),
                                          content: Text(
                                            t2.settingsDeleteProviderDesc(p.name),
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.of(ctx).pop(false),
                                              child: Text(t2.actionCancel),
                                            ),
                                            FilledButton(
                                              onPressed: () =>
                                                  Navigator.of(ctx).pop(true),
                                              child: Text(t2.actionDelete),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                    if (confirm == true) {
                                      await db.providersDao
                                          .deleteProvider(p.id);
                                      final updated =
                                          await db.providersDao.getAll();
                                      setDialogState(() => providers
                                        ..clear()
                                        ..addAll(updated));
                                    }
                                  },
                                ),
                              ],
                            ),
                          );
                        },
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
