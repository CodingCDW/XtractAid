import 'dart:math';

import 'package:dio/dio.dart';
import 'package:logging/logging.dart';

import '../core/constants/app_constants.dart';

final _log = Logger('LlmApiService');

/// A single chat message.
class ChatMessage {
  final String role; // system, user, assistant
  final String content;

  const ChatMessage({required this.role, required this.content});

  Map<String, String> toJson() => {'role': role, 'content': content};
}

/// Result of an LLM API call.
class LlmResponse {
  final String content;
  final int inputTokens;
  final int outputTokens;
  final String? finishReason;

  const LlmResponse({
    required this.content,
    this.inputTokens = 0,
    this.outputTokens = 0,
    this.finishReason,
  });
}

/// Service for calling LLM APIs with provider-specific adapters and retry logic.
class LlmApiService {
  final Dio _dio;

  LlmApiService({Dio? dio})
    : _dio =
          dio ??
          Dio(
            BaseOptions(
              connectTimeout: const Duration(seconds: 15),
              sendTimeout: const Duration(seconds: 30),
              receiveTimeout: const Duration(minutes: 5),
            ),
          );

  /// Filters [parameters] to only include keys in [allowedKeys],
  /// optionally remapping key names via [keyRemap]. Null values are skipped.
  static Map<String, dynamic> filterParameters({
    required Map<String, dynamic> parameters,
    required Set<String> allowedKeys,
    Map<String, String> keyRemap = const {},
  }) {
    final result = <String, dynamic>{};
    for (final key in allowedKeys) {
      if (!parameters.containsKey(key)) continue;
      final value = parameters[key];
      if (value == null) continue;
      final outputKey = keyRemap[key] ?? key;
      result[outputKey] = value;
    }
    return result;
  }

  /// Returns a copy of [body] with message arrays replaced by summaries
  /// so we can log parameter keys without dumping the full prompt text.
  static Map<String, dynamic> _sanitizeForLog(Map<String, dynamic> body) {
    final sanitized = Map<String, dynamic>.from(body);
    if (sanitized['messages'] is List) {
      sanitized['messages'] =
          '<${(sanitized['messages'] as List).length} messages>';
    }
    if (sanitized['contents'] is List) {
      sanitized['contents'] =
          '<${(sanitized['contents'] as List).length} contents>';
    }
    return sanitized;
  }

  /// Resolves a parameter value from [parameters] using canonical key + aliases.
  /// Supports dotted aliases (for example `reasoning.effort`).
  static dynamic _getParameter(
    Map<String, dynamic> parameters,
    String key, {
    List<String> aliases = const [],
  }) {
    for (final candidate in <String>[key, ...aliases]) {
      if (parameters.containsKey(candidate)) {
        final direct = parameters[candidate];
        if (direct != null) {
          return direct;
        }
      }
      if (candidate.contains('.')) {
        final dotted = _readDottedValue(parameters, candidate);
        if (dotted != null) {
          return dotted;
        }
      }
    }
    return null;
  }

  static dynamic _readDottedValue(Map<String, dynamic> map, String path) {
    dynamic current = map;
    for (final segment in path.split('.')) {
      if (current is! Map) {
        return null;
      }
      final next = current[segment];
      if (next == null) {
        return null;
      }
      current = next;
    }
    return current;
  }

