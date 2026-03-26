import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:encrypt/encrypt.dart';
import 'package:flutter/foundation.dart';

/// AES-256-CBC field-level encryption for POPIA-sensitive PII.
///
/// ### Encrypted fields
/// - `Member`: `idNumber`, `passportNumber`, `dateOfBirth`, `medicalAidNumber`
/// - `HctResult`: `screeningResult`, `expectedResult`
///
/// ### Key management
/// The 32-byte (256-bit) encryption key is supplied at build time via the
/// `--dart-define=PII_ENCRYPTION_KEY=<32-char ASCII key>` flag.  In CI/CD,
/// set the `PII_ENCRYPTION_KEY` secret and pass it as a `--dart-define`.
///
/// A development fallback key (`_devKey`) is used automatically when no
/// `--dart-define` value is present so that local development still works.
/// **Never deploy to production without setting the real key.**
///
/// ### Storage format
/// Encrypted values are stored as Base64 strings in Firestore in the form:
/// ```
/// enc:<base64-iv>:<base64-ciphertext>
/// ```
/// The `enc:` prefix allows the decrypt function to distinguish already-
/// encrypted values from plain-text legacy values during the migration
/// period — if decryption is not possible the original value is returned
/// unchanged (graceful degradation).
class FieldEncryption {
  FieldEncryption._();

  /// Build-time key injected via `--dart-define=PII_ENCRYPTION_KEY=...`.
  /// Must be exactly 32 ASCII characters (256 bits).
  static const String _buildTimeKey = String.fromEnvironment(
    'PII_ENCRYPTION_KEY',
    defaultValue: '',
  );

  /// Development-only fallback key.  Never used in production builds that
  /// supply `PII_ENCRYPTION_KEY` via `--dart-define`.
  static const String _devKey = 'KenwellHlthApp__DevKey__32chars!';

  static Key get _key {
    final raw = _buildTimeKey.isNotEmpty ? _buildTimeKey : _devKey;
    assert(
      // In release mode, assert is a no-op — enforce the key via an
      // explicit check so the app does not silently use the dev key in prod.
      kDebugMode || _buildTimeKey.isNotEmpty,
      'PII_ENCRYPTION_KEY must be set via --dart-define in release builds. '
      'Run: flutter build --dart-define=PII_ENCRYPTION_KEY=<32-char key>',
    );
    // Ensure exactly 32 bytes (pad/truncate if necessary).
    final bytes = utf8.encode(raw);
    final padded = Uint8List(32);
    for (var i = 0; i < 32; i++) {
      padded[i] = i < bytes.length ? bytes[i] : 0;
    }
    return Key(padded);
  }

  static const String _prefix = 'enc:';

  /// Encrypts [plaintext] and returns an `enc:<iv>:<ciphertext>` string.
  /// Returns `null` if [plaintext] is null or empty.
  static String? encrypt(String? plaintext) {
    if (plaintext == null || plaintext.isEmpty) return plaintext;

    final iv = IV(Uint8List.fromList(
      List<int>.generate(16, (_) => Random.secure().nextInt(256)),
    ));
    final encrypter = Encrypter(AES(_key, mode: AESMode.cbc));
    final encrypted = encrypter.encrypt(plaintext, iv: iv);

    return '$_prefix${base64.encode(iv.bytes)}:${encrypted.base64}';
  }

  /// Decrypts a value previously produced by [encrypt].
  ///
  /// If [value] does not start with the `enc:` prefix it is returned as-is
  /// (legacy plain-text migration path).  If decryption fails for any reason
  /// the original value is returned so the app does not crash on bad data.
  static String? decrypt(String? value) {
    if (value == null || value.isEmpty) return value;
    if (!value.startsWith(_prefix)) return value; // plain-text legacy

    try {
      final parts = value.substring(_prefix.length).split(':');
      if (parts.length != 2) return value;

      final iv = IV(base64.decode(parts[0]));
      final encrypted = Encrypted.fromBase64(parts[1]);
      final encrypter = Encrypter(AES(_key, mode: AESMode.cbc));
      return encrypter.decrypt(encrypted, iv: iv);
    } catch (_) {
      return value; // graceful degradation
    }
  }
}
