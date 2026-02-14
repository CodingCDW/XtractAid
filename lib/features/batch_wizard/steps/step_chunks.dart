import 'package:flutter/material.dart';

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
    final chunks = itemCount == 0 ? 0 : (itemCount / chunkSize).ceil();
    final totalCalls = chunks * promptCount * repetitions;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Chunk-Groesse: $chunkSize'),
        Slider(
          value: chunkSize.toDouble(),
          min: 1,
          max: 100,
          divisions: 99,
          label: '$chunkSize',
          onChanged: onChunkSizeChanged,
        ),
        const SizedBox(height: 8),
        Text('Wiederholungen: $repetitions'),
        Slider(
          value: repetitions.toDouble(),
          min: 1,
          max: 100,
          divisions: 99,
          label: '$repetitions',
          onChanged: onRepetitionsChanged,
        ),
        const SizedBox(height: 12),
        Text('$itemCount Items / $chunkSize = $chunks Chunks'),
        Text('$chunks Chunks x $promptCount Prompts x $repetitions Wiederholungen = $totalCalls API-Calls'),
        const SizedBox(height: 8),
        const Text(
          'Bei chunk_size > 1 werden mehrere Items gleichzeitig im Prompt gesendet. Dies spart API-Calls, kann aber die Qualitaet reduzieren.',
        ),
      ],
    );
  }
}