  /// Call an LLM API with retry logic.
  ///
  /// [providerType]: openai, anthropic, google, openrouter, ollama, lmstudio
  Future<LlmResponse> callLlm({
    required String providerType,
    required String baseUrl,
    required String modelId,
    required List<ChatMessage> messages,
    String? apiKey,
    Map<String, dynamic> parameters = const {},
  }) async {
    Exception? lastError;

    for (var attempt = 0; attempt <= AppConstants.maxRetries; attempt++) {
      try {
        return await _callProvider(
          providerType: providerType,
          baseUrl: baseUrl,
          modelId: modelId,
          messages: messages,
          apiKey: apiKey,
          parameters: parameters,
        );
      } on DioException catch (e) {
        lastError = e;
        final statusCode = e.response?.statusCode;

        if (statusCode == 429) {
          // Rate limit – wait longer
          final waitSeconds =
              AppConstants.rateLimitDelay.inSeconds + (attempt * 10);
          _log.warning(
            'Rate limited (429). Waiting ${waitSeconds}s (attempt ${attempt + 1})',
          );
          await Future.delayed(Duration(seconds: waitSeconds));
          continue;
        }

        if (statusCode != null && statusCode >= 500) {
          // Server error – exponential backoff
          final waitSeconds = pow(2, attempt).toInt();
          _log.warning(
            'Server error ($statusCode). Waiting ${waitSeconds}s (attempt ${attempt + 1})',
          );
          await Future.delayed(Duration(seconds: waitSeconds));
          continue;
        }

        if (e.type == DioExceptionType.connectionTimeout ||
            e.type == DioExceptionType.connectionError) {
          final waitSeconds = pow(2, attempt).toInt();
          _log.warning(
            'Connection error. Waiting ${waitSeconds}s (attempt ${attempt + 1})',
          );
          await Future.delayed(Duration(seconds: waitSeconds));
          continue;
        }

        // Client error (4xx except 429) – don't retry
        _log.severe(
          'Client error ($statusCode) for $providerType model=$modelId. '
          'Response: ${e.response?.data}',
        );
        rethrow;
      }
    }

    throw lastError ??
        Exception('LLM call failed after ${AppConstants.maxRetries} retries');
  }

  Future<LlmResponse> _callProvider({
    required String providerType,
    required String baseUrl,
    required String modelId,
    required List<ChatMessage> messages,
    String? apiKey,
    Map<String, dynamic> parameters = const {},
  }) async {
    switch (providerType) {
      case 'openai':
      case 'openrouter':
      case 'lmstudio':
        return _callOpenAiCompatible(
          baseUrl: baseUrl,
          modelId: modelId,
          messages: messages,
          apiKey: apiKey,
          parameters: parameters,
          isOpenRouter: providerType == 'openrouter',
          isNativeOpenAi: providerType == 'openai',
        );
      case 'anthropic':
        return _callAnthropic(
          baseUrl: baseUrl,
          modelId: modelId,
          messages: messages,
          apiKey: apiKey!,
          parameters: parameters,
        );
      case 'google':
        return _callGoogle(
          baseUrl: baseUrl,
          modelId: modelId,
          messages: messages,
          apiKey: apiKey!,
          parameters: parameters,
        );
      case 'ollama':
        return _callOllama(
          baseUrl: baseUrl,
          modelId: modelId,
          messages: messages,
          parameters: parameters,
        );
      default:
        throw ArgumentError('Unknown provider type: $providerType');
    }
  }

