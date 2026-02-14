// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'checkpoint.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CheckpointImpl _$$CheckpointImplFromJson(Map<String, dynamic> json) =>
    _$CheckpointImpl(
      batchId: json['batchId'] as String,
      progress: BatchProgress.fromJson(
        json['progress'] as Map<String, dynamic>,
      ),
      stats: BatchStats.fromJson(json['stats'] as Map<String, dynamic>),
      config: BatchConfig.fromJson(json['config'] as Map<String, dynamic>),
      results:
          (json['results'] as List<dynamic>?)
              ?.map((e) => e as Map<String, dynamic>)
              .toList() ??
          const [],
      savedAt: DateTime.parse(json['savedAt'] as String),
    );

Map<String, dynamic> _$$CheckpointImplToJson(_$CheckpointImpl instance) =>
    <String, dynamic>{
      'batchId': instance.batchId,
      'progress': instance.progress,
      'stats': instance.stats,
      'config': instance.config,
      'results': instance.results,
      'savedAt': instance.savedAt.toIso8601String(),
    };
