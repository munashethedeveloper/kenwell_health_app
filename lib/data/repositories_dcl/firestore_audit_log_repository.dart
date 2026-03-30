import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/models/audit_log_entry.dart';
import '../services/firestore_service.dart';

/// Read-only repository for the `audit_logs` Firestore collection.
///
/// Provides a real-time stream of [AuditLogEntry] objects ordered by
/// [performedAt] descending. Writing to audit logs is handled by
/// [AuditLogService]; this repository is exclusively for consumption.
class FirestoreAuditLogRepository {
  FirestoreAuditLogRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  /// Streams the most recent [limit] audit log entries, newest first.
  Stream<List<AuditLogEntry>> watchAuditLogs({int limit = 200}) {
    return _firestore
        .collection(FirestoreService.auditLogsCollection)
        .orderBy('performedAt', descending: true)
        .limit(limit)
        .snapshots()
        .map(
          (snap) => snap.docs
              .map((d) =>
                  AuditLogEntry.fromFirestore(d.data()))
              .toList(),
        );
  }
}