  /// OpenAI-compatible API (OpenAI, OpenRouter, LM Studio).
  Future<LlmResponse> _callOpenAiCompatible({
    required String baseUrl,
    required String modelId,
    required List<ChatMessage> messages,
    String? apiKey,
    Map<String, dynamic> parameters = const {},
    bool isOpenRouter = false,
    bool isNativeOpenAi = false,
  }) async {
    final headers = <String, String>{};
    if (apiKey != null && apiKey.isNotEmpty) {
      headers['Authorization'] = 'Bearer $apiKey';
    }
    if (isOpenRouter) {
      headers['HTTP-Referer'] = 'https://xtractaid.dev';
      headers['X-Title'] = 'XtractAid';
    }

    // Only send parameters the OpenAI Chat Completions API accepts.
    // Native OpenAI remaps max_tokens -> max_completion_tokens for newer models.
    const openAiAllowed = {
      'temperature',
      'max_tokens',
      'top_p',
      'frequency_penalty',
      'presence_penalty',
      'seed',
    };
    final keyRemap = isNativeOpenAi
        ? const {'max_tokens': 'max_completion_tokens'}
        : const <String, String>{};

    final normalizedParameters = <String, dynamic>{};
    final temperature = _getParameter(parameters, 'temperature');
    if (temperature != null) {
      normalizedParameters['temperature'] = temperature;
    }
    final maxTokens = _getParameter(
      parameters,
      'max_tokens',
      aliases: const ['max_output_tokens', 'max_completion_tokens'],
    );
    if (maxTokens != null) {
      normalizedParameters['max_tokens'] = maxTokens;
    }
    final topP = _getParameter(parameters, 'top_p', aliases: const ['topP']);
    if (topP != null) {
      normalizedParameters['top_p'] = topP;
    }
    final frequencyPenalty = _getParameter(
      parameters,
      'frequency_penalty',
      aliases: const ['frequencyPenalty'],
    );
    if (frequencyPenalty != null) {
      normalizedParameters['frequency_penalty'] = frequencyPenalty;
    }
    final presencePenalty = _getParameter(
      parameters,
      'presence_penalty',
      aliases: const ['presencePenalty'],
    );
    if (presencePenalty != null) {
      normalizedParameters['presence_penalty'] = presencePenalty;
    }
    final seed = _getParameter(parameters, 'seed');
    if (seed != null) {
      normalizedParameters['seed'] = seed;
    }

    final filtered = filterParameters(
      parameters: normalizedParameters,
      allowedKeys: openAiAllowed,
      keyRemap: keyRemap,
    );

    final body = <String, dynamic>{
      'model': modelId,
      'messages': messages.map((m) => m.toJson()).toList(),
      ...filtered,
    };

    // reasoning_effort is a special case: only add when not "none"
    // (absence = default = none). Non-reasoning models would reject it.
    final reasoningEffort = _getParameter(
      parameters,
      'reasoning_effort',
      aliases: const ['reasoning.effort'],
    );
    if (reasoningEffort != null &&
        reasoningEffort is String &&
        reasoningEffort != 'none') {
      body['reasoning_effort'] = reasoningEffort;
    }

    _log.fine('OpenAI request body: ${_sanitizeForLog(body)}');

    final response = await _dio.post(
      '$baseUrl/chat/completions',
      data: body,
      options: Options(
        headers: headers,
        connectTimeout: const Duration(seconds: 15),
        sendTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(minutes: 5),
      ),
    );

    final data = response.data as Map<String, dynamic>;
    final choices = data['choices'] as List?;
    if (choices == null || choices.isEmpty) {
      return const LlmResponse(content: '', finishReason: 'empty');
    }
    final choice = choices.first as Map<String, dynamic>;
    final message = choice['message'] as Map<String, dynamic>;
    final usage = data['usage'] as Map<String, dynamic>?;

    return LlmResponse(
      content: message['content'] as String? ?? '',
      inputTokens: usage?['prompt_tokens'] as int? ?? 0,
      outputTokens: usage?['completion_tokens'] as int? ?? 0,
      finishReason: choice['finish_reason'] as String?,
    );
  }

