import 'package:flutter/material.dart';

import '../../../core/l10n/generated/app_localizations.dart';

class StepPassword extends StatelessWidget {
  const StepPassword({
    super.key,
    required this.passwordController,
    required this.confirmController,
    required this.passwordStrength,
    required this.errorText,
    required this.onChanged,
  });

  final TextEditingController passwordController;
  final TextEditingController confirmController;
  final double passwordStrength;
  final String? errorText;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final t = S.of(context)!;
    final color = passwordStrength < 0.34
        ? Colors.red
        : passwordStrength < 0.67
            ? Colors.amber
            : Colors.green;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: passwordController,
          obscureText: true,
          onChanged: (_) => onChanged(),
          decoration: InputDecoration(
            labelText: t.labelPassword,
            border: const OutlineInputBorder(),
            errorText: errorText,
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: confirmController,
          obscureText: true,
          onChanged: (_) => onChanged(),
          decoration: InputDecoration(
            labelText: t.labelConfirmPassword,
            border: const OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        Text(t.passwordStrength),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: passwordStrength,
          minHeight: 10,
          backgroundColor: Colors.grey.shade300,
          valueColor: AlwaysStoppedAnimation<Color>(color),
        ),
        const SizedBox(height: 8),
        Text(
          passwordStrength < 0.34
              ? t.passwordWeak
              : passwordStrength < 0.67
                  ? t.passwordMedium
                  : t.passwordStrong,
        ),
      ],
    );
  }
}
