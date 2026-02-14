import 'package:flutter/material.dart';

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
    return AlertDialog(
      title: const Text('Datenschutz-Hinweis'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Sie senden Daten an ${widget.provider} (${widget.region}). DSGVO und interne Richtlinien beachten.',
          ),
          const SizedBox(height: 12),
          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            value: _doNotShowAgain,
            onChanged: (value) => setState(() => _doNotShowAgain = value ?? false),
            title: const Text('Nicht mehr anzeigen'),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(
            PrivacyWarningResult(accepted: false, doNotShowAgain: _doNotShowAgain),
          ),
          child: const Text('Abbrechen'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(
            PrivacyWarningResult(accepted: true, doNotShowAgain: _doNotShowAgain),
          ),
          child: const Text('Verstanden'),
        ),
      ],
    );
  }
}
