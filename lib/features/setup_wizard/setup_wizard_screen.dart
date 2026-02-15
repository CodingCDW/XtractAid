import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:logging/logging.dart';
import 'package:uuid/uuid.dart';

import '../../core/l10n/generated/app_localizations.dart';
import '../../data/database/app_database.dart';
import '../../data/models/provider_config.dart';
import '../../providers/database_provider.dart';
import '../../providers/encryption_provider.dart';
import '../../providers/model_registry_provider.dart';
import '../../providers/settings_provider.dart';
import '../../services/llm_api_service.dart';
import 'steps/step_api_key.dart';
import 'steps/step_basic_settings.dart';
import 'steps/step_finish.dart';
import 'steps/step_password.dart';
import 'steps/step_provider.dart';
import 'steps/step_welcome.dart';

final _log = Logger('SetupWizardScreen');

class SetupWizardScreen extends ConsumerStatefulWidget {
  const SetupWizardScreen({super.key});

  @override
  ConsumerState<SetupWizardScreen> createState() => _SetupWizardScreenState();
}

class _SetupWizardScreenState extends ConsumerState<SetupWizardScreen> {
  static const _providerOrder = [
    'openai',
    'anthropic',
    'google',
    'openrouter',
    'ollama',
    'lmstudio',
  ];

  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  final _apiKeyController = TextEditingController();
  final _llmApiService = LlmApiService();

  int _currentStep = 0;
  bool _isLoadingProviders = true;
  bool _isBusy = false;
  bool _isTestingConnection = false;
  bool _connectionTested = false;
  bool _connectionOk = false;
  bool _strictLocalMode = false;
  bool _passwordConfigured = false;
  String _language = 'de';
  String? _selectedProviderId;
  String? _providerLoadError;
  String? _passwordError;
  String? _savedProviderRecordId;
  List<ProviderConfig> _providers = const [];

  @override
  void initState() {
    super.initState();
    _loadProviders();
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    _apiKeyController.dispose();
    super.dispose();
  }

  Future<void> _loadProviders() async {
    try {
      final registry = ref.read(modelRegistryProvider);
      await registry.getMergedRegistry();
      final providerMap = registry.getProviders();
      final providers = _providerOrder
          .where(providerMap.containsKey)
          .map((id) => providerMap[id]!)
          .toList();

      if (!mounted) {
        return;
      }

      setState(() {
        _providers = providers;
        _selectedProviderId = providers.isNotEmpty ? providers.first.id : null;
        _providerLoadError = providers.isEmpty
            ? S.of(context)!.setupNoProviderData
            : null;
        _isLoadingProviders = false;
      });
    } catch (e) {
      _log.warning('Failed to load providers', e);
      if (!mounted) {
        return;
      }
      setState(() {
        _providerLoadError = S.of(context)!.setupProviderLoadError;
        _isLoadingProviders = false;
      });
    }
  }

  ProviderConfig? get _selectedProvider {
    final id = _selectedProviderId;
    if (id == null) {
      return null;
    }
    for (final provider in _providers) {
      if (provider.id == id) {
        return provider;
      }
    }
    return null;
  }

  double get _passwordStrength {
    final len = _passwordController.text.length;
    if (len < 8) {
      return 0.2;
    }
    if (len < 12) {
      return 0.55;
    }
    return 1.0;
  }

  Future<void> _handleContinue() async {
    if (_isBusy) {
      return;
    }

    final ok = await _runCurrentStepAction();
    if (!ok || !mounted) {
      return;
    }

    if (_currentStep < 5) {
      setState(() {
        _currentStep += 1;
      });
    }
  }

  Future<bool> _runCurrentStepAction() async {
    switch (_currentStep) {
      case 0:
        return _saveLanguage();
      case 1:
        return _savePassword();
      case 2:
        return _validateProviderStep();
      case 3:
        return _saveProvider();
      case 4:
        return _saveBasicSettings();
      case 5:
        return _finishSetup();
      default:
        return false;
    }
  }

