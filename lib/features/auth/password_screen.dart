import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Placeholder for the Password Screen (Phase 3).
class PasswordScreen extends StatelessWidget {
  const PasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'XtractAid',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: 300,
              child: TextField(
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Master Password',
                  prefixIcon: Icon(Icons.lock),
                ),
                onSubmitted: (_) => context.go('/projects'),
              ),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => context.go('/projects'),
              child: const Text('Unlock'),
            ),
          ],
        ),
      ),
    );
  }
}
