import 'package:flutter/material.dart';

import '../../core/l10n/generated/app_localizations.dart';

class PrivacyWarningResult {
  const PrivacyWarningResult({
    required this.accepted,
    required this.doNotShowAgain,
  });

  final bool accepted;
  final bool doNotShowAgain;
}

class PrivacyWarningDialog extends StatefulWidget {
  const PrivacyWarningDialog({
    super.key,
    required this.provider,
    required this.region,
  });

  final String provider;
  final String region;

  @override
  State<PrivacyWarningDialog> createState() => _PrivacyWarningDialogState();
}

class _PrivacyWarningDialogState extends State<PrivacyWarningDialog> {
  bool _doNotShowAgain = false;

  @override
  Widget build(BuildContext context) {
    final t = S.of(context)!;
    return AlertDialog(
      title: Text(t.privacyTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            t.privacyMessage(widget.provider, widget.region),
          ),
          const SizedBox(height: 12),
          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            value: _doNotShowAgain,
            onChanged: (value) => setState(() => _doNotShowAgain = value ?? false),
            title: Text(t.privacyDontShowAgain),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(
            PrivacyWarningResult(accepted: false, doNotShowAgain: _doNotShowAgain),
          ),
          child: Text(t.actionCancel),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(
            PrivacyWarningResult(accepted: true, doNotShowAgain: _doNotShowAgain),
          ),
          child: Text(t.privacyUnderstood),
        ),
      ],
    );
  }
}
