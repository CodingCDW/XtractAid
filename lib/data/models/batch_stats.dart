import 'package:freezed_annotation/freezed_annotation.dart';

part 'batch_stats.freezed.dart';
part 'batch_stats.g.dart';

@freezed
class BatchStats with _$BatchStats {
  const factory BatchStats({
    @Default(0) int totalApiCalls,
    @Default(0) int completedApiCalls,
    @Default(0) int failedApiCalls,
    @Default(0) int totalInputTokens,
    @Default(0) int totalOutputTokens,
    @Default(0.0) double totalCost,
    @Default(0) int totalItems,
    @Default(0) int processedItems,
    DateTime? startedAt,
    DateTime? completedAt,
  }) = _BatchStats;

  factory BatchStats.fromJson(Map<String, dynamic> json) =>
      _$BatchStatsFromJson(json);
}

@freezed
class BatchProgress with _$BatchProgress {
  const factory BatchProgress({
    @Default(0) int currentRepetition,
    @Default(0) int totalRepetitions,
    @Default(0) int currentPromptIndex,
    @Default(0) int totalPrompts,
    @Default(0) int currentChunkIndex,
    @Default(0) int totalChunks,
    @Default(0) int callCounter,
    @Default(0.0) double progressPercent,
    String? currentModelId,
    String? currentPromptName,
  }) = _BatchProgress;

  factory BatchProgress.fromJson(Map<String, dynamic> json) =>
      _$BatchProgressFromJson(json);
}
