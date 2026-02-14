import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'database_provider.dart';

/// Whether the initial setup has been completed.
final isSetupCompleteProvider = FutureProvider<bool>((ref) async {
  final db = ref.watch(databaseProvider);
  final value = await db.settingsDao.getValue('setup_complete');
  return value == 'true';
});

/// The user's selected locale, loaded from settings DB.
final localeProvider = StateProvider<Locale>((ref) {
  return const Locale('de');
});

/// Loads the persisted language setting and updates [localeProvider].
final localeLoaderProvider = FutureProvider<void>((ref) async {
  final db = ref.read(databaseProvider);
  final lang = await db.settingsDao.getValue('language');
  if (lang != null) {
    ref.read(localeProvider.notifier).state = Locale(lang);
  }
});
