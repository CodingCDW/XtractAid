import 'package:flutter_test/flutter_test.dart';
import 'package:xtractaid/core/utils/batch_helpers.dart';

void main() {
  group('isTerminalBatchStatus', () {
    test('completed is terminal', () {
      expect(isTerminalBatchStatus('completed'), true);
    });

    test('failed is terminal', () {
      expect(isTerminalBatchStatus('failed'), true);
    });

    test('cancelled is terminal', () {
      expect(isTerminalBatchStatus('cancelled'), true);
    });

    test('running is not terminal', () {
      expect(isTerminalBatchStatus('running'), false);
    });

    test('created is not terminal', () {
      expect(isTerminalBatchStatus('created'), false);
    });

    test('null is not terminal', () {
      expect(isTerminalBatchStatus(null), false);
    });

    test('empty string is not terminal', () {
      expect(isTerminalBatchStatus(''), false);
    });
  });

  group('extractDiscoveredModels', () {
    test('extracts Ollama models from models[].name', () {
      final payload = {
        'models': [
          {'name': 'llama3:latest', 'size': 4000000000},
          {'name': 'mistral:7b', 'size': 3000000000},
        ],
      };

      final result = extractDiscoveredModels('ollama', payload);

      expect(result.length, 2);
      expect(result[0].id, 'llama3:latest');
      expect(result[0].provider, 'ollama');
      expect(result[1].id, 'mistral:7b');
    });

    test('extracts OpenAI models from data[].id', () {
      final payload = {
        'data': [
          {'id': 'gpt-4o', 'object': 'model'},
          {'id': 'gpt-4o-mini', 'object': 'model'},
        ],
      };

      final result = extractDiscoveredModels('openai', payload);

      expect(result.length, 2);
      expect(result[0].id, 'gpt-4o');
      expect(result[0].provider, 'openai');
    });

    test('returns empty list for missing models key (Ollama)', () {
      final result = extractDiscoveredModels('ollama', {'other': []});
      expect(result, isEmpty);
    });

    test('returns empty list for missing data key (OpenAI)', () {
      final result = extractDiscoveredModels('openai', {'other': []});
      expect(result, isEmpty);
    });

    test('returns empty list for null payload', () {
      final result = extractDiscoveredModels('openai', null);
      expect(result, isEmpty);
    });

    test('skips entries with empty name (Ollama)', () {
      final payload = {
        'models': [
          {'name': 'llama3'},
          {'name': ''},
          {'name': null},
        ],
      };

      final result = extractDiscoveredModels('ollama', payload);
      expect(result.length, 1);
      expect(result[0].id, 'llama3');
    });

    test('works for lmstudio provider (uses data[].id)', () {
      final payload = {
        'data': [
          {'id': 'local-model-1'},
        ],
      };

      final result = extractDiscoveredModels('lmstudio', payload);
      expect(result.length, 1);
      expect(result[0].provider, 'lmstudio');
    });
  });
}
