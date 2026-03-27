import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kenwell_health_app/data/local/screening_local_store.dart';
import 'package:kenwell_health_app/data/services/audit_log_service.dart';
import 'package:kenwell_health_app/data/services/firestore_service.dart';
import 'package:kenwell_health_app/data/services/pending_write_service.dart';
import 'package:kenwell_health_app/domain/models/cander_screening.dart';
import 'package:kenwell_health_app/utils/logger.dart';

/// Repository for managing cancer screening records in Firestore.
///
/// Every mutating operation writes a corresponding entry to the `audit_logs`
/// collection via [AuditLogService].
///
/// Offline-first write strategy:
/// 1. Persist to local SQLite immediately so the record survives any network failure.
/// 2. Attempt the Firestore write.  On failure the write is enqueued in
///    [PendingWriteService] for automatic retry when connectivity is restored.
class FirestoreCancerScreeningRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ScreeningLocalStore _local = ScreeningLocalStore.instance;
  final AuditLogService _audit;
  final PendingWriteService _pendingWrites;
  static const String _collectionName =
      FirestoreService.cancerScreeningsCollection;

  FirestoreCancerScreeningRepository({
    AuditLogService? auditLogService,
    PendingWriteService? pendingWriteService,
  })  : _audit = auditLogService ?? AuditLogService(),
        _pendingWrites = pendingWriteService ?? PendingWriteService.instance;

  Future<void> addCancerScreening(CancerScreening screening) async {
    final data = screening.toMap();
    // 1. Persist locally first — guaranteed local copy regardless of connectivity.
    await _local.upsertCancerScreening(data);
    // 2. Write to Firestore (non-fatal: failure is queued for automatic retry).
    try {
      await _firestore
          .collection(_collectionName)
          .doc(screening.id)
          .set(data);
      unawaited(_audit.logCreate(
        collection: _collectionName,
        documentId: screening.id,
        data: data,
        summary: 'Cancer screening added for member ${screening.memberId}',
      ));
      AppLogger.info('Cancer screening added successfully: ${screening.id}');
    } catch (e) {
      AppLogger.error(
          'Cancer screening Firestore write failed, queued for retry', e);
      unawaited(_pendingWrites.enqueue(
        collection: _collectionName,
        docId: screening.id,
        data: data,
      ));
    }
  }

  Future<CancerScreening?> getCancerScreening(String id) async {
    try {
      final doc = await _firestore.collection(_collectionName).doc(id).get();
      if (!doc.exists) return null;
      final screening = CancerScreening.fromMap(doc.data()!);
      unawaited(_local.upsertCancerScreening(doc.data()!));
      return screening;
    } catch (e) {
      // Offline fallback 1: Firestore on-device cache.
      try {
        final cached = await _firestore
            .collection(_collectionName)
            .doc(id)
            .get(const GetOptions(source: Source.cache));
        if (cached.exists) return CancerScreening.fromMap(cached.data()!);
      } catch (_) {}
      // Offline fallback 2: local SQLite store.
      try {
        final row = await _local.getCancerScreeningById(id);
        if (row != null) return CancerScreening.fromMap(row);
      } catch (_) {}
      AppLogger.error('Failed to get cancer screening', e);
      rethrow;
    }
  }

  Future<List<CancerScreening>> getCancerScreeningsByMember(
      String memberId) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collectionName)
          .where('memberId', isEqualTo: memberId)
          .get();

      final screenings = querySnapshot.docs
          .map((doc) => CancerScreening.fromMap(doc.data()))
          .toList();
      for (final doc in querySnapshot.docs) {
        unawaited(_local.upsertCancerScreening(doc.data()));
      }
      return screenings;
    } catch (e) {
      // Offline fallback 1: Firestore on-device cache.
      try {
        final cached = await _firestore
            .collection(_collectionName)
            .where('memberId', isEqualTo: memberId)
            .get(const GetOptions(source: Source.cache));
        if (cached.docs.isNotEmpty) {
          return cached.docs
              .map((doc) => CancerScreening.fromMap(doc.data()))
              .toList();
        }
      } catch (_) {}
      // Offline fallback 2: local SQLite store.
      try {
        final rows = await _local.getCancerScreeningsByMember(memberId);
        if (rows.isNotEmpty) {
          return rows.map((r) => CancerScreening.fromMap(r)).toList();
        }
      } catch (_) {}
      AppLogger.error('Failed to get cancer screenings by member', e);
      rethrow;
    }
  }

  Future<List<CancerScreening>> getCancerScreeningsByEvent(
      String eventId) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collectionName)
          .where('eventId', isEqualTo: eventId)
          .orderBy('createdAt', descending: true)
          .get();

      final screenings = querySnapshot.docs
          .map((doc) => CancerScreening.fromMap(doc.data()))
          .toList();
      for (final doc in querySnapshot.docs) {
        unawaited(_local.upsertCancerScreening(doc.data()));
      }
      return screenings;
    } catch (e) {
      // Offline fallback 1: Firestore on-device cache.
      try {
        final cached = await _firestore
            .collection(_collectionName)
            .where('eventId', isEqualTo: eventId)
            .get(const GetOptions(source: Source.cache));
        if (cached.docs.isNotEmpty) {
          return cached.docs
              .map((doc) => CancerScreening.fromMap(doc.data()))
              .toList();
        }
      } catch (_) {}
      // Offline fallback 2: local SQLite store.
      try {
        final rows = await _local.getCancerScreeningsByEvent(eventId);
        if (rows.isNotEmpty) {
          return rows.map((r) => CancerScreening.fromMap(r)).toList();
        }
      } catch (_) {}
      AppLogger.error('Failed to get cancer screenings by event', e);
      rethrow;
    }
  }

  Future<List<CancerScreening>> getAllCancerScreenings() async {
    try {
      final querySnapshot = await _firestore
          .collection(_collectionName)
          .orderBy('createdAt', descending: true)
          .get();
      final screenings = querySnapshot.docs
          .map((doc) => CancerScreening.fromMap(doc.data()))
          .toList();
      for (final doc in querySnapshot.docs) {
        unawaited(_local.upsertCancerScreening(doc.data()));
      }
      return screenings;
    } catch (e) {
      // Offline fallback 1: Firestore on-device cache.
      try {
        final cached = await _firestore
            .collection(_collectionName)
            .get(const GetOptions(source: Source.cache));
        if (cached.docs.isNotEmpty) {
          return cached.docs
              .map((doc) => CancerScreening.fromMap(doc.data()))
              .toList();
        }
      } catch (_) {}
      // Offline fallback 2: local SQLite store.
      try {
        final rows = await _local.getAllCancerScreenings();
        if (rows.isNotEmpty) {
          return rows.map((r) => CancerScreening.fromMap(r)).toList();
        }
      } catch (_) {}
      AppLogger.error('Failed to get all cancer screenings', e);
      rethrow;
    }
  }

  /// Get cancer screenings for a specific set of events.
  /// Splits the event ID list into chunks of 30 to satisfy the Firestore
  /// `whereIn` limit of 30 elements.
  Future<List<CancerScreening>> getCancerScreeningsByEvents(
      List<String> eventIds) async {
    if (eventIds.isEmpty) return [];
    try {
      const chunkSize = 30;
      final results = <CancerScreening>[];
      for (var i = 0; i < eventIds.length; i += chunkSize) {
        final chunk =
            eventIds.sublist(i, (i + chunkSize).clamp(0, eventIds.length));
        final querySnapshot = await _firestore
            .collection(_collectionName)
            .where('eventId', whereIn: chunk)
            .get();
        results.addAll(querySnapshot.docs
            .map((doc) => CancerScreening.fromMap(doc.data())));
        for (final doc in querySnapshot.docs) {
          unawaited(_local.upsertCancerScreening(doc.data()));
        }
      }
      return results;
    } catch (e) {
      // Offline fallback 1: Firestore on-device cache.
      try {
        const chunkSize = 30;
        final results = <CancerScreening>[];
        for (var i = 0; i < eventIds.length; i += chunkSize) {
          final chunk =
              eventIds.sublist(i, (i + chunkSize).clamp(0, eventIds.length));
          final cached = await _firestore
              .collection(_collectionName)
              .where('eventId', whereIn: chunk)
              .get(const GetOptions(source: Source.cache));
          results.addAll(
              cached.docs.map((doc) => CancerScreening.fromMap(doc.data())));
        }
        if (results.isNotEmpty) return results;
      } catch (_) {}
      // Offline fallback 2: local SQLite store.
      try {
        final rows = await _local.getCancerScreeningsByEvents(eventIds);
        if (rows.isNotEmpty) {
          return rows.map((r) => CancerScreening.fromMap(r)).toList();
        }
      } catch (_) {}
      AppLogger.error('Failed to get cancer screenings by events', e);
      rethrow;
    }
  }

  /// Real-time stream of cancer screenings for a specific set of events.
  ///
  /// When [eventIds] has more than 30 items, multiple Firestore queries are
  /// merged.  Each Firestore query emits independently, so the combined stream
  /// re-emits whenever *any* chunk changes.
  Stream<List<CancerScreening>> watchCancerScreeningsByEvents(
      List<String> eventIds) {
    if (eventIds.isEmpty) {
      return Stream.value([]);
    }
    const chunkSize = 30;
    final chunks = <List<String>>[];
    for (var i = 0; i < eventIds.length; i += chunkSize) {
      chunks
          .add(eventIds.sublist(i, (i + chunkSize).clamp(0, eventIds.length)));
    }
    if (chunks.length == 1) {
      return _firestore
          .collection(_collectionName)
          .where('eventId', whereIn: chunks[0])
          .snapshots()
          .map((s) =>
              s.docs.map((d) => CancerScreening.fromMap(d.data())).toList());
    }
    // Multiple chunks: merge by holding the latest snapshot from each chunk
    // and combining them whenever any one updates.
    return _mergeChunkStreams(chunks);
  }

  Stream<List<CancerScreening>> _mergeChunkStreams(
      List<List<String>> chunks) async* {
    final latest = List<List<CancerScreening>>.filled(chunks.length, []);
    final controller = StreamController<List<CancerScreening>>();
    var active = chunks.length;
    for (var i = 0; i < chunks.length; i++) {
      final idx = i;
      _firestore
          .collection(_collectionName)
          .where('eventId', whereIn: chunks[idx])
          .snapshots()
          .listen(
            (s) {
              latest[idx] =
                  s.docs.map((d) => CancerScreening.fromMap(d.data())).toList();
              if (!controller.isClosed) {
                controller.add(latest.expand((l) => l).toList());
              }
            },
            onError: controller.addError,
            onDone: () {
              active--;
              if (active == 0) controller.close();
            },
          );
    }
    yield* controller.stream;
  }
}