  Future<bool> _saveLanguage() async {
    final db = ref.read(databaseProvider);
    try {
      await db.settingsDao.setValue('language', _language);
      return true;
    } catch (e) {
      _log.warning('Failed to save language', e);
      if (mounted) _showError(S.of(context)!.setupLanguageSaveError);
      return false;
    }
  }

  Future<bool> _savePassword() async {
    final password = _passwordController.text;
    final confirm = _confirmController.text;

    if (password.length < 8) {
      setState(() {
        _passwordError = S.of(context)!.setupMinPasswordLength;
      });
      return false;
    }
    if (password != confirm) {
      setState(() {
        _passwordError = S.of(context)!.setupPasswordMismatch;
      });
      return false;
    }

    setState(() {
      _passwordError = null;
    });

    final db = ref.read(databaseProvider);
    final encryption = ref.read(encryptionProvider);

    try {
      setState(() {
        _isBusy = true;
      });

      final salt = encryption.generateSalt();
      final hash = encryption.hashPassword(password, salt);
      await db.settingsDao.setValue('password_hash', hash);
      await db.settingsDao.setValue('password_salt', base64Encode(salt));
      encryption.unlock(password, salt);

      if (!mounted) {
        return false;
      }

      setState(() {
        _passwordConfigured = true;
      });
      return true;
    } catch (e) {
      _log.warning('Failed to save password', e);
      if (mounted) _showError(S.of(context)!.setupPasswordSaveError);
      return false;
    } finally {
      if (mounted) {
        setState(() {
          _isBusy = false;
        });
      }
    }
  }

  Future<bool> _validateProviderStep() async {
    if (_selectedProvider == null) {
      _showError(S.of(context)!.setupSelectProvider);
      return false;
    }
    return true;
  }

