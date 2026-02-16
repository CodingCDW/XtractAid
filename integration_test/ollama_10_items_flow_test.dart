import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:xtractaid/services/json_parser_service.dart';
import 'package:xtractaid/services/llm_api_service.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Ollama flow: 10 items, 1 prompt', (tester) async {
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    addTearDown(server.close);

    server.listen((request) async {
      if (request.method == 'GET' && request.uri.path == '/api/tags') {
        request.response
          ..statusCode = HttpStatus.ok
          ..headers.contentType = ContentType.json
          ..write(
            jsonEncode({
              'models': [
                {'name': 'test-model'},
              ],
            }),
          );
        await request.response.close();
        return;
      }

      if (request.method == 'POST' && request.uri.path == '/api/chat') {
        final body = await utf8.decoder.bind(request).join();
        final payload = jsonDecode(body) as Map<String, dynamic>;
        final messages = (payload['messages'] as List<dynamic>)
            .cast<Map<String, dynamic>>();
        final userMessage = messages.last['content']?.toString() ?? '';
        final idMatch = RegExp(r'ID:(\w+)').firstMatch(userMessage);
        final id = idMatch?.group(1) ?? 'UNKNOWN';

        request.response
          ..statusCode = HttpStatus.ok
          ..headers.contentType = ContentType.json
          ..write(
            jsonEncode({
              'message': {'content': '[{"ID":"$id","result":"ok"}]'},
              'prompt_eval_count': 12,
              'eval_count': 8,
              'done': true,
            }),
          );
        await request.response.close();
        return;
      }

      request.response.statusCode = HttpStatus.notFound;
      await request.response.close();
    });

    final baseUrl = 'http://${server.address.host}:${server.port}';
    final api = LlmApiService();
    final parser = JsonParserService();

    final ok = await api.testConnection(
      providerType: 'ollama',
      baseUrl: baseUrl,
    );
    expect(ok, isTrue);

    final aggregated = <Map<String, dynamic>>[];
    for (var i = 1; i <= 10; i++) {
      final id = 'I$i';
      final response = await api.callLlm(
        providerType: 'ollama',
        baseUrl: baseUrl,
        modelId: 'test-model',
        messages: [
          const ChatMessage(role: 'system', content: 'Return JSON only'),
          ChatMessage(role: 'user', content: 'ID:$id Item:Text $i'),
        ],
      );

      final parsed = parser.parseResponse(response.content);
      expect(parsed, isNotNull);
      aggregated.addAll(parsed!);
    }

    expect(aggregated.length, 10);
    expect(aggregated.map((row) => row['ID']).toSet().length, 10);
    expect(aggregated.every((row) => row['result'] == 'ok'), isTrue);
  });
}
