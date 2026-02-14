import 'package:freezed_annotation/freezed_annotation.dart';

part 'model_info.freezed.dart';
part 'model_info.g.dart';

@freezed
class ModelInfo with _$ModelInfo {
  const factory ModelInfo({
    required String id,
    required String provider,
    required String displayName,
    @Default('') String description,
    required int contextWindow,
    @Default(4096) int maxOutputTokens,
    required ModelPricing pricing,
    @Default(ModelCapabilities()) ModelCapabilities capabilities,
    @Default({}) Map<String, ModelParameter> parameters,
    String? notes,
    @Default('active') String status,
  }) = _ModelInfo;

  factory ModelInfo.fromJson(Map<String, dynamic> json) =>
      _$ModelInfoFromJson(json);
}

@freezed
class ModelPricing with _$ModelPricing {
  const factory ModelPricing({
    @Default(0) double inputPerMillion,
    @Default(0) double outputPerMillion,
    @Default('USD') String currency,
    String? updatedAt,
    String? notes,
  }) = _ModelPricing;

  factory ModelPricing.fromJson(Map<String, dynamic> json) =>
      _$ModelPricingFromJson(json);
}

@freezed
class ModelCapabilities with _$ModelCapabilities {
  const factory ModelCapabilities({
    @Default(true) bool chat,
    @Default(false) bool vision,
    @Default(false) bool functionCalling,
    @Default(false) bool jsonMode,
    @Default(true) bool streaming,
    @Default(false) bool reasoning,
    @Default(false) bool extendedThinking,
  }) = _ModelCapabilities;

  factory ModelCapabilities.fromJson(Map<String, dynamic> json) =>
      _$ModelCapabilitiesFromJson(json);
}

@freezed
class ModelParameter with _$ModelParameter {
  const factory ModelParameter({
    required bool supported,
    String? type, // float, integer, enum
    double? min,
    double? max,
    dynamic defaultValue,
    List<String>? values, // For enum type
    String? apiName, // API field name override
  }) = _ModelParameter;

  factory ModelParameter.fromJson(Map<String, dynamic> json) =>
      _$ModelParameterFromJson(json);
}
