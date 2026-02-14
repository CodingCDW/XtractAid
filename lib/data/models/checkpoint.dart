import 'package:freezed_annotation/freezed_annotation.dart';
import 'batch_config.dart';
import 'batch_stats.dart';

part 'checkpoint.freezed.dart';
part 'checkpoint.g.dart';

@freezed
class Checkpoint with _$Checkpoint {
  const factory Checkpoint({
    required String batchId,
    required BatchProgress progress,
    required BatchStats stats,
    required BatchConfig config,
    @Default([]) List<Map<String, dynamic>> results,
    required DateTime savedAt,
  }) = _Checkpoint;

  factory Checkpoint.fromJson(Map<String, dynamic> json) =>
      _$CheckpointFromJson(json);
}
