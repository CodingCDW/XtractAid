import 'dart:math';

import 'package:tiktoken_tokenizer_gpt4o_o1/tiktoken_tokenizer_gpt4o_o1.dart'
    as tiktoken;

import '../data/models/cost_estimate.dart';
import '../data/models/model_info.dart';

/// Estimates token counts and costs for batch execution.
class TokenEstimationService {
  static const int _fallbackCharsPerToken = 4;
  static final tiktoken.Tiktoken _o200kTokenizer = tiktoken.Tiktoken(
    tiktoken.OpenAiModel.gpt_4o,
  );
  static final tiktoken.Tiktoken _cl100kTokenizer = tiktoken.Tiktoken(
    tiktoken.OpenAiModel.gpt_4,
  );

  // Small in-memory cache to avoid repeated tokenization during live UI updates.
  final Map<int, int> _tokenCache = <int, int>{};

  /// Estimate token count for a text string.
  int estimateTokens(String text, {String? modelId}) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) {
      return 0;
    }

    final cacheKey = Object.hash(modelId, trimmed);
    final cached = _tokenCache[cacheKey];
    if (cached != null) {
      return cached;
    }

    int estimated;
    try {
      estimated = _resolveTokenizer(modelId).count(trimmed);
    } catch (_) {
      estimated = max(1, trimmed.length ~/ _fallbackCharsPerToken);
    }

    if (_tokenCache.length > 1000) {
      _tokenCache.clear();
    }
    _tokenCache[cacheKey] = estimated;
    return estimated;
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
    required String modelId,
    List<String> itemSamples = const [],
  }) {
    final totalChunks = (totalItems / chunkSize).ceil();
    final totalApiCalls = promptTexts.length * totalChunks * repetitions;
    final tokensPerItem = _estimateTokensPerItem(itemSamples, modelId: modelId);

    // Estimate input tokens per call: prompt + chunk items (+ tiny formatting overhead).
    var totalInputTokens = 0;
    for (final prompt in promptTexts) {
      final promptTokens = estimateTokens(prompt, modelId: modelId);
      final chunkTokens = chunkSize * tokensPerItem;
      final perCallInput = promptTokens + chunkTokens + 16;
      totalInputTokens += perCallInput * totalChunks * repetitions;
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

  int _estimateTokensPerItem(
    List<String> itemSamples, {
    required String modelId,
  }) {
    if (itemSamples.isEmpty) {
      return 100;
    }

    var sum = 0;
    var count = 0;
    for (final sample in itemSamples) {
      if (sample.trim().isEmpty) {
        continue;
      }
      sum += estimateTokens(sample, modelId: modelId);
      count++;
    }

    if (count == 0) {
      return 100;
    }

    return max(1, (sum / count).round());
  }

  tiktoken.Tiktoken _resolveTokenizer(String? modelId) {
    final normalized = modelId?.toLowerCase() ?? '';
    if (normalized.contains('gpt-4') && !normalized.contains('4o')) {
      return _cl100kTokenizer;
    }
    return _o200kTokenizer;
  }
}
