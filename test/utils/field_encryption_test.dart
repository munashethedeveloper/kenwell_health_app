import 'package:flutter_test/flutter_test.dart';
import 'package:kenwell_health_app/utils/field_encryption.dart';

void main() {
  group('FieldEncryption', () {
    test('encrypt returns null for null input', () {
      expect(FieldEncryption.encrypt(null), isNull);
    });

    test('encrypt returns empty string for empty input', () {
      expect(FieldEncryption.encrypt(''), isEmpty);
    });

    test('encrypted value starts with enc: prefix', () {
      final result = FieldEncryption.encrypt('9001015012345');
      expect(result, startsWith('enc:'));
    });

    test('decrypt null returns null', () {
      expect(FieldEncryption.decrypt(null), isNull);
    });

    test('decrypt empty string returns empty string', () {
      expect(FieldEncryption.decrypt(''), isEmpty);
    });

    test('decrypt round-trips correctly', () {
      const plaintext = '9001015012345';
      final encrypted = FieldEncryption.encrypt(plaintext)!;
      final decrypted = FieldEncryption.decrypt(encrypted);
      expect(decrypted, plaintext);
    });

    test('each encryption produces a different ciphertext (random IV)', () {
      const plaintext = 'AB1234567';
      final a = FieldEncryption.encrypt(plaintext)!;
      final b = FieldEncryption.encrypt(plaintext)!;
      expect(a, isNot(b)); // different IVs
    });

    test('decrypt of different ciphertexts produces the same plaintext', () {
      const plaintext = 'AB1234567';
      final a = FieldEncryption.encrypt(plaintext)!;
      final b = FieldEncryption.encrypt(plaintext)!;
      expect(FieldEncryption.decrypt(a), plaintext);
      expect(FieldEncryption.decrypt(b), plaintext);
    });

    test('decrypt returns value unchanged for legacy plain-text (no prefix)',
        () {
      const legacyValue = '9001015012345';
      expect(FieldEncryption.decrypt(legacyValue), legacyValue);
    });

    test('decrypt returns value unchanged for malformed enc: string', () {
      const malformed = 'enc:baddata';
      expect(FieldEncryption.decrypt(malformed), malformed);
    });

    test('encrypt handles special characters', () {
      const plaintext = 'John O\'Brien – SA#123';
      final encrypted = FieldEncryption.encrypt(plaintext)!;
      expect(FieldEncryption.decrypt(encrypted), plaintext);
    });

    test('encrypt handles long strings', () {
      final longValue = 'A' * 500;
      final encrypted = FieldEncryption.encrypt(longValue)!;
      expect(FieldEncryption.decrypt(encrypted), longValue);
    });
  });
}
