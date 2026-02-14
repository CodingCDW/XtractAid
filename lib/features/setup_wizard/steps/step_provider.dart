import 'package:flutter/material.dart';

import '../../../core/l10n/generated/app_localizations.dart';
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
    final t = S.of(context)!;

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
          decoration: InputDecoration(
            labelText: t.labelProvider,
            border: const OutlineInputBorder(),
          ),
          items: providers
              .map(
                (provider) => DropdownMenuItem<String>(
                  value: provider.id,
                  child: Text(
                    '${provider.name} (${provider.isLocal ? t.labelLocal : t.labelCloud})',
                  ),
                ),
              )
              .toList(),
          onChanged: onChanged,
        ),
        const SizedBox(height: 16),
        Text(t.setupProviderHint),
      ],
    );
  }
}
