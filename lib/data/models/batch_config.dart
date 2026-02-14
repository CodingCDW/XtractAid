import 'package:freezed_annotation/freezed_annotation.dart';

part 'batch_config.freezed.dart';
part 'batch_config.g.dart';

@freezed
class BatchConfig with _$BatchConfig {
  const factory BatchConfig({
    required String batchId,
    required String projectId,
    required String name,
    required BatchInput input,
    required List<String> promptFiles,
    required ChunkSettings chunkSettings,
    required List<BatchModelConfig> models,
    @Default(false) bool privacyConfirmed,
  }) = _BatchConfig;

  factory BatchConfig.fromJson(Map<String, dynamic> json) =>
      _$BatchConfigFromJson(json);
}

@freezed
class BatchInput with _$BatchInput {
  const factory BatchInput({
    required String type, // excel, folder
    required String path,
    String? sheetName,
    String? idColumn,
    String? itemColumn,
    @Default(0) int itemCount,
  }) = _BatchInput;

  factory BatchInput.fromJson(Map<String, dynamic> json) =>
      _$BatchInputFromJson(json);
}

@freezed
class ChunkSettings with _$ChunkSettings {
  const factory ChunkSettings({
    @Default(10) int chunkSize,
    @Default(1) int repetitions,
    @Default(true) bool shuffleBetweenReps,
  }) = _ChunkSettings;

  factory ChunkSettings.fromJson(Map<String, dynamic> json) =>
      _$ChunkSettingsFromJson(json);
}

@freezed
class BatchModelConfig with _$BatchModelConfig {
  const factory BatchModelConfig({
    required String modelId,
    required String providerId,
    @Default({}) Map<String, dynamic> parameters,
  }) = _BatchModelConfig;

  factory BatchModelConfig.fromJson(Map<String, dynamic> json) =>
      _$BatchModelConfigFromJson(json);
}
