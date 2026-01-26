import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kenwell_health_app/domain/models/hiv_result.dart';
import 'package:kenwell_health_app/data/services/firestore_service.dart';
import 'package:kenwell_health_app/utils/logger.dart';

class FirestoreHivResultRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collectionName = FirestoreService.hivResultsCollection;

  Future<void> addHivResult(HivResult result) async {
    try {
      await _firestore
          .collection(_collectionName)
          .doc(result.id)
          .set(result.toMap());
      AppLogger.info('HIV result added successfully: ${result.id}');
    } catch (e) {
      AppLogger.error('Failed to add HIV result', e);
      rethrow;
    }
  }

  Future<HivResult?> getHivResult(String id) async {
    try {
      final doc = await _firestore.collection(_collectionName).doc(id).get();
      if (!doc.exists) return null;
      return HivResult.fromMap(doc.data()!);
    } catch (e) {
      AppLogger.error('Failed to get HIV result', e);
      rethrow;
    }
  }

  Future<List<HivResult>> getHivResultsByMember(String memberId) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collectionName)
          .where('memberId', isEqualTo: memberId)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => HivResult.fromMap(doc.data()))
          .toList();
    } catch (e) {
      AppLogger.error('Failed to get HIV results by member', e);
      rethrow;
    }
  }

  Future<List<HivResult>> getHivResultsByEvent(String eventId) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collectionName)
          .where('eventId', isEqualTo: eventId)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => HivResult.fromMap(doc.data()))
          .toList();
    } catch (e) {
      AppLogger.error('Failed to get HIV results by event', e);
      rethrow;
    }
  }
}
