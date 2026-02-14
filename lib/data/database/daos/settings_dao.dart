import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/settings_table.dart';

part 'settings_dao.g.dart';

@DriftAccessor(tables: [Settings])
class SettingsDao extends DatabaseAccessor<AppDatabase>
    with _$SettingsDaoMixin {
  SettingsDao(super.db);

  Future<String?> getValue(String key) async {
    final row = await (select(settings)
          ..where((t) => t.key.equals(key)))
        .getSingleOrNull();
    return row?.value;
  }

  Future<void> setValue(String key, String value) async {
    await into(settings).insertOnConflictUpdate(SettingsCompanion(
      key: Value(key),
      value: Value(value),
      updatedAt: Value(DateTime.now()),
    ));
  }

  Future<void> deleteValue(String key) async {
    await (delete(settings)..where((t) => t.key.equals(key))).go();
  }

  Future<Map<String, String>> getAll() async {
    final rows = await select(settings).get();
    return {for (final r in rows) r.key: r.value};
  }
}
