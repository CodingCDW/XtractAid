import '../data/models/batch_config.dart';
import '../data/models/batch_stats.dart';
import '../data/models/item.dart';
import '../data/models/log_entry.dart';

sealed class WorkerCommand {}

class StartBatchCommand extends WorkerCommand {
  StartBatchCommand({
    required this.config,
    required this.items,
    required this.prompts,
    required this.projectPath,
    this.apiKey,
    this.providerBaseUrls = const {},
  });

  final BatchConfig config;
  final List<Item> items;
  final Map<String, String> prompts;
  final String projectPath;
  final String? apiKey;
  final Map<String, String> providerBaseUrls;
}

class PauseBatchCommand extends WorkerCommand {}

class ResumeBatchCommand extends WorkerCommand {}

class StopBatchCommand extends WorkerCommand {}

sealed class WorkerEvent {}

class ProgressEvent extends WorkerEvent {
  ProgressEvent(this.progress);

  final BatchProgress progress;
}

class LogEvent extends WorkerEvent {
  LogEvent(this.entry);

  final LogEntry entry;
}

class CheckpointSavedEvent extends WorkerEvent {
  CheckpointSavedEvent(this.callCount);

  final int callCount;
}

class BatchCompletedEvent extends WorkerEvent {
  BatchCompletedEvent({
    required this.stats,
    required this.results,
  });

  final BatchStats stats;
  final List<Map<String, dynamic>> results;
}

class BatchErrorEvent extends WorkerEvent {
  BatchErrorEvent({
    required this.message,
    this.details,
  });

  final String message;
  final String? details;
}

abstract final class WorkerMessageCodec {
  static Map<String, dynamic> encodeCommand(WorkerCommand command) {
    return switch (command) {
      StartBatchCommand() => {
          'type': 'start',
          'config': command.config.toJson(),
          'items': command.items.map((e) => e.toJson()).toList(),
          'prompts': command.prompts,
          'projectPath': command.projectPath,
          'apiKey': command.apiKey,
          'providerBaseUrls': command.providerBaseUrls,
        },
      PauseBatchCommand() => {'type': 'pause'},
      ResumeBatchCommand() => {'type': 'resume'},
      StopBatchCommand() => {'type': 'stop'},
    };
  }

  static WorkerCommand? decodeCommand(dynamic payload) {
    if (payload is! Map) {
      return null;
    }
    final type = payload['type'] as String?;
    if (type == null) {
      return null;
    }

    switch (type) {
      case 'start':
        final configMap = payload['config'];
        final itemsRaw = payload['items'];
        final promptsRaw = payload['prompts'];
        if (configMap is! Map || itemsRaw is! List || promptsRaw is! Map) {
          return null;
        }
        return StartBatchCommand(
          config: BatchConfig.fromJson(Map<String, dynamic>.from(configMap)),
          items: itemsRaw
              .whereType<Map>()
              .map((e) => Item.fromJson(Map<String, dynamic>.from(e)))
              .toList(),
          prompts: promptsRaw.map(
            (key, value) => MapEntry(key.toString(), value.toString()),
          ),
          projectPath: payload['projectPath']?.toString() ?? '',
          apiKey: payload['apiKey']?.toString(),
          providerBaseUrls: (payload['providerBaseUrls'] as Map?)
                  ?.map(
                    (key, value) => MapEntry(key.toString(), value.toString()),
                  ) ??
              const {},
        );
      case 'pause':
        return PauseBatchCommand();
      case 'resume':
        return ResumeBatchCommand();
      case 'stop':
        return StopBatchCommand();
      default:
        return null;
    }
  }

  static Map<String, dynamic> encodeEvent(WorkerEvent event) {
    return switch (event) {
      ProgressEvent() => {
          'type': 'progress',
          'progress': event.progress.toJson(),
        },
      LogEvent() => {
          'type': 'log',
          'entry': event.entry.toJson(),
        },
      CheckpointSavedEvent() => {
          'type': 'checkpointSaved',
          'callCount': event.callCount,
        },
      BatchCompletedEvent() => {
          'type': 'completed',
          'stats': event.stats.toJson(),
          'results': event.results,
        },
      BatchErrorEvent() => {
          'type': 'error',
          'message': event.message,
          'details': event.details,
        },
    };
  }

  static WorkerEvent? decodeEvent(dynamic payload) {
    if (payload is! Map) {
      return null;
    }
    final type = payload['type'] as String?;
    if (type == null) {
      return null;
    }

    switch (type) {
      case 'progress':
        final progressMap = payload['progress'];
        if (progressMap is! Map) {
          return null;
        }
        return ProgressEvent(
          BatchProgress.fromJson(Map<String, dynamic>.from(progressMap)),
        );
      case 'log':
        final entryMap = payload['entry'];
        if (entryMap is! Map) {
          return null;
        }
        return LogEvent(LogEntry.fromJson(Map<String, dynamic>.from(entryMap)));
      case 'checkpointSaved':
        final count = payload['callCount'];
        if (count is! int) {
          return null;
        }
        return CheckpointSavedEvent(count);
      case 'completed':
        final statsMap = payload['stats'];
        final resultsRaw = payload['results'];
        if (statsMap is! Map || resultsRaw is! List) {
          return null;
        }
        return BatchCompletedEvent(
          stats: BatchStats.fromJson(Map<String, dynamic>.from(statsMap)),
          results: resultsRaw
              .whereType<Map>()
              .map((e) => Map<String, dynamic>.from(e))
              .toList(),
        );
      case 'error':
        return BatchErrorEvent(
          message: payload['message']?.toString() ?? 'Unknown worker error',
          details: payload['details']?.toString(),
        );
      default:
        return null;
    }
  }
}
