// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'provider_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ProviderConfigImpl _$$ProviderConfigImplFromJson(Map<String, dynamic> json) =>
    _$ProviderConfigImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      type: json['type'] as String,
      baseUrl: json['baseUrl'] as String,
      authType: json['authType'] as String? ?? 'bearer',
      modelsEndpoint: json['modelsEndpoint'] as String?,
      isLocal: json['isLocal'] as bool? ?? false,
      isEnabled: json['isEnabled'] as bool? ?? true,
    );

Map<String, dynamic> _$$ProviderConfigImplToJson(
  _$ProviderConfigImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'type': instance.type,
  'baseUrl': instance.baseUrl,
  'authType': instance.authType,
  'modelsEndpoint': instance.modelsEndpoint,
  'isLocal': instance.isLocal,
  'isEnabled': instance.isEnabled,
};
