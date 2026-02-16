import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:xtractaid/features/auth/password_screen.dart';
import 'package:xtractaid/services/encryption_service.dart';

import '../test_helpers/test_harness.dart';

void main() {
  testWidgets('Auth shows error on wrong password', (tester) async {
    final db = createTestDatabase();
    final encryption = EncryptionService();
    addTearDown(db.close);

    final salt = encryption.generateSalt();
    final hash = encryption.hashPassword('correct-password', salt);
    await db.settingsDao.setValue('password_salt', base64Encode(salt));
    await db.settingsDao.setValue('password_hash', hash);

    await tester.pumpWidget(
      buildTestApp(
        child: const PasswordScreen(),
        db: db,
        encryption: encryption,
      ),
    );

    await tester.enterText(find.byType(TextField), 'wrong-password');
    await tester.tap(find.widgetWithText(FilledButton, 'Unlock'));
    await tester.pumpAndSettle();

    expect(find.text('Wrong password'), findsOneWidget);
  });
}
