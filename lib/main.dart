import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logging/logging.dart';

import 'app.dart';
import 'providers/batch_execution_provider.dart';

final _log = Logger('XtractAid');

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Configure logging.
  Logger.root.level = kDebugMode ? Level.ALL : Level.WARNING;
  Logger.root.onRecord.listen((record) {
    debugPrint(
      '[${record.level.name}] ${record.loggerName}: ${record.message}',
    );
    if (record.error != null) {
      debugPrint('  Error: ${record.error}');
    }
    if (record.stackTrace != null) {
      debugPrint('  Stack: ${record.stackTrace}');
    }
  });

  // Global Flutter framework error handler (rendering, layout, etc.).
  FlutterError.onError = (details) {
    _log.severe(
      'FlutterError: ${details.exceptionAsString()}',
      details.exception,
      details.stack,
    );
    // In debug mode, also print the full Flutter-style report.
    if (kDebugMode) {
      FlutterError.dumpErrorToConsole(details);
    }
  };

  // Global handler for errors not caught by Flutter framework
  // (async errors, isolate errors, etc.).
  PlatformDispatcher.instance.onError = (error, stack) {
    _log.severe('Uncaught platform error', error, stack);
    return true; // Prevent app crash.
  };

  final container = ProviderContainer();

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: _AppLifecycleWrapper(
        container: container,
        child: const XtractAidApp(),
      ),
    ),
  );
}

/// Watches app lifecycle to checkpoint running batches on pause/detach.
class _AppLifecycleWrapper extends StatefulWidget {
  const _AppLifecycleWrapper({
    required this.container,
    required this.child,
  });

  final ProviderContainer container;
  final Widget child;

  @override
  State<_AppLifecycleWrapper> createState() => _AppLifecycleWrapperState();
}

class _AppLifecycleWrapperState extends State<_AppLifecycleWrapper>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      _checkpointRunningBatch();
    }
  }

  void _checkpointRunningBatch() {
    try {
      final notifier =
          widget.container.read(batchExecutionProvider.notifier);
      final batchState = widget.container.read(batchExecutionProvider);

      if (batchState.status == BatchExecutionStatus.running) {
        _log.info('App pausing — pausing running batch for checkpoint.');
        notifier.pause();
      }
    } catch (e) {
      _log.warning('Could not checkpoint batch on lifecycle change: $e');
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
