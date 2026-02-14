import 'package:flutter/material.dart';

import '../../../core/l10n/generated/app_localizations.dart';
import '../../../data/models/model_info.dart';
import '../../../shared/widgets/model_configurator.dart';
import '../../../shared/widgets/model_selector.dart';

class StepModel extends StatelessWidget {
  const StepModel({
    super.key,
    required this.models,
    required this.selectedModelId,
    required this.selectedModelInfo,
    required this.parameters,
    required this.parameterValues,
    required this.onModelChanged,
    required this.onParameterChanged,
  });

  final List<ModelInfo> models;
  final String? selectedModelId;
  final ModelInfo? selectedModelInfo;
  final Map<String, ModelParameter> parameters;
  final Map<String, dynamic> parameterValues;
  final ValueChanged<String?> onModelChanged;
  final void Function(String key, dynamic value) onParameterChanged;

  @override
  Widget build(BuildContext context) {
    final t = S.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ModelSelector(
          models: models,
          selectedModelId: selectedModelId,
          onChanged: onModelChanged,
        ),
        const SizedBox(height: 12),
        if (selectedModelInfo != null)
          Text(
            '${t.modelContext} ${selectedModelInfo!.contextWindow} | ${t.modelPriceLabel} ${selectedModelInfo!.pricing.inputPerMillion}/${selectedModelInfo!.pricing.outputPerMillion} ${selectedModelInfo!.pricing.currency}',
          ),
        const SizedBox(height: 12),
        ModelConfigurator(
          parameters: parameters,
          parameterValues: parameterValues,
          onParameterChanged: onParameterChanged,
        ),
      ],
    );
  }
}
