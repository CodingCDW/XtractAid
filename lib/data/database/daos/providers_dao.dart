import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/providers_table.dart';

part 'providers_dao.g.dart';

@DriftAccessor(tables: [Providers])
class ProvidersDao extends DatabaseAccessor<AppDatabase>
    with _$ProvidersDaoMixin {
  ProvidersDao(super.db);

  Future<List<Provider>> getAll() => select(providers).get();

  Stream<List<Provider>> watchAll() => select(providers).watch();

  Future<Provider?> getById(String id) async {
    return (select(providers)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
  }

  Future<List<Provider>> getEnabled() async {
    return (select(providers)..where((t) => t.isEnabled.equals(true))).get();
  }

  Future<void> insertProvider(ProvidersCompanion entry) async {
    await into(providers).insertOnConflictUpdate(entry);
  }

  Future<void> updateProvider(String id, ProvidersCompanion entry) async {
    await (update(providers)..where((t) => t.id.equals(id))).write(entry);
  }

  Future<void> deleteProvider(String id) async {
    await (delete(providers)..where((t) => t.id.equals(id))).go();
  }
}
