import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kenwell_health_app/domain/models/cancer_screening.dart';
import 'package:kenwell_health_app/data/services/firestore_service.dart';
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
      final querySnapshot = await _firestore
          .collection(_collectionName)
          .where('memberId', isEqualTo: memberId)
          .orderBy('createdAt', descending: true)
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
}
