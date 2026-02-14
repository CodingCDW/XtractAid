import 'package:flutter/material.dart';

import '../../../core/l10n/generated/app_localizations.dart';

class StepChunks extends StatelessWidget {
  const StepChunks({
    super.key,
    required this.chunkSize,
    required this.repetitions,
    required this.itemCount,
    required this.promptCount,
    required this.onChunkSizeChanged,
    required this.onRepetitionsChanged,
  });

  final int chunkSize;
  final int repetitions;
  final int itemCount;
  final int promptCount;
  final ValueChanged<double> onChunkSizeChanged;
  final ValueChanged<double> onRepetitionsChanged;

  @override
  Widget build(BuildContext context) {
    final t = S.of(context)!;
    final chunks = itemCount == 0 ? 0 : (itemCount / chunkSize).ceil();
    final totalCalls = chunks * promptCount * repetitions;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('${t.chunksChunkSize} $chunkSize'),
        Slider(
          value: chunkSize.toDouble(),
          min: 1,
          max: 100,
          divisions: 99,
          label: '$chunkSize',
          onChanged: onChunkSizeChanged,
        ),
        const SizedBox(height: 8),
        Text('${t.chunksRepetitions} $repetitions'),
        Slider(
          value: repetitions.toDouble(),
          min: 1,
          max: 100,
          divisions: 99,
          label: '$repetitions',
          onChanged: onRepetitionsChanged,
        ),
        const SizedBox(height: 12),
        Text(t.chunksCalcChunks(itemCount, chunkSize, chunks)),
        Text(t.chunksCalcCalls(chunks, promptCount, repetitions, totalCalls)),
        const SizedBox(height: 8),
        Text(t.chunksTooltip),
      ],
    );
  }
}
