import 'package:flutter/material.dart';

class StepWelcome extends StatelessWidget {
  const StepWelcome({
    super.key,
    required this.language,
    required this.onLanguageChanged,
  });

  final String language;
  final ValueChanged<String?> onLanguageChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.auto_awesome, color: theme.colorScheme.primary),
            const SizedBox(width: 8),
            Text('XtractAid', style: theme.textTheme.headlineSmall),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          'XtractAid analysiert Textdaten aus Dateien in Batches mit LLM-Modellen und erstellt strukturierte Ergebnisse.',
          style: theme.textTheme.bodyMedium,
        ),
        const SizedBox(height: 24),
        DropdownButtonFormField<String>(
          initialValue: language,
          decoration: const InputDecoration(
            labelText: 'Sprache',
            border: OutlineInputBorder(),
          ),
          items: const [
            DropdownMenuItem(value: 'de', child: Text('Deutsch (DE)')),
            DropdownMenuItem(value: 'en', child: Text('English (EN)')),
          ],
          onChanged: onLanguageChanged,
        ),
      ],
    );
  }
}
