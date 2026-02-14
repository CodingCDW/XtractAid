import 'package:flutter/material.dart';

import '../../../core/l10n/generated/app_localizations.dart';
import '../../../data/models/cost_estimate.dart';
import '../../../shared/widgets/cost_estimate_card.dart';

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
    final t = S.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('${t.confirmItems} $itemCount'),
        Text('${t.confirmSource} ${inputPath ?? '-'}'),
        Text('${t.confirmPrompts} ${selectedPrompts.isEmpty ? '-' : selectedPrompts.join(', ')}'),
        Text('${t.confirmChunkSize} $chunkSize'),
        Text('${t.confirmRepetitions} $repetitions'),
        Text('${t.confirmTotalCalls} $totalCalls'),
        Text('${t.confirmModel} $modelLabel'),
        const SizedBox(height: 12),
        CostEstimateCard(estimate: costEstimate),
        if (requirePrivacyConfirmation)
          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            value: privacyConfirmed,
            onChanged: onPrivacyChanged,
            title: Text(t.confirmPrivacyCheckbox),
          ),
      ],
    );
  }
}
