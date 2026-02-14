import 'package:flutter/material.dart';

import '../../../data/models/provider_config.dart';

class StepProvider extends StatelessWidget {
  const StepProvider({
    super.key,
    required this.providers,
    required this.selectedProviderId,
    required this.onChanged,
    required this.isLoading,
    required this.errorText,
  });

  final List<ProviderConfig> providers;
  final String? selectedProviderId;
  final ValueChanged<String?> onChanged;
  final bool isLoading;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (errorText != null) {
      return Text(errorText!, style: TextStyle(color: Theme.of(context).colorScheme.error));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButtonFormField<String>(
          initialValue: selectedProviderId,
          decoration: const InputDecoration(
            labelText: 'Provider',
            border: OutlineInputBorder(),
          ),
          items: providers
              .map(
                (provider) => DropdownMenuItem<String>(
                  value: provider.id,
                  child: Text(
                    '${provider.name} (${provider.isLocal ? 'lokal' : 'cloud'})',
                  ),
                ),
              )
              .toList(),
          onChanged: onChanged,
        ),
        const SizedBox(height: 16),
        const Text(
          'Cloud-Provider benoetigen einen API-Key. Lokale Provider (Ollama, LM Studio) laufen auf Ihrem Rechner.',
        ),
      ],
    );
  }
}
