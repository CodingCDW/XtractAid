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
