import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n/generated/app_localizations.dart';
import '../../providers/database_provider.dart';

class ProjectDetailScreen extends ConsumerWidget {
  const ProjectDetailScreen({
    super.key,
    required this.projectId,
  });

  final String projectId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = S.of(context)!;
    final db = ref.watch(databaseProvider);

    return FutureBuilder(
      future: db.projectsDao.getById(projectId),
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
                        Text(project.name, style: Theme.of(context).textTheme.headlineSmall),
                        const SizedBox(height: 4),
                        Text(project.path),
                      ],
                    ),
                  ),
                  FilledButton.icon(
                    onPressed: () => context.go('/projects/$projectId/batch/new'),
                    icon: const Icon(Icons.add),
                    label: Text(t.projectDetailNewBatch),
                  ),
                ],
              ),
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
                                  return Center(child: Text(t.projectDetailNoBatches));
                                }
                                return ListView.separated(
                                  itemCount: batches.length,
                                  separatorBuilder: (_, _) => const Divider(height: 1),
                                  itemBuilder: (context, index) {
                                    final batch = batches[index];
                                    return ListTile(
                                      title: Text(batch.name),
                                      subtitle: Text('${t.labelStatus} ${batch.status}'),
                                      onTap: () => context.go('/projects/$projectId/batch/${batch.id}'),
                                    );
                                  },
                                );
                              },
                            ),
                            _DirectoryFilesView(
                              directoryPath: '${project.path}/prompts',
                              extensions: const ['.txt', '.md'],
                              emptyMessage: 'Keine Prompt-Dateien gefunden.',
                            ),
                            _DirectoryFilesView(
                              directoryPath: '${project.path}/input',
                              extensions: const ['.xlsx', '.xls', '.csv', '.pdf', '.docx', '.txt', '.md'],
                              emptyMessage: 'Keine Input-Dateien gefunden.',
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
