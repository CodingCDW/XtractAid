// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'model_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ModelInfoImpl _$$ModelInfoImplFromJson(Map<String, dynamic> json) =>
    _$ModelInfoImpl(
      id: json['id'] as String,
      provider: json['provider'] as String,
      displayName: json['displayName'] as String,
      description: json['description'] as String? ?? '',
      contextWindow: (json['contextWindow'] as num).toInt(),
      maxOutputTokens: (json['maxOutputTokens'] as num?)?.toInt() ?? 4096,
      pricing: ModelPricing.fromJson(json['pricing'] as Map<String, dynamic>),
      capabilities: json['capabilities'] == null
          ? const ModelCapabilities()
          : ModelCapabilities.fromJson(
              json['capabilities'] as Map<String, dynamic>,
            ),
      parameters:
          (json['parameters'] as Map<String, dynamic>?)?.map(
            (k, e) =>
                MapEntry(k, ModelParameter.fromJson(e as Map<String, dynamic>)),
          ) ??
          const {},
      notes: json['notes'] as String?,
      status: json['status'] as String? ?? 'active',
    );

Map<String, dynamic> _$$ModelInfoImplToJson(_$ModelInfoImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'provider': instance.provider,
      'displayName': instance.displayName,
      'description': instance.description,
      'contextWindow': instance.contextWindow,
      'maxOutputTokens': instance.maxOutputTokens,
      'pricing': instance.pricing,
      'capabilities': instance.capabilities,
      'parameters': instance.parameters,
      'notes': instance.notes,
      'status': instance.status,
    };

_$ModelPricingImpl _$$ModelPricingImplFromJson(Map<String, dynamic> json) =>
    _$ModelPricingImpl(
      inputPerMillion: (json['inputPerMillion'] as num?)?.toDouble() ?? 0,
      outputPerMillion: (json['outputPerMillion'] as num?)?.toDouble() ?? 0,
      currency: json['currency'] as String? ?? 'USD',
      updatedAt: json['updatedAt'] as String?,
      notes: json['notes'] as String?,
    );

Map<String, dynamic> _$$ModelPricingImplToJson(_$ModelPricingImpl instance) =>
    <String, dynamic>{
      'inputPerMillion': instance.inputPerMillion,
      'outputPerMillion': instance.outputPerMillion,
      'currency': instance.currency,
      'updatedAt': instance.updatedAt,
      'notes': instance.notes,
    };

_$ModelCapabilitiesImpl _$$ModelCapabilitiesImplFromJson(
  Map<String, dynamic> json,
) => _$ModelCapabilitiesImpl(
  chat: json['chat'] as bool? ?? true,
  vision: json['vision'] as bool? ?? false,
  functionCalling: json['functionCalling'] as bool? ?? false,
  jsonMode: json['jsonMode'] as bool? ?? false,
  streaming: json['streaming'] as bool? ?? true,
  reasoning: json['reasoning'] as bool? ?? false,
  extendedThinking: json['extendedThinking'] as bool? ?? false,
);

Map<String, dynamic> _$$ModelCapabilitiesImplToJson(
  _$ModelCapabilitiesImpl instance,
) => <String, dynamic>{
  'chat': instance.chat,
  'vision': instance.vision,
  'functionCalling': instance.functionCalling,
  'jsonMode': instance.jsonMode,
  'streaming': instance.streaming,
  'reasoning': instance.reasoning,
  'extendedThinking': instance.extendedThinking,
};

_$ModelParameterImpl _$$ModelParameterImplFromJson(Map<String, dynamic> json) =>
    _$ModelParameterImpl(
      supported: json['supported'] as bool,
      type: json['type'] as String?,
      min: (json['min'] as num?)?.toDouble(),
      max: (json['max'] as num?)?.toDouble(),
      defaultValue: json['defaultValue'],
      values: (json['values'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      apiName: json['apiName'] as String?,
    );

Map<String, dynamic> _$$ModelParameterImplToJson(
  _$ModelParameterImpl instance,
) => <String, dynamic>{
  'supported': instance.supported,
  'type': instance.type,
  'min': instance.min,
  'max': instance.max,
  'defaultValue': instance.defaultValue,
  'values': instance.values,
  'apiName': instance.apiName,
};
