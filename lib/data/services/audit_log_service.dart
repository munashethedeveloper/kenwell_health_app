import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../../domain/models/audit_log_entry.dart';
import 'firestore_service.dart';

/// Service that writes immutable audit log entries to Firestore.
///
/// Every core create / update / delete operation should call one of the
/// convenience helpers here.  Logging is fire-and-forget — failures are
/// silently swallowed so they never block the primary operation.
class AuditLogService {
  AuditLogService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;
  final _uuid = const Uuid();

  /// The UID of the currently signed-in user, or `'anonymous'` if unknown.
  String get _currentUserId =>
      FirebaseAuth.instance.currentUser?.uid ?? 'anonymous';

  // ── Public helpers ─────────────────────────────────────────────────────────

  /// Log a document creation.
  Future<void> logCreate({
    required String collection,
    required String documentId,
    required Map<String, dynamic> data,
    String? summary,
  }) =>
      _log(
        action: 'create',
        collection: collection,
        documentId: documentId,
        summary: summary,
        newData: data,
      );

  /// Log a document update.
  Future<void> logUpdate({
    required String collection,
    required String documentId,
    required Map<String, dynamic> newData,
    Map<String, dynamic>? previousData,
    String? summary,
  }) =>
      _log(
        action: 'update',
        collection: collection,
        documentId: documentId,
        summary: summary,
        previousData: previousData,
        newData: newData,
      );

  /// Log a document deletion.
  Future<void> logDelete({
    required String collection,
    required String documentId,
    Map<String, dynamic>? previousData,
    String? summary,
  }) =>
      _log(
        action: 'delete',
        collection: collection,
        documentId: documentId,
        summary: summary,
        previousData: previousData,
      );

  // ── Internal ──────────────────────────────────────────────────────────────

  /// Field names whose values are large binary blobs (base64-encoded images).
  ///
  /// These are stripped from [newData] / [previousData] before the entry is
  /// persisted to Firestore for two reasons:
  ///   1. Firestore has a 1 MB per-document limit; a single consent record can
  ///      carry two signature images that together exceed that limit.
  ///   2. Signature images are sensitive biometric data that does not need to
  ///      be replicated into the audit trail — the source document already
  ///      holds the authoritative copy.
  static const _binaryFieldKeys = {
    'signatureData',
    'hpSignatureData',
    'patientSignatureData',
    'nurseSignatureData',
    'signatureBase64',
  };

  /// Returns a shallow copy of [data] with all large binary fields removed.
  Map<String, dynamic>? _sanitize(Map<String, dynamic>? data) {
    if (data == null) return null;
    return {
      for (final entry in data.entries)
        if (!_binaryFieldKeys.contains(entry.key.toString()))
          entry.key: entry.value,
    };
  }

  Future<void> _log({
    required String action,
    required String collection,
    required String documentId,
    String? summary,
    Map<String, dynamic>? previousData,
    Map<String, dynamic>? newData,
  }) async {
    try {
      final entry = AuditLogEntry(
        id: _uuid.v4(),
        action: action,
        collection: collection,
        documentId: documentId,
        performedBy: _currentUserId,
        performedAt: DateTime.now().toUtc(),
        summary: summary,
        previousData: _sanitize(previousData),
        newData: _sanitize(newData),
      );
      await _firestore
          .collection(FirestoreService.auditLogsCollection)
          .doc(entry.id)
          .set(entry.toFirestore());
    } catch (e) {
      // Audit failures must never block the caller.
      debugPrint('AuditLogService: failed to write log entry – $e');
    }
  }
}
