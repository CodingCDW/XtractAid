import '../core/utils/provider_helpers.dart';
import '../data/database/app_database.dart';

enum ProjectModelAccessMode { allowRemote, localOnly }

extension ProjectModelAccessModeStorage on ProjectModelAccessMode {
  String get storageValue {
    return switch (this) {
      ProjectModelAccessMode.allowRemote => 'allow_remote',
      ProjectModelAccessMode.localOnly => 'local_only',
    };
  }
}

class ProjectModelAccessService {
  static const String strictLocalModeKey = 'strict_local_mode';
  static const String _projectModeKeyPrefix = 'project_model_access_';

  String projectModeKey(String projectId) => '$_projectModeKeyPrefix$projectId';

  Future<bool> isStrictLocalModeEnabled(AppDatabase db) async {
    final raw = await db.settingsDao.getValue(strictLocalModeKey);
    return raw == 'true';
  }

  Future<ProjectModelAccessMode> getStoredProjectMode(
    AppDatabase db,
    String projectId,
  ) async {
    final raw = await db.settingsDao.getValue(projectModeKey(projectId));
    if (raw == ProjectModelAccessMode.localOnly.storageValue) {
      return ProjectModelAccessMode.localOnly;
    }
    return ProjectModelAccessMode.allowRemote;
  }

  Future<ProjectModelAccessMode> getEffectiveProjectMode(
    AppDatabase db,
    String projectId,
  ) async {
    final strictLocalMode = await isStrictLocalModeEnabled(db);
    if (strictLocalMode) {
      return ProjectModelAccessMode.localOnly;
    }
    return getStoredProjectMode(db, projectId);
  }

  Future<void> setProjectMode(
    AppDatabase db,
    String projectId,
    ProjectModelAccessMode mode,
  ) async {
    await db.settingsDao.setValue(projectModeKey(projectId), mode.storageValue);
  }

  Future<void> deleteProjectMode(AppDatabase db, String projectId) async {
    await db.settingsDao.deleteValue(projectModeKey(projectId));
  }

  bool isProviderAllowed(String providerType, ProjectModelAccessMode mode) {
    if (mode == ProjectModelAccessMode.allowRemote) {
      return true;
    }
    return isLocalProviderType(providerType);
  }
}
