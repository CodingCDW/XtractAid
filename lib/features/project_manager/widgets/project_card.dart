import 'package:flutter/material.dart';

import '../../../core/l10n/generated/app_localizations.dart';
import '../../../data/database/app_database.dart';

class ProjectCard extends StatelessWidget {
  const ProjectCard({
    super.key,
    required this.project,
    required this.onOpen,
    this.onDelete,
    this.isBusy = false,
  });

  final Project project;
  final VoidCallback onOpen;
  final VoidCallback? onDelete;
  final bool isBusy;

  String _formatDate(DateTime? dt, String neverLabel) {
    if (dt == null) {
      return neverLabel;
    }
    final local = dt.toLocal();
    return '${local.year.toString().padLeft(4, '0')}-${local.month.toString().padLeft(2, '0')}-${local.day.toString().padLeft(2, '0')} ${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final t = S.of(context)!;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(project.name, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(project.path),
            const SizedBox(height: 8),
            Text(
              '${t.projectsLastOpened} ${_formatDate(project.lastOpenedAt, t.projectsNever)}',
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  OutlinedButton.icon(
                    onPressed: isBusy ? null : onDelete,
                    icon: const Icon(Icons.delete_outline),
                    label: Text(t.actionDelete),
                  ),
                  const SizedBox(width: 8),
                  FilledButton.icon(
                    onPressed: isBusy ? null : onOpen,
                    icon: const Icon(Icons.open_in_new),
                    label: Text(t.actionOpen),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
