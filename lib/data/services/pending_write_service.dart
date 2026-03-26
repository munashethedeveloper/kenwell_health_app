import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../local/app_database.dart';
import 'app_performance.dart';

/// Lightweight write-queue for best-effort Firestore mutations that may fail
/// in edge cases (permission errors, quota, network glitches after the SDK's
/// own offline cache is exhausted).
///
/// Usage:
/// ```dart
/// // Enqueue a failed write for later retry.
/// await PendingWriteService.instance.enqueue(
///   collection: 'members',
///   docId: member.id,
///   data: member.toMap(),
/// );
///
/// // Flush when connectivity is restored.
/// await PendingWriteService.instance.flushPending();
/// ```
///
/// The service uses a raw SQLite table (`pending_writes`) that is created in
/// [AppDatabase] schema v16.  Documents are retried up to [maxAttempts] times
/// before being abandoned (left in the table for manual inspection).
class PendingWriteService {
  PendingWriteService._({AppDatabase? database, FirebaseFirestore? firestore})
      : _db = database ?? AppDatabase.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  /// Shared singleton — used by production code.
  static final PendingWriteService instance = PendingWriteService._();

  /// Override for tests.
  factory PendingWriteService.forTesting({
    required AppDatabase database,
    required FirebaseFirestore firestore,
  }) =>
      PendingWriteService._(database: database, firestore: firestore);

  static const int maxAttempts = 5;

  final AppDatabase _db;
  final FirebaseFirestore _firestore;

  // ── Write ─────────────────────────────────────────────────────────────────

  /// Adds a Firestore set-with-merge operation to the pending queue.
  Future<void> enqueue({
    required String collection,
    required String docId,
    required Map<String, dynamic> data,
  }) async {
    try {
      await _db.customStatement(
        '''INSERT OR IGNORE INTO pending_writes
             (id, collection, doc_id, data_json, attempt_count, created_at)
           VALUES (?, ?, ?, ?, 0, ?)''',
        [
          const Uuid().v4(),
          collection,
          docId,
          jsonEncode(data),
          DateTime.now().millisecondsSinceEpoch,
        ],
      );
      debugPrint('PendingWriteService: queued $collection/$docId');
    } catch (e) {
      debugPrint('PendingWriteService.enqueue failed: $e');
    }
  }

  // ── Flush ─────────────────────────────────────────────────────────────────

  /// Retries all pending writes.
  ///
  /// Called automatically by [ConnectivityService] when the device goes online.
  /// Succeeded entries are deleted; failed entries have their attempt count
  /// incremented.  Entries that exceed [maxAttempts] are left for later retry
  /// but are not deleted — an operator can inspect them via the audit log.
  Future<void> flushPending() {
    return AppPerformance.traceAsync(
      AppPerformance.kFlushPendingWrites,
      _flushPendingImpl,
    );
  }

  Future<void> _flushPendingImpl() async {
    List<Map<String, dynamic>> rows;
    try {
      final results = await _db
          .customSelect(
            'SELECT * FROM pending_writes ORDER BY created_at ASC',
          )
          .get();
      rows = results.map((r) => r.data).toList();
    } catch (e) {
      debugPrint('PendingWriteService.flushPending: read failed – $e');
      return;
    }

    if (rows.isEmpty) return;
    debugPrint('PendingWriteService: flushing ${rows.length} pending write(s)');

    for (final row in rows) {
      final id = row['id'] as String;
      final attempts = (row['attempt_count'] as int? ?? 0);
      if (attempts >= maxAttempts) {
        debugPrint(
            'PendingWriteService: abandoning $id after $maxAttempts attempts');
        continue;
      }

      try {
        final data =
            jsonDecode(row['data_json'] as String) as Map<String, dynamic>;
        await _firestore
            .collection(row['collection'] as String)
            .doc(row['doc_id'] as String)
            .set(data, SetOptions(merge: true));

        await _db.customStatement(
          'DELETE FROM pending_writes WHERE id = ?',
          [id],
        );
        debugPrint(
            'PendingWriteService: flushed ${row["collection"]}/${row["doc_id"]}');
      } catch (e) {
        await _db.customStatement(
          'UPDATE pending_writes SET attempt_count = attempt_count + 1 WHERE id = ?',
          [id],
        );
        debugPrint('PendingWriteService: retry failed for $id – $e');
      }
    }
  }

  // ── Queue size ────────────────────────────────────────────────────────────

  /// Returns the number of entries currently in the queue.
  Future<int> pendingCount() async {
    try {
      final results = await _db
          .customSelect('SELECT COUNT(*) AS cnt FROM pending_writes')
          .get();
      return (results.first.data['cnt'] as int? ?? 0);
    } catch (_) {
      return 0;
    }
  }
}
