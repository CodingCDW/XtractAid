import 'package:flutter/material.dart';

import '../../../core/l10n/generated/app_localizations.dart';

class StepApiKey extends StatelessWidget {
  const StepApiKey({
    super.key,
    required this.isLocalProvider,
    required this.apiKeyController,
    required this.isTesting,
    required this.connectionTested,
    required this.connectionOk,
    required this.onTestConnection,
  });

  final bool isLocalProvider;
  final TextEditingController apiKeyController;
  final bool isTesting;
  final bool connectionTested;
  final bool connectionOk;
  final VoidCallback onTestConnection;

  @override
  Widget build(BuildContext context) {
    final t = S.of(context)!;
    final color = connectionOk ? Colors.green : Theme.of(context).colorScheme.error;
    final icon = connectionOk ? Icons.check_circle : Icons.error;
    final text = connectionOk ? t.setupConnectionSuccess : t.setupConnectionFailed;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (isLocalProvider)
          Text(t.setupLocalApiKeyHint)
        else
          TextField(
            controller: apiKeyController,
            obscureText: true,
            decoration: InputDecoration(
              labelText: t.labelApiKey,
              border: const OutlineInputBorder(),
            ),
          ),
        const SizedBox(height: 16),
        FilledButton.icon(
          onPressed: isTesting ? null : onTestConnection,
          icon: isTesting
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.network_check),
          label: Text(t.actionTestConnection),
        ),
        const SizedBox(height: 12),
        if (connectionTested)
          Row(
            children: [
              Icon(icon, color: color),
              const SizedBox(width: 8),
              Text(text, style: TextStyle(color: color)),
            ],
          ),
      ],
    );
  }
}