  /// Anthropic Messages API.
  Future<LlmResponse> _callAnthropic({
    required String baseUrl,
    required String modelId,
    required List<ChatMessage> messages,
    required String apiKey,
    Map<String, dynamic> parameters = const {},
  }) async {
    // Separate system message from user/assistant messages
    String? systemPrompt;
    final apiMessages = <Map<String, String>>[];
    for (final m in messages) {
      if (m.role == 'system') {
        systemPrompt = m.content;
      } else {
        apiMessages.add(m.toJson());
      }
    }

    // Only send parameters the Anthropic Messages API accepts.
    const anthropicAllowed = {'temperature', 'max_tokens', 'top_p', 'top_k'};
    final normalizedParameters = <String, dynamic>{};
    final temperature = _getParameter(parameters, 'temperature');
    if (temperature != null) {
      normalizedParameters['temperature'] = temperature;
    }
    final maxTokensParameter = _getParameter(
      parameters,
      'max_tokens',
      aliases: const ['max_output_tokens'],
    );
    if (maxTokensParameter != null) {
      normalizedParameters['max_tokens'] = maxTokensParameter;
    }
    final topP = _getParameter(parameters, 'top_p', aliases: const ['topP']);
    if (topP != null) {
      normalizedParameters['top_p'] = topP;
    }
    final topK = _getParameter(parameters, 'top_k', aliases: const ['topK']);
    if (topK != null) {
      normalizedParameters['top_k'] = topK;
    }

    final filtered = filterParameters(
      parameters: normalizedParameters,
      allowedKeys: anthropicAllowed,
    );

    // max_tokens is required by Anthropic -- always set with fallback.
    final maxTokens = filtered.remove('max_tokens') ?? 4096;

    final body = <String, dynamic>{
      'model': modelId,
      'messages': apiMessages,
      // ignore: use_null_aware_elements
      if (systemPrompt != null) 'system': systemPrompt,
      'max_tokens': maxTokens,
      ...filtered,
    };

    _log.fine('Anthropic request body: ${_sanitizeForLog(body)}');

    final response = await _dio.post(
      '$baseUrl/messages',
      data: body,
      options: Options(
        headers: {
          'x-api-key': apiKey,
          'anthropic-version': '2023-06-01',
          'content-type': 'application/json',
        },
        connectTimeout: const Duration(seconds: 15),
        sendTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(minutes: 5),
      ),
    );

    final data = response.data as Map<String, dynamic>;
    final content = (data['content'] as List)
        .where((c) => c['type'] == 'text')
        .map((c) => c['text'] as String)
        .join('\n');
    final usage = data['usage'] as Map<String, dynamic>?;

    return LlmResponse(
      content: content,
      inputTokens: usage?['input_tokens'] as int? ?? 0,
      outputTokens: usage?['output_tokens'] as int? ?? 0,
      finishReason: data['stop_reason'] as String?,
    );
  }

  /// Google Generative AI API.
  Future<LlmResponse> _callGoogle({
    required String baseUrl,
    required String modelId,
    required List<ChatMessage> messages,
    required String apiKey,
    Map<String, dynamic> parameters = const {},
  }) async {
    // Convert messages to Google format
    final contents = <Map<String, dynamic>>[];
    String? systemInstruction;

    for (final m in messages) {
      if (m.role == 'system') {
        systemInstruction = m.content;
      } else {
        contents.add({
          'role': m.role == 'assistant' ? 'model' : 'user',
          'parts': [
            {'text': m.content},
          ],
        });
      }
    }

    final temperature = _getParameter(parameters, 'temperature');
    final maxTokens = _getParameter(
      parameters,
      'max_tokens',
      aliases: const ['max_output_tokens', 'maxOutputTokens'],
    );
    final topP = _getParameter(parameters, 'top_p', aliases: const ['topP']);
    final topK = _getParameter(parameters, 'top_k', aliases: const ['topK']);

    final body = <String, dynamic>{
      'contents': contents,
      if (systemInstruction != null)
        'systemInstruction': {
          'parts': [
            {'text': systemInstruction},
          ],
        },
      'generationConfig': {
        if (temperature != null) 'temperature': temperature,
        if (maxTokens != null) 'maxOutputTokens': maxTokens,
        if (topP != null) 'topP': topP,
        if (topK != null) 'topK': topK,
      },
    };

    final response = await _dio.post(
      '$baseUrl/models/$modelId:generateContent',
      data: body,
      options: Options(
        headers: {'x-goog-api-key': apiKey},
        connectTimeout: const Duration(seconds: 15),
        sendTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(minutes: 5),
      ),
    );

    final data = response.data as Map<String, dynamic>;
    final candidates = data['candidates'] as List?;
    if (candidates == null || candidates.isEmpty) {
      return const LlmResponse(content: '', finishReason: 'empty');
    }

    final candidate = candidates.first as Map<String, dynamic>;
    final parts =
        (candidate['content'] as Map<String, dynamic>?)?['parts'] as List? ??
        [];
    final text = parts.map((p) => p['text'] as String? ?? '').join();
    final usage = data['usageMetadata'] as Map<String, dynamic>?;

    return LlmResponse(
      content: text,
      inputTokens: usage?['promptTokenCount'] as int? ?? 0,
      outputTokens: usage?['candidatesTokenCount'] as int? ?? 0,
      finishReason: candidate['finishReason'] as String?,
    );
  }

