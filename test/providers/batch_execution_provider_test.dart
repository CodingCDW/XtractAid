import 'package:flutter_test/flutter_test.dart';
import 'package:xtractaid/data/models/batch_stats.dart';
import 'package:xtractaid/data/models/log_entry.dart';
import 'package:xtractaid/providers/batch_execution_provider.dart';
import 'package:xtractaid/workers/worker_messages.dart';

void main() {
  late BatchExecutionNotifier notifier;

  setUp(() {
    notifier = BatchExecutionNotifier();
  });

  tearDown(() {
    notifier.dispose();
  });

  group('BatchExecutionNotifier._onWorkerEvent', () {
    test('ProgressEvent with stats updates state.stats', () {
      const stats = BatchStats(totalApiCalls: 10, completedApiCalls: 3);
      final event = ProgressEvent(
        const BatchProgress(callCounter: 3, progressPercent: 0.3),
        stats: stats,
      );

      notifier.handleWorkerEventForTest(event);

      expect(notifier.state.status, BatchExecutionStatus.running);
      expect(notifier.state.stats, isNotNull);
      expect(notifier.state.stats!.completedApiCalls, 3);
      expect(notifier.state.progress!.callCounter, 3);
    });

    test('ProgressEvent without stats keeps existing stats', () {
      // Set initial stats
      notifier.handleWorkerEventForTest(ProgressEvent(
        const BatchProgress(callCounter: 1),
        stats: const BatchStats(totalApiCalls: 10, completedApiCalls: 1),
      ));

      // Then event without stats
      notifier.handleWorkerEventForTest(ProgressEvent(
        const BatchProgress(callCounter: 2),
      ));

      expect(notifier.state.stats, isNotNull);
      expect(notifier.state.stats!.completedApiCalls, 1); // old stats kept
      expect(notifier.state.progress!.callCounter, 2); // progress updated
    });

    test('ProgressEvent overwrites old stats with new stats', () {
      notifier.handleWorkerEventForTest(ProgressEvent(
        const BatchProgress(callCounter: 1),
        stats: const BatchStats(completedApiCalls: 1),
      ));

      notifier.handleWorkerEventForTest(ProgressEvent(
        const BatchProgress(callCounter: 2),
        stats: const BatchStats(completedApiCalls: 5),
      ));

      expect(notifier.state.stats!.completedApiCalls, 5);
    });

    test('LogEvent appends to logs', () {
      final entry = LogEntry(
        level: LogLevel.info,
        message: 'Test log',
        timestamp: DateTime.now(),
      );
      notifier.handleWorkerEventForTest(LogEvent(entry));

      expect(notifier.state.logs.length, 1);
      expect(notifier.state.logs.first.message, 'Test log');
    });

    test('CheckpointSavedEvent adds checkpoint log entry', () {
      notifier.handleWorkerEventForTest(CheckpointSavedEvent(42));

      expect(notifier.state.logs.length, 1);
      expect(notifier.state.logs.first.message, contains('42'));
      expect(notifier.state.logs.first.level, LogLevel.info);
    });

    test('BatchCompletedEvent sets completed status with stats and results',
        () {
      final results = [
        {'id': '1', 'output': 'done'},
      ];
      notifier.handleWorkerEventForTest(BatchCompletedEvent(
        stats: const BatchStats(totalApiCalls: 5, completedApiCalls: 5),
        results: results,
      ));

      expect(notifier.state.status, BatchExecutionStatus.completed);
      expect(notifier.state.stats!.completedApiCalls, 5);
      expect(notifier.state.results.length, 1);
    });

    test('BatchErrorEvent sets failed status with error message', () {
      notifier.handleWorkerEventForTest(BatchErrorEvent(
        message: 'API timeout',
        details: 'Connection refused',
      ));

      expect(notifier.state.status, BatchExecutionStatus.failed);
      expect(notifier.state.errorMessage, 'API timeout');
    });
  });
}
