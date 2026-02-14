import 'package:flutter/material.dart';

import '../../../core/l10n/generated/app_localizations.dart';

class StepFinish extends StatelessWidget {
  const StepFinish({
    super.key,
    required this.providerName,
    required this.connectionOk,
    required this.passwordSet,
  });

  final String providerName;
  final bool connectionOk;
  final bool passwordSet;

  @override
  Widget build(BuildContext context) {
    final t = S.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(t.setupSummaryTitle, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 16),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.hub),
          title: Text(t.labelProvider),
          subtitle: Text(providerName.isEmpty ? '-' : providerName),
        ),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Icon(
            connectionOk ? Icons.check_circle : Icons.error,
            color: connectionOk ? Colors.green : Theme.of(context).colorScheme.error,
          ),
          title: Text(t.setupSummaryConnection),
          subtitle: Text(connectionOk ? t.setupSummaryConnectionOk : t.setupSummaryConnectionFail),
        ),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Icon(
            passwordSet ? Icons.lock : Icons.lock_open,
            color: passwordSet ? Colors.green : Theme.of(context).colorScheme.error,
          ),
          title: Text(t.labelMasterPassword),
          subtitle: Text(passwordSet ? t.setupSummaryPasswordSet : t.setupSummaryPasswordNotSet),
        ),
      ],
    );
  }
}
