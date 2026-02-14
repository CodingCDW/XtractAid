# XtractAid Model Registry System

## Übersicht

XtractAid verwendet ein **dreistufiges System** für Model-Informationen:

```
┌─────────────────────────────────────────────────────────────┐
│  1. BUNDLED REGISTRY (mit App ausgeliefert)                 │
│     - Bekannte Modelle mit Defaults                         │
│     - Stand: Release-Datum                                  │
└─────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────┐
│  2. REMOTE REGISTRY (optional, auto-update)                 │
│     - GitHub-hosted JSON                                    │
│     - Community-maintained                                  │
│     - Wöchentlicher Check auf Updates                       │
└─────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────┐
│  3. USER OVERRIDES (lokal)                                  │
│     - User kann alles überschreiben                         │
│     - Eigene Modelle hinzufügen                             │
│     - Hat höchste Priorität                                 │
└─────────────────────────────────────────────────────────────┘
```

---

## 1. Registry-Datenformat

### model_registry.json

```json
{
  "$schema": "https://xtractaid.dev/schemas/registry-v1.json",
  "version": "2025.06.01",
  "updated_at": "2025-06-01T12:00:00Z",
  
  "providers": {
    "openai": {
      "name": "OpenAI",
      "base_url": "https://api.openai.com/v1",
      "auth_type": "bearer",
      "models_endpoint": "/models",
      "supports_model_list": true,
      "docs_url": "https://platform.openai.com/docs/models"
    },
    "anthropic": {
      "name": "Anthropic",
      "base_url": "https://api.anthropic.com/v1",
      "auth_type": "x-api-key",
      "supports_model_list": false,
      "docs_url": "https://docs.anthropic.com/en/docs/models-overview"
    },
    "google": {
      "name": "Google AI",
      "base_url": "https://generativelanguage.googleapis.com/v1",
      "auth_type": "query_param",
      "auth_param": "key",
      "models_endpoint": "/models",
      "supports_model_list": true,
      "docs_url": "https://ai.google.dev/models"
    },
    "openrouter": {
      "name": "OpenRouter",
      "base_url": "https://openrouter.ai/api/v1",
      "auth_type": "bearer",
      "models_endpoint": "/models",
      "supports_model_list": true,
      "supports_pricing_api": true,
      "docs_url": "https://openrouter.ai/docs"
    },
    "ollama": {
      "name": "Ollama (Local)",
      "base_url": "http://localhost:11434",
      "auth_type": "none",
      "models_endpoint": "/api/tags",
      "supports_model_list": true,
      "is_local": true
    },
    "lmstudio": {
      "name": "LM Studio (Local)",
      "base_url": "http://localhost:1234/v1",
      "auth_type": "none",
      "models_endpoint": "/models",
      "supports_model_list": true,
      "is_local": true,
      "requires_cli": true,
      "cli_command": "lms"
    }
  },

  "models": {
    
    "gpt-4o": {
      "provider": "openai",
      "display_name": "GPT-4o",
      "description": "Most capable GPT-4 model, multimodal",
      "context_window": 128000,
      "max_output_tokens": 16384,
      "pricing": {
        "input_per_million": 2.50,
        "output_per_million": 10.00,
        "currency": "USD",
        "updated_at": "2025-05-15"
      },
      "capabilities": {
        "chat": true,
        "vision": true,
        "function_calling": true,
        "json_mode": true,
        "streaming": true
      },
      "parameters": {
        "temperature": {
          "supported": true,
          "type": "float",
          "min": 0.0,
          "max": 2.0,
          "default": 1.0
        },
        "max_tokens": {
          "supported": true,
          "type": "integer",
          "min": 1,
          "max": 16384,
          "default": 4096
        },
        "top_p": {
          "supported": true,
          "type": "float",
          "min": 0.0,
          "max": 1.0,
          "default": 1.0
        },
        "reasoning_effort": {
          "supported": false
        }
      },
      "status": "active"
    },

    "gpt-4o-mini": {
      "provider": "openai",
      "display_name": "GPT-4o Mini",
      "description": "Fast, affordable GPT-4 variant",
      "context_window": 128000,
      "max_output_tokens": 16384,
      "pricing": {
        "input_per_million": 0.15,
        "output_per_million": 0.60,
        "currency": "USD",
        "updated_at": "2025-05-15"
      },
      "capabilities": {
        "chat": true,
        "vision": true,
        "function_calling": true,
        "json_mode": true,
        "streaming": true
      },
      "parameters": {
        "temperature": {"supported": true, "type": "float", "min": 0.0, "max": 2.0, "default": 1.0},
        "max_tokens": {"supported": true, "type": "integer", "min": 1, "max": 16384, "default": 4096},
        "top_p": {"supported": true, "type": "float", "min": 0.0, "max": 1.0, "default": 1.0},
        "reasoning_effort": {"supported": false}
      },
      "status": "active"
    },

    "o1": {
      "provider": "openai",
      "display_name": "o1",
      "description": "Advanced reasoning model",
      "context_window": 200000,
      "max_output_tokens": 100000,
      "pricing": {
        "input_per_million": 15.00,
        "output_per_million": 60.00,
        "currency": "USD",
        "updated_at": "2025-05-15"
      },
      "capabilities": {
        "chat": true,
        "vision": true,
        "function_calling": false,
        "json_mode": false,
        "streaming": true,
        "reasoning": true
      },
      "parameters": {
        "temperature": {"supported": false},
        "max_tokens": {"supported": true, "type": "integer", "min": 1, "max": 100000, "default": 16384},
        "top_p": {"supported": false},
        "reasoning_effort": {
          "supported": true,
          "type": "enum",
          "values": ["low", "medium", "high"],
          "default": "medium"
        }
      },
      "notes": "Temperature not supported. Uses internal chain-of-thought. Response may include <think> tags.",
      "status": "active"
    },

    "o1-mini": {
      "provider": "openai",
      "display_name": "o1 Mini",
      "description": "Fast reasoning model",
      "context_window": 128000,
      "max_output_tokens": 65536,
      "pricing": {
        "input_per_million": 3.00,
        "output_per_million": 12.00,
        "currency": "USD",
        "updated_at": "2025-05-15"
      },
      "capabilities": {
        "chat": true,
        "vision": false,
        "function_calling": false,
        "json_mode": false,
        "streaming": true,
        "reasoning": true
      },
      "parameters": {
        "temperature": {"supported": false},
        "max_tokens": {"supported": true, "type": "integer", "min": 1, "max": 65536, "default": 16384},
        "reasoning_effort": {
          "supported": true,
          "type": "enum",
          "values": ["low", "medium", "high"],
          "default": "medium"
        }
      },
      "status": "active"
    },

    "o3-mini": {
      "provider": "openai",
      "display_name": "o3 Mini",
      "description": "Latest compact reasoning model",
      "context_window": 200000,
      "max_output_tokens": 100000,
      "pricing": {
        "input_per_million": 1.10,
        "output_per_million": 4.40,
        "currency": "USD",
        "updated_at": "2025-05-15"
      },
      "capabilities": {
        "chat": true,
        "vision": false,
        "function_calling": true,
        "json_mode": true,
        "streaming": true,
        "reasoning": true
      },
      "parameters": {
        "temperature": {"supported": false},
        "max_tokens": {"supported": true, "type": "integer", "min": 1, "max": 100000, "default": 16384},
        "reasoning_effort": {
          "supported": true,
          "type": "enum",
          "values": ["low", "medium", "high"],
          "default": "medium"
        }
      },
      "status": "active"
    },

    "claude-sonnet-4-20250514": {
      "provider": "anthropic",
      "display_name": "Claude Sonnet 4",
      "description": "Latest Claude model, best balance of speed and capability",
      "context_window": 200000,
      "max_output_tokens": 16384,
      "pricing": {
        "input_per_million": 3.00,
        "output_per_million": 15.00,
        "currency": "USD",
        "updated_at": "2025-05-15"
      },
      "capabilities": {
        "chat": true,
        "vision": true,
        "function_calling": true,
        "json_mode": false,
        "streaming": true,
        "extended_thinking": true
      },
      "parameters": {
        "temperature": {"supported": true, "type": "float", "min": 0.0, "max": 1.0, "default": 1.0},
        "max_tokens": {"supported": true, "type": "integer", "min": 1, "max": 16384, "default": 4096},
        "top_p": {"supported": true, "type": "float", "min": 0.0, "max": 1.0, "default": 1.0},
        "top_k": {"supported": true, "type": "integer", "min": 1, "max": 500, "default": 250}
      },
      "status": "active"
    },

    "claude-3-5-sonnet-20241022": {
      "provider": "anthropic",
      "display_name": "Claude 3.5 Sonnet",
      "description": "Previous generation Claude, still excellent",
      "context_window": 200000,
      "max_output_tokens": 8192,
      "pricing": {
        "input_per_million": 3.00,
        "output_per_million": 15.00,
        "currency": "USD",
        "updated_at": "2025-05-15"
      },
      "capabilities": {
        "chat": true,
        "vision": true,
        "function_calling": true,
        "json_mode": false,
        "streaming": true
      },
      "parameters": {
        "temperature": {"supported": true, "type": "float", "min": 0.0, "max": 1.0, "default": 1.0},
        "max_tokens": {"supported": true, "type": "integer", "min": 1, "max": 8192, "default": 4096},
        "top_p": {"supported": true, "type": "float", "min": 0.0, "max": 1.0, "default": 1.0},
        "top_k": {"supported": true, "type": "integer", "min": 1, "max": 500, "default": 250}
      },
      "status": "active"
    },

    "claude-3-5-haiku-20241022": {
      "provider": "anthropic",
      "display_name": "Claude 3.5 Haiku",
      "description": "Fast and affordable Claude",
      "context_window": 200000,
      "max_output_tokens": 8192,
      "pricing": {
        "input_per_million": 0.80,
        "output_per_million": 4.00,
        "currency": "USD",
        "updated_at": "2025-05-15"
      },
      "capabilities": {
        "chat": true,
        "vision": true,
        "function_calling": true,
        "json_mode": false,
        "streaming": true
      },
      "parameters": {
        "temperature": {"supported": true, "type": "float", "min": 0.0, "max": 1.0, "default": 1.0},
        "max_tokens": {"supported": true, "type": "integer", "min": 1, "max": 8192, "default": 4096},
        "top_p": {"supported": true, "type": "float", "min": 0.0, "max": 1.0, "default": 1.0}
      },
      "status": "active"
    },

    "claude-3-opus-20240229": {
      "provider": "anthropic",
      "display_name": "Claude 3 Opus",
      "description": "Most capable Claude 3 model",
      "context_window": 200000,
      "max_output_tokens": 4096,
      "pricing": {
        "input_per_million": 15.00,
        "output_per_million": 75.00,
        "currency": "USD",
        "updated_at": "2025-05-15"
      },
      "capabilities": {
        "chat": true,
        "vision": true,
        "function_calling": true,
        "json_mode": false,
        "streaming": true
      },
      "parameters": {
        "temperature": {"supported": true, "type": "float", "min": 0.0, "max": 1.0, "default": 1.0},
        "max_tokens": {"supported": true, "type": "integer", "min": 1, "max": 4096, "default": 4096}
      },
      "status": "active"
    },

    "gemini-1.5-pro": {
      "provider": "google",
      "display_name": "Gemini 1.5 Pro",
      "description": "Google's flagship model with 1M context",
      "context_window": 1000000,
      "max_output_tokens": 8192,
      "pricing": {
        "input_per_million": 1.25,
        "output_per_million": 5.00,
        "currency": "USD",
        "updated_at": "2025-05-15",
        "notes": "Prices for prompts >128K tokens are higher"
      },
      "capabilities": {
        "chat": true,
        "vision": true,
        "function_calling": true,
        "json_mode": true,
        "streaming": true
      },
      "parameters": {
        "temperature": {"supported": true, "type": "float", "min": 0.0, "max": 2.0, "default": 1.0},
        "max_tokens": {"supported": true, "type": "integer", "min": 1, "max": 8192, "default": 4096, "api_name": "maxOutputTokens"},
        "top_p": {"supported": true, "type": "float", "min": 0.0, "max": 1.0, "default": 1.0},
        "top_k": {"supported": true, "type": "integer", "min": 1, "max": 40, "default": 40}
      },
      "status": "active"
    },

    "gemini-1.5-flash": {
      "provider": "google",
      "display_name": "Gemini 1.5 Flash",
      "description": "Fast and efficient Gemini variant",
      "context_window": 1000000,
      "max_output_tokens": 8192,
      "pricing": {
        "input_per_million": 0.075,
        "output_per_million": 0.30,
        "currency": "USD",
        "updated_at": "2025-05-15"
      },
      "capabilities": {
        "chat": true,
        "vision": true,
        "function_calling": true,
        "json_mode": true,
        "streaming": true
      },
      "parameters": {
        "temperature": {"supported": true, "type": "float", "min": 0.0, "max": 2.0, "default": 1.0},
        "max_tokens": {"supported": true, "type": "integer", "min": 1, "max": 8192, "default": 4096, "api_name": "maxOutputTokens"}
      },
      "status": "active"
    },

    "gemini-2.0-flash": {
      "provider": "google",
      "display_name": "Gemini 2.0 Flash",
      "description": "Latest Gemini 2.0 model",
      "context_window": 1000000,
      "max_output_tokens": 8192,
      "pricing": {
        "input_per_million": 0.10,
        "output_per_million": 0.40,
        "currency": "USD",
        "updated_at": "2025-05-15"
      },
      "capabilities": {
        "chat": true,
        "vision": true,
        "function_calling": true,
        "json_mode": true,
        "streaming": true
      },
      "parameters": {
        "temperature": {"supported": true, "type": "float", "min": 0.0, "max": 2.0, "default": 1.0},
        "max_tokens": {"supported": true, "type": "integer", "min": 1, "max": 8192, "default": 4096}
      },
      "status": "active"
    }
  },

  "local_model_defaults": {
    "pricing": {
      "input_per_million": 0,
      "output_per_million": 0,
      "currency": "USD"
    },
    "capabilities": {
      "chat": true,
      "vision": false,
      "function_calling": false,
      "json_mode": false,
      "streaming": true
    },
    "parameters": {
      "temperature": {"supported": true, "type": "float", "min": 0.0, "max": 2.0, "default": 0.7},
      "max_tokens": {"supported": true, "type": "integer", "min": 1, "max": 32768, "default": 4096},
      "top_p": {"supported": true, "type": "float", "min": 0.0, "max": 1.0, "default": 1.0}
    }
  }
}
```

