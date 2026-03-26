import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kenwell_health_app/data/local/screening_local_store.dart';
import 'package:kenwell_health_app/domain/models/hra_screening.dart';
import 'package:kenwell_health_app/data/services/audit_log_service.dart';
import 'package:kenwell_health_app/data/services/firestore_service.dart';
import 'package:kenwell_health_app/data/services/pending_write_service.dart';
import 'package:kenwell_health_app/utils/logger.dart';

/// Repository for managing HRA screening records in Firestore.
///
/// Every mutating operation (add / update / delete) writes a corresponding
/// entry to the `audit_logs` collection via [AuditLogService].
///
/// Offline-first write strategy:
/// 1. Persist to local SQLite immediately so the record survives any network failure.
/// 2. Attempt the Firestore write.  On failure the write is enqueued in
///    [PendingWriteService] for automatic retry when connectivity is restored.
class FirestoreHraRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ScreeningLocalStore _local = ScreeningLocalStore.instance;
  final AuditLogService _audit;
  final PendingWriteService _pendingWrites;
  static const String _collectionName =
      FirestoreService.hraScreeningsCollection;

  FirestoreHraRepository({
    AuditLogService? auditLogService,
    PendingWriteService? pendingWriteService,
  })  : _audit = auditLogService ?? AuditLogService(),
        _pendingWrites = pendingWriteService ?? PendingWriteService.instance;

  /// Add a new HRA screening
  Future<void> addHraScreening(HraScreening screening) async {
    final data = screening.toMap();
    // 1. Persist locally first — guaranteed local copy regardless of connectivity.
    await _local.upsertHraScreening(data);
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
        summary: 'HRA screening added for member ${screening.memberId}',
      ));
      AppLogger.info('HRA screening added successfully: ${screening.id}');
    } catch (e) {
      AppLogger.error(
          'HRA screening Firestore write failed, queued for retry', e);
      unawaited(_pendingWrites.enqueue(
        collection: _collectionName,
        docId: screening.id,
        data: data,
      ));
    }
  }

  /// Get HRA screening by ID
  Future<HraScreening?> getHraScreening(String id) async {
    try {
      final doc = await _firestore.collection(_collectionName).doc(id).get();
      if (!doc.exists) {
        return null;
      }
      final screening = HraScreening.fromMap(doc.data()!);
      unawaited(_local.upsertHraScreening(doc.data()!));
      return screening;
    } catch (e) {
      // Offline fallback 1: Firestore on-device cache.
      try {
        final cached = await _firestore
            .collection(_collectionName)
            .doc(id)
            .get(const GetOptions(source: Source.cache));
        if (cached.exists) return HraScreening.fromMap(cached.data()!);
      } catch (_) {}
      // Offline fallback 2: local SQLite store.
      try {
        final row = await _local.getHraScreeningById(id);
        if (row != null) return HraScreening.fromMap(row);
      } catch (_) {}
      AppLogger.error('Failed to get HRA screening', e);
      rethrow;
    }
  }

  /// Update HRA screening
  Future<void> updateHraScreening(HraScreening screening) async {
    try {
      final updatedScreening = screening.copyWith(updatedAt: DateTime.now());
      await _firestore
          .collection(_collectionName)
          .doc(screening.id)
          .update(updatedScreening.toMap());
      unawaited(_audit.logUpdate(
        collection: _collectionName,
        documentId: screening.id,
        newData: updatedScreening.toMap(),
        summary: 'HRA screening updated for member ${screening.memberId}',
      ));
      AppLogger.info('HRA screening updated successfully: ${screening.id}');
    } catch (e) {
      AppLogger.error('Failed to update HRA screening', e);
      rethrow;
    }
  }

  /// Delete HRA screening
  Future<void> deleteHraScreening(String id) async {
    try {
      await _firestore.collection(_collectionName).doc(id).delete();
      unawaited(_audit.logDelete(
        collection: _collectionName,
        documentId: id,
        summary: 'HRA screening deleted: $id',
      ));
      AppLogger.info('HRA screening deleted successfully: $id');
    } catch (e) {
      AppLogger.error('Failed to delete HRA screening', e);
      rethrow;
    }
  }

  /// Get all HRA screenings for a specific member
  Future<List<HraScreening>> getHraScreeningsByMember(String memberId) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collectionName)
          .where('memberId', isEqualTo: memberId)
          .get();

      final screenings = querySnapshot.docs
          .map((doc) => HraScreening.fromMap(doc.data()))
          .toList();
      for (final doc in querySnapshot.docs) {
        unawaited(_local.upsertHraScreening(doc.data()));
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
              .map((doc) => HraScreening.fromMap(doc.data()))
              .toList();
        }
      } catch (_) {}
      // Offline fallback 2: local SQLite store.
      try {
        final rows = await _local.getHraScreeningsByMember(memberId);
        if (rows.isNotEmpty) {
          return rows.map((r) => HraScreening.fromMap(r)).toList();
        }
      } catch (_) {}
      AppLogger.error('Failed to get HRA screenings by member', e);
      rethrow;
    }
  }

  /// Get all HRA screenings for a specific event
  Future<List<HraScreening>> getHraScreeningsByEvent(String eventId) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collectionName)
          .where('eventId', isEqualTo: eventId)
          .orderBy('createdAt', descending: true)
          .get();

      final screenings = querySnapshot.docs
          .map((doc) => HraScreening.fromMap(doc.data()))
          .toList();
      for (final doc in querySnapshot.docs) {
        unawaited(_local.upsertHraScreening(doc.data()));
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
              .map((doc) => HraScreening.fromMap(doc.data()))
              .toList();
        }
      } catch (_) {}
      // Offline fallback 2: local SQLite store.
      try {
        final rows = await _local.getHraScreeningsByEvent(eventId);
        if (rows.isNotEmpty) {
          return rows.map((r) => HraScreening.fromMap(r)).toList();
        }
      } catch (_) {}
      AppLogger.error('Failed to get HRA screenings by event', e);
      rethrow;
    }
  }

  /// Watch all HRA screenings (real-time stream)
  Stream<List<HraScreening>> watchAllHraScreenings() {
    return _firestore
        .collection(_collectionName)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => HraScreening.fromMap(doc.data()))
            .toList());
  }

  /// Watch HRA screenings for a specific member (real-time stream)
  Stream<List<HraScreening>> watchHraScreeningsByMember(String memberId) {
    return _firestore
        .collection(_collectionName)
        .where('memberId', isEqualTo: memberId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => HraScreening.fromMap(doc.data()))
            .toList());
  }

  /// Watch HRA screenings for a specific event (real-time stream)
  Stream<List<HraScreening>> watchHraScreeningsByEvent(String eventId) {
    return _firestore
        .collection(_collectionName)
        .where('eventId', isEqualTo: eventId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => HraScreening.fromMap(doc.data()))
            .toList());
  }

  /// Get all HRA screenings across all events
  Future<List<HraScreening>> getAllHraScreenings() async {
    try {
      final querySnapshot = await _firestore
          .collection(_collectionName)
          .orderBy('createdAt', descending: true)
          .get();
      final screenings = querySnapshot.docs
          .map((doc) => HraScreening.fromMap(doc.data()))
          .toList();
      for (final doc in querySnapshot.docs) {
        unawaited(_local.upsertHraScreening(doc.data()));
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
              .map((doc) => HraScreening.fromMap(doc.data()))
              .toList();
        }
      } catch (_) {}
      // Offline fallback 2: local SQLite store.
      try {
        final rows = await _local.getAllHraScreenings();
        if (rows.isNotEmpty) {
          return rows.map((r) => HraScreening.fromMap(r)).toList();
        }
      } catch (_) {}
      AppLogger.error('Failed to get all HRA screenings', e);
      rethrow;
    }
  }

  /// Get HRA screenings for a specific set of events.
  /// Splits the event ID list into chunks of 30 to satisfy the Firestore
  /// `whereIn` limit of 30 elements.
  Future<List<HraScreening>> getHraScreeningsByEvents(
      List<String> eventIds) async {
    if (eventIds.isEmpty) return [];
    try {
      const chunkSize = 30;
      final results = <HraScreening>[];
      for (var i = 0; i < eventIds.length; i += chunkSize) {
        final chunk =
            eventIds.sublist(i, (i + chunkSize).clamp(0, eventIds.length));
        final querySnapshot = await _firestore
            .collection(_collectionName)
            .where('eventId', whereIn: chunk)
            .get();
        results.addAll(
            querySnapshot.docs.map((doc) => HraScreening.fromMap(doc.data())));
        for (final doc in querySnapshot.docs) {
          unawaited(_local.upsertHraScreening(doc.data()));
        }
      }
      return results;
    } catch (e) {
      // Offline fallback 1: Firestore on-device cache.
      try {
        const chunkSize = 30;
        final results = <HraScreening>[];
        for (var i = 0; i < eventIds.length; i += chunkSize) {
          final chunk =
              eventIds.sublist(i, (i + chunkSize).clamp(0, eventIds.length));
          final cached = await _firestore
              .collection(_collectionName)
              .where('eventId', whereIn: chunk)
              .get(const GetOptions(source: Source.cache));
          results.addAll(
              cached.docs.map((doc) => HraScreening.fromMap(doc.data())));
        }
        if (results.isNotEmpty) return results;
      } catch (_) {}
      // Offline fallback 2: local SQLite store.
      try {
        final rows = await _local.getHraScreeningsByEvents(eventIds);
        if (rows.isNotEmpty) {
          return rows.map((r) => HraScreening.fromMap(r)).toList();
        }
      } catch (_) {}
      AppLogger.error('Failed to get HRA screenings by events', e);
      rethrow;
    }
  }

  /// Real-time stream of HRA screenings for a specific set of events.
  Stream<List<HraScreening>> watchHraScreeningsByEvents(List<String> eventIds) {
    if (eventIds.isEmpty) return Stream.value([]);
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
              s.docs.map((d) => HraScreening.fromMap(d.data())).toList());
    }
    return _mergeChunkStreams(chunks);
  }

  Stream<List<HraScreening>> _mergeChunkStreams(
      List<List<String>> chunks) async* {
    final latest = List<List<HraScreening>>.filled(chunks.length, []);
    final controller = StreamController<List<HraScreening>>();
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
                  s.docs.map((d) => HraScreening.fromMap(d.data())).toList();
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
