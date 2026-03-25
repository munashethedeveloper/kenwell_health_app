/// Represents a single audit log entry stored in Firestore.
///
/// Every Create / Update / Delete operation on a core collection writes
/// one [AuditLogEntry] to the `audit_logs` collection, providing a
/// tamper-evident history of who changed what and when.
class AuditLogEntry {
  const AuditLogEntry({
    required this.id,
    required this.action,
    required this.collection,
    required this.documentId,
    required this.performedBy,
    required this.performedAt,
    this.summary,
    this.previousData,
    this.newData,
  });

  /// Unique log entry ID (auto-generated UUID).
  final String id;

  /// The type of operation: 'create', 'update', or 'delete'.
  final String action;

  /// The Firestore collection that was affected (e.g. 'events', 'members').
  final String collection;

  /// The ID of the document that was affected.
  final String documentId;

  /// UID of the user who performed the action.
  final String performedBy;

  /// When the action was performed (UTC).
  final DateTime performedAt;

  /// Optional human-readable summary (e.g. "Created event: Annual Wellness Day").
  final String? summary;

  /// Snapshot of the data before the operation (for updates/deletes).
  final Map<String, dynamic>? previousData;

  /// Snapshot of the data after the operation (for creates/updates).
  final Map<String, dynamic>? newData;

  Map<String, dynamic> toFirestore() => {
        'id': id,
        'action': action,
        'collection': collection,
        'documentId': documentId,
        'performedBy': performedBy,
        'performedAt': performedAt.toUtc().toIso8601String(),
        if (summary != null) 'summary': summary,
        if (previousData != null) 'previousData': previousData,
        if (newData != null) 'newData': newData,
      };

  factory AuditLogEntry.fromFirestore(Map<String, dynamic> data) =>
      AuditLogEntry(
        id: data['id'] as String? ?? '',
        action: data['action'] as String? ?? '',
        collection: data['collection'] as String? ?? '',
        documentId: data['documentId'] as String? ?? '',
        performedBy: data['performedBy'] as String? ?? '',
        performedAt: data['performedAt'] != null
            ? DateTime.parse(data['performedAt'] as String)
            : DateTime.now(),
        summary: data['summary'] as String?,
        previousData: data['previousData'] as Map<String, dynamic>?,
        newData: data['newData'] as Map<String, dynamic>?,
      );
}