---

## 2. Service-Implementierung

### Model Discovery Service

```dart
// lib/services/model_discovery_service.dart

import 'package:dio/dio.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'model_discovery_service.freezed.dart';
part 'model_discovery_service.g.dart';

@freezed
class DiscoveredModel with _$DiscoveredModel {
  const factory DiscoveredModel({
    required String id,
    required String name,
    required String provider,
    @Default(true) bool isFromApi,
  }) = _DiscoveredModel;

  factory DiscoveredModel.fromJson(Map<String, dynamic> json) =>
      _$DiscoveredModelFromJson(json);
}

class ModelDiscoveryService {
  /// Discovers available models from provider APIs.
  final Dio _dio;

  ModelDiscoveryService({Dio? dio}) : _dio = dio ?? Dio();

  /// Fetch available models from OpenAI API.
  Future<List<DiscoveredModel>> discoverOpenAiModels(String apiKey) async {
    final response = await _dio.get(
      'https://api.openai.com/v1/models',
      options: Options(
        headers: {'Authorization': 'Bearer $apiKey'},
        receiveTimeout: const Duration(seconds: 10),
      ),
    );
    final data = response.data as Map<String, dynamic>;
    final models = (data['data'] as List?) ?? [];

    // Filter to chat models only
    const chatPrefixes = ['gpt-', 'o1', 'o3'];
    return models
        .where((m) => chatPrefixes.any((p) => (m['id'] as String).contains(p)))
        .map((m) => DiscoveredModel(
              id: m['id'] as String,
              name: m['id'] as String,
              provider: 'openai',
            ))
        .toList();
  }

  /// Fetch available models from local Ollama instance.
  Future<List<DiscoveredModel>> discoverOllamaModels({
    String baseUrl = 'http://localhost:11434',
  }) async {
    try {
      final response = await _dio.get(
        '$baseUrl/api/tags',
        options: Options(receiveTimeout: const Duration(seconds: 5)),
      );
      final data = response.data as Map<String, dynamic>;
      final models = (data['models'] as List?) ?? [];

      return models
          .map((m) => DiscoveredModel(
                id: m['name'] as String,
                name: m['name'] as String,
                provider: 'ollama',
              ))
          .toList();
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError) return []; // Ollama not running
      rethrow;
    }
  }

  /// Fetch loaded model from LM Studio.
  Future<List<DiscoveredModel>> discoverLmStudioModels({
    String baseUrl = 'http://localhost:1234/v1',
  }) async {
    try {
      final response = await _dio.get(
        '$baseUrl/models',
        options: Options(receiveTimeout: const Duration(seconds: 5)),
      );
      final data = response.data as Map<String, dynamic>;
      final models = (data['data'] as List?) ?? [];

      return models
          .map((m) => DiscoveredModel(
                id: m['id'] as String,
                name: m['id'] as String,
                provider: 'lmstudio',
              ))
          .toList();
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError) return []; // LM Studio not running
      rethrow;
    }
  }

  /// Fetch models from OpenRouter (includes pricing!).
  Future<List<DiscoveredModel>> discoverOpenRouterModels(String apiKey) async {
    final response = await _dio.get(
      'https://openrouter.ai/api/v1/models',
      options: Options(
        headers: {'Authorization': 'Bearer $apiKey'},
        receiveTimeout: const Duration(seconds: 10),
      ),
    );
    final data = response.data as Map<String, dynamic>;
    final models = (data['data'] as List?) ?? [];

    // OpenRouter returns pricing info!
    return models
        .map((m) => DiscoveredModel(
              id: m['id'] as String,
              name: (m['name'] as String?) ?? m['id'] as String,
              provider: 'openrouter',
              // Extra: m['pricing']['prompt'], m['pricing']['completion']
            ))
        .toList();
  }
}
```

