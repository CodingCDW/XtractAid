import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/database_provider.dart';
import '../../providers/encryption_provider.dart';
import '../../providers/settings_provider.dart';

class PasswordScreen extends ConsumerStatefulWidget {
  const PasswordScreen({super.key});

  @override
  ConsumerState<PasswordScreen> createState() => _PasswordScreenState();
}

class _PasswordScreenState extends ConsumerState<PasswordScreen> {
  final _passwordController = TextEditingController();
  String? _errorText;
  bool _isBusy = false;

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _unlock() async {
    final password = _passwordController.text;
    if (password.isEmpty) {
      setState(() {
        _errorText = 'Bitte Passwort eingeben.';
      });
      return;
    }

    final db = ref.read(databaseProvider);
    final encryption = ref.read(encryptionProvider);

    setState(() {
      _isBusy = true;
      _errorText = null;
    });

    try {
      final saltB64 = await db.settingsDao.getValue('password_salt');
      final storedHash = await db.settingsDao.getValue('password_hash');
      if (saltB64 == null || storedHash == null) {
        setState(() {
          _errorText = 'Setup unvollstaendig. Bitte neu einrichten.';
        });
        return;
      }

      final salt = base64Decode(saltB64);
      final isValid = encryption.verifyPassword(password, salt, storedHash);
      if (!isValid) {
        setState(() {
          _errorText = 'Falsches Passwort';
        });
        return;
      }

      encryption.unlock(password, salt);
      if (!mounted) {
        return;
      }
      context.go('/projects');
    } catch (_) {
      setState(() {
        _errorText = 'Entsperren fehlgeschlagen.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isBusy = false;
        });
      }
    }
  }

  Future<void> _showForgotPasswordDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Passwort vergessen?'),
          content: const Text(
            'Alle API-Keys werden geloescht. Fortfahren?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Abbrechen'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Fortfahren'),
            ),
          ],
        );
      },
    );

    if (result != true) {
      return;
    }

    final db = ref.read(databaseProvider);
    final encryption = ref.read(encryptionProvider);

    setState(() {
      _isBusy = true;
    });

    try {
      final allProviders = await db.providersDao.getAll();
      for (final provider in allProviders) {
        await db.providersDao.deleteProvider(provider.id);
      }
      await db.settingsDao.deleteValue('password_hash');
      await db.settingsDao.deleteValue('password_salt');
      await db.settingsDao.deleteValue('setup_complete');
      encryption.lock();
      ref.invalidate(isSetupCompleteProvider);

      if (!mounted) {
        return;
      }
      context.go('/setup');
    } catch (_) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: Text('Reset fehlgeschlagen.')),
        );
    } finally {
      if (mounted) {
        setState(() {
          _isBusy = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 360),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.lock_outline,
                  size: 40,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 12),
                Text(
                  'XtractAid',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  onChanged: (_) {
                    if (_errorText != null) {
                      setState(() {
                        _errorText = null;
                      });
                    }
                  },
                  onSubmitted: (_) => _unlock(),
                  decoration: InputDecoration(
                    labelText: 'Master Password',
                    prefixIcon: const Icon(Icons.lock),
                    errorText: _errorText,
                  ),
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: _isBusy ? null : _unlock,
                  child: _isBusy
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Unlock'),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: _isBusy ? null : _showForgotPasswordDialog,
                  child: const Text('Passwort vergessen?'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
