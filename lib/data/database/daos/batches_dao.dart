import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/batches_table.dart';

part 'batches_dao.g.dart';

@DriftAccessor(tables: [Batches])
class BatchesDao extends DatabaseAccessor<AppDatabase> with _$BatchesDaoMixin {
  BatchesDao(super.db);

  Future<List<Batche>> getAll() => select(batches).get();

  Future<List<Batche>> getByProject(String projectId) async {
    return (select(batches)
          ..where((t) => t.projectId.equals(projectId))
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .get();
  }

  Stream<List<Batche>> watchByProject(String projectId) {
    return (select(batches)
          ..where((t) => t.projectId.equals(projectId))
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .watch();
  }

  Future<Batche?> getById(String id) async {
    return (select(batches)..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  Future<void> insertBatch(BatchesCompanion entry) async {
    await into(batches).insert(entry);
  }

  Future<void> updateBatch(String id, BatchesCompanion entry) async {
    await (update(batches)..where((t) => t.id.equals(id))).write(entry);
  }

  Future<void> updateStatus(String id, String status) async {
    await (update(batches)..where((t) => t.id.equals(id))).write(
      BatchesCompanion(status: Value(status), updatedAt: Value(DateTime.now())),
    );
  }

  Future<void> deleteBatch(String id) async {
    await (delete(batches)..where((t) => t.id.equals(id))).go();
  }

  /// On app startup, there cannot be any still-running worker isolate from a
  /// previous session. Mark persisted "running" batches as failed/interrupted.
  Future<int> recoverStaleRunningBatches() async {
    final now = DateTime.now();
    return (update(batches)..where((t) => t.status.equals('running'))).write(
      BatchesCompanion(
        status: const Value('failed'),
        updatedAt: Value(now),
        completedAt: Value(now),
      ),
    );
  }
}
