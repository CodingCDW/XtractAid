import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:logging/logging.dart';

import '../core/constants/app_constants.dart';
import '../data/database/app_database.dart';
import '../data/models/model_info.dart';
import '../data/models/provider_config.dart';

/// Manages model information from bundled + remote + user sources.
///
/// Priority: Bundled < Remote < User Overrides
class ModelRegistryService {
  static final _log = Logger('ModelRegistryService');
  // M7: In-memory cache TTL (1 hour) separate from remote fetch interval
  static const Duration _inMemoryCacheTtl = Duration(hours: 1);
  static const Duration _remoteFailureLogCooldown = Duration(minutes: 10);
  static const Duration _remoteFailureRetryInterval = Duration(minutes: 15);
  final AppDatabase _db;
  final Dio _dio;

  Map<String, dynamic> _cache = {};
  DateTime? _cacheUpdated;
  DateTime? _remoteCacheUpdated;
  Map<String, dynamic>? _remoteCache;
  String? _lastRemoteFailureSignature;
  DateTime? _lastRemoteFailureLoggedAt;

  ModelRegistryService({required AppDatabase db, Dio? dio})
    : _db = db,
      _dio = dio ?? Dio();

  /// Whether the registry has been loaded.
  bool get isLoaded => _cache.isNotEmpty;

  /// Clears in-memory cache so the next read re-merges bundled/remote/user data.
  void clearCache() {
    _cache = {};
    _cacheUpdated = null;
  }

  /// Load the registry bundled with the app.
  Future<Map<String, dynamic>> getBundledRegistry() async {
    final jsonString = await rootBundle.loadString(
      'assets/model_registry.json',
    );
    return json.decode(jsonString) as Map<String, dynamic>;
  }

  /// Fetch the latest registry from GitHub.
  Future<Map<String, dynamic>?> fetchRemoteRegistry() async {
    if (_remoteCacheUpdated != null &&
        DateTime.now().difference(_remoteCacheUpdated!) <
            (_remoteCache == null
                ? _remoteFailureRetryInterval
                : AppConstants.registryCacheDuration)) {
      return _remoteCache;
    }

    final attempts = <String>[];
    var sawNon404Failure = false;
    for (final url in AppConstants.remoteRegistryUrls) {
      try {
        final response = await _dio.get(
          url,
          options: Options(receiveTimeout: const Duration(seconds: 10)),
        );
        final data = response.data;
        if (data is Map<String, dynamic>) {
          _remoteCache = data;
          _remoteCacheUpdated = DateTime.now();
          return data;
        }
        attempts.add('$url -> invalid JSON payload');
      } on DioException catch (e) {
        final status = e.response?.statusCode;
        final statusLabel = status != null ? 'HTTP $status' : e.type.name;
        attempts.add('$url -> $statusLabel');
        if (status != 404) {
          sawNon404Failure = true;
        }
      } catch (e) {
        attempts.add('$url -> $e');
        sawNon404Failure = true;
      }
    }

    _remoteCache = null;
    _remoteCacheUpdated = DateTime.now();
    final signature = attempts.join(' | ');
    if (sawNon404Failure) {
      _logRemoteFailure(signature);
    } else {
      _log.info('Remote registry not available (optional): $signature');
    }
    return null;
  }

  void _logRemoteFailure(String signature) {
    final now = DateTime.now();
    final sameFailure = _lastRemoteFailureSignature == signature;
    final withinCooldown =
        _lastRemoteFailureLoggedAt != null &&
        now.difference(_lastRemoteFailureLoggedAt!) < _remoteFailureLogCooldown;
    if (sameFailure && withinCooldown) {
      return;
    }
    _lastRemoteFailureSignature = signature;
    _lastRemoteFailureLoggedAt = now;
    _log.warning('Failed to fetch remote registry: $signature');
  }

  /// Get user-defined model configurations from local DB.
  Future<Map<String, Map<String, dynamic>>> getUserOverrides() async {
    final rows = await _db.modelsDao.getAllUserOverrides();
    return {
      for (final r in rows)
        r.modelId: json.decode(r.overrideJson) as Map<String, dynamic>,
    };
  }

  /// Get combined registry: bundled + remote + user overrides.
  Future<Map<String, dynamic>> getMergedRegistry({
    bool forceRefresh = false,
  }) async {
    // Check cache
    if (!forceRefresh && _cache.isNotEmpty && _cacheUpdated != null) {
      if (DateTime.now().difference(_cacheUpdated!) < _inMemoryCacheTtl) {
        return _cache;
      }
    }

    // Start with bundled
    final registry = await getBundledRegistry();

    // Try to get remote updates
    final remote = await fetchRemoteRegistry();
    if (remote != null) {
      final remoteVersion = remote['version'] as String? ?? '';
      final localVersion = registry['version'] as String? ?? '';
      if (remoteVersion.compareTo(localVersion) > 0) {
        final localProviders = registry['providers'];
        final remoteProviders = remote['providers'];
        if (localProviders is Map && remoteProviders is Map) {
          localProviders.addAll(remoteProviders);
        }
        final localModels = registry['models'];
        final remoteModels = remote['models'];
        if (localModels is Map && remoteModels is Map) {
          localModels.addAll(remoteModels);
        }
        registry['version'] = remote['version'];
        registry['updated_at'] = remote['updated_at'];
      }
    }

    // Apply user overrides (highest priority)
    final userOverrides = await getUserOverrides();
    final modelsRaw = registry['models'];
    final models = modelsRaw is Map<String, dynamic>
        ? modelsRaw
        : <String, dynamic>{};
    if (modelsRaw is! Map) {
      registry['models'] = models;
    }
    for (final entry in userOverrides.entries) {
      final existing = models[entry.key];
      if (existing is Map<String, dynamic>) {
        existing.addAll(entry.value);
      } else {
        models[entry.key] = entry.value;
      }
    }

    _cache = registry;
    _cacheUpdated = DateTime.now();
    return registry;
  }

