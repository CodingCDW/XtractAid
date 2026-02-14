import 'package:flutter/material.dart';

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
    return DropdownButtonFormField<String>(
      initialValue: selectedModelId,
      decoration: const InputDecoration(
        labelText: 'Model',
        border: OutlineInputBorder(),
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
