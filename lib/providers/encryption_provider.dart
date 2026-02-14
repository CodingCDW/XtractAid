import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/encryption_service.dart';

/// Provides the singleton encryption service.
final encryptionProvider = Provider<EncryptionService>((ref) {
  return EncryptionService();
});
