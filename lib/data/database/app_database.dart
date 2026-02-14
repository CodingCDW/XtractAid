import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import 'tables/settings_table.dart';
import 'tables/providers_table.dart';
import 'tables/models_table.dart';
import 'tables/projects_table.dart';
import 'tables/batches_table.dart';
import 'tables/batch_logs_table.dart';
import 'daos/settings_dao.dart';
import 'daos/providers_dao.dart';
import 'daos/models_dao.dart';
import 'daos/projects_dao.dart';
import 'daos/batches_dao.dart';
import 'daos/batch_logs_dao.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [Settings, Providers, Models, Projects, Batches, BatchLogs],
  daos: [SettingsDao, ProvidersDao, ModelsDao, ProjectsDao, BatchesDao, BatchLogsDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  AppDatabase.forTesting(super.e);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        // Future migrations go here
      },
    );
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationSupportDirectory();
    final file = File(p.join(dbFolder.path, 'xtractaid.db'));
    return NativeDatabase.createInBackground(file);
  });
}
