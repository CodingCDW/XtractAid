import 'package:flutter_test/flutter_test.dart';
import 'package:xtractaid/data/models/batch_stats.dart';
import 'package:xtractaid/workers/worker_messages.dart';

void main() {
  group('WorkerMessageCodec', () {
    group('ProgressEvent', () {
      test('encode includes stats when provided', () {
        final event = ProgressEvent(
          const BatchProgress(callCounter: 5, progressPercent: 0.5),
          stats: const BatchStats(totalApiCalls: 10, completedApiCalls: 5),
        );
        final json = WorkerMessageCodec.encodeEvent(event);

        expect(json['type'], 'progress');
        expect(json.containsKey('stats'), true);
        expect(json['stats']['totalApiCalls'], 10);
      });

      test('encode omits stats when null', () {
        final event = ProgressEvent(
          const BatchProgress(callCounter: 1),
        );
        final json = WorkerMessageCodec.encodeEvent(event);

        expect(json['type'], 'progress');
        expect(json.containsKey('stats'), false);
      });

      test('decode with stats populates stats field', () {
        final json = {
          'type': 'progress',
          'progress': const BatchProgress(callCounter: 3).toJson(),
          'stats': const BatchStats(totalApiCalls: 6, completedApiCalls: 3)
              .toJson(),
        };
        final event = WorkerMessageCodec.decodeEvent(json);

        expect(event, isA<ProgressEvent>());
        final progress = event as ProgressEvent;
        expect(progress.stats, isNotNull);
        expect(progress.stats!.totalApiCalls, 6);
      });

      test('decode without stats returns null stats', () {
        final json = {
          'type': 'progress',
          'progress': const BatchProgress(callCounter: 1).toJson(),
        };
        final event = WorkerMessageCodec.decodeEvent(json) as ProgressEvent;

        expect(event.stats, isNull);
      });

      test('roundtrip preserves all fields', () {
        final original = ProgressEvent(
          const BatchProgress(
            callCounter: 7,
            progressPercent: 0.7,
            currentModelId: 'gpt-4o',
          ),
          stats: BatchStats(
            totalApiCalls: 10,
            completedApiCalls: 7,
            totalInputTokens: 500,
            totalOutputTokens: 200,
            totalCost: 0.05,
            startedAt: DateTime(2025, 1, 1),
          ),
        );

        final json = WorkerMessageCodec.encodeEvent(original);
        final decoded = WorkerMessageCodec.decodeEvent(json) as ProgressEvent;

        expect(decoded.progress.callCounter, 7);
        expect(decoded.progress.currentModelId, 'gpt-4o');
        expect(decoded.stats!.totalApiCalls, 10);
        expect(decoded.stats!.totalCost, 0.05);
      });
    });

    group('BatchCompletedEvent', () {
      test('roundtrip with stats and results', () {
        final original = BatchCompletedEvent(
          stats: const BatchStats(totalApiCalls: 5, completedApiCalls: 5),
          results: [
            {'id': '1', 'output': 'result1'},
            {'id': '2', 'output': 'result2'},
          ],
        );

        final json = WorkerMessageCodec.encodeEvent(original);
        final decoded =
            WorkerMessageCodec.decodeEvent(json) as BatchCompletedEvent;

        expect(decoded.stats.completedApiCalls, 5);
        expect(decoded.results.length, 2);
        expect(decoded.results[0]['id'], '1');
      });
    });

    group('BatchErrorEvent', () {
      test('roundtrip with message and details', () {
        final original = BatchErrorEvent(
          message: 'Something failed',
          details: 'Stack trace here',
        );

        final json = WorkerMessageCodec.encodeEvent(original);
        final decoded =
            WorkerMessageCodec.decodeEvent(json) as BatchErrorEvent;

        expect(decoded.message, 'Something failed');
        expect(decoded.details, 'Stack trace here');
      });

      test('roundtrip with null details', () {
        final original = BatchErrorEvent(message: 'Error occurred');

        final json = WorkerMessageCodec.encodeEvent(original);
        final decoded =
            WorkerMessageCodec.decodeEvent(json) as BatchErrorEvent;

        expect(decoded.message, 'Error occurred');
        expect(decoded.details, isNull);
      });
    });

    group('Command encode/decode', () {
      test('PauseBatchCommand roundtrip', () {
        final json = WorkerMessageCodec.encodeCommand(PauseBatchCommand());
        final decoded = WorkerMessageCodec.decodeCommand(json);

        expect(decoded, isA<PauseBatchCommand>());
      });

      test('ResumeBatchCommand roundtrip', () {
        final json = WorkerMessageCodec.encodeCommand(ResumeBatchCommand());
        final decoded = WorkerMessageCodec.decodeCommand(json);

        expect(decoded, isA<ResumeBatchCommand>());
      });

      test('returns null for invalid payload', () {
        expect(WorkerMessageCodec.decodeCommand('not a map'), isNull);
        expect(WorkerMessageCodec.decodeCommand({'no_type': true}), isNull);
        expect(WorkerMessageCodec.decodeCommand({'type': 'unknown'}), isNull);
      });

      test('returns null for invalid event payload', () {
        expect(WorkerMessageCodec.decodeEvent('not a map'), isNull);
        expect(WorkerMessageCodec.decodeEvent({'no_type': true}), isNull);
        expect(WorkerMessageCodec.decodeEvent({'type': 'unknown'}), isNull);
      });
    });
  });
}
