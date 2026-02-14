import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/database/app_database.dart';
import 'database_provider.dart';

final projectListProvider = StreamProvider<List<Project>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.projectsDao.watchAll();
});

final currentProjectProvider = StateProvider<Project?>((ref) => null);
