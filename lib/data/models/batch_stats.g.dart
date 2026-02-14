// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'batch_stats.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$BatchStatsImpl _$$BatchStatsImplFromJson(Map<String, dynamic> json) =>
    _$BatchStatsImpl(
      totalApiCalls: (json['totalApiCalls'] as num?)?.toInt() ?? 0,
      completedApiCalls: (json['completedApiCalls'] as num?)?.toInt() ?? 0,
      failedApiCalls: (json['failedApiCalls'] as num?)?.toInt() ?? 0,
      totalInputTokens: (json['totalInputTokens'] as num?)?.toInt() ?? 0,
      totalOutputTokens: (json['totalOutputTokens'] as num?)?.toInt() ?? 0,
      totalCost: (json['totalCost'] as num?)?.toDouble() ?? 0.0,
      totalItems: (json['totalItems'] as num?)?.toInt() ?? 0,
      processedItems: (json['processedItems'] as num?)?.toInt() ?? 0,
      startedAt: json['startedAt'] == null
          ? null
          : DateTime.parse(json['startedAt'] as String),
      completedAt: json['completedAt'] == null
          ? null
          : DateTime.parse(json['completedAt'] as String),
    );

Map<String, dynamic> _$$BatchStatsImplToJson(_$BatchStatsImpl instance) =>
    <String, dynamic>{
      'totalApiCalls': instance.totalApiCalls,
      'completedApiCalls': instance.completedApiCalls,
      'failedApiCalls': instance.failedApiCalls,
      'totalInputTokens': instance.totalInputTokens,
      'totalOutputTokens': instance.totalOutputTokens,
      'totalCost': instance.totalCost,
      'totalItems': instance.totalItems,
      'processedItems': instance.processedItems,
      'startedAt': instance.startedAt?.toIso8601String(),
      'completedAt': instance.completedAt?.toIso8601String(),
    };

_$BatchProgressImpl _$$BatchProgressImplFromJson(Map<String, dynamic> json) =>
    _$BatchProgressImpl(
      currentRepetition: (json['currentRepetition'] as num?)?.toInt() ?? 0,
      totalRepetitions: (json['totalRepetitions'] as num?)?.toInt() ?? 0,
      currentPromptIndex: (json['currentPromptIndex'] as num?)?.toInt() ?? 0,
      totalPrompts: (json['totalPrompts'] as num?)?.toInt() ?? 0,
      currentChunkIndex: (json['currentChunkIndex'] as num?)?.toInt() ?? 0,
      totalChunks: (json['totalChunks'] as num?)?.toInt() ?? 0,
      callCounter: (json['callCounter'] as num?)?.toInt() ?? 0,
      progressPercent: (json['progressPercent'] as num?)?.toDouble() ?? 0.0,
      currentModelId: json['currentModelId'] as String?,
      currentPromptName: json['currentPromptName'] as String?,
    );

Map<String, dynamic> _$$BatchProgressImplToJson(_$BatchProgressImpl instance) =>
    <String, dynamic>{
      'currentRepetition': instance.currentRepetition,
      'totalRepetitions': instance.totalRepetitions,
      'currentPromptIndex': instance.currentPromptIndex,
      'totalPrompts': instance.totalPrompts,
      'currentChunkIndex': instance.currentChunkIndex,
      'totalChunks': instance.totalChunks,
      'callCounter': instance.callCounter,
      'progressPercent': instance.progressPercent,
      'currentModelId': instance.currentModelId,
      'currentPromptName': instance.currentPromptName,
    };
