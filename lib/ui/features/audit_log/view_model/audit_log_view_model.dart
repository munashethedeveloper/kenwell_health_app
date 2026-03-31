import 'package:flutter/foundation.dart';

import '../../../../data/repositories_dcl/firestore_audit_log_repository.dart';
import '../../../../domain/models/audit_log_entry.dart';

/// ViewModel for the Audit Log screen.
///
/// Holds the active filter selection and exposes a real-time stream of
/// [AuditLogEntry] objects from [FirestoreAuditLogRepository].
///
/// The screen observes [filter] via [ChangeNotifier] and rebuilds its
/// [StreamBuilder] source when the filter changes.
class AuditLogViewModel extends ChangeNotifier {
  AuditLogViewModel({FirestoreAuditLogRepository? repository})
      : _repository = repository ?? FirestoreAuditLogRepository();

  final FirestoreAuditLogRepository _repository;

  /// Active filter: `'all'`, `'create'`, `'update'`, or `'delete'`.
  String _filter = 'all';
  String get filter => _filter;

  /// Update the active action filter and notify the screen to re-subscribe.
  void setFilter(String value) {
    if (_filter == value) return;
    _filter = value;
    notifyListeners();
  }

  /// Real-time stream of all audit log entries (newest first, limit 200).
  ///
  /// Filtering by [filter] is applied client-side after the snapshot arrives
  /// so a single Firestore subscription is reused across filter changes.
  Stream<List<AuditLogEntry>> get auditLogStream =>
      _repository.watchAuditLogs().map(
            (entries) => _filter == 'all'
                ? entries
                : entries
                    .where(
                      (e) => e.action.toLowerCase() == _filter,
                    )
                    .toList(),
          );
}
