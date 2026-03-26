import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kenwell_health_app/data/local/screening_local_store.dart';
import 'package:kenwell_health_app/domain/models/hct_result.dart';
import 'package:kenwell_health_app/data/services/audit_log_service.dart';
import 'package:kenwell_health_app/data/services/firestore_service.dart';
import 'package:kenwell_health_app/utils/field_encryption.dart';
import 'package:kenwell_health_app/utils/logger.dart';

/// Repository for managing HCT test result records in Firestore.
///
/// Every mutating operation writes a corresponding entry to the `audit_logs`
/// collection via [AuditLogService].
class FirestoreHctResultRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ScreeningLocalStore _local = ScreeningLocalStore.instance;
  final AuditLogService _audit;
  static const String _collectionName = FirestoreService.hctResultsCollection;

  FirestoreHctResultRepository({AuditLogService? auditLogService})
      : _audit = auditLogService ?? AuditLogService();

  // ── Encryption helpers ──────────────────────────────────────────────────

  /// Returns a copy of the serialised [HctResult] map with the sensitive
  /// [screeningResult] and [expectedResult] fields AES-256-CBC encrypted.
  Map<String, dynamic> _toEncryptedMap(HctResult result) {
    final map = Map<String, dynamic>.from(result.toMap());
    map['screeningResult'] =
        FieldEncryption.encrypt(map['screeningResult'] as String?);
    map['expectedResult'] =
        FieldEncryption.encrypt(map['expectedResult'] as String?);
    return map;
  }

  /// Decrypts the sensitive fields in a raw Firestore/local [map] before
  /// constructing an [HctResult] via [HctResult.fromMap].
  HctResult _fromMap(Map<String, dynamic> map) {
    final decrypted = Map<String, dynamic>.from(map);
    decrypted['screeningResult'] =
        FieldEncryption.decrypt(decrypted['screeningResult'] as String?);
    decrypted['expectedResult'] =
        FieldEncryption.decrypt(decrypted['expectedResult'] as String?);
    return HctResult.fromMap(decrypted);
  }

  // ── Public API ──────────────────────────────────────────────────────────

  Future<void> addHctResult(HctResult result) async {
    final encryptedMap = _toEncryptedMap(result);
    try {
      await _firestore
          .collection(_collectionName)
          .doc(result.id)
          .set(encryptedMap);
      // Write-through: persist to local SQLite store so data is available offline.
      unawaited(_local.upsertHctResult(encryptedMap));
      unawaited(_audit.logCreate(
        collection: _collectionName,
        documentId: result.id,
        data: encryptedMap,
        summary: 'HCT result added for member ${result.memberId}',
      ));
      AppLogger.info('HCT result added successfully: ${result.id}');
    } catch (e) {
      AppLogger.error('Failed to add HCT result', e);
      rethrow;
    }
  }

  Future<HctResult?> getHctResult(String id) async {
    try {
      final doc = await _firestore.collection(_collectionName).doc(id).get();
      if (!doc.exists) return null;
      final result = _fromMap(doc.data()!);
      unawaited(_local.upsertHctResult(doc.data()!));
      return result;
    } catch (e) {
      // Offline fallback 1: Firestore on-device cache.
      try {
        final cached = await _firestore
            .collection(_collectionName)
            .doc(id)
            .get(const GetOptions(source: Source.cache));
        if (cached.exists) return _fromMap(cached.data()!);
      } catch (_) {}
      // Offline fallback 2: local SQLite store.
      try {
        final row = await _local.getHctResultById(id);
        if (row != null) return _fromMap(row);
      } catch (_) {}
      AppLogger.error('Failed to get HCT result', e);
      rethrow;
    }
  }

  Future<List<HctResult>> getHctResultsByMember(String memberId) async {
    try {
      // NOTE: No orderBy here — .where('memberId').orderBy('createdAt')
      // requires a Firestore composite index.  Without it Firestore throws an
      // error that is silently caught in loadAllCompletionFlags, leaving the
      // hctCompleted flag permanently false.  A single equality filter uses
      // the auto-created single-field index and needs no composite index.
      // The composite index IS defined in firestore.indexes.json for queries
      // (e.g., watchConsentsByMember) where ordering is required for the UI.
      final querySnapshot = await _firestore
          .collection(_collectionName)
          .where('memberId', isEqualTo: memberId)
          .get();

      final results =
          querySnapshot.docs.map((doc) => _fromMap(doc.data())).toList();
      for (final doc in querySnapshot.docs) {
        unawaited(_local.upsertHctResult(doc.data()));
      }
      return results;
    } catch (e) {
      // Offline fallback 1: Firestore on-device cache.
      try {
        final cached = await _firestore
            .collection(_collectionName)
            .where('memberId', isEqualTo: memberId)
            .get(const GetOptions(source: Source.cache));
        if (cached.docs.isNotEmpty) {
          return cached.docs.map((doc) => _fromMap(doc.data())).toList();
        }
      } catch (_) {}
      // Offline fallback 2: local SQLite store.
      try {
        final rows = await _local.getHctResultsByMember(memberId);
        if (rows.isNotEmpty) {
          return rows.map((r) => _fromMap(r)).toList();
        }
      } catch (_) {}
      AppLogger.error('Failed to get HCT results by member', e);
      rethrow;
    }
  }

  Future<List<HctResult>> getHctResultsByEvent(String eventId) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collectionName)
          .where('eventId', isEqualTo: eventId)
          .orderBy('createdAt', descending: true)
          .get();

      final results =
          querySnapshot.docs.map((doc) => _fromMap(doc.data())).toList();
      for (final doc in querySnapshot.docs) {
        unawaited(_local.upsertHctResult(doc.data()));
      }
      return results;
    } catch (e) {
      // Offline fallback 1: Firestore on-device cache.
      try {
        final cached = await _firestore
            .collection(_collectionName)
            .where('eventId', isEqualTo: eventId)
            .get(const GetOptions(source: Source.cache));
        if (cached.docs.isNotEmpty) {
          return cached.docs.map((doc) => _fromMap(doc.data())).toList();
        }
      } catch (_) {}
      // Offline fallback 2: local SQLite store.
      try {
        final rows = await _local.getHctResultsByEvent(eventId);
        if (rows.isNotEmpty) {
          return rows.map((r) => _fromMap(r)).toList();
        }
      } catch (_) {}
      AppLogger.error('Failed to get HCT results by event', e);
      rethrow;
    }
  }
}
