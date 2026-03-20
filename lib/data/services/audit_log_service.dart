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
        previousData: previousData,
        newData: newData,
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