### Registry Service

```dart
// lib/services/model_registry_service.dart

import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart' show rootBundle;
import '../data/database/app_database.dart';

const _remoteRegistryUrl =
    'https://raw.githubusercontent.com/xtractaid/model-registry/main/registry.json';
const _cacheDuration = Duration(days: 7);

class ModelRegistryService {
  /// Manages model information from bundled + remote + user sources.
  final AppDatabase _db;
  final Dio _dio;

  Map<String, dynamic> _cache = {};
  DateTime? _cacheUpdated;

  ModelRegistryService({required AppDatabase db, Dio? dio})
      : _db = db,
        _dio = dio ?? Dio();

  /// Load the registry bundled with the app.
  Future<Map<String, dynamic>> getBundledRegistry() async {
    final jsonString = await rootBundle.loadString('assets/model_registry.json');
    return json.decode(jsonString) as Map<String, dynamic>;
  }

  /// Fetch the latest registry from GitHub.
  Future<Map<String, dynamic>?> fetchRemoteRegistry() async {
    try {
      final response = await _dio.get(
        _remoteRegistryUrl,
        options: Options(receiveTimeout: const Duration(seconds: 10)),
      );
      return response.data as Map<String, dynamic>;
    } catch (e) {
      // Network error or invalid response – fall back to bundled
      return null;
    }
  }

  /// Get user-defined model configurations from local DB.
  Future<Map<String, Map<String, dynamic>>> getUserOverrides() async {
    // Query Drift models table for user-added/modified models
    // Returns map of model_id -> override_data
    final rows = await _db.modelsDao.getAllUserOverrides();
    return {for (final r in rows) r.modelId: json.decode(r.overrideJson)};
  }

  /// Get combined registry: bundled + remote + user overrides.
  Future<Map<String, dynamic>> getMergedRegistry({
    bool forceRefresh = false,
  }) async {
    // Check cache
    if (!forceRefresh && _cache.isNotEmpty && _cacheUpdated != null) {
      if (DateTime.now().difference(_cacheUpdated!) < _cacheDuration) {
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
        // Merge: remote overrides bundled
        (registry['providers'] as Map).addAll(remote['providers'] as Map? ?? {});
        (registry['models'] as Map).addAll(remote['models'] as Map? ?? {});
        registry['version'] = remote['version'];
        registry['updated_at'] = remote['updated_at'];
      }
    }

    // Apply user overrides (highest priority)
    final userOverrides = await getUserOverrides();
    final models = registry['models'] as Map<String, dynamic>;
    for (final entry in userOverrides.entries) {
      if (models.containsKey(entry.key)) {
        (models[entry.key] as Map).addAll(entry.value);
      } else {
        models[entry.key] = entry.value;
      }
    }

    // Cache result
    _cache = registry;
    _cacheUpdated = DateTime.now();

    return registry;
  }

  /// Get full info for a specific model.
  Map<String, dynamic>? getModelInfo(String modelId) {
    // Synchronous version using cache
    if (_cache.isEmpty) return null;
    final models = _cache['models'] as Map<String, dynamic>?;
    return models?[modelId] as Map<String, dynamic>?;
  }

  /// Get parameter definitions for a model.
  Map<String, dynamic> getModelParameters(String modelId) {
    final info = getModelInfo(modelId);
    if (info == null) {
      // Return sensible defaults for unknown models
      return {
        'temperature': {'supported': true, 'min': 0.0, 'max': 2.0, 'default': 0.7},
        'max_tokens': {'supported': true, 'min': 1, 'max': 32768, 'default': 4096},
      };
    }
    return (info['parameters'] as Map<String, dynamic>?) ?? {};
  }

  /// Get pricing info for a model.
  Map<String, dynamic> getModelPricing(String modelId) {
    final info = getModelInfo(modelId);
    if (info == null) {
      return {'input_per_million': 0, 'output_per_million': 0, 'currency': 'USD'};
    }
    return (info['pricing'] as Map<String, dynamic>?) ??
        {'input_per_million': 0, 'output_per_million': 0};
  }
}
```