  /// Get all provider configurations.
  Map<String, ProviderConfig> getProviders() {
    final providers = _cache['providers'] as Map<String, dynamic>? ?? {};
    return providers.map((key, value) {
      final v = value as Map<String, dynamic>;
      return MapEntry(
        key,
        ProviderConfig(
          id: key,
          name: v['name'] as String? ?? key,
          type: key,
          baseUrl: v['base_url'] as String? ?? '',
          authType: v['auth_type'] as String? ?? 'bearer',
          modelsEndpoint: v['models_endpoint'] as String?,
          isLocal: v['is_local'] as bool? ?? false,
        ),
      );
    });
  }

  /// Get all model IDs.
  List<String> getModelIds() {
    final models = _cache['models'] as Map<String, dynamic>? ?? {};
    return models.keys.toList();
  }

  /// Get models grouped by provider.
  Map<String, List<String>> getModelsByProvider() {
    final models = _cache['models'] as Map<String, dynamic>? ?? {};
    final result = <String, List<String>>{};
    for (final entry in models.entries) {
      final provider =
          (entry.value as Map<String, dynamic>)['provider'] as String? ?? '';
      result.putIfAbsent(provider, () => []).add(entry.key);
    }
    return result;
  }

  /// Get full info for a specific model as raw map.
  Map<String, dynamic>? getModelInfoRaw(String modelId) {
    final models = _cache['models'] as Map<String, dynamic>?;
    return models?[modelId] as Map<String, dynamic>?;
  }

  /// Get typed ModelInfo for a specific model.
  ModelInfo? getModelInfo(String modelId) {
    final raw = getModelInfoRaw(modelId);
    if (raw == null) return null;

    final pricing = raw['pricing'] as Map<String, dynamic>? ?? {};
    final capabilities = raw['capabilities'] as Map<String, dynamic>? ?? {};
    final params = raw['parameters'] as Map<String, dynamic>? ?? {};

    return ModelInfo(
      id: modelId,
      provider: raw['provider'] as String? ?? '',
      displayName: raw['display_name'] as String? ?? modelId,
      description: raw['description'] as String? ?? '',
      contextWindow: raw['context_window'] as int? ?? 0,
      maxOutputTokens: raw['max_output_tokens'] as int? ?? 4096,
      pricing: ModelPricing(
        inputPerMillion:
            (pricing['input_per_million'] as num?)?.toDouble() ?? 0,
        outputPerMillion:
            (pricing['output_per_million'] as num?)?.toDouble() ?? 0,
        currency: pricing['currency'] as String? ?? 'USD',
      ),
      capabilities: ModelCapabilities(
        chat: capabilities['chat'] as bool? ?? true,
        vision: capabilities['vision'] as bool? ?? false,
        functionCalling: capabilities['function_calling'] as bool? ?? false,
        jsonMode: capabilities['json_mode'] as bool? ?? false,
        streaming: capabilities['streaming'] as bool? ?? true,
        reasoning: capabilities['reasoning'] as bool? ?? false,
        extendedThinking: capabilities['extended_thinking'] as bool? ?? false,
      ),
      parameters: params.map((key, value) {
        final p = value as Map<String, dynamic>;
        return MapEntry(
          key,
          ModelParameter(
            supported: p['supported'] as bool? ?? false,
            type: p['type'] as String?,
            min: (p['min'] as num?)?.toDouble(),
            max: (p['max'] as num?)?.toDouble(),
            defaultValue: p['default'],
            values: (p['values'] as List?)?.cast<String>(),
            apiName: p['api_name'] as String?,
          ),
        );
      }),
      notes: raw['notes'] as String?,
      status: raw['status'] as String? ?? 'active',
    );
  }

  /// Get parameter definitions for a model.
  Map<String, ModelParameter> getModelParameters(String modelId) {
    final info = getModelInfo(modelId);
    if (info == null) {
      return {
        'temperature': const ModelParameter(
          supported: true,
          type: 'float',
          min: 0.0,
          max: 2.0,
          defaultValue: 0.7,
        ),
        'max_tokens': const ModelParameter(
          supported: true,
          type: 'integer',
          min: 1,
          max: 32768,
          defaultValue: 4096,
        ),
      };
    }
    return info.parameters;
  }

  /// Get pricing info for a model.
  ModelPricing getModelPricing(String modelId) {
    final info = getModelInfo(modelId);
    return info?.pricing ?? const ModelPricing();
  }

  /// Get default parameters for local models (Ollama, LM Studio).
  Map<String, dynamic> getLocalModelDefaults() {
    return _cache['local_model_defaults'] as Map<String, dynamic>? ?? {};
  }
}
