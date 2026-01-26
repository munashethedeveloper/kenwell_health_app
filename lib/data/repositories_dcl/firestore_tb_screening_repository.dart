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
      final querySnapshot = await _firestore
          .collection(_collectionName)
          .where('memberId', isEqualTo: memberId)
          .orderBy('createdAt', descending: true)
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
}
