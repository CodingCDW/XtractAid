import 'dart:collection';
import 'dart:math';

import 'package:logging/logging.dart';
import 'package:tiktoken_tokenizer_gpt4o_o1/tiktoken_tokenizer_gpt4o_o1.dart'
    as tiktoken;

import '../data/models/cost_estimate.dart';
import '../data/models/model_info.dart';

final _log = Logger('TokenEstimationService');

/// Estimates token counts and costs for batch execution.
class TokenEstimationService {
  static const int _fallbackCharsPerToken = 4;
  static const int _maxCacheSize = 1000;

  // M5: Lazy initialization with error handling
  static tiktoken.Tiktoken? _o200kTokenizer;
  static tiktoken.Tiktoken? _cl100kTokenizer;

  static tiktoken.Tiktoken? _getO200kTokenizer() {
    if (_o200kTokenizer == null) {
      try {
        _o200kTokenizer = tiktoken.Tiktoken(tiktoken.OpenAiModel.gpt_4o);
      } catch (e) {
        _log.warning('Failed to initialize o200k tokenizer, using fallback: $e');
      }
    }
    return _o200kTokenizer;
  }

  static tiktoken.Tiktoken? _getCl100kTokenizer() {
    if (_cl100kTokenizer == null) {
      try {
        _cl100kTokenizer = tiktoken.Tiktoken(tiktoken.OpenAiModel.gpt_4);
      } catch (e) {
        _log.warning('Failed to initialize cl100k tokenizer, using fallback: $e');
      }
    }
    return _cl100kTokenizer;
  }

  // M4: LRU cache using LinkedHashMap with access-order tracking.
  final LinkedHashMap<int, int> _tokenCache = LinkedHashMap<int, int>();

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
    final tokenizer = _resolveTokenizer(modelId);
    if (tokenizer != null) {
      try {
        estimated = tokenizer.count(trimmed);
      } catch (e) {
        _log.warning('Tokenizer failed, using char-based fallback: $e');
        estimated = max(1, trimmed.length ~/ _fallbackCharsPerToken);
      }
    } else {
      _log.fine('No tokenizer available for model $modelId, using char-based fallback');
      estimated = max(1, trimmed.length ~/ _fallbackCharsPerToken);
    }

    // M4: LRU eviction - remove oldest entry when cache is full
    if (_tokenCache.length >= _maxCacheSize) {
      _tokenCache.remove(_tokenCache.keys.first);
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

  tiktoken.Tiktoken? _resolveTokenizer(String? modelId) {
    final normalized = modelId?.toLowerCase() ?? '';
    if (normalized.contains('gpt-4') && !normalized.contains('4o')) {
      return _getCl100kTokenizer();
    }
    return _getO200kTokenizer();
  }
}
