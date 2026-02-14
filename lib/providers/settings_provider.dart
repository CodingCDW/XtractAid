import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'database_provider.dart';

/// Whether the initial setup has been completed.
final isSetupCompleteProvider = FutureProvider<bool>((ref) async {
  final db = ref.watch(databaseProvider);
  final value = await db.settingsDao.getValue('setup_complete');
  return value == 'true';
});
