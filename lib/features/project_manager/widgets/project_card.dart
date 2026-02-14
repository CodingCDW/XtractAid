import 'package:flutter/material.dart';

import '../../../data/database/app_database.dart';

class ProjectCard extends StatelessWidget {
  const ProjectCard({
    super.key,
    required this.project,
    required this.onOpen,
  });

  final Project project;
  final VoidCallback onOpen;

  String _formatDate(DateTime? dt) {
    if (dt == null) {
      return 'Nie';
    }
    final local = dt.toLocal();
    return '${local.year.toString().padLeft(4, '0')}-${local.month.toString().padLeft(2, '0')}-${local.day.toString().padLeft(2, '0')} ${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
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
            Text('Letzte Oeffnung: ${_formatDate(project.lastOpenedAt)}'),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton.icon(
                onPressed: onOpen,
                icon: const Icon(Icons.open_in_new),
                label: const Text('Oeffnen'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
