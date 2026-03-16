import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kenwell_health_app/domain/models/tb_screening.dart';
import 'package:kenwell_health_app/data/services/firestore_service.dart';
import 'package:kenwell_health_app/utils/logger.dart';

class FirestoreTbScreeningRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collectionName = FirestoreService.tbScreeningsCollection;

  Future<void> addTbScreening(TbScreening screening) async {
    try {
      await _firestore
          .collection(_collectionName)
          .doc(screening.id)
          .set(screening.toMap());
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
      return TbScreening.fromMap(doc.data()!);
    } catch (e) {
      AppLogger.error('Failed to get TB screening', e);
      rethrow;
    }
  }

  Future<List<TbScreening>> getTbScreeningsByMember(String memberId) async {
    try {
      // NOTE: No orderBy here — .where('memberId').orderBy('createdAt')
      // requires a Firestore composite index.  Without it Firestore throws an
      // error that is silently caught in loadAllCompletionFlags, leaving the
      // tbCompleted flag permanently false.  A single equality filter uses
      // the auto-created single-field index and needs no composite index.
      final querySnapshot = await _firestore
          .collection(_collectionName)
          .where('memberId', isEqualTo: memberId)
          .get();

      return querySnapshot.docs
          .map((doc) => TbScreening.fromMap(doc.data()))
          .toList();
    } catch (e) {
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

      return querySnapshot.docs
          .map((doc) => TbScreening.fromMap(doc.data()))
          .toList();
    } catch (e) {
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
      return querySnapshot.docs
          .map((doc) => TbScreening.fromMap(doc.data()))
          .toList();
    } catch (e) {
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
        final chunk = eventIds.sublist(
            i, (i + chunkSize).clamp(0, eventIds.length));
        final querySnapshot = await _firestore
            .collection(_collectionName)
            .where('eventId', whereIn: chunk)
            .get();
        results.addAll(
            querySnapshot.docs.map((doc) => TbScreening.fromMap(doc.data())));
      }
      return results;
    } catch (e) {
      AppLogger.error('Failed to get TB screenings by events', e);
      rethrow;
    }
  }
}
