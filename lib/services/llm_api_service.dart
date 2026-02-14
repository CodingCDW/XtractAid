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

  LlmApiService({Dio? dio}) : _dio = dio ?? Dio();

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
          final waitSeconds = AppConstants.rateLimitDelay.inSeconds +
              (attempt * 10);
          _log.warning('Rate limited (429). Waiting ${waitSeconds}s (attempt ${attempt + 1})');
          await Future.delayed(Duration(seconds: waitSeconds));
          continue;
        }

        if (statusCode != null && statusCode >= 500) {
          // Server error – exponential backoff
          final waitSeconds = pow(2, attempt).toInt();
          _log.warning('Server error ($statusCode). Waiting ${waitSeconds}s (attempt ${attempt + 1})');
          await Future.delayed(Duration(seconds: waitSeconds));
          continue;
        }

        if (e.type == DioExceptionType.connectionTimeout ||
            e.type == DioExceptionType.connectionError) {
          final waitSeconds = pow(2, attempt).toInt();
          _log.warning('Connection error. Waiting ${waitSeconds}s (attempt ${attempt + 1})');
          await Future.delayed(Duration(seconds: waitSeconds));
          continue;
        }

        // Client error (4xx except 429) – don't retry
        rethrow;
      }
    }

    throw lastError ?? Exception('LLM call failed after ${AppConstants.maxRetries} retries');
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
  }) async {
    final headers = <String, String>{};
    if (apiKey != null && apiKey.isNotEmpty) {
      headers['Authorization'] = 'Bearer $apiKey';
    }
    if (isOpenRouter) {
      headers['HTTP-Referer'] = 'https://xtractaid.dev';
      headers['X-Title'] = 'XtractAid';
    }

    final body = <String, dynamic>{
      'model': modelId,
      'messages': messages.map((m) => m.toJson()).toList(),
      ...parameters,
    };

    final response = await _dio.post(
      '$baseUrl/chat/completions',
      data: body,
      options: Options(
        headers: headers,
        receiveTimeout: const Duration(minutes: 5),
      ),
    );

    final data = response.data as Map<String, dynamic>;
    final choice = (data['choices'] as List).first as Map<String, dynamic>;
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

    final body = <String, dynamic>{
      'model': modelId,
      'messages': apiMessages,
      // ignore: use_null_aware_elements
      if (systemPrompt != null) 'system': systemPrompt,
      'max_tokens': parameters['max_tokens'] ?? 4096,
      ...parameters,
    };
    // Remove max_tokens from spread if already set
    body['max_tokens'] = parameters['max_tokens'] ?? 4096;

    final response = await _dio.post(
      '$baseUrl/messages',
      data: body,
      options: Options(
        headers: {
          'x-api-key': apiKey,
          'anthropic-version': '2023-06-01',
          'content-type': 'application/json',
        },
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
            {'text': m.content}
          ],
        });
      }
    }

    final body = <String, dynamic>{
      'contents': contents,
      if (systemInstruction != null)
        'systemInstruction': {
          'parts': [
            {'text': systemInstruction}
          ]
        },
      'generationConfig': {
        if (parameters.containsKey('temperature'))
          'temperature': parameters['temperature'],
        if (parameters.containsKey('max_tokens'))
          'maxOutputTokens': parameters['max_tokens'],
        if (parameters.containsKey('top_p')) 'topP': parameters['top_p'],
        if (parameters.containsKey('top_k')) 'topK': parameters['top_k'],
      },
    };

    final response = await _dio.post(
      '$baseUrl/models/$modelId:generateContent?key=$apiKey',
      data: body,
      options: Options(receiveTimeout: const Duration(minutes: 5)),
    );

    final data = response.data as Map<String, dynamic>;
    final candidates = data['candidates'] as List?;
    if (candidates == null || candidates.isEmpty) {
      return const LlmResponse(content: '', finishReason: 'empty');
    }

    final candidate = candidates.first as Map<String, dynamic>;
    final parts = (candidate['content'] as Map<String, dynamic>?)?['parts'] as List? ?? [];
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
    final body = <String, dynamic>{
      'model': modelId,
      'messages': messages.map((m) => m.toJson()).toList(),
      'stream': false,
      if (parameters.isNotEmpty)
        'options': {
          if (parameters.containsKey('temperature'))
            'temperature': parameters['temperature'],
          if (parameters.containsKey('top_p'))
            'top_p': parameters['top_p'],
          if (parameters.containsKey('max_tokens'))
            'num_predict': parameters['max_tokens'],
        },
    };

    final response = await _dio.post(
      '$baseUrl/api/chat',
      data: body,
      options: Options(receiveTimeout: const Duration(minutes: 10)),
    );

    final data = response.data as Map<String, dynamic>;
    final message = data['message'] as Map<String, dynamic>? ?? {};

    return LlmResponse(
      content: message['content'] as String? ?? '',
      inputTokens: data['prompt_eval_count'] as int? ?? 0,
      outputTokens: data['eval_count'] as int? ?? 0,
      finishReason: data['done'] == true ? 'stop' : null,
    );
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
              'model': 'claude-3-5-haiku-20241022',
              'max_tokens': 1,
              'messages': [
                {'role': 'user', 'content': 'hi'}
              ],
            },
            options: Options(
              headers: {
                'x-api-key': apiKey ?? '',
                'anthropic-version': '2023-06-01',
              },
              receiveTimeout: const Duration(seconds: 10),
            ),
          );
          return true;
        case 'google':
          await _dio.get(
            '$baseUrl/models?key=$apiKey',
            options: Options(receiveTimeout: const Duration(seconds: 10)),
          );
          return true;
        case 'ollama':
          await _dio.get(
            '$baseUrl/api/tags',
            options: Options(receiveTimeout: const Duration(seconds: 5)),
          );
          return true;
        case 'lmstudio':
          await _dio.get(
            '$baseUrl/models',
            options: Options(receiveTimeout: const Duration(seconds: 5)),
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
