import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kenwell_health_app/data/local/screening_local_store.dart';
import 'package:kenwell_health_app/domain/models/tb_screening.dart';
import 'package:kenwell_health_app/data/services/audit_log_service.dart';
import 'package:kenwell_health_app/data/services/firestore_service.dart';
import 'package:kenwell_health_app/utils/logger.dart';

/// Repository for managing TB screening records in Firestore.
///
/// Every mutating operation writes a corresponding entry to the `audit_logs`
/// collection via [AuditLogService].
class FirestoreTbScreeningRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ScreeningLocalStore _local = ScreeningLocalStore.instance;
  final AuditLogService _audit;
  static const String _collectionName = FirestoreService.tbScreeningsCollection;

  FirestoreTbScreeningRepository({AuditLogService? auditLogService})
      : _audit = auditLogService ?? AuditLogService();

  Future<void> addTbScreening(TbScreening screening) async {
    try {
      await _firestore
          .collection(_collectionName)
          .doc(screening.id)
          .set(screening.toMap());
      // Write-through: persist to local SQLite store so data is available offline.
      unawaited(_local.upsertTbScreening(screening.toMap()));
      unawaited(_audit.logCreate(
        collection: _collectionName,
        documentId: screening.id,
        data: screening.toMap(),
        summary: 'TB screening added for member ${screening.memberId}',
      ));
      AppLogger.info('TB screening added successfully: ${screening.id}');
    } catch (e) {
      AppLogger.error('Failed to add TB screening', e);
      rethrow;
    }
  }

  Future<TbScreening?> getTbScreening(String id) async {
    try {
      final doc = await _firestore.collection(_collectionName).doc(id).get();
      if (!doc.exists) return null;
      final screening = TbScreening.fromMap(doc.data()!);
      unawaited(_local.upsertTbScreening(doc.data()!));
      return screening;
    } catch (e) {
      // Offline fallback 1: Firestore on-device cache.
      try {
        final cached = await _firestore
            .collection(_collectionName)
            .doc(id)
            .get(const GetOptions(source: Source.cache));
        if (cached.exists) return TbScreening.fromMap(cached.data()!);
      } catch (_) {}
      // Offline fallback 2: local SQLite store.
      try {
        final row = await _local.getTbScreeningById(id);
        if (row != null) return TbScreening.fromMap(row);
      } catch (_) {}
      AppLogger.error('Failed to get TB screening', e);
      rethrow;
    }
  }

  Future<List<TbScreening>> getTbScreeningsByMember(String memberId) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collectionName)
          .where('memberId', isEqualTo: memberId)
          .get();

      final screenings = querySnapshot.docs
          .map((doc) => TbScreening.fromMap(doc.data()))
          .toList();
      for (final doc in querySnapshot.docs) {
        unawaited(_local.upsertTbScreening(doc.data()));
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
              .map((doc) => TbScreening.fromMap(doc.data()))
              .toList();
        }
      } catch (_) {}
      // Offline fallback 2: local SQLite store.
      try {
        final rows = await _local.getTbScreeningsByMember(memberId);
        if (rows.isNotEmpty) {
          return rows.map((r) => TbScreening.fromMap(r)).toList();
        }
      } catch (_) {}
      AppLogger.error('Failed to get TB screenings by member', e);
      rethrow;
    }
  }

  Future<List<TbScreening>> getTbScreeningsByEvent(String eventId) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collectionName)
          .where('eventId', isEqualTo: eventId)
          .orderBy('createdAt', descending: true)
          .get();

      final screenings = querySnapshot.docs
          .map((doc) => TbScreening.fromMap(doc.data()))
          .toList();
      for (final doc in querySnapshot.docs) {
        unawaited(_local.upsertTbScreening(doc.data()));
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
              .map((doc) => TbScreening.fromMap(doc.data()))
              .toList();
        }
      } catch (_) {}
      // Offline fallback 2: local SQLite store.
      try {
        final rows = await _local.getTbScreeningsByEvent(eventId);
        if (rows.isNotEmpty) {
          return rows.map((r) => TbScreening.fromMap(r)).toList();
        }
      } catch (_) {}
      AppLogger.error('Failed to get TB screenings by event', e);
      rethrow;
    }
  }

  Future<List<TbScreening>> getAllTbScreenings() async {
    try {
      final querySnapshot = await _firestore
          .collection(_collectionName)
          .orderBy('createdAt', descending: true)
          .get();
      final screenings = querySnapshot.docs
          .map((doc) => TbScreening.fromMap(doc.data()))
          .toList();
      for (final doc in querySnapshot.docs) {
        unawaited(_local.upsertTbScreening(doc.data()));
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
              .map((doc) => TbScreening.fromMap(doc.data()))
              .toList();
        }
      } catch (_) {}
      // Offline fallback 2: local SQLite store.
      try {
        final rows = await _local.getAllTbScreenings();
        if (rows.isNotEmpty) {
          return rows.map((r) => TbScreening.fromMap(r)).toList();
        }
      } catch (_) {}
      AppLogger.error('Failed to get all TB screenings', e);
      rethrow;
    }
  }

  /// Get TB screenings for a specific set of events.
  /// Splits the event ID list into chunks of 30 to satisfy the Firestore
  /// `whereIn` limit of 30 elements.
  Future<List<TbScreening>> getTbScreeningsByEvents(
      List<String> eventIds) async {
    if (eventIds.isEmpty) return [];
    try {
      const chunkSize = 30;
      final results = <TbScreening>[];
      for (var i = 0; i < eventIds.length; i += chunkSize) {
        final chunk =
            eventIds.sublist(i, (i + chunkSize).clamp(0, eventIds.length));
        final querySnapshot = await _firestore
            .collection(_collectionName)
            .where('eventId', whereIn: chunk)
            .get();
        results.addAll(
            querySnapshot.docs.map((doc) => TbScreening.fromMap(doc.data())));
        for (final doc in querySnapshot.docs) {
          unawaited(_local.upsertTbScreening(doc.data()));
        }
      }
      return results;
    } catch (e) {
      // Offline fallback 1: Firestore on-device cache.
      try {
        const chunkSize = 30;
        final results = <TbScreening>[];
        for (var i = 0; i < eventIds.length; i += chunkSize) {
          final chunk =
              eventIds.sublist(i, (i + chunkSize).clamp(0, eventIds.length));
          final cached = await _firestore
              .collection(_collectionName)
              .where('eventId', whereIn: chunk)
              .get(const GetOptions(source: Source.cache));
          results.addAll(
              cached.docs.map((doc) => TbScreening.fromMap(doc.data())));
        }
        if (results.isNotEmpty) return results;
      } catch (_) {}
      // Offline fallback 2: local SQLite store.
      try {
        final rows = await _local.getTbScreeningsByEvents(eventIds);
        if (rows.isNotEmpty) {
          return rows.map((r) => TbScreening.fromMap(r)).toList();
        }
      } catch (_) {}
      AppLogger.error('Failed to get TB screenings by events', e);
      rethrow;
    }
  }

  /// Real-time stream of TB screenings for a specific set of events.
  Stream<List<TbScreening>> watchTbScreeningsByEvents(List<String> eventIds) {
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
          .map(
              (s) => s.docs.map((d) => TbScreening.fromMap(d.data())).toList());
    }
    return _mergeChunkStreams(chunks);
  }

  Stream<List<TbScreening>> _mergeChunkStreams(
      List<List<String>> chunks) async* {
    final latest = List<List<TbScreening>>.filled(chunks.length, []);
    final controller = StreamController<List<TbScreening>>();
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
                  s.docs.map((d) => TbScreening.fromMap(d.data())).toList();
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
