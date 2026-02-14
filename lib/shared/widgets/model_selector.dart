import 'package:flutter/material.dart';

import '../../core/l10n/generated/app_localizations.dart';
import '../../data/models/model_info.dart';

class ModelSelector extends StatelessWidget {
  const ModelSelector({
    super.key,
    required this.models,
    required this.selectedModelId,
    required this.onChanged,
  });

  final List<ModelInfo> models;
  final String? selectedModelId;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    final t = S.of(context)!;
    return DropdownButtonFormField<String>(
      initialValue: selectedModelId,
      decoration: InputDecoration(
        labelText: t.labelModel,
        border: const OutlineInputBorder(),
      ),
      items: models
          .map(
            (model) => DropdownMenuItem<String>(
              value: model.id,
              child: Text('${model.provider.toUpperCase()} - ${model.displayName}'),
            ),
          )
          .toList(),
      onChanged: onChanged,
    );
  }
}
