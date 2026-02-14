import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:pointycastle/export.dart';

import '../core/constants/app_constants.dart';

/// AES-256-GCM encryption service with PBKDF2 key derivation.
///
/// Storage format: [salt 32B][iv 12B][ciphertext][tag 16B]
class EncryptionService {
  Uint8List? _derivedKey;
  final _random = Random.secure();

  /// Whether a master password has been set and key derived.
  bool get isUnlocked => _derivedKey != null;

  /// Derive an encryption key from the master password.
  void unlock(String password, Uint8List salt) {
    _derivedKey = _deriveKey(password, salt);
  }

  /// Clear the derived key from memory.
  void lock() {
    _derivedKey = null;
  }

  /// Generate a random salt.
  Uint8List generateSalt() {
    return _randomBytes(AppConstants.saltLength);
  }

  /// Hash a password for verification (stored in settings).
  String hashPassword(String password, Uint8List salt) {
    final key = _deriveKey(password, salt);
    return base64Encode(key);
  }

  /// Verify a password against a stored hash.
  bool verifyPassword(String password, Uint8List salt, String storedHash) {
    final hash = hashPassword(password, salt);
    return hash == storedHash;
  }

  /// Encrypt plaintext using the derived key.
  /// Returns: [salt 32B][iv 12B][ciphertext][tag 16B]
  Uint8List encryptData(String plaintext) {
    if (_derivedKey == null) {
      throw StateError('EncryptionService is locked. Call unlock() first.');
    }

    final iv = _randomBytes(AppConstants.ivLength);
    final key = encrypt.Key(Uint8List.fromList(_derivedKey!));
    final ivObj = encrypt.IV(iv);

    final encrypter = encrypt.Encrypter(
      encrypt.AES(key, mode: encrypt.AESMode.gcm),
    );
    final encrypted = encrypter.encryptBytes(
      utf8.encode(plaintext),
      iv: ivObj,
    );

    // Combine: iv + encrypted bytes (ciphertext + tag)
    final result = Uint8List(AppConstants.ivLength + encrypted.bytes.length);
    result.setAll(0, iv);
    result.setAll(AppConstants.ivLength, encrypted.bytes);
    return result;
  }

  /// Decrypt data encrypted with [encryptData].
  /// Input format: [iv 12B][ciphertext][tag 16B]
  String decryptData(Uint8List encryptedData) {
    if (_derivedKey == null) {
      throw StateError('EncryptionService is locked. Call unlock() first.');
    }

    final iv = Uint8List.sublistView(encryptedData, 0, AppConstants.ivLength);
    final cipherBytes = Uint8List.sublistView(
      encryptedData,
      AppConstants.ivLength,
    );

    final key = encrypt.Key(Uint8List.fromList(_derivedKey!));
    final ivObj = encrypt.IV(iv);

    final encrypter = encrypt.Encrypter(
      encrypt.AES(key, mode: encrypt.AESMode.gcm),
    );
    final decrypted = encrypter.decryptBytes(
      encrypt.Encrypted(cipherBytes),
      iv: ivObj,
    );

    return utf8.decode(decrypted);
  }

  /// Derive a key using PBKDF2 with HMAC-SHA256.
  Uint8List _deriveKey(String password, Uint8List salt) {
    final params = Pbkdf2Parameters(salt, AppConstants.pbkdf2Iterations, AppConstants.keyLength);
    final pbkdf2 = PBKDF2KeyDerivator(HMac(SHA256Digest(), 64));
    pbkdf2.init(params);
    return pbkdf2.process(Uint8List.fromList(utf8.encode(password)));
  }

  Uint8List _randomBytes(int length) {
    return Uint8List.fromList(
      List<int>.generate(length, (_) => _random.nextInt(256)),
    );
  }
}
