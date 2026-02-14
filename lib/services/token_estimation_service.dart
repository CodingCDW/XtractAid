import 'dart:math';

import '../core/constants/app_constants.dart';
import '../data/models/cost_estimate.dart';
import '../data/models/model_info.dart';

/// Estimates token counts and costs for batch execution.
///
/// Uses a simple chars/4 heuristic since there's no tiktoken equivalent in Dart.
class TokenEstimationService {
  /// Estimate token count for a text string.
  int estimateTokens(String text) {
    return max(1, text.length ~/ AppConstants.charsPerToken);
  }

  /// Estimate total tokens for a batch.
  ///
  /// Input tokens = sum of (prompt + chunk items) across all calls
  /// Output tokens = max_tokens * number of API calls
  CostEstimate estimateBatchCost({
    required List<String> promptTexts,
    required int totalItems,
    required int chunkSize,
    required int repetitions,
    required int maxOutputTokens,
    required ModelPricing pricing,
  }) {
    final totalChunks = (totalItems / chunkSize).ceil();
    final totalApiCalls = promptTexts.length * totalChunks * repetitions;

    // Estimate input tokens per call: prompt + chunk of items
    var totalInputTokens = 0;
    for (final prompt in promptTexts) {
      final promptTokens = estimateTokens(prompt);
      // Average item contributes ~100 tokens (rough estimate)
      final chunkTokens = chunkSize * 100;
      totalInputTokens += (promptTokens + chunkTokens) * totalChunks * repetitions;
    }

    final totalOutputTokens = maxOutputTokens * totalApiCalls;

    final inputCost = totalInputTokens / 1000000 * pricing.inputPerMillion;
    final outputCost = totalOutputTokens / 1000000 * pricing.outputPerMillion;

    return CostEstimate(
      estimatedInputTokens: totalInputTokens,
      estimatedOutputTokens: totalOutputTokens,
      estimatedApiCalls: totalApiCalls,
      estimatedCostUsd: inputCost + outputCost,
      currency: pricing.currency,
    );
  }

  /// Estimate cost for a single API call.
  double estimateCallCost({
    required int inputTokens,
    required int outputTokens,
    required ModelPricing pricing,
  }) {
    return (inputTokens / 1000000 * pricing.inputPerMillion) +
        (outputTokens / 1000000 * pricing.outputPerMillion);
  }
}
