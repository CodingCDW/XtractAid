import '../../core/l10n/generated/app_localizations.dart';
import '../../providers/batch_execution_provider.dart';

/// Returns true if [status] represents a terminal batch state.
bool isTerminalBatchStatus(String? status) {
  return status == 'completed' || status == 'failed' || status == 'cancelled';
}

/// Returns a localized label for a [BatchExecutionStatus].
String batchExecutionStatusLabel(BatchExecutionStatus status, S t) {
  return switch (status) {
    BatchExecutionStatus.idle => t.execStatusIdle,
    BatchExecutionStatus.starting => t.execStatusStarting,
    BatchExecutionStatus.running => t.execStatusRunning,
    BatchExecutionStatus.paused => t.execStatusPaused,
    BatchExecutionStatus.completed => t.execStatusCompleted,
    BatchExecutionStatus.failed => t.execStatusFailed,
  };
}

/// Data class for a discovered model from a provider.
class DiscoveredModel {
  const DiscoveredModel({
    required this.provider,
    required this.id,
    this.canAdd = true,
  });

  final String provider;
  final String id;
  final bool canAdd;
}

/// Extracts model IDs from a provider API response [payload].
/// Ollama uses `models[].name`, other providers use `data[].id`.
List<DiscoveredModel> extractDiscoveredModels(
  String providerType,
  dynamic payload,
) {
  if (providerType == 'ollama') {
    if (payload is Map && payload['models'] is List) {
      final list = payload['models'] as List;
      return list
          .whereType<Map>()
          .map((m) => m['name']?.toString() ?? '')
          .where((s) => s.isNotEmpty)
          .map((id) => DiscoveredModel(provider: providerType, id: id))
          .toList();
    }
    return const [];
  }

  if (payload is Map && payload['data'] is List) {
    final list = payload['data'] as List;
    return list
        .whereType<Map>()
        .map((m) => m['id']?.toString() ?? '')
        .where((s) => s.isNotEmpty)
        .map((id) => DiscoveredModel(provider: providerType, id: id))
        .toList();
  }

  return const [];
}

/// Returns a stable batch name like `Batch_ModelName_1a2b3c4d`.
String generateBatchName({required String modelName, required String batchId}) {
  final modelSegment = _sanitizeSegment(modelName, fallback: 'Model');
  final shortId = _shortId(batchId);
  return 'Batch_${modelSegment}_$shortId';
}

/// Returns a run folder name like
/// `Batch_ModelName_1a2b3c4d_2026-02-17_07-33-12`.
String generateBatchRunFolderName({
  required String batchName,
  required String batchId,
  required DateTime runAt,
}) {
  final baseName = _sanitizeSegment(
    batchName,
    fallback: 'Batch_${_shortId(batchId)}',
  );
  return '${baseName}_${_formatDate(runAt)}_${_formatTime(runAt)}';
}

String _sanitizeSegment(String value, {required String fallback}) {
  var normalized = value.trim();
  if (normalized.isEmpty) {
    return fallback;
  }

  normalized = normalized
      .replaceAll(RegExp(r'\s+'), '_')
      .replaceAll(RegExp(r'[^A-Za-z0-9._-]'), '_')
      .replaceAll(RegExp(r'_+'), '_')
      .replaceAll(RegExp(r'^_+|_+$'), '');

  return normalized.isEmpty ? fallback : normalized;
}

String _shortId(String value) {
  final compact = value.replaceAll(RegExp(r'[^A-Za-z0-9]'), '');
  if (compact.isEmpty) {
    return '00000000';
  }
  return compact.length <= 8 ? compact : compact.substring(0, 8);
}

String _formatDate(DateTime value) {
  final year = value.year.toString().padLeft(4, '0');
  final month = value.month.toString().padLeft(2, '0');
  final day = value.day.toString().padLeft(2, '0');
  return '$year-$month-$day';
}

String _formatTime(DateTime value) {
  final hour = value.hour.toString().padLeft(2, '0');
  final minute = value.minute.toString().padLeft(2, '0');
  final second = value.second.toString().padLeft(2, '0');
  return '$hour-$minute-$second';
}
