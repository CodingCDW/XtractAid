import 'package:flutter_test/flutter_test.dart';
import 'package:xtractaid/core/utils/provider_helpers.dart';

void main() {
  group('isLocalProviderType', () {
    test('ollama is local', () {
      expect(isLocalProviderType('ollama'), true);
    });

    test('lmstudio is local', () {
      expect(isLocalProviderType('lmstudio'), true);
    });

    test('openai is not local', () {
      expect(isLocalProviderType('openai'), false);
    });

    test('anthropic is not local', () {
      expect(isLocalProviderType('anthropic'), false);
    });

    test('google is not local', () {
      expect(isLocalProviderType('google'), false);
    });

    test('openrouter is not local', () {
      expect(isLocalProviderType('openrouter'), false);
    });

    test('empty string is not local', () {
      expect(isLocalProviderType(''), false);
    });
  });

  group('providerDisplayName', () {
    test('maps openai to OpenAI', () {
      expect(providerDisplayName('openai'), 'OpenAI');
    });

    test('maps anthropic to Anthropic', () {
      expect(providerDisplayName('anthropic'), 'Anthropic');
    });

    test('maps google to Google', () {
      expect(providerDisplayName('google'), 'Google');
    });

    test('maps openrouter to OpenRouter', () {
      expect(providerDisplayName('openrouter'), 'OpenRouter');
    });

    test('maps ollama to Ollama', () {
      expect(providerDisplayName('ollama'), 'Ollama');
    });

    test('maps lmstudio to LM Studio', () {
      expect(providerDisplayName('lmstudio'), 'LM Studio');
    });

    test('returns unknown type as-is (fallback)', () {
      expect(providerDisplayName('custom_provider'), 'custom_provider');
    });
  });
}
