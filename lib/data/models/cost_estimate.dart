import 'package:freezed_annotation/freezed_annotation.dart';

part 'cost_estimate.freezed.dart';
part 'cost_estimate.g.dart';

@freezed
class CostEstimate with _$CostEstimate {
  const factory CostEstimate({
    @Default(0) int estimatedInputTokens,
    @Default(0) int estimatedOutputTokens,
    @Default(0) int estimatedApiCalls,
    @Default(0.0) double estimatedCostUsd,
    @Default('USD') String currency,
  }) = _CostEstimate;

  factory CostEstimate.fromJson(Map<String, dynamic> json) =>
      _$CostEstimateFromJson(json);
}

@freezed
class TokenEstimate with _$TokenEstimate {
  const factory TokenEstimate({
    @Default(0) int inputTokens,
    @Default(0) int outputTokens,
    @Default(0) int totalTokens,
  }) = _TokenEstimate;

  factory TokenEstimate.fromJson(Map<String, dynamic> json) =>
      _$TokenEstimateFromJson(json);
}
