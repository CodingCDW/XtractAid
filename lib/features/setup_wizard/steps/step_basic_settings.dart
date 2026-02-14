import 'package:flutter/material.dart';

class StepBasicSettings extends StatelessWidget {
  const StepBasicSettings({
    super.key,
    required this.strictLocalMode,
    required this.onChanged,
  });

  final bool strictLocalMode;
  final ValueChanged<bool?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CheckboxListTile(
          value: strictLocalMode,
          onChanged: onChanged,
          contentPadding: EdgeInsets.zero,
          title: const Text('Strict Local Mode'),
          subtitle: const Text('Nur lokale Provider erlauben (Ollama, LM Studio).'),
        ),
        const SizedBox(height: 8),
        const Text(
          'Diese Einstellungen koennen spaeter in den Einstellungen geaendert werden.',
        ),
      ],
    );
  }
}
