import 'package:flutter_test/flutter_test.dart';

import 'package:xtractaid/features/settings/settings_screen.dart';

import '../test_helpers/test_harness.dart';

void main() {
  testWidgets('Settings updates strict local mode', (tester) async {
    final db = createTestDatabase();
    addTearDown(db.close);

    await db.settingsDao.setValue('language', 'en');
    await db.settingsDao.setValue('strict_local_mode', 'false');
    await db.settingsDao.setValue('checkpoint_interval', '10');

    await tester.pumpWidget(
      buildTestApp(child: const SettingsScreen(), db: db),
    );
    await tester.pumpAndSettle();

    expect(find.text('Settings'), findsOneWidget);

    await tester.tap(find.text('Strict Local Mode'));
    await tester.pumpAndSettle();

    expect(await db.settingsDao.getValue('strict_local_mode'), 'true');
  });
}
