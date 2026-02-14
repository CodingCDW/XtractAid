// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cost_estimate.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CostEstimateImpl _$$CostEstimateImplFromJson(
  Map<String, dynamic> json,
) => _$CostEstimateImpl(
  estimatedInputTokens: (json['estimatedInputTokens'] as num?)?.toInt() ?? 0,
  estimatedOutputTokens: (json['estimatedOutputTokens'] as num?)?.toInt() ?? 0,
  estimatedApiCalls: (json['estimatedApiCalls'] as num?)?.toInt() ?? 0,
  estimatedCostUsd: (json['estimatedCostUsd'] as num?)?.toDouble() ?? 0.0,
  currency: json['currency'] as String? ?? 'USD',
);

Map<String, dynamic> _$$CostEstimateImplToJson(_$CostEstimateImpl instance) =>
    <String, dynamic>{
      'estimatedInputTokens': instance.estimatedInputTokens,
      'estimatedOutputTokens': instance.estimatedOutputTokens,
      'estimatedApiCalls': instance.estimatedApiCalls,
      'estimatedCostUsd': instance.estimatedCostUsd,
      'currency': instance.currency,
    };

_$TokenEstimateImpl _$$TokenEstimateImplFromJson(Map<String, dynamic> json) =>
    _$TokenEstimateImpl(
      inputTokens: (json['inputTokens'] as num?)?.toInt() ?? 0,
      outputTokens: (json['outputTokens'] as num?)?.toInt() ?? 0,
      totalTokens: (json['totalTokens'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$$TokenEstimateImplToJson(_$TokenEstimateImpl instance) =>
    <String, dynamic>{
      'inputTokens': instance.inputTokens,
      'outputTokens': instance.outputTokens,
      'totalTokens': instance.totalTokens,
    };
