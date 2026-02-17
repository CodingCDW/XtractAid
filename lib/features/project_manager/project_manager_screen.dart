import 'package:drift/drift.dart' show Value;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';

import '../../core/constants/app_constants.dart';
import '../../data/database/app_database.dart';
import '../../providers/database_provider.dart';
import '../../providers/project_provider.dart';
import '../../core/l10n/generated/app_localizations.dart';
import '../../services/project_model_access_service.dart';
import '../../services/project_file_service.dart';
import 'widgets/new_project_dialog.dart';
import 'widgets/open_project_dialog.dart';
import 'widgets/project_card.dart';

class ProjectManagerScreen extends ConsumerStatefulWidget {
  const ProjectManagerScreen({super.key});

  @override
  ConsumerState<ProjectManagerScreen> createState() =>
      _ProjectManagerScreenState();
}

class _ProjectManagerScreenState extends ConsumerState<ProjectManagerScreen> {
  final _projectFileService = ProjectFileService();
  final _projectModelAccessService = ProjectModelAccessService();
  bool _isBusy = false;

  Future<String?> _pickDirectory() {
    return FilePicker.platform.getDirectoryPath();
  }

  Future<void> _createProject() async {
    final dialogResult = await showDialog<NewProjectDialogResult>(
      context: context,
      builder: (context) => NewProjectDialog(onPickDirectory: _pickDirectory),
    );

    if (dialogResult == null) {
      return;
    }

    final db = ref.read(databaseProvider);
    final projectId = const Uuid().v4();
    final projectPath = p.join(dialogResult.baseDirectory, dialogResult.name);

    setState(() {
      _isBusy = true;
    });

    try {
      await _projectFileService.createProject(
        path: projectPath,
        name: dialogResult.name,
        projectId: projectId,
      );

      await db.projectsDao.insertProject(
        ProjectsCompanion(
          id: Value(projectId),
          name: Value(dialogResult.name),
          path: Value(projectPath),
          lastOpenedAt: Value(DateTime.now()),
        ),
      );
      await db.projectsDao.touchLastOpened(projectId);

      final project = await db.projectsDao.getById(projectId);
      ref.read(currentProjectProvider.notifier).state = project;

      if (!mounted) {
        return;
      }
      context.go('/projects/$projectId');
    } catch (_) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text(S.of(context)!.projectsCreateError)),
        );
    } finally {
      if (mounted) {
        setState(() {
          _isBusy = false;
        });
      }
    }
  }

  Future<void> _openProjectFolder() async {
    final dialogResult = await showDialog<OpenProjectDialogResult>(
      context: context,
      builder: (context) => OpenProjectDialog(onPickDirectory: _pickDirectory),
    );

    if (dialogResult == null) {
      return;
    }

    setState(() {
      _isBusy = true;
    });

    final db = ref.read(databaseProvider);

    try {
      final validated = await _projectFileService.validateProject(
        dialogResult.directory,
      );
      if (validated == null) {
        if (!mounted) {
          return;
        }
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(content: Text(S.of(context)!.projectsInvalidProject)),
          );
        return;
      }

      final projectId = (validated['id'] as String?)?.trim().isNotEmpty == true
          ? validated['id'] as String
          : const Uuid().v4();
      final projectName =
          (validated['name'] as String?)?.trim().isNotEmpty == true
          ? validated['name'] as String
          : p.basename(dialogResult.directory);

      final existing = await db.projectsDao.getById(projectId);
      if (existing == null) {
        await db.projectsDao.insertProject(
          ProjectsCompanion(
            id: Value(projectId),
            name: Value(projectName),
            path: Value(dialogResult.directory),
            lastOpenedAt: Value(DateTime.now()),
          ),
        );
      } else {
        await db.projectsDao.updateProject(
          projectId,
          ProjectsCompanion(
            name: Value(projectName),
            path: Value(dialogResult.directory),
            updatedAt: Value(DateTime.now()),
          ),
        );
      }

      await db.projectsDao.touchLastOpened(projectId);
      final project = await db.projectsDao.getById(projectId);
      ref.read(currentProjectProvider.notifier).state = project;

      if (!mounted) {
        return;
      }
      context.go('/projects/$projectId');
    } catch (_) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text(S.of(context)!.projectsOpenError)),
        );
    } finally {
      if (mounted) {
        setState(() {
          _isBusy = false;
        });
      }
    }
  }

  Future<void> _openKnownProject(Project project) async {
    final db = ref.read(databaseProvider);
    await db.projectsDao.touchLastOpened(project.id);
    final updated = await db.projectsDao.getById(project.id);
    ref.read(currentProjectProvider.notifier).state = updated;

    if (!mounted) {
      return;
    }
    context.go('/projects/${project.id}');
  }

  Future<void> _confirmDeleteProject(Project project) async {
    final t = S.of(context)!;
    final action = await showDialog<_ProjectDeleteAction>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(t.actionDelete),
          content: Text(t.projectsDeleteConfirm(project.name, project.path)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(t.actionCancel),
            ),
            OutlinedButton(
              onPressed: () => Navigator.of(
                dialogContext,
              ).pop(_ProjectDeleteAction.removeFromListOnly),
              child: Text(t.projectsDeleteListOnly),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(dialogContext).colorScheme.error,
              ),
              onPressed: () => Navigator.of(
                dialogContext,
              ).pop(_ProjectDeleteAction.deleteCompletely),
              child: Text(t.projectsDeleteProject),
            ),
          ],
        );
      },
    );

    if (action == null) {
      return;
    }

    await _deleteProject(
      project,
      deleteFolderFromDisk: action == _ProjectDeleteAction.deleteCompletely,
    );
  }

  Future<void> _deleteProject(
    Project project, {
    required bool deleteFolderFromDisk,
  }) async {
    final t = S.of(context)!;
    final db = ref.read(databaseProvider);
    setState(() {
      _isBusy = true;
    });

    try {
      final batches = await db.batchesDao.getByProject(project.id);
      for (final batch in batches) {
        await db.batchLogsDao.deleteByBatch(batch.id);
      }
      for (final batch in batches) {
        await db.batchesDao.deleteBatch(batch.id);
      }
      await db.projectsDao.deleteProject(project.id);
      await _projectModelAccessService.deleteProjectMode(db, project.id);

      if (deleteFolderFromDisk) {
        await _projectFileService.deleteProjectFolder(project.path);
      }

      final currentProject = ref.read(currentProjectProvider);
      if (currentProject?.id == project.id) {
        ref.read(currentProjectProvider.notifier).state = null;
      }

      if (!mounted) {
        return;
      }

      final message = deleteFolderFromDisk
          ? t.projectsDeleteSuccessFull(project.name)
          : t.projectsDeleteSuccessList(project.name);
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(message)));
    } catch (e) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(t.projectsDeleteFailed('$e'))));
    } finally {
      if (mounted) {
        setState(() {
          _isBusy = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = S.of(context)!;
    final projectsAsync = ref.watch(projectListProvider);

    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.keyN, control: true): () {
          if (!_isBusy) _createProject();
        },
        const SingleActivator(LogicalKeyboardKey.keyO, control: true): () {
          if (!_isBusy) _openProjectFolder();
        },
      },
      child: Focus(
        autofocus: true,
        child: Scaffold(
          appBar: AppBar(
            title: Text(t.projectsTitle),
            actions: [
              TextButton.icon(
                onPressed: _isBusy ? null : _createProject,
                icon: const Icon(Icons.add),
                label: Text(t.projectsNew),
              ),
              const SizedBox(width: 8),
              TextButton.icon(
                onPressed: _isBusy ? null : _openProjectFolder,
                icon: const Icon(Icons.folder_open),
                label: Text(t.projectsOpen),
              ),
              const SizedBox(width: 12),
            ],
          ),
          body: projectsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) =>
                Center(child: Text(t.errorGeneric(error.toString()))),
            data: (projects) {
              final sorted = [...projects]
                ..sort((a, b) {
                  final aLast = a.lastOpenedAt ?? a.updatedAt;
                  final bLast = b.lastOpenedAt ?? b.updatedAt;
                  return bLast.compareTo(aLast);
                });
              final recent = sorted
                  .take(AppConstants.recentProjectsLimit)
                  .toList();

              if (recent.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.folder_copy_outlined, size: 56),
                      const SizedBox(height: 12),
                      Text(t.projectsEmpty),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: recent.length,
                itemBuilder: (context, index) {
                  final project = recent[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: ProjectCard(
                      project: project,
                      isBusy: _isBusy,
                      onOpen: () => _openKnownProject(project),
                      onDelete: () => _confirmDeleteProject(project),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}

enum _ProjectDeleteAction { removeFromListOnly, deleteCompletely }
