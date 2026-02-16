import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:xtractaid/data/models/batch_config.dart';
import 'package:xtractaid/data/models/batch_stats.dart';
import 'package:xtractaid/data/models/log_entry.dart';
import 'package:xtractaid/services/encryption_service.dart';
import 'package:xtractaid/services/file_parser_service.dart';
import 'package:xtractaid/services/report_generator_service.dart';

import 'package:xtractaid/data/database/app_database.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('E2E flow: setup -> auth -> project -> batch -> report', (
    tester,
  ) async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    final encryption = EncryptionService();
    final parser = FileParserService();
    final reports = ReportGeneratorService();

    final root = await Directory.systemTemp.createTemp('xtractaid_e2e_');
    addTearDown(() async {
      await db.close();
      if (await root.exists()) {
        await root.delete(recursive: true);
      }
    });

    final projectDir = Directory('${root.path}/project_a');
    await Directory('${projectDir.path}/prompts').create(recursive: true);
    await Directory('${projectDir.path}/input').create(recursive: true);
    await Directory('${projectDir.path}/results').create(recursive: true);
    await File(
      '${projectDir.path}/prompts/meta.txt',
    ).writeAsString('Return JSON for [Insert IDs and Items here]');
    await File(
      '${projectDir.path}/input/items.csv',
    ).writeAsString('ID,Item\nA1,Alpha text\nA2,Beta text\n');

    // Setup
    final salt = encryption.generateSalt();
    final hash = encryption.hashPassword('pw-12345678', salt);
    await db.settingsDao.setValue('password_salt', base64Encode(salt));
    await db.settingsDao.setValue('password_hash', hash);
    await db.settingsDao.setValue('setup_complete', 'true');
    await db.settingsDao.setValue('language', 'en');

    // Auth
    expect(encryption.verifyPassword('pw-12345678', salt, hash), isTrue);
    encryption.unlock('pw-12345678', salt);
    expect(encryption.isUnlocked, isTrue);

    // Project
    await db.projectsDao.insertProject(
      ProjectsCompanion.insert(
        id: 'project-a',
        name: 'Project A',
        path: projectDir.path,
        lastOpenedAt: Value(DateTime.now()),
      ),
    );

    final parsed = await parser.parseCsv(
      '${projectDir.path}/input/items.csv',
      idColumn: 'ID',
      itemColumn: 'Item',
    );
    expect(parsed.items.length, 2);

    // Batch + Result
    final config = BatchConfig(
      batchId: 'batch-a',
      projectId: 'project-a',
      name: 'Batch A',
      input: BatchInput(
        type: 'excel',
        path: '${projectDir.path}/input/items.csv',
        idColumn: 'ID',
        itemColumn: 'Item',
        itemCount: parsed.items.length,
      ),
      promptFiles: const ['meta.txt'],
      chunkSettings: const ChunkSettings(chunkSize: 1, repetitions: 1),
      models: const [
        BatchModelConfig(modelId: 'ollama/test-model', providerId: 'ollama'),
      ],
      privacyConfirmed: true,
    );

    final stats = BatchStats(
      totalApiCalls: 2,
      completedApiCalls: 2,
      failedApiCalls: 0,
      totalInputTokens: 40,
      totalOutputTokens: 20,
      totalCost: 0.0,
      totalItems: 2,
      processedItems: 2,
      startedAt: DateTime.now().subtract(const Duration(seconds: 3)),
      completedAt: DateTime.now(),
    );

    final resultRows = [
      {'ID': 'A1', 'summary': 'Alpha'},
      {'ID': 'A2', 'summary': 'Beta'},
    ];
    final reportPaths = await reports.generateReports(
      projectPath: projectDir.path,
      batchId: config.batchId,
      config: config,
      stats: stats,
      results: resultRows,
      logs: [
        LogEntry(
          level: LogLevel.info,
          message: 'Batch completed',
          timestamp: DateTime.now(),
        ),
      ],
      promptContents: const {
        'meta.txt': 'Return JSON for [Insert IDs and Items here]',
      },
    );

    expect(File(reportPaths.excelPath).existsSync(), isTrue);
    expect(File(reportPaths.markdownPath).existsSync(), isTrue);
    expect(File(reportPaths.htmlPath).existsSync(), isTrue);
  });
}