---

## 3. UI-Integration

### Model Selector mit dynamischen Parametern

```dart
// lib/shared/widgets/model_configurator.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/model_registry_provider.dart';

class ModelConfigurator extends ConsumerStatefulWidget {
  final String modelId;
  final ValueChanged<Map<String, dynamic>> onChange;

  const ModelConfigurator({
    super.key,
    required this.modelId,
    required this.onChange,
  });

  @override
  ConsumerState<ModelConfigurator> createState() => _ModelConfiguratorState();
}

class _ModelConfiguratorState extends ConsumerState<ModelConfigurator> {
  Map<String, dynamic> _params = {};

  @override
  void initState() {
    super.initState();
    _initDefaults();
  }

  @override
  void didUpdateWidget(ModelConfigurator old) {
    super.didUpdateWidget(old);
    if (old.modelId != widget.modelId) _initDefaults();
  }

  void _initDefaults() {
    final registry = ref.read(modelRegistryProvider);
    final info = registry.getModelInfo(widget.modelId);
    if (info == null) return;

    final parameters = info['parameters'] as Map<String, dynamic>? ?? {};
    final defaults = <String, dynamic>{};
    for (final entry in parameters.entries) {
      final param = entry.value as Map<String, dynamic>;
      if (param['supported'] == true && param['default'] != null) {
        defaults[entry.key] = param['default'];
      }
    }
    setState(() => _params = defaults);
    widget.onChange(defaults);
  }

  void _handleParamChange(String key, dynamic value) {
    setState(() => _params = {..._params, key: value});
    widget.onChange(_params);
  }

  @override
  Widget build(BuildContext context) {
    final registry = ref.watch(modelRegistryProvider);
    final info = registry.getModelInfo(widget.modelId);
    if (info == null) return const Center(child: CircularProgressIndicator());

    final pricing = info['pricing'] as Map<String, dynamic>? ?? {};
    final contextWindow = info['context_window'] as int? ?? 0;
    final parameters = info['parameters'] as Map<String, dynamic>? ?? {};

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Model Info Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(info['provider'] as String? ?? '',
                style: Theme.of(context).textTheme.bodySmall),
            Text(
              '\$${pricing['input_per_million']}/\$${pricing['output_per_million']} per M tokens',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            Text('${(contextWindow / 1000).toStringAsFixed(0)}K context',
                style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
        const SizedBox(height: 16),

        // Dynamic Parameters
        for (final entry in parameters.entries)
          if ((entry.value as Map)['supported'] == true)
            _buildParameter(context, entry.key, entry.value as Map<String, dynamic>),

        // Warnings for special models
        if (parameters['temperature'] != null &&
            (parameters['temperature'] as Map)['supported'] != true)
          _buildWarning(
            context,
            color: Colors.amber,
            text: 'This model does not support temperature control.',
          ),
        if (parameters['reasoning_effort'] != null &&
            (parameters['reasoning_effort'] as Map)['supported'] == true)
          _buildWarning(
            context,
            color: Colors.blue,
            text: 'This is a reasoning model. Responses may include <think> tags.',
          ),
      ],
    );
  }

  Widget _buildParameter(BuildContext ctx, String key, Map<String, dynamic> param) {
    final label = key.replaceAll('_', ' ');
    final type = param['type'] as String?;

    if (type == 'float' || type == 'integer') {
      final min = (param['min'] as num?)?.toDouble() ?? 0;
      final max = (param['max'] as num?)?.toDouble() ?? 1;
      final current = (_params[key] as num?)?.toDouble() ?? (param['default'] as num?)?.toDouble() ?? min;
      final divisions = type == 'float' ? ((max - min) / 0.1).round() : (max - min).round();

      return Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Column(children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(label, style: Theme.of(ctx).textTheme.titleSmall),
            Text(type == 'float' ? current.toStringAsFixed(1) : current.toInt().toString(),
                style: Theme.of(ctx).textTheme.bodySmall),
          ]),
          Slider(
            value: current.clamp(min, max),
            min: min,
            max: max,
            divisions: divisions > 0 ? divisions : 1,
            onChanged: (v) => _handleParamChange(key, type == 'integer' ? v.round() : v),
          ),
        ]),
      );
    }

    if (type == 'enum') {
      final values = (param['values'] as List?)?.cast<String>() ?? [];
      final current = _params[key] as String? ?? param['default'] as String? ?? values.first;

      return Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: Theme.of(ctx).textTheme.titleSmall),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: current,
            items: values.map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(),
            onChanged: (v) { if (v != null) _handleParamChange(key, v); },
          ),
        ]),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildWarning(BuildContext ctx, {required MaterialColor color, required String text}) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.shade50,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(text, style: TextStyle(fontSize: 12, color: color.shade700)),
    );
  }
}
```

