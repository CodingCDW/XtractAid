import 'package:flutter/material.dart';

import '../../core/l10n/generated/app_localizations.dart';
import '../../data/models/cost_estimate.dart';

class CostEstimateCard extends StatelessWidget {
  const CostEstimateCard({super.key, required this.estimate});

  final CostEstimate estimate;

  @override
  Widget build(BuildContext context) {
    final t = S.of(context)!;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(t.costTitle),
            const SizedBox(height: 6),
            Text('${t.costInputTokens} ${estimate.estimatedInputTokens}'),
            Text('${t.costOutputTokens} ${estimate.estimatedOutputTokens}'),
            Text('${t.costApiCalls} ${estimate.estimatedApiCalls}'),
            Text(
              '${t.costTotal} ${estimate.estimatedCostUsd.toStringAsFixed(4)} ${estimate.currency}',
            ),
            Text(
              t.costDisclaimer,
            ),
          ],
        ),
      ),
    );
  }
}