  /// Ollama Chat API.
  Future<LlmResponse> _callOllama({
    required String baseUrl,
    required String modelId,
    required List<ChatMessage> messages,
    Map<String, dynamic> parameters = const {},
  }) async {
    final normalizedBaseUrl = _normalizeOllamaBaseUrl(baseUrl);
    final temperature = _getParameter(parameters, 'temperature');
    final topP = _getParameter(parameters, 'top_p', aliases: const ['topP']);
    final maxTokens = _getParameter(
      parameters,
      'max_tokens',
      aliases: const ['num_predict', 'max_output_tokens'],
    );
    final options = <String, dynamic>{
      if (temperature != null) 'temperature': temperature,
      if (topP != null) 'top_p': topP,
      if (maxTokens != null) 'num_predict': maxTokens,
    };
    final body = <String, dynamic>{
      'model': modelId,
      'messages': messages.map((m) => m.toJson()).toList(),
      'stream': false,
      if (options.isNotEmpty) 'options': options,
    };

    try {
      final response = await _dio.post(
        '$normalizedBaseUrl/api/chat',
        data: body,
        options: Options(
          connectTimeout: const Duration(seconds: 15),
          sendTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(minutes: 10),
        ),
      );

      final data = response.data as Map<String, dynamic>;
      final message = data['message'] as Map<String, dynamic>? ?? {};

      return LlmResponse(
        content: message['content'] as String? ?? '',
        inputTokens: data['prompt_eval_count'] as int? ?? 0,
        outputTokens: data['eval_count'] as int? ?? 0,
        finishReason: data['done'] == true ? 'stop' : null,
      );
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode;
      final missingModel = _extractOllamaMissingModel(e.response?.data);
      if (statusCode == 404 && missingModel != null) {
        throw Exception(
          'Ollama model "$missingModel" not found. '
          'Check `ollama list` and use the exact model tag (for example `gemma3:4b`).',
        );
      }

      // Older Ollama builds may not expose /api/chat yet.
      if (statusCode == 404) {
        _log.warning(
          'Ollama /api/chat returned 404. Falling back to /api/generate.',
        );
        return _callOllamaGenerate(
          baseUrl: normalizedBaseUrl,
          modelId: modelId,
          messages: messages,
          options: options,
        );
      }
      rethrow;
    }
  }

  Future<LlmResponse> _callOllamaGenerate({
    required String baseUrl,
    required String modelId,
    required List<ChatMessage> messages,
    required Map<String, dynamic> options,
  }) async {
    final response = await _dio.post(
      '$baseUrl/api/generate',
      data: {
        'model': modelId,
        'prompt': _messagesToOllamaPrompt(messages),
        'stream': false,
        if (options.isNotEmpty) 'options': options,
      },
      options: Options(
        connectTimeout: const Duration(seconds: 15),
        sendTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(minutes: 10),
      ),
    );

    final data = response.data as Map<String, dynamic>;
    return LlmResponse(
      content: data['response'] as String? ?? '',
      inputTokens: data['prompt_eval_count'] as int? ?? 0,
      outputTokens: data['eval_count'] as int? ?? 0,
      finishReason: data['done'] == true ? 'stop' : null,
    );
  }

  String _normalizeOllamaBaseUrl(String baseUrl) {
    var normalized = baseUrl.trim().replaceAll(RegExp(r'/+$'), '');
    if (normalized.isEmpty) {
      return 'http://localhost:11434';
    }

    const suffixes = <String>[
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
        normalized = normalized.substring(0, normalized.length - suffix.length);
        break;
      }
    }

