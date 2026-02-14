import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/batch_logs_table.dart';

part 'batch_logs_dao.g.dart';

@DriftAccessor(tables: [BatchLogs])
class BatchLogsDao extends DatabaseAccessor<AppDatabase>
    with _$BatchLogsDaoMixin {
  BatchLogsDao(super.db);

  Future<List<BatchLog>> getByBatch(String batchId) async {
    return (select(batchLogs)
          ..where((t) => t.batchId.equals(batchId))
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .get();
  }

  Stream<List<BatchLog>> watchByBatch(String batchId) {
    return (select(batchLogs)
          ..where((t) => t.batchId.equals(batchId))
          ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
        .watch();
  }

  Future<void> insertLog(BatchLogsCompanion entry) async {
    await into(batchLogs).insert(entry);
  }

  Future<void> deleteByBatch(String batchId) async {
    await (delete(batchLogs)..where((t) => t.batchId.equals(batchId))).go();
  }
}
