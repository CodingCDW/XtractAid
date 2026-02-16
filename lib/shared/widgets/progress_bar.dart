import 'package:flutter/material.dart';

import '../../core/l10n/generated/app_localizations.dart';

class ProgressBarWidget extends StatelessWidget {
  const ProgressBarWidget({
    super.key,
    required this.progressPercent,
    required this.completedCalls,
    required this.totalCalls,
  });

  final double progressPercent;
  final int completedCalls;
  final int totalCalls;

  @override
  Widget build(BuildContext context) {
    final t = S.of(context)!;
    final clamped = progressPercent.clamp(0.0, 100.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LinearProgressIndicator(value: clamped / 100),
        const SizedBox(height: 6),
        Text(t.execProgressCalls(clamped.toStringAsFixed(1), completedCalls, totalCalls)),
      ],
    );
  }
}
