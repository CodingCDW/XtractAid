import 'package:dio/dio.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:xtractaid/core/l10n/generated/app_localizations.dart';
import 'package:xtractaid/data/database/app_database.dart';
import 'package:xtractaid/providers/database_provider.dart';
import 'package:xtractaid/providers/encryption_provider.dart';
import 'package:xtractaid/providers/model_registry_provider.dart';
import 'package:xtractaid/services/encryption_service.dart';
import 'package:xtractaid/services/model_registry_service.dart';

AppDatabase createTestDatabase() {
  return AppDatabase.forTesting(NativeDatabase.memory());
}

ModelRegistryService createFastRegistryService(AppDatabase db) {
  return ModelRegistryService(
    db: db,
    dio: Dio(
      BaseOptions(
        connectTimeout: const Duration(milliseconds: 50),
        sendTimeout: const Duration(milliseconds: 50),
        receiveTimeout: const Duration(milliseconds: 50),
      ),
    ),
  );
}

Widget buildTestApp({
  required Widget child,
  required AppDatabase db,
  EncryptionService? encryption,
  ModelRegistryService? registry,
  Locale locale = const Locale('en'),
}) {
  final localEncryption = encryption ?? EncryptionService();
  final localRegistry = registry ?? createFastRegistryService(db);

  return ProviderScope(
    overrides: [
      databaseProvider.overrideWithValue(db),
      encryptionProvider.overrideWithValue(localEncryption),
      modelRegistryProvider.overrideWithValue(localRegistry),
    ],
    child: MaterialApp(
      locale: locale,
      localizationsDelegates: S.localizationsDelegates,
      supportedLocales: S.supportedLocales,
      home: child,
    ),
  );
}
