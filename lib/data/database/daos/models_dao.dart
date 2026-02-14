import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/models_table.dart';

part 'models_dao.g.dart';

@DriftAccessor(tables: [Models])
class ModelsDao extends DatabaseAccessor<AppDatabase>
    with _$ModelsDaoMixin {
  ModelsDao(super.db);

  Future<List<Model>> getAllUserOverrides() => select(models).get();

  Stream<List<Model>> watchAllUserOverrides() => select(models).watch();

  Future<Model?> getByModelId(String modelId) async {
    return (select(models)..where((t) => t.modelId.equals(modelId)))
        .getSingleOrNull();
  }

  Future<void> upsertOverride(ModelsCompanion entry) async {
    await into(models).insertOnConflictUpdate(entry);
  }

  Future<void> deleteOverride(String modelId) async {
    await (delete(models)..where((t) => t.modelId.equals(modelId))).go();
  }
}
