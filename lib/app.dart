import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'providers/settings_provider.dart';

class XtractAidApp extends ConsumerWidget {
  const XtractAidApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final setupComplete = ref.watch(isSetupCompleteProvider);

    return setupComplete.when(
      data: (isComplete) {
        final router = AppRouter.create(isSetupComplete: isComplete);
        return MaterialApp.router(
          title: 'XtractAid',
          theme: AppTheme.light,
          routerConfig: router,
          debugShowCheckedModeBanner: false,
        );
      },
      loading: () => MaterialApp(
        theme: AppTheme.light,
        home: const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
      ),
      error: (error, stack) => MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: Center(
            child: Text('Error: $error'),
          ),
        ),
      ),
    );
  }
}