---

## 4. Update-Mechanismus

### Automatische Registry-Updates

```dart
// lib/services/registry_updater_service.dart

import 'dart:async';

class RegistryUpdateResult {
  final bool updateAvailable;
  final String? currentVersion;
  final String? newVersion;
  final List<String> changes;

  const RegistryUpdateResult({
    required this.updateAvailable,
    this.currentVersion,
    this.newVersion,
    this.changes = const [],
  });
}

class RegistryUpdaterService {
  /// Background service to check for registry updates.
  final ModelRegistryService _registry;
  Timer? _timer;
  DateTime? lastCheck;

  RegistryUpdaterService({required ModelRegistryService registry})
      : _registry = registry;

  /// Check if remote registry has updates.
  Future<RegistryUpdateResult> checkForUpdates() async {
    final current = await _registry.getBundledRegistry();
    final remote = await _registry.fetchRemoteRegistry();

    if (remote != null) {
      final remoteVersion = remote['version'] as String? ?? '';
      final localVersion = current['version'] as String? ?? '';
      if (remoteVersion.compareTo(localVersion) > 0) {
        lastCheck = DateTime.now();
        return RegistryUpdateResult(
          updateAvailable: true,
          currentVersion: localVersion,
          newVersion: remoteVersion,
          changes: _diffRegistries(current, remote),
        );
      }
    }
    lastCheck = DateTime.now();
    return const RegistryUpdateResult(updateAvailable: false);
  }

  /// Generate human-readable list of changes.
  List<String> _diffRegistries(Map<String, dynamic> old, Map<String, dynamic> neu) {
    final changes = <String>[];

    final oldModels = (old['models'] as Map<String, dynamic>? ?? {}).keys.toSet();
    final newModels = (neu['models'] as Map<String, dynamic>? ?? {}).keys.toSet();

    final added = newModels.difference(oldModels);
    final removed = oldModels.difference(newModels);

    for (final m in added) {
      changes.add('New model: $m');
    }
    for (final m in removed) {
      changes.add('Removed model: $m');
    }

    // Check for pricing changes
    for (final modelId in oldModels.intersection(newModels)) {
      final oldPricing = (old['models'] as Map)[modelId]['pricing'] ?? {};
      final newPricing = (neu['models'] as Map)[modelId]['pricing'] ?? {};
      if (oldPricing.toString() != newPricing.toString()) {
        changes.add('Pricing updated: $modelId');
      }
    }

    return changes;
  }

  /// Start background update checker (weekly).
  void start() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(days: 7), (_) => checkForUpdates());
  }

  /// Stop background update checker.
  void dispose() {
    _timer?.cancel();
    _timer = null;
  }
}
```

