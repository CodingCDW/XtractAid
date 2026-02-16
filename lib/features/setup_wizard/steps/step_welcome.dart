import 'package:flutter/material.dart';

import '../../../core/l10n/generated/app_localizations.dart';

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
    final t = S.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.auto_awesome, color: theme.colorScheme.primary),
            const SizedBox(width: 8),
            Text(t.appTitle, style: theme.textTheme.headlineSmall),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          t.setupDescription,
          style: theme.textTheme.bodyMedium,
        ),
        const SizedBox(height: 24),
        DropdownButtonFormField<String>(
          initialValue: language,
          decoration: InputDecoration(
            labelText: t.labelLanguage,
            border: const OutlineInputBorder(),
          ),
          items: [
            DropdownMenuItem(value: 'de', child: Text(t.setupGermanLabel)),
            DropdownMenuItem(value: 'en', child: Text(t.setupEnglishLabel)),
          ],
          onChanged: onLanguageChanged,
        ),
      ],
    );
  }
}
