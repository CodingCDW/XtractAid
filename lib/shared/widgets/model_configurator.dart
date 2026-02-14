import 'package:flutter/material.dart';

import '../../data/models/model_info.dart';

class ModelConfigurator extends StatelessWidget {
  const ModelConfigurator({
    super.key,
    required this.parameters,
    required this.parameterValues,
    required this.onParameterChanged,
  });

  final Map<String, ModelParameter> parameters;
  final Map<String, dynamic> parameterValues;
  final void Function(String key, dynamic value) onParameterChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: parameters.entries
          .where((entry) => entry.value.supported)
          .map(
            (entry) => _ParameterField(
              name: entry.key,
              parameter: entry.value,
              value: parameterValues[entry.key],
              onChanged: (value) => onParameterChanged(entry.key, value),
            ),
          )
          .toList(),
    );
  }
}

class _ParameterField extends StatelessWidget {
  const _ParameterField({
    required this.name,
    required this.parameter,
    required this.value,
    required this.onChanged,
  });

  final String name;
  final ModelParameter parameter;
  final dynamic value;
  final ValueChanged<dynamic> onChanged;

  @override
  Widget build(BuildContext context) {
    final type = parameter.type ?? 'float';

    if (type == 'enum') {
      final values = parameter.values ?? const <String>[];
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: DropdownButtonFormField<String>(
          initialValue: value?.toString(),
          decoration: InputDecoration(
            labelText: name,
            border: const OutlineInputBorder(),
          ),
          items: values
              .map((v) => DropdownMenuItem<String>(value: v, child: Text(v)))
              .toList(),
          onChanged: onChanged,
        ),
      );
    }

    final min = parameter.min ?? (type == 'integer' ? 1 : 0);
    final max = parameter.max ?? (type == 'integer' ? 100 : 2);
    final current = (value is num)
        ? value.toDouble()
        : (parameter.defaultValue is num
            ? (parameter.defaultValue as num).toDouble()
            : min);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$name: ${type == 'integer' ? current.round() : current.toStringAsFixed(2)}'),
          Slider(
            value: current.clamp(min, max),
            min: min,
            max: max,
            divisions: type == 'integer'
                ? (max - min).toInt().clamp(1, 5000)
                : 100,
            onChanged: (newValue) {
              if (type == 'integer') {
                onChanged(newValue.round());
              } else {
                onChanged(double.parse(newValue.toStringAsFixed(2)));
              }
            },
          ),
        ],
      ),
    );
  }
}
