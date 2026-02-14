import 'package:flutter/material.dart';

import '../../data/models/cost_estimate.dart';

class CostEstimateCard extends StatelessWidget {
  const CostEstimateCard({super.key, required this.estimate});

  final CostEstimate estimate;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Kosten-Vorschau'),
            const SizedBox(height: 6),
            Text('Input-Tokens: ${estimate.estimatedInputTokens}'),
            Text('Output-Tokens: ${estimate.estimatedOutputTokens}'),
            Text('API-Calls: ${estimate.estimatedApiCalls}'),
            Text(
              'Gesamt: ${estimate.estimatedCostUsd.toStringAsFixed(4)} ${estimate.currency}',
            ),
            const Text(
              'Schaetzung basierend auf modellnahem GPT-4o/o1-Tokenizer.',
            ),
          ],
        ),
      ),
    );
  }
}
