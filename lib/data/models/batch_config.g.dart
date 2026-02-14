// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'batch_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$BatchConfigImpl _$$BatchConfigImplFromJson(Map<String, dynamic> json) =>
    _$BatchConfigImpl(
      batchId: json['batchId'] as String,
      projectId: json['projectId'] as String,
      name: json['name'] as String,
      input: BatchInput.fromJson(json['input'] as Map<String, dynamic>),
      promptFiles: (json['promptFiles'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      chunkSettings: ChunkSettings.fromJson(
        json['chunkSettings'] as Map<String, dynamic>,
      ),
      models: (json['models'] as List<dynamic>)
          .map((e) => BatchModelConfig.fromJson(e as Map<String, dynamic>))
          .toList(),
      privacyConfirmed: json['privacyConfirmed'] as bool? ?? false,
    );

Map<String, dynamic> _$$BatchConfigImplToJson(_$BatchConfigImpl instance) =>
    <String, dynamic>{
      'batchId': instance.batchId,
      'projectId': instance.projectId,
      'name': instance.name,
      'input': instance.input,
      'promptFiles': instance.promptFiles,
      'chunkSettings': instance.chunkSettings,
      'models': instance.models,
      'privacyConfirmed': instance.privacyConfirmed,
    };

_$BatchInputImpl _$$BatchInputImplFromJson(Map<String, dynamic> json) =>
    _$BatchInputImpl(
      type: json['type'] as String,
      path: json['path'] as String,
      sheetName: json['sheetName'] as String?,
      idColumn: json['idColumn'] as String?,
      itemColumn: json['itemColumn'] as String?,
      itemCount: (json['itemCount'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$$BatchInputImplToJson(_$BatchInputImpl instance) =>
    <String, dynamic>{
      'type': instance.type,
      'path': instance.path,
      'sheetName': instance.sheetName,
      'idColumn': instance.idColumn,
      'itemColumn': instance.itemColumn,
      'itemCount': instance.itemCount,
    };

_$ChunkSettingsImpl _$$ChunkSettingsImplFromJson(Map<String, dynamic> json) =>
    _$ChunkSettingsImpl(
      chunkSize: (json['chunkSize'] as num?)?.toInt() ?? 10,
      repetitions: (json['repetitions'] as num?)?.toInt() ?? 1,
      shuffleBetweenReps: json['shuffleBetweenReps'] as bool? ?? true,
    );

Map<String, dynamic> _$$ChunkSettingsImplToJson(_$ChunkSettingsImpl instance) =>
    <String, dynamic>{
      'chunkSize': instance.chunkSize,
      'repetitions': instance.repetitions,
      'shuffleBetweenReps': instance.shuffleBetweenReps,
    };

_$BatchModelConfigImpl _$$BatchModelConfigImplFromJson(
  Map<String, dynamic> json,
) => _$BatchModelConfigImpl(
  modelId: json['modelId'] as String,
  providerId: json['providerId'] as String,
  parameters: json['parameters'] as Map<String, dynamic>? ?? const {},
);

Map<String, dynamic> _$$BatchModelConfigImplToJson(
  _$BatchModelConfigImpl instance,
) => <String, dynamic>{
  'modelId': instance.modelId,
  'providerId': instance.providerId,
  'parameters': instance.parameters,
};
