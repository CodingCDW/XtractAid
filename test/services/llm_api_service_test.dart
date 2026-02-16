import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xtractaid/services/llm_api_service.dart';

/// Interceptor that captures the request body and returns a fake response,
/// so we can verify what parameters get sent to each provider.
class _CaptureInterceptor extends Interceptor {
  Map<String, dynamic>? capturedBody;
  final Map<String, dynamic> Function(RequestOptions) fakeResponse;

  _CaptureInterceptor({required this.fakeResponse});

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    capturedBody = options.data is Map<String, dynamic>
        ? Map<String, dynamic>.from(options.data as Map<String, dynamic>)
        : null;
    handler.resolve(
      Response(
        requestOptions: options,
        statusCode: 200,
        data: fakeResponse(options),
      ),
    );
  }
}

/// Standard fake responses for each provider format.
Map<String, dynamic> _openAiResponse(RequestOptions _) => {
  'choices': [
    {
      'message': {'role': 'assistant', 'content': 'hello'},
      'finish_reason': 'stop',
    },
  ],
  'usage': {'prompt_tokens': 10, 'completion_tokens': 5},
};

Map<String, dynamic> _anthropicResponse(RequestOptions _) => {
  'content': [
    {'type': 'text', 'text': 'hello'},
  ],
  'usage': {'input_tokens': 10, 'output_tokens': 5},
  'stop_reason': 'end_turn',
};

class _OllamaPathInterceptor extends Interceptor {
  _OllamaPathInterceptor({
    required this.chatStatusCode,
    this.chatErrorPayload = const {'error': 'not found'},
  });

  final int chatStatusCode;
  final dynamic chatErrorPayload;
  final List<String> paths = <String>[];

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    paths.add(options.path);

    if (options.path.endsWith('/api/chat')) {
      if (chatStatusCode == 200) {
        handler.resolve(
          Response(
            requestOptions: options,
            statusCode: 200,
            data: {
              'message': {'role': 'assistant', 'content': 'chat ok'},
              'prompt_eval_count': 7,
              'eval_count': 3,
              'done': true,
            },
          ),
        );
        return;
      }
      handler.reject(
        DioException(
          requestOptions: options,
          response: Response(
            requestOptions: options,
            statusCode: chatStatusCode,
            data: chatErrorPayload,
          ),
          type: DioExceptionType.badResponse,
        ),
      );
      return;
    }

    if (options.path.endsWith('/api/generate')) {
      handler.resolve(
        Response(
          requestOptions: options,
          statusCode: 200,
          data: {
            'response': 'generate ok',
            'prompt_eval_count': 9,
            'eval_count': 4,
            'done': true,
          },
        ),
      );
      return;
    }

    handler.reject(
      DioException(
        requestOptions: options,
        response: Response(
          requestOptions: options,
          statusCode: 404,
          data: {'error': 'unexpected path ${options.path}'},
        ),
        type: DioExceptionType.badResponse,
      ),
    );
  }
}

