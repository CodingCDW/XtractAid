import 'package:flutter/material.dart';

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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Setup-Zusammenfassung', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 16),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.hub),
          title: const Text('Provider'),
          subtitle: Text(providerName.isEmpty ? '-' : providerName),
        ),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Icon(
            connectionOk ? Icons.check_circle : Icons.error,
            color: connectionOk ? Colors.green : Theme.of(context).colorScheme.error,
          ),
          title: const Text('Verbindung'),
          subtitle: Text(connectionOk ? 'OK' : 'Nicht getestet/fehlgeschlagen'),
        ),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Icon(
            passwordSet ? Icons.lock : Icons.lock_open,
            color: passwordSet ? Colors.green : Theme.of(context).colorScheme.error,
          ),
          title: const Text('Master-Passwort'),
          subtitle: Text(passwordSet ? 'Gesetzt' : 'Nicht gesetzt'),
        ),
      ],
    );
  }
}
