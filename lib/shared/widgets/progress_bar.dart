import 'package:flutter/material.dart';

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
    final clamped = progressPercent.clamp(0.0, 100.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LinearProgressIndicator(value: clamped / 100),
        const SizedBox(height: 6),
        Text('${clamped.toStringAsFixed(1)}%  |  $completedCalls/$totalCalls Calls'),
      ],
    );
  }
}
