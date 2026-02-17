import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:xtractaid/data/database/app_database.dart';

import '../../../test_helpers/test_harness.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = createTestDatabase();
  });

  tearDown(() async {
    await db.close();
  });

  /// Helper: insert a batch with the given status.
  Future<void> insertTestBatch(String id, String status) async {
    await db.batchesDao.insertBatch(
      BatchesCompanion(
        id: Value(id),
        projectId: const Value('proj-1'),
        name: Value('Batch $id'),
        configJson: const Value('{}'),
        status: Value(status),
      ),
    );
  }

  group('BatchesDao', () {
    group('recoverStaleRunningBatches', () {
      test('changes running batch to failed', () async {
        await insertTestBatch('b1', 'running');

        final count = await db.batchesDao.recoverStaleRunningBatches();
        expect(count, 1);

        final batch = await db.batchesDao.getById('b1');
        expect(batch!.status, 'failed');
        expect(batch.completedAt, isNotNull);
      });

      test('does not change completed batch', () async {
        await insertTestBatch('b1', 'completed');

        final count = await db.batchesDao.recoverStaleRunningBatches();
        expect(count, 0);

        final batch = await db.batchesDao.getById('b1');
        expect(batch!.status, 'completed');
      });

      test('does not change failed batch', () async {
        await insertTestBatch('b1', 'failed');

        final count = await db.batchesDao.recoverStaleRunningBatches();
        expect(count, 0);

        final batch = await db.batchesDao.getById('b1');
        expect(batch!.status, 'failed');
      });

      test('does not change created batch', () async {
        await insertTestBatch('b1', 'created');

        final count = await db.batchesDao.recoverStaleRunningBatches();
        expect(count, 0);

        final batch = await db.batchesDao.getById('b1');
        expect(batch!.status, 'created');
      });

      test('recovers multiple running batches', () async {
        await insertTestBatch('b1', 'running');
        await insertTestBatch('b2', 'running');
        await insertTestBatch('b3', 'completed');

        final count = await db.batchesDao.recoverStaleRunningBatches();
        expect(count, 2);

        final b1 = await db.batchesDao.getById('b1');
        final b2 = await db.batchesDao.getById('b2');
        final b3 = await db.batchesDao.getById('b3');

        expect(b1!.status, 'failed');
        expect(b2!.status, 'failed');
        expect(b3!.status, 'completed');
      });

      test('returns 0 when no running batches exist', () async {
        await insertTestBatch('b1', 'completed');
        await insertTestBatch('b2', 'failed');

        final count = await db.batchesDao.recoverStaleRunningBatches();
        expect(count, 0);
      });
    });
  });
}
