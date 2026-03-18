import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kenwell_health_app/data/services/firestore_service.dart';
import 'package:kenwell_health_app/domain/models/cander_screening.dart';
import 'package:kenwell_health_app/utils/logger.dart';

class FirestoreCancerScreeningRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collectionName =
      FirestoreService.cancerScreeningsCollection;

  Future<void> addCancerScreening(CancerScreening screening) async {
    try {
      await _firestore
          .collection(_collectionName)
          .doc(screening.id)
          .set(screening.toMap());
      AppLogger.info('Cancer screening added successfully: ${screening.id}');
    } catch (e) {
      AppLogger.error('Failed to add cancer screening', e);
      rethrow;
    }
  }

  Future<CancerScreening?> getCancerScreening(String id) async {
    try {
      final doc = await _firestore.collection(_collectionName).doc(id).get();
      if (!doc.exists) return null;
      return CancerScreening.fromMap(doc.data()!);
    } catch (e) {
      AppLogger.error('Failed to get cancer screening', e);
      rethrow;
    }
  }

  Future<List<CancerScreening>> getCancerScreeningsByMember(
      String memberId) async {
    try {
      // NOTE: No orderBy here — .where('memberId').orderBy('createdAt')
      // requires a Firestore composite index.  Without it Firestore throws an
      // error that is silently caught in loadAllCompletionFlags, leaving the
      // cancerCompleted flag permanently false.  A single equality filter uses
      // the auto-created single-field index and needs no composite index.
      final querySnapshot = await _firestore
          .collection(_collectionName)
          .where('memberId', isEqualTo: memberId)
          .get();

      return querySnapshot.docs
          .map((doc) => CancerScreening.fromMap(doc.data()))
          .toList();
    } catch (e) {
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

      return querySnapshot.docs
          .map((doc) => CancerScreening.fromMap(doc.data()))
          .toList();
    } catch (e) {
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
      return querySnapshot.docs
          .map((doc) => CancerScreening.fromMap(doc.data()))
          .toList();
    } catch (e) {
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
      }
      return results;
    } catch (e) {
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
