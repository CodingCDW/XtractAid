import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/projects_table.dart';

part 'projects_dao.g.dart';

@DriftAccessor(tables: [Projects])
class ProjectsDao extends DatabaseAccessor<AppDatabase>
    with _$ProjectsDaoMixin {
  ProjectsDao(super.db);

  Future<List<Project>> getAll() => select(projects).get();

  Stream<List<Project>> watchAll() => select(projects).watch();

  Future<List<Project>> getRecent({int limit = 10}) async {
    return (select(projects)
          ..orderBy([
            (t) => OrderingTerm.desc(t.lastOpenedAt),
            (t) => OrderingTerm.desc(t.updatedAt),
          ])
          ..limit(limit))
        .get();
  }

  Future<Project?> getById(String id) async {
    return (select(projects)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
  }

  Future<void> insertProject(ProjectsCompanion entry) async {
    await into(projects).insert(entry);
  }

  Future<void> updateProject(String id, ProjectsCompanion entry) async {
    await (update(projects)..where((t) => t.id.equals(id))).write(entry);
  }

  Future<void> touchLastOpened(String id) async {
    await (update(projects)..where((t) => t.id.equals(id))).write(
      ProjectsCompanion(lastOpenedAt: Value(DateTime.now())),
    );
  }

  Future<void> deleteProject(String id) async {
    await (delete(projects)..where((t) => t.id.equals(id))).go();
  }
}
