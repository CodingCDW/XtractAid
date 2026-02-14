import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:xtractaid/services/encryption_service.dart';

void main() {
  late EncryptionService service;

  setUp(() {
    service = EncryptionService();
  });

  group('EncryptionService', () {
    group('generateSalt', () {
      test('returns 32 bytes', () {
        final salt = service.generateSalt();
        expect(salt.length, 32);
      });

      test('returns unique values', () {
        final salt1 = service.generateSalt();
        final salt2 = service.generateSalt();
        expect(salt1, isNot(equals(salt2)));
      });
    });

    group('hashPassword', () {
      test('produces deterministic hash for same inputs', () {
        final salt = service.generateSalt();
        final hash1 = service.hashPassword('testpass', salt);
        final hash2 = service.hashPassword('testpass', salt);
        expect(hash1, hash2);
      });

      test('produces different hashes for different passwords', () {
        final salt = service.generateSalt();
        final hash1 = service.hashPassword('password1', salt);
        final hash2 = service.hashPassword('password2', salt);
        expect(hash1, isNot(equals(hash2)));
      });

      test('produces different hashes for different salts', () {
        final salt1 = service.generateSalt();
        final salt2 = service.generateSalt();
        final hash1 = service.hashPassword('testpass', salt1);
        final hash2 = service.hashPassword('testpass', salt2);
        expect(hash1, isNot(equals(hash2)));
      });

      test('returns base64 encoded string', () {
        final salt = service.generateSalt();
        final hash = service.hashPassword('testpass', salt);
        // Should not throw
        final decoded = base64Decode(hash);
        expect(decoded.length, 32); // AES-256 key length
      });
    });

    group('verifyPassword', () {
      test('returns true for correct password', () {
        final salt = service.generateSalt();
        final hash = service.hashPassword('correct', salt);
        expect(service.verifyPassword('correct', salt, hash), isTrue);
      });

      test('returns false for wrong password', () {
        final salt = service.generateSalt();
        final hash = service.hashPassword('correct', salt);
        expect(service.verifyPassword('wrong', salt, hash), isFalse);
      });
    });

    group('unlock / lock', () {
      test('isUnlocked is false by default', () {
        expect(service.isUnlocked, isFalse);
      });

      test('isUnlocked is true after unlock', () {
        final salt = service.generateSalt();
        service.unlock('password', salt);
        expect(service.isUnlocked, isTrue);
      });

      test('isUnlocked is false after lock', () {
        final salt = service.generateSalt();
        service.unlock('password', salt);
        service.lock();
        expect(service.isUnlocked, isFalse);
      });
    });

    group('encrypt / decrypt roundtrip', () {
      test('decrypts back to original plaintext', () {
        final salt = service.generateSalt();
        service.unlock('my-secret-password', salt);

        const plaintext = 'Hello, World! This is a test API key.';
        final encrypted = service.encryptData(plaintext);
        final decrypted = service.decryptData(encrypted);

        expect(decrypted, plaintext);
      });

      test('encrypts empty string correctly', () {
        final salt = service.generateSalt();
        service.unlock('password', salt);

        final encrypted = service.encryptData('');
        final decrypted = service.decryptData(encrypted);

        expect(decrypted, '');
      });

      test('encrypts unicode text correctly', () {
        final salt = service.generateSalt();
        service.unlock('password', salt);

        const plaintext = 'Schlüssel mit Ümlauten: äöüß 🔑';
        final encrypted = service.encryptData(plaintext);
        final decrypted = service.decryptData(encrypted);

        expect(decrypted, plaintext);
      });

      test('produces different ciphertext each time (random IV)', () {
        final salt = service.generateSalt();
        service.unlock('password', salt);

        const plaintext = 'same text';
        final encrypted1 = service.encryptData(plaintext);
        final encrypted2 = service.encryptData(plaintext);

        expect(encrypted1, isNot(equals(encrypted2)));
      });

      test('throws when encrypting while locked', () {
        expect(
          () => service.encryptData('test'),
          throwsA(isA<StateError>()),
        );
      });

      test('throws when decrypting while locked', () {
        final salt = service.generateSalt();
        service.unlock('password', salt);
        final encrypted = service.encryptData('test');
        service.lock();

        expect(
          () => service.decryptData(encrypted),
          throwsA(isA<StateError>()),
        );
      });
    });
  });
}
