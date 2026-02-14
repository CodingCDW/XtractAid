import 'dart:convert';
import 'dart:io';

import 'package:logging/logging.dart';

import '../core/constants/app_constants.dart';
import '../data/models/batch_config.dart';
import '../data/models/batch_stats.dart';
import '../data/models/checkpoint.dart';

final _log = Logger('CheckpointService');

/// Saves and loads batch execution checkpoints as JSON files.
///
/// Checkpoint files are stored in the project folder:
/// `results/{batchId}/checkpoints/checkpoint_{batchId}.json`
class CheckpointService {
  /// Save a checkpoint to disk.
  Future<void> saveCheckpoint({
    required String projectPath,
    required String batchId,
    required BatchProgress progress,
    required BatchStats stats,
    required BatchConfig config,
    required List<Map<String, dynamic>> results,
  }) async {
    final checkpoint = Checkpoint(
      batchId: batchId,
      progress: progress,
      stats: stats,
      config: config,
      results: results,
      savedAt: DateTime.now(),
    );

    final dir = _checkpointDir(projectPath, batchId);
    if (!dir.existsSync()) dir.createSync(recursive: true);

    final file = File('${dir.path}/checkpoint_$batchId.json');
    final jsonStr = const JsonEncoder.withIndent('  ').convert(checkpoint.toJson());
    await file.writeAsString(jsonStr);

    _log.fine('Checkpoint saved: ${file.path} (call #${progress.callCounter})');
  }

  /// Check if a checkpoint exists for a batch.
  bool hasCheckpoint(String projectPath, String batchId) {
    final file = File('${_checkpointDir(projectPath, batchId).path}/checkpoint_$batchId.json');
    return file.existsSync();
  }

  /// Load a checkpoint from disk.
  Future<Checkpoint?> loadCheckpoint(
    String projectPath,
    String batchId,
  ) async {
    final file = File('${_checkpointDir(projectPath, batchId).path}/checkpoint_$batchId.json');
    if (!file.existsSync()) return null;

    try {
      final jsonStr = await file.readAsString();
      final jsonMap = json.decode(jsonStr) as Map<String, dynamic>;
      return Checkpoint.fromJson(jsonMap);
    } catch (e) {
      _log.warning('Failed to load checkpoint for $batchId: $e');
      return null;
    }
  }

  /// Delete checkpoint for a batch.
  Future<void> deleteCheckpoint(String projectPath, String batchId) async {
    final file = File('${_checkpointDir(projectPath, batchId).path}/checkpoint_$batchId.json');
    if (file.existsSync()) {
      await file.delete();
    }
  }

  /// Clean up old checkpoints (older than retention period).
  Future<int> cleanupOldCheckpoints(
    String projectPath, {
    int retentionDays = AppConstants.checkpointRetentionDays,
  }) async {
    final resultsDir = Directory('$projectPath/results');
    if (!resultsDir.existsSync()) return 0;

    final cutoff = DateTime.now().subtract(Duration(days: retentionDays));
    var deletedCount = 0;

    for (final entity in resultsDir.listSync()) {
      if (entity is! Directory) continue;
      final cpDir = Directory('${entity.path}/checkpoints');
      if (!cpDir.existsSync()) continue;

      for (final file in cpDir.listSync().whereType<File>()) {
        if (file.path.endsWith('.json')) {
          final modified = file.lastModifiedSync();
          if (modified.isBefore(cutoff)) {
            file.deleteSync();
            deletedCount++;
          }
        }
      }
    }

    if (deletedCount > 0) {
      _log.info('Cleaned up $deletedCount old checkpoint(s).');
    }
    return deletedCount;
  }

  Directory _checkpointDir(String projectPath, String batchId) {
    return Directory('$projectPath/results/$batchId/checkpoints');
  }
}
