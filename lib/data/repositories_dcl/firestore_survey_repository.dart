import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

/// Repository for the `survey_results` Firestore collection.
///
/// Centralises all direct Firestore access for survey data so that
/// ViewModels never import `cloud_firestore` directly.
class FirestoreSurveyRepository {
  static const _collection = 'survey_results';

  const FirestoreSurveyRepository();

  /// Saves [data] as a new survey document with [id] as the document ID.
  Future<void> saveSurveyResult({
    required String id,
    required Map<String, dynamic> data,
  }) async {
    await FirebaseFirestore.instance
        .collection(_collection)
        .doc(id)
        .set({...data, 'id': id});
  }

  /// Returns true if a survey of [type] already exists for [memberId] and
  /// [eventId].
  Future<bool> hasCompletedSurvey({
    required String memberId,
    required String eventId,
    String type = 'survey',
  }) async {
    try {
      final snap = await FirebaseFirestore.instance
          .collection(_collection)
          .where('memberId', isEqualTo: memberId)
          .where('eventId', isEqualTo: eventId)
          .where('type', isEqualTo: type)
          .limit(1)
          .get();
      return snap.docs.isNotEmpty;
    } catch (e) {
      debugPrint('FirestoreSurveyRepository.hasCompletedSurvey error: $e');
      return false;
    }
  }
}