---

## 5. User Override UI

```dart
// lib/features/model_manager/model_manager_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'tabs/discovered_models_tab.dart';
import 'tabs/registry_models_tab.dart';
import 'tabs/custom_models_tab.dart';
import 'widgets/registry_update_banner.dart';

class ModelManagerScreen extends ConsumerWidget {
  const ModelManagerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Model Manager'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Discovered Models'),
              Tab(text: 'Model Registry'),
              Tab(text: 'Custom Models'),
            ],
          ),
        ),
        body: const Column(
          children: [
            // Update notification
            RegistryUpdateBanner(),

            // Tab content
            Expanded(
              child: TabBarView(
                children: [
                  // Models fetched from APIs
                  DiscoveredModelsTab(),
                  // Models from bundled/remote registry
                  RegistryModelsTab(),
                  // User-added models
                  CustomModelsTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

---

## 6. Vorteile dieser Lösung

| Aspekt | Lösung |
|--------|--------|
| **Aktualität** | Remote-Registry wird wöchentlich geprüft |
| **Offline-Fähigkeit** | Bundled Registry funktioniert immer |
| **Flexibilität** | User kann alles überschreiben |
| **Wartbarkeit** | Registry als separate JSON, leicht zu aktualisieren |
| **Discovery** | API-Abfrage wo möglich (OpenAI, Ollama, LM Studio) |
| **Preise** | Bundled + Remote + User Override |
| **Parameter** | Model-spezifisch, UI passt sich an |

---

## 7. GitHub Repository für Registry

Wir sollten ein separates Repo erstellen:

```
github.com/xtractaid/model-registry/
├── registry.json          # Haupt-Registry
├── CHANGELOG.md           # Änderungen dokumentieren
├── CONTRIBUTING.md        # Wie man Updates einreicht
└── .github/
    └── workflows/
        └── validate.yml   # JSON-Validierung bei PRs
```

Community kann PRs für Updates einreichen (neue Modelle, Preisänderungen).
