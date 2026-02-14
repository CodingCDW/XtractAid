import 'package:flutter/material.dart';

import '../../data/models/checkpoint.dart';

enum ResumeDecision { restart, resume }

class ResumeDialog extends StatelessWidget {
  const ResumeDialog({
    super.key,
    required this.checkpoint,
  });

  final Checkpoint checkpoint;

  @override
  Widget build(BuildContext context) {
    final saved = checkpoint.savedAt.toLocal();
    return AlertDialog(
      title: const Text('Checkpoint gefunden'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Gespeichert: ${saved.year}-${saved.month.toString().padLeft(2, '0')}-${saved.day.toString().padLeft(2, '0')} ${saved.hour.toString().padLeft(2, '0')}:${saved.minute.toString().padLeft(2, '0')}'),
          Text('Fortschritt: ${checkpoint.progress.progressPercent.toStringAsFixed(1)}%'),
          Text('Calls: ${checkpoint.stats.completedApiCalls}/${checkpoint.stats.totalApiCalls}'),
          Text('Tokens: ${checkpoint.stats.totalInputTokens + checkpoint.stats.totalOutputTokens}'),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(ResumeDecision.restart),
          child: const Text('Neu starten'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(ResumeDecision.resume),
          child: const Text('Fortsetzen'),
        ),
      ],
    );
  }
}
