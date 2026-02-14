import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/model_registry_service.dart';
import 'database_provider.dart';

/// Provides the model registry service.
final modelRegistryProvider = Provider<ModelRegistryService>((ref) {
  final db = ref.watch(databaseProvider);
  return ModelRegistryService(db: db);
});

/// Async provider that loads and returns the merged registry.
final mergedRegistryProvider =
    FutureProvider<Map<String, dynamic>>((ref) async {
  final registry = ref.watch(modelRegistryProvider);
  return registry.getMergedRegistry();
});
