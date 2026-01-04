import 'package:flutter/material.dart';
import '../services/wellness_session_service.dart';
import '../services/firebase_auth_service.dart';

/// Extension on WellnessFlowViewModel to add Firestore persistence
/// This mixin can be used to save wellness flow data to Firestore
mixin WellnessSessionPersistence {
  final WellnessSessionService _sessionService = WellnessSessionService();
  final FirebaseAuthService _authService = FirebaseAuthService();

  String? _currentSessionId;
  String? get currentSessionId => _currentSessionId;

  /// Initialize a new wellness session
  Future<String?> initializeWellnessSession(String eventId) async {
    try {
      // Get current nurse user
      final currentUser = await _authService.currentUser();
      if (currentUser == null) {
        debugPrint('No authenticated user found');
        return null;
      }

      // Create new session
      final sessionId = await _sessionService.createSession(
        eventId: eventId,
        nurseUserId: currentUser.id,
      );

      _currentSessionId = sessionId;
      debugPrint('Initialized wellness session: $sessionId');
      return sessionId;
    } catch (e) {
      debugPrint('Error initializing wellness session: $e');
      return null;
    }
  }

  /// Save consent form to Firestore
  Future<bool> saveConsentToFirestore({
    required String? sessionId,
    required Map<String, dynamic> consentData,
  }) async {
    try {
      if (sessionId == null) {
        debugPrint('No session ID available');
        return false;
      }

      await _sessionService.saveConsent(
        sessionId: sessionId,
        consentData: consentData,
      );

      return true;
    } catch (e) {
      debugPrint('Error saving consent to Firestore: $e');
      return false;
    }
  }

  /// Save member details to Firestore
  Future<String?> saveMemberDetailsToFirestore({
    required String? sessionId,
    required Map<String, dynamic> memberData,
  }) async {
    try {
      if (sessionId == null) {
        debugPrint('No session ID available');
        return null;
      }

      final participantId = await _sessionService.saveMemberDetails(
        sessionId: sessionId,
        memberData: memberData,
      );

      return participantId;
    } catch (e) {
      debugPrint('Error saving member details to Firestore: $e');
      return null;
    }
  }

  /// Save personal details to Firestore
  Future<bool> savePersonalDetailsToFirestore({
    required String? sessionId,
    required Map<String, dynamic> personalData,
  }) async {
    try {
      if (sessionId == null) {
        debugPrint('No session ID available');
        return false;
      }

      await _sessionService.savePersonalDetails(
        sessionId: sessionId,
        personalData: personalData,
      );

      return true;
    } catch (e) {
      debugPrint('Error saving personal details to Firestore: $e');
      return false;
    }
  }

  /// Save risk assessment to Firestore
  Future<bool> saveRiskAssessmentToFirestore({
    required String? sessionId,
    required Map<String, dynamic> riskData,
  }) async {
    try {
      if (sessionId == null) {
        debugPrint('No session ID available');
        return false;
      }

      await _sessionService.saveRiskAssessment(
        sessionId: sessionId,
        riskData: riskData,
      );

      return true;
    } catch (e) {
      debugPrint('Error saving risk assessment to Firestore: $e');
      return false;
    }
  }

  /// Save HIV test to Firestore
  Future<bool> saveHIVTestToFirestore({
    required String? sessionId,
    required Map<String, dynamic> hivTestData,
  }) async {
    try {
      if (sessionId == null) {
        debugPrint('No session ID available');
        return false;
      }

      await _sessionService.saveHIVTest(
        sessionId: sessionId,
        hivTestData: hivTestData,
      );

      return true;
    } catch (e) {
      debugPrint('Error saving HIV test to Firestore: $e');
      return false;
    }
  }

  /// Save HIV results to Firestore
  Future<bool> saveHIVResultsToFirestore({
    required String? sessionId,
    required Map<String, dynamic> hivResultsData,
  }) async {
    try {
      if (sessionId == null) {
        debugPrint('No session ID available');
        return false;
      }

      await _sessionService.saveHIVResults(
        sessionId: sessionId,
        hivResultsData: hivResultsData,
      );

      return true;
    } catch (e) {
      debugPrint('Error saving HIV results to Firestore: $e');
      return false;
    }
  }

  /// Save TB test to Firestore
  Future<bool> saveTBTestToFirestore({
    required String? sessionId,
    required Map<String, dynamic> tbTestData,
  }) async {
    try {
      if (sessionId == null) {
        debugPrint('No session ID available');
        return false;
      }

      await _sessionService.saveTBTest(
        sessionId: sessionId,
        tbTestData: tbTestData,
      );

      return true;
    } catch (e) {
      debugPrint('Error saving TB test to Firestore: $e');
      return false;
    }
  }

  /// Save survey to Firestore
  Future<bool> saveSurveyToFirestore({
    required String? sessionId,
    required Map<String, dynamic> surveyData,
  }) async {
    try {
      if (sessionId == null) {
        debugPrint('No session ID available');
        return false;
      }

      await _sessionService.saveSurvey(
        sessionId: sessionId,
        surveyData: surveyData,
      );

      return true;
    } catch (e) {
      debugPrint('Error saving survey to Firestore: $e');
      return false;
    }
  }

  /// Complete the wellness session
  Future<bool> completeWellnessSession(String? sessionId) async {
    try {
      if (sessionId == null) {
        debugPrint('No session ID available');
        return false;
      }

      await _sessionService.completeSession(sessionId: sessionId);
      debugPrint('Wellness session completed: $sessionId');

      // Validate integrity before completing
      final validation =
          await _sessionService.validateSessionIntegrity(sessionId);
      if (!validation['valid']) {
        debugPrint('Session integrity warnings: ${validation['warnings']}');
      }

      return true;
    } catch (e) {
      debugPrint('Error completing wellness session: $e');
      return false;
    }
  }

  /// Get session statistics
  Future<Map<String, dynamic>> getSessionStatistics(String eventId) async {
    try {
      return await _sessionService.getEventStatistics(eventId);
    } catch (e) {
      debugPrint('Error getting session statistics: $e');
      return {};
    }
  }
}