void main() {
  group('LlmApiService.filterParameters', () {
    test('only allows keys in the allowlist', () {
      final result = LlmApiService.filterParameters(
        parameters: {
          'temperature': 0.7,
          'max_tokens': 1024,
          'reasoning_effort': 'high',
          'unknown_param': 'bad',
        },
        allowedKeys: {'temperature', 'max_tokens'},
      );

      expect(result, {'temperature': 0.7, 'max_tokens': 1024});
      expect(result.containsKey('reasoning_effort'), false);
      expect(result.containsKey('unknown_param'), false);
    });

    test('remaps keys via keyRemap', () {
      final result = LlmApiService.filterParameters(
        parameters: {'max_tokens': 4096, 'temperature': 0.5},
        allowedKeys: {'max_tokens', 'temperature'},
        keyRemap: {'max_tokens': 'max_completion_tokens'},
      );

      expect(result['max_completion_tokens'], 4096);
      expect(result.containsKey('max_tokens'), false);
      expect(result['temperature'], 0.5);
    });

    test('skips null values', () {
      final result = LlmApiService.filterParameters(
        parameters: {'temperature': null, 'max_tokens': 1024},
        allowedKeys: {'temperature', 'max_tokens'},
      );

      expect(result, {'max_tokens': 1024});
      expect(result.containsKey('temperature'), false);
    });

    test('skips keys not present in parameters', () {
      final result = LlmApiService.filterParameters(
        parameters: {'temperature': 0.5},
        allowedKeys: {'temperature', 'max_tokens', 'top_p'},
      );

      expect(result, {'temperature': 0.5});
      expect(result.length, 1);
    });

    test('returns empty map when no keys match', () {
      final result = LlmApiService.filterParameters(
        parameters: {'reasoning_effort': 'high'},
        allowedKeys: {'temperature', 'max_tokens'},
      );

      expect(result, isEmpty);
    });
  });

  group('OpenAI parameter filtering', () {
    late _CaptureInterceptor interceptor;
    late LlmApiService service;

    setUp(() {
      interceptor = _CaptureInterceptor(fakeResponse: _openAiResponse);
      final dio = Dio()..interceptors.add(interceptor);
      service = LlmApiService(dio: dio);
    });

    test('filters out unknown parameters like reasoning_effort=none', () async {
      await service.callLlm(
        providerType: 'openai',
        baseUrl: 'http://fake',
        modelId: 'gpt-4o',
        messages: [const ChatMessage(role: 'user', content: 'hi')],
        apiKey: 'sk-test',
        parameters: {
          'temperature': 1.0,
          'max_tokens': 4096,
          'top_p': 1.0,
          'reasoning_effort': 'none',
        },
      );

      final body = interceptor.capturedBody!;
      expect(
        body.containsKey('reasoning_effort'),
        false,
        reason: 'reasoning_effort=none should be excluded',
      );
    });

    test('includes reasoning_effort when not "none"', () async {
      await service.callLlm(
        providerType: 'openai',
        baseUrl: 'http://fake',
        modelId: 'o1',
        messages: [const ChatMessage(role: 'user', content: 'hi')],
        apiKey: 'sk-test',
        parameters: {
          'temperature': 1.0,
          'max_tokens': 16384,
          'reasoning_effort': 'high',
        },
      );

      final body = interceptor.capturedBody!;
      expect(body['reasoning_effort'], 'high');
    });

    test(
      'remaps max_tokens to max_completion_tokens for native OpenAI',
      () async {
        await service.callLlm(
          providerType: 'openai',
          baseUrl: 'http://fake',
          modelId: 'gpt-5.2',
          messages: [const ChatMessage(role: 'user', content: 'hi')],
          apiKey: 'sk-test',
          parameters: {'max_tokens': 4096, 'temperature': 0.7},
        );

        final body = interceptor.capturedBody!;
        expect(body['max_completion_tokens'], 4096);
        expect(
          body.containsKey('max_tokens'),
          false,
          reason: 'Native OpenAI should remap max_tokens',
        );
      },
    );

    test('accepts max_output_tokens alias for native OpenAI', () async {
      await service.callLlm(
        providerType: 'openai',
        baseUrl: 'http://fake',
        modelId: 'gpt-5.2',
        messages: [const ChatMessage(role: 'user', content: 'hi')],
        apiKey: 'sk-test',
        parameters: {'max_output_tokens': 2048, 'temperature': 0.7},
      );

      final body = interceptor.capturedBody!;
      expect(body['max_completion_tokens'], 2048);
      expect(body.containsKey('max_tokens'), false);
    });

    test('accepts dotted reasoning.effort alias', () async {
      await service.callLlm(
        providerType: 'openai',
        baseUrl: 'http://fake',
        modelId: 'gpt-5.2',
        messages: [const ChatMessage(role: 'user', content: 'hi')],
        apiKey: 'sk-test',
        parameters: {
          'max_tokens': 1024,
          'reasoning': {'effort': 'high'},
        },
      );

      final body = interceptor.capturedBody!;
      expect(body['reasoning_effort'], 'high');
    });

    test('keeps max_tokens for OpenRouter (no remap)', () async {
      await service.callLlm(
        providerType: 'openrouter',
        baseUrl: 'http://fake',
        modelId: 'openai/gpt-5.2',
        messages: [const ChatMessage(role: 'user', content: 'hi')],
        apiKey: 'sk-test',
        parameters: {'max_tokens': 4096, 'temperature': 0.7},
      );

      final body = interceptor.capturedBody!;
      expect(body['max_tokens'], 4096);
      expect(
        body.containsKey('max_completion_tokens'),
        false,
        reason: 'OpenRouter should keep max_tokens',
      );
    });

    test('does not include unsupported parameters', () async {
      await service.callLlm(
        providerType: 'openai',
        baseUrl: 'http://fake',
        modelId: 'gpt-4o',
        messages: [const ChatMessage(role: 'user', content: 'hi')],
        apiKey: 'sk-test',
        parameters: {'temperature': 0.5, 'top_k': 40, 'custom_param': 'value'},
      );

      final body = interceptor.capturedBody!;
      expect(body['temperature'], 0.5);
      expect(
        body.containsKey('top_k'),
        false,
        reason: 'top_k is not in the OpenAI allowlist',
      );
      expect(body.containsKey('custom_param'), false);
    });
  });

  group('Anthropic parameter filtering', () {
    late _CaptureInterceptor interceptor;
    late LlmApiService service;

    setUp(() {
      interceptor = _CaptureInterceptor(fakeResponse: _anthropicResponse);
      final dio = Dio()..interceptors.add(interceptor);
      service = LlmApiService(dio: dio);
    });

    test('filters out unknown parameters', () async {
      await service.callLlm(
        providerType: 'anthropic',
        baseUrl: 'http://fake',
        modelId: 'claude-sonnet-4-20250514',
        messages: [const ChatMessage(role: 'user', content: 'hi')],
        apiKey: 'sk-ant-test',
        parameters: {
          'temperature': 0.8,
          'max_tokens': 4096,
          'top_p': 0.9,
          'top_k': 250,
          'reasoning_effort': 'high',
          'frequency_penalty': 0.5,
        },
      );

      final body = interceptor.capturedBody!;
      expect(body['temperature'], 0.8);
      expect(body['max_tokens'], 4096);
      expect(body['top_p'], 0.9);
      expect(body['top_k'], 250);
      expect(
        body.containsKey('reasoning_effort'),
        false,
        reason: 'Anthropic does not support reasoning_effort',
      );
      expect(
        body.containsKey('frequency_penalty'),
        false,
        reason: 'Anthropic does not support frequency_penalty',
      );
    });

    test('sets max_tokens with fallback 4096 when not provided', () async {
      await service.callLlm(
        providerType: 'anthropic',
        baseUrl: 'http://fake',
        modelId: 'claude-sonnet-4-20250514',
        messages: [const ChatMessage(role: 'user', content: 'hi')],
        apiKey: 'sk-ant-test',
        parameters: {'temperature': 0.5},
      );

      final body = interceptor.capturedBody!;
      expect(
        body['max_tokens'],
        4096,
        reason: 'max_tokens should fallback to 4096',
      );
    });

    test('respects provided max_tokens value', () async {
      await service.callLlm(
        providerType: 'anthropic',
        baseUrl: 'http://fake',
        modelId: 'claude-sonnet-4-20250514',
        messages: [const ChatMessage(role: 'user', content: 'hi')],
        apiKey: 'sk-ant-test',
        parameters: {'max_tokens': 8192},
      );

      final body = interceptor.capturedBody!;
      expect(body['max_tokens'], 8192);
    });

    test('accepts max_output_tokens alias for Anthropic', () async {
      await service.callLlm(
        providerType: 'anthropic',
        baseUrl: 'http://fake',
        modelId: 'claude-sonnet-4-20250514',
        messages: [const ChatMessage(role: 'user', content: 'hi')],
        apiKey: 'sk-ant-test',
        parameters: {'max_output_tokens': 1234},
      );

      final body = interceptor.capturedBody!;
      expect(body['max_tokens'], 1234);
    });
  });

  group('Ollama endpoint handling', () {
    test(
      'normalizes baseUrl and falls back to /api/generate on 404 chat path',
      () async {
        final interceptor = _OllamaPathInterceptor(chatStatusCode: 404);
        final dio = Dio()..interceptors.add(interceptor);
        final service = LlmApiService(dio: dio);

        final response = await service.callLlm(
          providerType: 'ollama',
          baseUrl: 'http://fake:11434/v1/',
          modelId: 'gemma3:4b',
          messages: [const ChatMessage(role: 'user', content: 'hi')],
        );

        expect(response.content, 'generate ok');
        expect(
          interceptor.paths.contains('http://fake:11434/api/chat'),
          true,
          reason: 'baseUrl should be normalized for Ollama',
        );
        expect(
          interceptor.paths.contains('http://fake:11434/api/generate'),
          true,
        );
      },
    );

    test('throws clear error when Ollama reports missing model', () async {
      final interceptor = _OllamaPathInterceptor(
        chatStatusCode: 404,
        chatErrorPayload: {'error': 'model "gemme3:4b" not found'},
      );
      final dio = Dio()..interceptors.add(interceptor);
      final service = LlmApiService(dio: dio);

      await expectLater(
        () => service.callLlm(
          providerType: 'ollama',
          baseUrl: 'http://fake:11434',
          modelId: 'gemme3:4b',
          messages: [const ChatMessage(role: 'user', content: 'hi')],
        ),
        throwsA(
          predicate(
            (e) => e.toString().contains('model "gemme3:4b" not found'),
          ),
        ),
      );
    });
  });
}
