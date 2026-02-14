import 'package:flutter/material.dart';

import '../../../core/l10n/generated/app_localizations.dart';

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
    final t = S.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CheckboxListTile(
          value: strictLocalMode,
          onChanged: onChanged,
          contentPadding: EdgeInsets.zero,
          title: Text(t.setupStrictLocalMode),
          subtitle: Text(t.setupStrictLocalModeDesc),
        ),
        const SizedBox(height: 8),
        Text(t.setupSettingsChangeLater),
      ],
    );
  }
}
