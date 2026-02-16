import 'dart:io';

import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:xtractaid/data/database/app_database.dart';
import 'package:xtractaid/features/batch_wizard/batch_wizard_screen.dart';

import '../test_helpers/test_harness.dart';

void main() {
  testWidgets('Batch wizard requires loaded items before continuing', (
    tester,
  ) async {
    final db = createTestDatabase();
    addTearDown(db.close);

    final tempDir = await Directory.systemTemp.createTemp(
      'xtractaid_batch_wizard_test_',
    );
    addTearDown(() async {
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });
    await Directory('${tempDir.path}/prompts').create(recursive: true);
    await File(
      '${tempDir.path}/prompts/test_prompt.txt',
    ).writeAsString('Return JSON for [Insert IDs and Items here]');

    await db.projectsDao.insertProject(
      ProjectsCompanion.insert(
        id: 'project-1',
        name: 'Test Project',
        path: tempDir.path,
        lastOpenedAt: const Value.absent(),
      ),
    );

    await tester.pumpWidget(
      buildTestApp(
        child: const BatchWizardScreen(projectId: 'project-1'),
        db: db,
      ),
    );
    await tester.pumpAndSettle(const Duration(milliseconds: 400));

    await tester.tap(find.widgetWithText(FilledButton, 'Next'));
    await tester.pumpAndSettle();

    expect(find.text('Please load items before continuing.'), findsOneWidget);
  });
}
