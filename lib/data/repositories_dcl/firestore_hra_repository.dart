import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kenwell_health_app/domain/models/hra_screening.dart';
import 'package:kenwell_health_app/data/services/firestore_service.dart';
import 'package:kenwell_health_app/utils/logger.dart';

class FirestoreHraRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collectionName =
      FirestoreService.hraScreeningsCollection;

  /// Add a new HRA screening
  Future<void> addHraScreening(HraScreening screening) async {
    try {
      await _firestore
          .collection(_collectionName)
          .doc(screening.id)
          .set(screening.toMap());
      AppLogger.info('HRA screening added successfully: ${screening.id}');
    } catch (e) {
      AppLogger.error('Failed to add HRA screening', e);
      rethrow;
    }
  }

  /// Get HRA screening by ID
  Future<HraScreening?> getHraScreening(String id) async {
    try {
      final doc = await _firestore.collection(_collectionName).doc(id).get();
      if (!doc.exists) {
        return null;
      }
      return HraScreening.fromMap(doc.data()!);
    } catch (e) {
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
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => HraScreening.fromMap(doc.data()))
          .toList();
    } catch (e) {
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

      return querySnapshot.docs
          .map((doc) => HraScreening.fromMap(doc.data()))
          .toList();
    } catch (e) {
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
}