    return normalized.replaceAll(RegExp(r'/+$'), '');
  }

  String? _extractOllamaMissingModel(dynamic responseData) {
    String? errorMessage;
    if (responseData is Map && responseData['error'] is String) {
      errorMessage = responseData['error'] as String;
    } else if (responseData is String) {
      errorMessage = responseData;
    }
    if (errorMessage == null) {
      return null;
    }

    final match = RegExp(
      r'''model\s+["']?([^"']+)["']?\s+not\s+found''',
      caseSensitive: false,
    ).firstMatch(errorMessage);
    return match?.group(1);
  }

  String _messagesToOllamaPrompt(List<ChatMessage> messages) {
    final buffer = StringBuffer();
    for (final message in messages) {
      final role = switch (message.role) {
        'system' => 'System',
        'assistant' => 'Assistant',
        _ => 'User',
      };
      if (buffer.isNotEmpty) {
        buffer.writeln();
      }
      buffer.writeln('$role: ${message.content}');
    }
    if (buffer.isNotEmpty) {
      buffer.writeln();
    }
    buffer.write('Assistant:');
    return buffer.toString();
  }

  /// Test connectivity to a provider by making a lightweight API call.
  Future<bool> testConnection({
    required String providerType,
    required String baseUrl,
    String? apiKey,
  }) async {
    try {
      switch (providerType) {
        case 'openai':
        case 'openrouter':
          final headers = <String, String>{};
          if (apiKey != null) headers['Authorization'] = 'Bearer $apiKey';
          await _dio.get(
            '$baseUrl/models',
            options: Options(
              headers: headers,
              connectTimeout: const Duration(seconds: 10),
              sendTimeout: const Duration(seconds: 10),
              receiveTimeout: const Duration(seconds: 10),
            ),
          );
          return true;
        case 'anthropic':
          // Anthropic doesn't have a /models endpoint, so we send a minimal request
          // that will fail with auth error if key is wrong, but succeed in connecting
          await _dio.post(
            '$baseUrl/messages',
            data: {
              'model': 'claude-haiku-4-5-20251001',
              'max_tokens': 1,
              'messages': [
                {'role': 'user', 'content': 'hi'},
              ],
            },
            options: Options(
              headers: {
                'x-api-key': apiKey ?? '',
                'anthropic-version': '2023-06-01',
              },
              connectTimeout: const Duration(seconds: 10),
              sendTimeout: const Duration(seconds: 10),
              receiveTimeout: const Duration(seconds: 10),
            ),
          );
          return true;
        case 'google':
          await _dio.get(
            '$baseUrl/models',
            options: Options(
              headers: {'x-goog-api-key': apiKey ?? ''},
              connectTimeout: const Duration(seconds: 10),
              sendTimeout: const Duration(seconds: 10),
              receiveTimeout: const Duration(seconds: 10),
            ),
          );
          return true;
        case 'ollama':
          final normalizedBaseUrl = _normalizeOllamaBaseUrl(baseUrl);
          await _dio.get(
            '$normalizedBaseUrl/api/tags',
            options: Options(
              connectTimeout: const Duration(seconds: 5),
              sendTimeout: const Duration(seconds: 5),
              receiveTimeout: const Duration(seconds: 5),
            ),
          );
          return true;
        case 'lmstudio':
          await _dio.get(
            '$baseUrl/models',
            options: Options(
              connectTimeout: const Duration(seconds: 5),
              sendTimeout: const Duration(seconds: 5),
              receiveTimeout: const Duration(seconds: 5),
            ),
          );
          return true;
        default:
          return false;
      }
    } on DioException catch (e) {
      // For Anthropic, a 401 means we connected but key is bad
      // A 200 or 400 means connection works
      if (providerType == 'anthropic' && e.response?.statusCode != null) {
        return true; // Connection works, even if auth fails
      }
      return false;
    }
  }
}
