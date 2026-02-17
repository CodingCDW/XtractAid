import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n/generated/app_localizations.dart';
import '../../data/database/app_database.dart';
import '../../providers/database_provider.dart';
import '../../services/project_model_access_service.dart';

class ProjectDetailScreen extends ConsumerWidget {
  const ProjectDetailScreen({super.key, required this.projectId});

  final String projectId;

  Future<Project?> _loadProject(AppDatabase db) async {
    await db.batchesDao.recoverStaleRunningBatches();
    return db.projectsDao.getById(projectId);
  }

  Future<void> _openResultsFolder(
    BuildContext context,
    String projectPath,
  ) async {
    final t = S.of(context)!;
    final resultsDirectory = Directory('$projectPath/results');

    try {
      if (!await resultsDirectory.exists()) {
        await resultsDirectory.create(recursive: true);
      }

      final opened = await _openDirectoryInFileManager(resultsDirectory.path);
      if (!opened && context.mounted) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(content: Text(t.projectDetailOpenResultsError)),
          );
      }
    } catch (_) {
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text(t.projectDetailOpenResultsError)),
        );
    }
  }

  Future<bool> _openDirectoryInFileManager(String path) async {
    try {
      if (Platform.isWindows) {
        final windowsPath = path.replaceAll('/', r'\');
        try {
          await Process.start('explorer.exe', [windowsPath], runInShell: true);
          return true;
        } on ProcessException {
          // Fallback for environments where explorer isn't on PATH.
          final windir = Platform.environment['WINDIR'] ?? r'C:\Windows';
          await Process.start('$windir\\explorer.exe', [
            windowsPath,
          ], runInShell: true);
          return true;
        }
      } else if (Platform.isMacOS) {
        await Process.start('open', [path], runInShell: true);
        return true;
      } else if (Platform.isLinux) {
        await Process.start('xdg-open', [path], runInShell: true);
        return true;
      } else {
        return false;
      }
    } on ProcessException {
      return false;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = S.of(context)!;
    final db = ref.watch(databaseProvider);

    return FutureBuilder(
      future: _loadProject(db),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final project = snapshot.data;
        if (project == null) {
          return Center(child: Text(t.projectsNotFound));
        }

        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          project.name,
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 4),
                        Text(project.path),
                      ],
                    ),
                  ),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      OutlinedButton.icon(
                        onPressed: () =>
                            _openResultsFolder(context, project.path),
                        icon: const Icon(Icons.folder_open_outlined),
                        label: Text(t.projectDetailOpenResults),
                      ),
                      FilledButton.icon(
                        onPressed: () =>
                            context.go('/projects/$projectId/batch/new'),
                        icon: const Icon(Icons.add),
                        label: Text(t.projectDetailNewBatch),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _ProjectModelAccessCard(projectId: projectId),
              const SizedBox(height: 16),
              Expanded(
                child: DefaultTabController(
                  length: 3,
                  child: Column(
                    children: [
                      TabBar(
                        tabs: [
                          Tab(text: t.projectDetailBatches),
                          Tab(text: t.projectDetailPrompts),
                          Tab(text: t.projectDetailInput),
                        ],
                      ),
                      Expanded(
                        child: TabBarView(
                          children: [
                            StreamBuilder(
                              stream: db.batchesDao.watchByProject(projectId),
                              builder: (context, batchSnapshot) {
                                final batches = batchSnapshot.data ?? const [];
                                if (batches.isEmpty) {
                                  return Center(
                                    child: Text(t.projectDetailNoBatches),
                                  );
                                }
                                return ListView.separated(
                                  itemCount: batches.length,
                                  separatorBuilder: (_, _) =>
                                      const Divider(height: 1),
                                  itemBuilder: (context, index) {
                                    final batch = batches[index];
                                    return ListTile(
                                      title: Text(batch.name),
                                      subtitle: Text(
                                        '${t.labelStatus} ${batch.status}',
                                      ),
                                      trailing: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            tooltip: t.actionChange,
                                            icon: const Icon(
                                              Icons.edit_outlined,
                                            ),
                                            onPressed: batch.status == 'running'
                                                ? null
                                                : () => context.go(
                                                    '/projects/$projectId/batch/${batch.id}/edit',
                                                  ),
                                          ),
                                          IconButton(
                                            tooltip: t.actionDelete,
                                            icon: const Icon(
                                              Icons.delete_outline,
                                            ),
                                            onPressed: batch.status == 'running'
                                                ? null
                                                : () async {
                                                    final confirmed =
                                                        await showDialog<bool>(
                                                          context: context,
                                                          builder: (ctx) => AlertDialog(
                                                            title: Text(
                                                              t.batchDeleteTitle,
                                                            ),
                                                            content: Text(
                                                              t.batchDeleteDesc(
                                                                batch.name,
                                                              ),
                                                            ),
                                                            actions: [
                                                              TextButton(
                                                                onPressed: () =>
                                                                    Navigator.of(
                                                                      ctx,
                                                                    ).pop(
                                                                      false,
                                                                    ),
                                                                child: Text(
                                                                  t.actionCancel,
                                                                ),
                                                              ),
                                                              FilledButton(
                                                                onPressed: () =>
                                                                    Navigator.of(
                                                                      ctx,
                                                                    ).pop(true),
                                                                child: Text(
                                                                  t.actionDelete,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        );
                                                    if (confirmed == true) {
                                                      await db.batchesDao
                                                          .deleteBatch(
                                                            batch.id,
                                                          );
                                                    }
                                                  },
                                          ),
                                        ],
                                      ),
                                      onTap: () => context.go(
                                        '/projects/$projectId/batch/${batch.id}',
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                            _DirectoryFilesView(
                              directoryPath: '${project.path}/prompts',
                              extensions: const ['.txt', '.md'],
                              emptyMessage: t.projectDetailNoPromptFiles,
                            ),
                            _DirectoryFilesView(
                              directoryPath: '${project.path}/input',
                              extensions: const [
                                '.xlsx',
                                '.xls',
                                '.csv',
                                '.pdf',
                                '.docx',
                                '.txt',
                                '.md',
                              ],
                              emptyMessage: t.projectDetailNoInputFiles,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ProjectModelAccessCard extends ConsumerStatefulWidget {
  const _ProjectModelAccessCard({required this.projectId});

  final String projectId;

  @override
  ConsumerState<_ProjectModelAccessCard> createState() =>
      _ProjectModelAccessCardState();
}

class _ProjectModelAccessCardState
    extends ConsumerState<_ProjectModelAccessCard> {
  final _projectModelAccessService = ProjectModelAccessService();

  bool _isLoading = true;
  bool _isSaving = false;
  bool _strictLocalModeEnabled = false;
  ProjectModelAccessMode _storedMode = ProjectModelAccessMode.allowRemote;

  @override
  void initState() {
    super.initState();
    _loadMode();
  }

  Future<void> _loadMode() async {
    final db = ref.read(databaseProvider);
    final strictLocalMode = await _projectModelAccessService
        .isStrictLocalModeEnabled(db);
    final storedMode = await _projectModelAccessService.getStoredProjectMode(
      db,
      widget.projectId,
    );
    if (!mounted) {
      return;
    }
    setState(() {
      _strictLocalModeEnabled = strictLocalMode;
      _storedMode = storedMode;
      _isLoading = false;
    });
  }

  Future<void> _setMode(ProjectModelAccessMode mode) async {
    if (_isSaving) {
      return;
    }
    setState(() {
      _isSaving = true;
    });
    try {
      final db = ref.read(databaseProvider);
      await _projectModelAccessService.setProjectMode(
        db,
        widget.projectId,
        mode,
      );
      if (!mounted) {
        return;
      }
      setState(() {
        _storedMode = mode;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: Text('Failed to save project mode.')),
        );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = S.of(context)!;
    if (_isLoading) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: LinearProgressIndicator(),
        ),
      );
    }

    final isGerman = Localizations.localeOf(context).languageCode == 'de';
    final effectiveMode = _strictLocalModeEnabled
        ? ProjectModelAccessMode.localOnly
        : _storedMode;

    final title = isGerman ? 'Projektmodus' : 'Project Mode';
    final subtitle = _strictLocalModeEnabled
        ? t.settingsStrictLocalModeDesc
        : effectiveMode == ProjectModelAccessMode.localOnly
        ? (isGerman
              ? 'Nur lokale Provider fur dieses Projekt (Ollama, LM Studio).'
              : 'Only local providers for this project (Ollama, LM Studio).')
        : (isGerman
              ? 'Lokale und Cloud-Provider sind fur dieses Projekt erlaubt.'
              : 'Local and cloud providers are allowed for this project.');

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 6),
            Text(subtitle),
            const SizedBox(height: 10),
            SegmentedButton<ProjectModelAccessMode>(
              segments: [
                ButtonSegment<ProjectModelAccessMode>(
                  value: ProjectModelAccessMode.localOnly,
                  icon: const Icon(Icons.computer_outlined),
                  label: Text(t.labelLocal),
                ),
                ButtonSegment<ProjectModelAccessMode>(
                  value: ProjectModelAccessMode.allowRemote,
                  icon: const Icon(Icons.cloud_outlined),
                  label: Text(t.labelCloud),
                ),
              ],
              selected: {effectiveMode},
              onSelectionChanged: _strictLocalModeEnabled || _isSaving
                  ? null
                  : (selection) {
                      if (selection.isEmpty) {
                        return;
                      }
                      _setMode(selection.first);
                    },
            ),
          ],
        ),
      ),
    );
  }
}

class _DirectoryFilesView extends StatelessWidget {
  const _DirectoryFilesView({
    required this.directoryPath,
    required this.extensions,
    required this.emptyMessage,
  });

  final String directoryPath;
  final List<String> extensions;
  final String emptyMessage;

  Future<List<FileSystemEntity>> _loadFiles() async {
    final directory = Directory(directoryPath);
    if (!await directory.exists()) {
      return const [];
    }

    final files = await directory
        .list()
        .where((entity) => entity is File)
        .where((entity) {
          final lower = entity.path.toLowerCase();
          for (final ext in extensions) {
            if (lower.endsWith(ext)) {
              return true;
            }
          }
          return false;
        })
        .toList();

    files.sort((a, b) => a.path.compareTo(b.path));
    return files;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<FileSystemEntity>>(
      future: _loadFiles(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final files = snapshot.data ?? const [];
        if (files.isEmpty) {
          return Center(child: Text(emptyMessage));
        }

        return ListView.separated(
          itemCount: files.length,
          separatorBuilder: (_, _) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final entity = files[index];
            final name = entity.path.split(Platform.pathSeparator).last;
            return ListTile(
              leading: const Icon(Icons.description_outlined),
              title: Text(name),
              subtitle: Text(entity.path),
            );
          },
        );
      },
    );
  }
}
