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

  /// Get cancer screenings for a specific set of events (up to 30 IDs).
  Future<List<CancerScreening>> getCancerScreeningsByEvents(
      List<String> eventIds) async {
    if (eventIds.isEmpty) return [];
    try {
      final querySnapshot = await _firestore
          .collection(_collectionName)
          .where('eventId', whereIn: eventIds)
          .get();
      return querySnapshot.docs
          .map((doc) => CancerScreening.fromMap(doc.data()))
          .toList();
    } catch (e) {
      AppLogger.error('Failed to get cancer screenings by events', e);
      rethrow;
    }
  }
}
