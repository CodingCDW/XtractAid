import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:xtractaid/features/setup_wizard/setup_wizard_screen.dart';

import '../test_helpers/test_harness.dart';

void main() {
  testWidgets('Setup wizard validates password minimum length', (tester) async {
    final db = createTestDatabase();
    addTearDown(db.close);

    await tester.pumpWidget(
      buildTestApp(child: const SetupWizardScreen(), db: db),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(FilledButton, 'Next'));
    await tester.pumpAndSettle();

    final passwordFields = find.byType(TextField);
    await tester.enterText(passwordFields.at(0), '1234567');
    await tester.enterText(passwordFields.at(1), '1234567');

    await tester.tap(find.widgetWithText(FilledButton, 'Next'));
    await tester.pumpAndSettle();

    expect(find.text('At least 8 characters required.'), findsOneWidget);
  });
}
