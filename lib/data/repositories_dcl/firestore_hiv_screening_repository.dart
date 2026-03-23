import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kenwell_health_app/domain/models/hiv_screening.dart';
import 'package:kenwell_health_app/data/services/firestore_service.dart';
import 'package:kenwell_health_app/utils/logger.dart';

class FirestoreHivScreeningRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collectionName =
      FirestoreService.hivScreeningsCollection;

  Future<void> addHivScreening(HivScreening screening) async {
    try {
      await _firestore
          .collection(_collectionName)
          .doc(screening.id)
          .set(screening.toMap());
      AppLogger.info('HIV screening added successfully: ${screening.id}');
    } catch (e) {
      AppLogger.error('Failed to add HIV screening', e);
      rethrow;
    }
  }

  Future<HivScreening?> getHivScreening(String id) async {
    try {
      final doc = await _firestore.collection(_collectionName).doc(id).get();
      if (!doc.exists) return null;
      return HivScreening.fromMap(doc.data()!);
    } catch (e) {
      // Offline fallback: serve from Firestore's local on-device cache.
      try {
        final cached = await _firestore
            .collection(_collectionName)
            .doc(id)
            .get(const GetOptions(source: Source.cache));
        if (cached.exists) return HivScreening.fromMap(cached.data()!);
      } catch (_) {}
      AppLogger.error('Failed to get HIV screening', e);
      rethrow;
    }
  }

  Future<List<HivScreening>> getHivScreeningsByMember(String memberId) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collectionName)
          .where('memberId', isEqualTo: memberId)
          .get();

      return querySnapshot.docs
          .map((doc) => HivScreening.fromMap(doc.data()))
          .toList();
    } catch (e) {
      // Offline fallback: serve from Firestore's local on-device cache.
      try {
        final cached = await _firestore
            .collection(_collectionName)
            .where('memberId', isEqualTo: memberId)
            .get(const GetOptions(source: Source.cache));
        return cached.docs
            .map((doc) => HivScreening.fromMap(doc.data()))
            .toList();
      } catch (_) {}
      AppLogger.error('Failed to get HIV screenings by member', e);
      rethrow;
    }
  }

  Future<List<HivScreening>> getHivScreeningsByEvent(String eventId) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collectionName)
          .where('eventId', isEqualTo: eventId)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => HivScreening.fromMap(doc.data()))
          .toList();
    } catch (e) {
      AppLogger.error('Failed to get HIV screenings by event', e);
      rethrow;
    }
  }

  Future<List<HivScreening>> getAllHivScreenings() async {
    try {
      final querySnapshot = await _firestore
          .collection(_collectionName)
          .orderBy('createdAt', descending: true)
          .get();
      return querySnapshot.docs
          .map((doc) => HivScreening.fromMap(doc.data()))
          .toList();
    } catch (e) {
      AppLogger.error('Failed to get all HIV screenings', e);
      rethrow;
    }
  }

  /// Get HIV screenings for a specific set of events.
  /// Splits the event ID list into chunks of 30 to satisfy the Firestore
  /// `whereIn` limit of 30 elements.
  Future<List<HivScreening>> getHivScreeningsByEvents(
      List<String> eventIds) async {
    if (eventIds.isEmpty) return [];
    try {
      const chunkSize = 30;
      final results = <HivScreening>[];
      for (var i = 0; i < eventIds.length; i += chunkSize) {
        final chunk =
            eventIds.sublist(i, (i + chunkSize).clamp(0, eventIds.length));
        final querySnapshot = await _firestore
            .collection(_collectionName)
            .where('eventId', whereIn: chunk)
            .get();
        results.addAll(
            querySnapshot.docs.map((doc) => HivScreening.fromMap(doc.data())));
      }
      return results;
    } catch (e) {
      AppLogger.error('Failed to get HIV screenings by events', e);
      rethrow;
    }
  }

  /// Real-time stream of HIV screenings for a specific set of events.
  Stream<List<HivScreening>> watchHivScreeningsByEvents(List<String> eventIds) {
    if (eventIds.isEmpty) return Stream.value([]);
    const chunkSize = 30;
    final chunks = <List<String>>[];
    for (var i = 0; i < eventIds.length; i += chunkSize) {
      chunks.add(eventIds.sublist(i, (i + chunkSize).clamp(0, eventIds.length)));
    }
    if (chunks.length == 1) {
      return _firestore
          .collection(_collectionName)
          .where('eventId', whereIn: chunks[0])
          .snapshots()
          .map((s) => s.docs.map((d) => HivScreening.fromMap(d.data())).toList());
    }
    return _mergeChunkStreams(chunks);
  }

  Stream<List<HivScreening>> _mergeChunkStreams(
      List<List<String>> chunks) async* {
    final latest = List<List<HivScreening>>.filled(chunks.length, []);
    final controller = StreamController<List<HivScreening>>();
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
              s.docs.map((d) => HivScreening.fromMap(d.data())).toList();
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
