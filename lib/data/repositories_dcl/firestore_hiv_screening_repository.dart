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
      AppLogger.error('Failed to get HIV screening', e);
      rethrow;
    }
  }

  Future<List<HivScreening>> getHivScreeningsByMember(String memberId) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collectionName)
          .where('memberId', isEqualTo: memberId)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => HivScreening.fromMap(doc.data()))
          .toList();
    } catch (e) {
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
}
