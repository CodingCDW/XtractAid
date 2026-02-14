import 'package:flutter/material.dart';

import '../../core/l10n/generated/app_localizations.dart';
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
    final t = S.of(context)!;
    final saved = checkpoint.savedAt.toLocal();
    return AlertDialog(
      title: Text(t.resumeTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('${t.resumeSaved} ${saved.year}-${saved.month.toString().padLeft(2, '0')}-${saved.day.toString().padLeft(2, '0')} ${saved.hour.toString().padLeft(2, '0')}:${saved.minute.toString().padLeft(2, '0')}'),
          Text('${t.resumeProgress} ${checkpoint.progress.progressPercent.toStringAsFixed(1)}%'),
          Text('${t.resumeCalls} ${checkpoint.stats.completedApiCalls}/${checkpoint.stats.totalApiCalls}'),
          Text('${t.resumeTokens} ${checkpoint.stats.totalInputTokens + checkpoint.stats.totalOutputTokens}'),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(ResumeDecision.restart),
          child: Text(t.resumeRestart),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(ResumeDecision.resume),
          child: Text(t.resumeContinue),
        ),
      ],
    );
  }
}
