import 'package:go_router/go_router.dart';

import '../../features/auth/password_screen.dart';
import '../../features/batch_execution/batch_execution_screen.dart';
import '../../features/batch_wizard/batch_wizard_screen.dart';
import '../../features/project_manager/project_detail_screen.dart';
import '../../features/project_manager/project_manager_screen.dart';
import '../../features/model_manager/model_manager_screen.dart';
import '../../features/settings/settings_screen.dart';
import '../../features/setup_wizard/setup_wizard_screen.dart';
import '../shell/app_shell.dart';

abstract final class AppRouter {
  static GoRouter create({required bool isSetupComplete}) {
    return GoRouter(
      initialLocation: isSetupComplete ? '/auth' : '/setup',
      routes: [
        GoRoute(
          path: '/setup',
          builder: (context, state) => const SetupWizardScreen(),
        ),
        GoRoute(
          path: '/auth',
          builder: (context, state) => const PasswordScreen(),
        ),
        ShellRoute(
          builder: (context, state, child) => AppShell(child: child),
          routes: [
            GoRoute(
              path: '/projects',
              builder: (context, state) => const ProjectManagerScreen(),
              routes: [
                GoRoute(
                  path: ':projectId',
                  builder: (context, state) {
                    final projectId = state.pathParameters['projectId']!;
                    return ProjectDetailScreen(projectId: projectId);
                  },
                  routes: [
                    GoRoute(
                      path: 'batch/new',
                      builder: (context, state) {
                        final projectId = state.pathParameters['projectId']!;
                        return BatchWizardScreen(projectId: projectId);
                      },
                    ),
                    GoRoute(
                      path: 'batch/:batchId',
                      builder: (context, state) {
                        final projectId = state.pathParameters['projectId']!;
                        final batchId = state.pathParameters['batchId']!;
                        return BatchExecutionScreen(
                          projectId: projectId,
                          batchId: batchId,
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
            GoRoute(
              path: '/models',
              builder: (context, state) => const ModelManagerScreen(),
            ),
            GoRoute(
              path: '/settings',
              builder: (context, state) => const SettingsScreen(),
            ),
          ],
        ),
      ],
    );
  }
}
