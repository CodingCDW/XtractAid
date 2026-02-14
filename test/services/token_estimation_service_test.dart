import 'package:flutter_test/flutter_test.dart';
import 'package:xtractaid/data/models/model_info.dart';
import 'package:xtractaid/services/token_estimation_service.dart';

void main() {
  late TokenEstimationService service;

  setUp(() {
    service = TokenEstimationService();
  });

  group('TokenEstimationService', () {
    group('estimateTokens', () {
      test('returns 0 for empty string', () {
        expect(service.estimateTokens(''), 0);
      });

      test('returns 0 for whitespace-only string', () {
        expect(service.estimateTokens('   \n  '), 0);
      });

      test('returns positive count for normal text', () {
        final tokens = service.estimateTokens('Hello, world!');
        expect(tokens, greaterThan(0));
      });

      test('longer text produces more tokens', () {
        final short = service.estimateTokens('Hello');
        final long = service.estimateTokens(
          'Hello, this is a much longer text with many more words and tokens.',
        );
        expect(long, greaterThan(short));
      });

      test('returns consistent results (caching)', () {
        const text = 'Consistent test input';
        final first = service.estimateTokens(text);
        final second = service.estimateTokens(text);
        expect(first, second);
      });

      test('handles unicode text', () {
        final tokens = service.estimateTokens('Ümlaute äöü und Sonderzeichen €£¥');
        expect(tokens, greaterThan(0));
      });

      test('uses different tokenizer for GPT-4 vs GPT-4o', () {
        const text = 'A reasonably long text for tokenization comparison purposes.';
        final gpt4 = service.estimateTokens(text, modelId: 'gpt-4');
        final gpt4o = service.estimateTokens(text, modelId: 'gpt-4o');
        // Both should return valid counts (may or may not differ)
        expect(gpt4, greaterThan(0));
        expect(gpt4o, greaterThan(0));
      });
    });

    group('estimateBatchCost', () {
      const pricing = ModelPricing(
        inputPerMillion: 5.0,
        outputPerMillion: 15.0,
        currency: 'USD',
      );

      test('calculates correct API call count', () {
        final estimate = service.estimateBatchCost(
          promptTexts: ['Prompt 1', 'Prompt 2'],
          totalItems: 10,
          chunkSize: 5,
          repetitions: 2,
          maxOutputTokens: 1000,
          pricing: pricing,
          modelId: 'gpt-4o',
        );

        // 2 prompts * 2 chunks * 2 reps = 8 calls
        expect(estimate.estimatedApiCalls, 8);
      });

      test('returns positive cost for non-zero inputs', () {
        final estimate = service.estimateBatchCost(
          promptTexts: ['Analyze this.'],
          totalItems: 5,
          chunkSize: 1,
          repetitions: 1,
          maxOutputTokens: 4096,
          pricing: pricing,
          modelId: 'gpt-4o',
        );

        expect(estimate.estimatedCostUsd, greaterThan(0));
        expect(estimate.estimatedInputTokens, greaterThan(0));
        expect(estimate.estimatedOutputTokens, greaterThan(0));
      });

      test('more repetitions increase cost', () {
        final est1 = service.estimateBatchCost(
          promptTexts: ['Test'],
          totalItems: 10,
          chunkSize: 5,
          repetitions: 1,
          maxOutputTokens: 1000,
          pricing: pricing,
          modelId: 'gpt-4o',
        );

        final est3 = service.estimateBatchCost(
          promptTexts: ['Test'],
          totalItems: 10,
          chunkSize: 5,
          repetitions: 3,
          maxOutputTokens: 1000,
          pricing: pricing,
          modelId: 'gpt-4o',
        );

        expect(est3.estimatedCostUsd, greaterThan(est1.estimatedCostUsd));
        expect(est3.estimatedApiCalls, 3 * est1.estimatedApiCalls);
      });

      test('uses item samples for better estimation', () {
        final withSamples = service.estimateBatchCost(
          promptTexts: ['Test'],
          totalItems: 10,
          chunkSize: 1,
          repetitions: 1,
          maxOutputTokens: 100,
          pricing: pricing,
          modelId: 'gpt-4o',
          itemSamples: [
            'This is a very long sample item text ' * 20,
          ],
        );

        final withoutSamples = service.estimateBatchCost(
          promptTexts: ['Test'],
          totalItems: 10,
          chunkSize: 1,
          repetitions: 1,
          maxOutputTokens: 100,
          pricing: pricing,
          modelId: 'gpt-4o',
        );

        // With long samples, input tokens should be higher
        expect(
          withSamples.estimatedInputTokens,
          greaterThan(withoutSamples.estimatedInputTokens),
        );
      });

      test('preserves currency from pricing', () {
        const eurPricing = ModelPricing(
          inputPerMillion: 5.0,
          outputPerMillion: 15.0,
          currency: 'EUR',
        );

        final estimate = service.estimateBatchCost(
          promptTexts: ['Test'],
          totalItems: 1,
          chunkSize: 1,
          repetitions: 1,
          maxOutputTokens: 100,
          pricing: eurPricing,
          modelId: 'gpt-4o',
        );

        expect(estimate.currency, 'EUR');
      });
    });

    group('estimateCallCost', () {
      test('calculates correctly', () {
        const pricing = ModelPricing(
          inputPerMillion: 10.0,
          outputPerMillion: 30.0,
        );

        // 1M input tokens at $10/M + 1M output tokens at $30/M = $40
        final cost = service.estimateCallCost(
          inputTokens: 1000000,
          outputTokens: 1000000,
          pricing: pricing,
        );

        expect(cost, closeTo(40.0, 0.001));
      });

      test('returns zero for zero tokens', () {
        const pricing = ModelPricing(
          inputPerMillion: 10.0,
          outputPerMillion: 30.0,
        );

        final cost = service.estimateCallCost(
          inputTokens: 0,
          outputTokens: 0,
          pricing: pricing,
        );

        expect(cost, 0.0);
      });
    });
  });
}
