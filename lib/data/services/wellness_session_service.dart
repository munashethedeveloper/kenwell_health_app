import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'firestore_service.dart';

/// Service for managing wellness session data in Firestore
/// A wellness session tracks a participant's journey through the wellness flow:
/// Consent -> Member Registration -> Screenings (HIV/TB/HRA) -> Survey
class WellnessSessionService {
  final FirestoreService _firestore;
  final FirebaseFirestore _firestoreInstance;

  WellnessSessionService({FirestoreService? firestoreService})
      : _firestore = firestoreService ?? FirestoreService(),
        _firestoreInstance = FirebaseFirestore.instance;

  // Collection names
  static const String sessionsCollection = 'wellness_sessions';
  static const String participantsCollection = 'participants';

  /// Create a new wellness session
  /// Returns the session ID
  Future<String> createSession({
    required String eventId,
    required String nurseUserId,
  }) async {
    try {
      final sessionData = {
        'eventId': eventId,
        'nurseUserId': nurseUserId,
        'status': 'in_progress',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'completedSteps': <String>[],
      };

      final docRef = await _firestoreInstance
          .collection(sessionsCollection)
          .add(sessionData);

      debugPrint('Created wellness session: ${docRef.id}');
      return docRef.id;
    } catch (e, stackTrace) {
      debugPrint('Error creating wellness session: $e');
      debugPrintStack(stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Save consent form data
  Future<void> saveConsent({
    required String sessionId,
    required Map<String, dynamic> consentData,
  }) async {
    try {
      await _firestoreInstance
          .collection(sessionsCollection)
          .doc(sessionId)
          .update({
        'consent': {
          ...consentData,
          'timestamp': FieldValue.serverTimestamp(),
        },
        'updatedAt': FieldValue.serverTimestamp(),
        'completedSteps': FieldValue.arrayUnion(['consent']),
      });

      debugPrint('Saved consent for session: $sessionId');
    } catch (e, stackTrace) {
      debugPrint('Error saving consent: $e');
      debugPrintStack(stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Save member/participant details
  Future<String> saveMemberDetails({
    required String sessionId,
    required Map<String, dynamic> memberData,
  }) async {
    try {
      // Create participant document
      final participantData = {
        ...memberData,
        'sessionId': sessionId,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      final docRef = await _firestoreInstance
          .collection(participantsCollection)
          .add(participantData);

      // Update session with participant reference
      await _firestoreInstance
          .collection(sessionsCollection)
          .doc(sessionId)
          .update({
        'participantId': docRef.id,
        'memberDetails': {
          ...memberData,
          'timestamp': FieldValue.serverTimestamp(),
        },
        'updatedAt': FieldValue.serverTimestamp(),
        'completedSteps': FieldValue.arrayUnion(['member_registration']),
      });

      debugPrint('Saved member details for session: $sessionId');
      return docRef.id;
    } catch (e, stackTrace) {
      debugPrint('Error saving member details: $e');
      debugPrintStack(stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Save personal details (if separate from member registration)
  Future<void> savePersonalDetails({
    required String sessionId,
    required Map<String, dynamic> personalData,
  }) async {
    try {
      await _firestoreInstance
          .collection(sessionsCollection)
          .doc(sessionId)
          .update({
        'personalDetails': {
          ...personalData,
          'timestamp': FieldValue.serverTimestamp(),
        },
        'updatedAt': FieldValue.serverTimestamp(),
        'completedSteps': FieldValue.arrayUnion(['personal_details']),
      });

      debugPrint('Saved personal details for session: $sessionId');
    } catch (e, stackTrace) {
      debugPrint('Error saving personal details: $e');
      debugPrintStack(stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Save risk assessment data
  Future<void> saveRiskAssessment({
    required String sessionId,
    required Map<String, dynamic> riskData,
  }) async {
    try {
      await _firestoreInstance
          .collection(sessionsCollection)
          .doc(sessionId)
          .update({
        'riskAssessment': {
          ...riskData,
          'timestamp': FieldValue.serverTimestamp(),
        },
        'updatedAt': FieldValue.serverTimestamp(),
        'completedSteps': FieldValue.arrayUnion(['risk_assessment']),
      });

      debugPrint('Saved risk assessment for session: $sessionId');
    } catch (e, stackTrace) {
      debugPrint('Error saving risk assessment: $e');
      debugPrintStack(stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Save HIV test data
  Future<void> saveHIVTest({
    required String sessionId,
    required Map<String, dynamic> hivTestData,
  }) async {
    try {
      await _firestoreInstance
          .collection(sessionsCollection)
          .doc(sessionId)
          .update({
        'hivTest': {
          ...hivTestData,
          'timestamp': FieldValue.serverTimestamp(),
        },
        'updatedAt': FieldValue.serverTimestamp(),
        'completedSteps': FieldValue.arrayUnion(['hiv_test']),
      });

      debugPrint('Saved HIV test for session: $sessionId');
    } catch (e, stackTrace) {
      debugPrint('Error saving HIV test: $e');
      debugPrintStack(stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Save HIV test results
  Future<void> saveHIVResults({
    required String sessionId,
    required Map<String, dynamic> hivResultsData,
  }) async {
    try {
      await _firestoreInstance
          .collection(sessionsCollection)
          .doc(sessionId)
          .update({
        'hivResults': {
          ...hivResultsData,
          'timestamp': FieldValue.serverTimestamp(),
        },
        'updatedAt': FieldValue.serverTimestamp(),
        'completedSteps': FieldValue.arrayUnion(['hiv_results']),
      });

      debugPrint('Saved HIV results for session: $sessionId');
    } catch (e, stackTrace) {
      debugPrint('Error saving HIV results: $e');
      debugPrintStack(stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Save TB test data
  Future<void> saveTBTest({
    required String sessionId,
    required Map<String, dynamic> tbTestData,
  }) async {
    try {
      await _firestoreInstance
          .collection(sessionsCollection)
          .doc(sessionId)
          .update({
        'tbTest': {
          ...tbTestData,
          'timestamp': FieldValue.serverTimestamp(),
        },
        'updatedAt': FieldValue.serverTimestamp(),
        'completedSteps': FieldValue.arrayUnion(['tb_test']),
      });

      debugPrint('Saved TB test for session: $sessionId');
    } catch (e, stackTrace) {
      debugPrint('Error saving TB test: $e');
      debugPrintStack(stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Save survey data
  Future<void> saveSurvey({
    required String sessionId,
    required Map<String, dynamic> surveyData,
  }) async {
    try {
      await _firestoreInstance
          .collection(sessionsCollection)
          .doc(sessionId)
          .update({
        'survey': {
          ...surveyData,
          'timestamp': FieldValue.serverTimestamp(),
        },
        'updatedAt': FieldValue.serverTimestamp(),
        'completedSteps': FieldValue.arrayUnion(['survey']),
      });

      debugPrint('Saved survey for session: $sessionId');
    } catch (e, stackTrace) {
      debugPrint('Error saving survey: $e');
      debugPrintStack(stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Complete a wellness session
  Future<void> completeSession({
    required String sessionId,
  }) async {
    try {
      await _firestoreInstance
          .collection(sessionsCollection)
          .doc(sessionId)
          .update({
        'status': 'completed',
        'completedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      debugPrint('Completed wellness session: $sessionId');
    } catch (e, stackTrace) {
      debugPrint('Error completing session: $e');
      debugPrintStack(stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Get session data
  Future<Map<String, dynamic>?> getSession(String sessionId) async {
    try {
      return await _firestore.getDocument(
        collection: sessionsCollection,
        documentId: sessionId,
      );
    } catch (e) {
      debugPrint('Error getting session: $e');
      return null;
    }
  }

  /// Get all sessions for an event
  Future<List<Map<String, dynamic>>> getSessionsForEvent(String eventId) async {
    try {
      return await _firestore.queryDocuments(
        collection: sessionsCollection,
        field: 'eventId',
        isEqualTo: eventId,
      );
    } catch (e) {
      debugPrint('Error getting sessions for event: $e');
      return [];
    }
  }

  /// Get participant data
  Future<Map<String, dynamic>?> getParticipant(String participantId) async {
    try {
      return await _firestore.getDocument(
        collection: participantsCollection,
        documentId: participantId,
      );
    } catch (e) {
      debugPrint('Error getting participant: $e');
      return null;
    }
  }

  /// Validate session integrity
  Future<Map<String, dynamic>> validateSessionIntegrity(
      String sessionId) async {
    try {
      final session = await getSession(sessionId);

      if (session == null) {
        return {
          'valid': false,
          'errors': ['Session not found'],
        };
      }

      final errors = <String>[];
      final warnings = <String>[];

      // Check required fields
      if (session['eventId'] == null) {
        errors.add('Missing eventId');
      }

      if (session['nurseUserId'] == null) {
        errors.add('Missing nurseUserId');
      }

      // Check consent
      if (session['consent'] == null) {
        warnings.add('Missing consent data');
      }

      // Check member details
      if (session['memberDetails'] == null &&
          session['participantId'] == null) {
        warnings.add('Missing member/participant data');
      }

      // Validate participant if exists
      if (session['participantId'] != null) {
        final participant = await getParticipant(session['participantId']);
        if (participant == null) {
          errors.add('Participant document not found');
        }
      }

      // Check completed steps consistency
      final completedSteps =
          (session['completedSteps'] as List?)?.cast<String>() ?? [];

      if (session['consent'] != null && !completedSteps.contains('consent')) {
        warnings.add('Consent data exists but not in completedSteps');
      }

      if (session['survey'] != null && !completedSteps.contains('survey')) {
        warnings.add('Survey data exists but not in completedSteps');
      }

      return {
        'valid': errors.isEmpty,
        'errors': errors,
        'warnings': warnings,
        'completedSteps': completedSteps,
        'status': session['status'],
      };
    } catch (e) {
      debugPrint('Error validating session integrity: $e');
      return {
        'valid': false,
        'errors': ['Validation error: $e'],
      };
    }
  }

  /// Get session statistics for an event
  Future<Map<String, dynamic>> getEventStatistics(String eventId) async {
    try {
      final sessions = await getSessionsForEvent(eventId);

      int totalSessions = sessions.length;
      int completedSessions =
          sessions.where((s) => s['status'] == 'completed').length;
      int inProgressSessions =
          sessions.where((s) => s['status'] == 'in_progress').length;

      // Count screenings
      int hivTests = sessions
          .where((s) => s['hivTest'] != null || s['hivResults'] != null)
          .length;
      int tbTests = sessions.where((s) => s['tbTest'] != null).length;
      int riskAssessments =
          sessions.where((s) => s['riskAssessment'] != null).length;
      int surveysCompleted = sessions.where((s) => s['survey'] != null).length;

      return {
        'totalSessions': totalSessions,
        'completedSessions': completedSessions,
        'inProgressSessions': inProgressSessions,
        'hivTests': hivTests,
        'tbTests': tbTests,
        'riskAssessments': riskAssessments,
        'surveysCompleted': surveysCompleted,
      };
    } catch (e) {
      debugPrint('Error getting event statistics: $e');
      return {};
    }
  }
}