  Future<void> _testConnection() async {
    final provider = _selectedProvider;
    if (provider == null) {
      _showError(S.of(context)!.setupNoProviderSelected);
      return;
    }

    if (!provider.isLocal && _apiKeyController.text.trim().isEmpty) {
      _showError(S.of(context)!.setupEnterApiKey);
      return;
    }

    setState(() {
      _isTestingConnection = true;
      _connectionTested = false;
    });

    try {
      final ok = await _llmApiService.testConnection(
        providerType: provider.type,
        baseUrl: provider.baseUrl,
        apiKey: provider.isLocal ? null : _apiKeyController.text.trim(),
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _connectionTested = true;
        _connectionOk = ok;
      });
    } catch (e) {
      _log.warning('Connection test failed', e);
      if (!mounted) {
        return;
      }
      setState(() {
        _connectionTested = true;
        _connectionOk = false;
      });
    } finally {
      if (mounted) {
        setState(() {
          _isTestingConnection = false;
        });
      }
    }
  }

  Future<bool> _saveProvider() async {
    final provider = _selectedProvider;
    if (provider == null) {
      _showError(S.of(context)!.setupNoProviderSelected);
      return false;
    }
    if (!_connectionTested || !_connectionOk) {
      _showError(S.of(context)!.setupTestConnectionFirst);
      return false;
    }

    final encryption = ref.read(encryptionProvider);
    final db = ref.read(databaseProvider);

    if (!provider.isLocal && _apiKeyController.text.trim().isEmpty) {
      _showError(S.of(context)!.setupEnterApiKey);
      return false;
    }

    try {
      setState(() {
        _isBusy = true;
      });

      final encryptedBlob = provider.isLocal
          ? null
          : encryption.encryptData(_apiKeyController.text.trim());
      final recordId = _savedProviderRecordId ?? const Uuid().v4();

      await db.providersDao.insertProvider(
        ProvidersCompanion(
          id: Value(recordId),
          name: Value(provider.name),
          type: Value(provider.type),
          baseUrl: Value(provider.baseUrl),
          encryptedApiKey: Value(encryptedBlob),
          isEnabled: const Value(true),
          updatedAt: Value(DateTime.now()),
        ),
      );

      if (!mounted) {
        return false;
      }

      setState(() {
        _savedProviderRecordId = recordId;
      });
      return true;
    } catch (e) {
      _log.warning('Failed to save provider', e);
      if (mounted) _showError(S.of(context)!.setupProviderSaveError);
      return false;
    } finally {
      if (mounted) {
        setState(() {
          _isBusy = false;
        });
      }
    }
  }

  Future<bool> _saveBasicSettings() async {
    final db = ref.read(databaseProvider);
    try {
      await db.settingsDao.setValue(
        'strict_local_mode',
        _strictLocalMode ? 'true' : 'false',
      );
      return true;
    } catch (e) {
      _log.warning('Failed to save settings', e);
      if (mounted) _showError(S.of(context)!.setupSettingsSaveError);
      return false;
    }
  }

  Future<bool> _finishSetup() async {
    final db = ref.read(databaseProvider);

    try {
      await db.settingsDao.setValue('setup_complete', 'true');
      if (!mounted) {
        return false;
      }
      ref.invalidate(isSetupCompleteProvider);
      context.go('/projects');
      return true;
    } catch (e) {
      _log.warning('Failed to complete setup', e);
      if (mounted) _showError(S.of(context)!.setupCompleteError);
      return false;
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
    final provider = _selectedProvider;

    return Scaffold(
      appBar: AppBar(title: Text(t.setupTitle)),
      body: Stepper(
        currentStep: _currentStep,
        onStepContinue: _handleContinue,
        onStepCancel: _currentStep == 0
            ? null
            : () {
                setState(() {
                  _currentStep -= 1;
                });
              },
        controlsBuilder: (context, details) {
          final isLast = _currentStep == 5;
          return Row(
            children: [
              FilledButton(
                onPressed: _isBusy ? null : details.onStepContinue,
                child: Text(isLast ? t.setupStartApp : t.actionNext),
              ),
              const SizedBox(width: 12),
              if (_currentStep > 0)
                TextButton(
                  onPressed: _isBusy ? null : details.onStepCancel,
                  child: Text(t.actionBack),
                ),
            ],
          );
        },
        steps: [
          Step(
            title: Text(t.setupStepWelcome),
            isActive: _currentStep >= 0,
            content: StepWelcome(
              language: _language,
              onLanguageChanged: (value) {
                if (value == null) {
                  return;
                }
                setState(() {
                  _language = value;
                });
              },
            ),
          ),
          Step(
            title: Text(t.setupStepPassword),
            isActive: _currentStep >= 1,
            content: StepPassword(
              passwordController: _passwordController,
              confirmController: _confirmController,
              passwordStrength: _passwordStrength,
              errorText: _passwordError,
              onChanged: () {
                setState(() {
                  _passwordError = null;
                });
              },
            ),
          ),
          Step(
            title: Text(t.setupStepProvider),
            isActive: _currentStep >= 2,
            content: StepProvider(
              providers: _providers,
              selectedProviderId: _selectedProviderId,
              onChanged: (value) {
                setState(() {
                  _selectedProviderId = value;
                  _connectionTested = false;
                  _connectionOk = false;
                  _apiKeyController.clear();
                });
              },
              isLoading: _isLoadingProviders,
              errorText: _providerLoadError,
            ),
          ),
          Step(
            title: Text(t.setupStepApiKey),
            isActive: _currentStep >= 3,
            content: StepApiKey(
              isLocalProvider: provider?.isLocal ?? false,
              apiKeyController: _apiKeyController,
              isTesting: _isTestingConnection,
              connectionTested: _connectionTested,
              connectionOk: _connectionOk,
              onTestConnection: _testConnection,
            ),
          ),
          Step(
            title: Text(t.setupStepBasicSettings),
            isActive: _currentStep >= 4,
            content: StepBasicSettings(
              strictLocalMode: _strictLocalMode,
              onChanged: (value) {
                setState(() {
                  _strictLocalMode = value ?? false;
                });
              },
            ),
          ),
          Step(
            title: Text(t.setupStepFinish),
            isActive: _currentStep >= 5,
            content: StepFinish(
              providerName: provider?.name ?? '',
              connectionOk: _connectionOk,
              passwordSet: _passwordConfigured,
            ),
          ),
        ],
      ),
    );
  }
}
