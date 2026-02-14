import 'package:flutter/material.dart';

import '../../../data/models/cost_estimate.dart';

class StepConfirm extends StatelessWidget {
  const StepConfirm({
    super.key,
    required this.itemCount,
    required this.inputPath,
    required this.selectedPrompts,
    required this.chunkSize,
    required this.repetitions,
    required this.totalCalls,
    required this.modelLabel,
    required this.costEstimate,
    required this.requirePrivacyConfirmation,
    required this.privacyConfirmed,
    required this.onPrivacyChanged,
  });

  final int itemCount;
  final String? inputPath;
  final List<String> selectedPrompts;
  final int chunkSize;
  final int repetitions;
  final int totalCalls;
  final String modelLabel;
  final CostEstimate costEstimate;
  final bool requirePrivacyConfirmation;
  final bool privacyConfirmed;
  final ValueChanged<bool?> onPrivacyChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Items: $itemCount'),
        Text('Quelle: ${inputPath ?? '-'}'),
        Text('Prompts: ${selectedPrompts.isEmpty ? '-' : selectedPrompts.join(', ')}'),
        Text('Chunk-Groesse: $chunkSize'),
        Text('Wiederholungen: $repetitions'),
        Text('Gesamt API-Calls: $totalCalls'),
        Text('Model: $modelLabel'),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Kosten-Vorschau'),
                const SizedBox(height: 6),
                Text('Input-Tokens: ${costEstimate.estimatedInputTokens}'),
                Text('Output-Tokens: ${costEstimate.estimatedOutputTokens}'),
                Text('API-Calls: ${costEstimate.estimatedApiCalls}'),
                Text('Gesamt: ${costEstimate.estimatedCostUsd.toStringAsFixed(4)} ${costEstimate.currency}'),
                const Text('Schaetzung basierend auf ~4 Zeichen/Token.'),
              ],
            ),
          ),
        ),
        if (requirePrivacyConfirmation)
          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            value: privacyConfirmed,
            onChanged: onPrivacyChanged,
            title: const Text(
              'Ich bestaetige, dass das Senden dieser Daten an den Cloud-Provider mit meinen Datenschutzanforderungen vereinbar ist.',
            ),
          ),
      ],
    );
  }
}
