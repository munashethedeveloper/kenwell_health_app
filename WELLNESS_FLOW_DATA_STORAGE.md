# Wellness Flow Data Storage Guide

This guide explains how wellness event flow data is saved to Firestore with proper data integrity.

## Overview

The wellness flow represents a participant's journey through health screenings at an event:

**Flow Steps:**
1. **Consent Form** - Participant consent and screening selections
2. **Member Registration** - Personal information and demographics
3. **Personal Details** - Additional participant information
4. **Risk Assessment** (Optional) - Health risk assessment (HRA)
5. **HIV Test** (Optional) - HIV testing questionnaire
6. **HIV Results** (Optional) - HIV test results and counseling
7. **TB Test** (Optional) - TB screening
8. **Survey** - Feedback survey (always completed)

## Data Structure in Firestore

### Collections

#### `wellness_sessions` Collection

Stores complete wellness session data for each participant.

```
wellness_sessions/{sessionId}
  - eventId: string (references events collection)
  - nurseUserId: string (references users collection)
  - participantId: string (references participants collection)
  - status: string ('in_progress' or 'completed')
  - createdAt: timestamp
  - updatedAt: timestamp
  - completedAt: timestamp (nullable)
  - completedSteps: array of strings
  
  - consent: {
      venue: string
      date: string
      practitioner: string
      selectedScreenings: array ['hra', 'hiv', 'tb']
      signature: base64 string (image)
      timestamp: timestamp
    }
  
  - memberDetails: {
      screeningSite: string
      name: string
      surname: string
      dateOfBirth: string
      idNumber: string
      passportNumber: string
      idDocumentChoice: string
      nationality: string
      citizenshipStatus: string
      medicalAidName: string
      medicalAidNumber: string
      medicalAidStatus: string
      email: string
      cellNumber: string
      personalNumber: string
      maritalStatus: string
      gender: string
      timestamp: timestamp
    }
  
  - personalDetails: {
      // Additional personal information if needed
      timestamp: timestamp
    }
  
  - riskAssessment: {
      // HRA questions and answers
      timestamp: timestamp
    }
  
  - hivTest: {
      firstHIVTest: string
      lastTestMonth: string
      lastTestYear: string
      lastTestResult: string
      sharedNeedles: string
      unprotectedSex: string
      treatedSTI: string
      treatedTB: string
      noCondomUse: string
      noCondomReason: string
      knowPartnerStatus: string
      timestamp: timestamp
    }
  
  - hivResults: {
      screeningTest: {
        testName: string
        batchNo: string
        expiryDate: string
        result: string
      }
      confirmationTest: {
        testName: string
        batchNo: string
        expiryDate: string
        result: string
      }
      finalResult: string
      nurseFirstName: string
      nurseLastName: string
      nurseSignature: base64 string
      timestamp: timestamp
    }
  
  - tbTest: {
      // TB screening questions and results
      timestamp: timestamp
    }
  
  - survey: {
      heardAbout: string
      province: string
      ratings: {
        overallExperience: number
        friendlyStaff: number
        nurseProfessional: number
        clearResults: number
        realisedValue: number
        encourageColleagues: number
      }
      contactConsent: string
      timestamp: timestamp
    }
```

#### `participants` Collection

Stores participant information separately for easy querying and reporting.

```
participants/{participantId}
  - sessionId: string (references wellness_sessions)
  - name: string
  - surname: string
  - email: string
  - cellNumber: string
  - dateOfBirth: string
  - gender: string
  - idNumber: string
  - passportNumber: string
  - nationality: string
  - createdAt: timestamp
  - updatedAt: timestamp
```

## Implementation

### Service Layer

**`WellnessSessionService`** (`lib/data/services/wellness_session_service.dart`)

Provides methods to save each step of the wellness flow:

```dart
final sessionService = WellnessSessionService();

// 1. Create session
final sessionId = await sessionService.createSession(
  eventId: eventId,
  nurseUserId: currentUserId,
);

// 2. Save consent
await sessionService.saveConsent(
  sessionId: sessionId,
  consentData: {
    'venue': 'Main Hall',
    'date': '2024-01-15',
    'practitioner': 'Jane Doe',
    'selectedScreenings': ['hiv', 'tb'],
    'signature': signatureBase64,
  },
);

// 3. Save member details
final participantId = await sessionService.saveMemberDetails(
  sessionId: sessionId,
  memberData: {
    'name': 'John',
    'surname': 'Smith',
    'email': 'john@example.com',
    // ... other fields
  },
);

// 4. Save screenings (if selected)
await sessionService.saveHIVTest(
  sessionId: sessionId,
  hivTestData: {...},
);

await sessionService.saveHIVResults(
  sessionId: sessionId,
  hivResultsData: {...},
);

// 5. Save survey
await sessionService.saveSurvey(
  sessionId: sessionId,
  surveyData: {...},
);

// 6. Complete session
await sessionService.completeSession(sessionId: sessionId);
```

### View Model Integration

**`WellnessSessionPersistence`** (`lib/ui/features/wellness/view_model/wellness_session_persistence.dart`)

Mixin that can be added to WellnessFlowViewModel for easy Firestore integration:

```dart
class WellnessFlowViewModel extends ChangeNotifier with WellnessSessionPersistence {
  // Existing code...
  
  // Initialize session when starting wellness flow
  Future<void> startWellnessFlow(String eventId) async {
    final sessionId = await initializeWellnessSession(eventId);
    // Continue with flow...
  }
  
  // Save consent when completed
  Future<void> onConsentCompleted() async {
    final consentData = consentVM.toMap();
    await saveConsentToFirestore(
      sessionId: currentSessionId,
      consentData: consentData,
    );
    // Move to next step...
  }
  
  // Save member details when completed
  Future<void> onMemberDetailsCompleted() async {
    final memberData = memberDetailsVM.toMap();
    await saveMemberDetailsToFirestore(
      sessionId: currentSessionId,
      memberData: memberData,
    );
    // Move to next step...
  }
  
  // Continue for each step...
  
  // Complete session when flow is done
  Future<void> onFlowCompleted() async {
    await completeWellnessSession(currentSessionId);
  }
}
```

## Data Integrity Features

### 1. Referential Integrity

**Event → Sessions:** Each session links to an event via `eventId`
```dart
// Query all sessions for an event
final sessions = await sessionService.getSessionsForEvent(eventId);
```

**Session → Participant:** Each session links to a participant
```dart
// Get participant details
final participant = await sessionService.getParticipant(participantId);
```

**Session → Nurse:** Each session links to the nurse who conducted it
```dart
// Sessions include nurseUserId
// Can query which nurse conducted which sessions
```

### 2. Temporal Integrity

All data includes timestamps:
- `createdAt` - When the document was created
- `updatedAt` - When the document was last modified
- `completedAt` - When the session was marked complete
- `timestamp` - When each step was completed

### 3. Completeness Tracking

The `completedSteps` array tracks which steps have been completed:
```dart
completedSteps: ['consent', 'member_registration', 'hiv_test', 'survey']
```

This ensures:
- You can verify which steps were completed
- You can resume incomplete sessions
- You can track progress

### 4. Validation

**Built-in validation:**
```dart
final validation = await sessionService.validateSessionIntegrity(sessionId);

if (validation['valid']) {
  print('Session is valid');
} else {
  print('Errors: ${validation['errors']}');
  print('Warnings: ${validation['warnings']}');
}
```

Validates:
- Required fields exist
- Referenced documents exist
- Completed steps match data present

### 5. Audit Trail

Every update includes:
- Timestamp of when data was saved
- User ID of who performed the action
- History preserved (Firestore keeps document history)

## Usage Examples

### Example 1: Start Wellness Flow with Auto-Save

```dart
class WellnessFlowViewModel extends ChangeNotifier with WellnessSessionPersistence {
  WellnessEvent? activeEvent;
  
  Future<void> startFlow() async {
    if (activeEvent == null) return;
    
    // Initialize Firestore session
    final sessionId = await initializeWellnessSession(activeEvent!.id);
    if (sessionId == null) {
      // Handle error
      return;
    }
    
    debugPrint('Started wellness session: $sessionId');
  }
  
  Future<void> completeConsent() async {
    // Save to Firestore
    final consentData = {
      'venue': consentVM.venueController.text,
      'date': consentVM.dateController.text,
      'practitioner': consentVM.practitionerController.text,
      'selectedScreenings': consentVM.selectedScreenings,
      'signature': await _getSignatureBase64(),
    };
    
    await saveConsentToFirestore(
      sessionId: currentSessionId,
      consentData: consentData,
    );
    
    // Continue to next step
    moveToNextStep();
  }
}
```

### Example 2: Query Statistics

```dart
// Get statistics for an event
final stats = await sessionService.getEventStatistics(eventId);

print('Total participants: ${stats['totalSessions']}');
print('HIV tests: ${stats['hivTests']}');
print('TB tests: ${stats['tbTests']}');
print('Surveys completed: ${stats['surveysCompleted']}');
```

### Example 3: Resume Incomplete Session

```dart
// Get all sessions for an event
final sessions = await sessionService.getSessionsForEvent(eventId);

// Find incomplete sessions
final incomplete = sessions.where((s) => s['status'] == 'in_progress');

for (var session in incomplete) {
  final completedSteps = session['completedSteps'] as List;
  print('Session ${session.id} completed: $completedSteps');
  
  // Resume from last completed step
  if (!completedSteps.contains('survey')) {
    // Show survey screen
  } else if (!completedSteps.contains('hiv_results')) {
    // Show HIV results screen
  }
  // ...
}
```

## Security Rules

Add these Firestore security rules:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    function isAuthenticated() {
      return request.auth != null;
    }
    
    function getUserRole() {
      return get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role;
    }
    
    function isNurseOrAdmin() {
      return getUserRole() in ['NURSE', 'ADMIN', 'MANAGEMENT'];
    }
    
    // Wellness sessions
    match /wellness_sessions/{sessionId} {
      // Nurses, admins, and management can create and read sessions
      allow create: if isNurseOrAdmin();
      allow read: if isNurseOrAdmin();
      
      // Only the nurse who created the session can update it (unless admin)
      allow update: if isNurseOrAdmin() && 
                      (resource.data.nurseUserId == request.auth.uid || 
                       getUserRole() in ['ADMIN', 'MANAGEMENT']);
      
      // Only admins can delete
      allow delete: if getUserRole() == 'ADMIN';
    }
    
    // Participants
    match /participants/{participantId} {
      // Nurses, admins, and management can read participant data
      allow read: if isNurseOrAdmin();
      
      // Automatically created with sessions, so check session permissions
      allow create: if isNurseOrAdmin();
      
      // Only admins and management can update participant info
      allow update: if getUserRole() in ['ADMIN', 'MANAGEMENT'];
      
      // Only admins can delete
      allow delete: if getUserRole() == 'ADMIN';
    }
  }
}
```

## Best Practices

### 1. Always Initialize Session First

```dart
// ❌ Bad - saving without session
await saveConsent(consentData);

// ✅ Good - initialize session first
final sessionId = await initializeWellnessSession(eventId);
await saveConsentToFirestore(sessionId: sessionId, consentData: consentData);
```

### 2. Use Transactions for Critical Updates

For operations that must succeed together, use batched writes or transactions (already handled by the service).

### 3. Handle Errors Gracefully

```dart
try {
  await saveConsentToFirestore(
    sessionId: sessionId,
    consentData: consentData,
  );
} catch (e) {
  // Show error to user
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Failed to save data: $e')),
  );
  // Allow retry
}
```

### 4. Validate Before Completing

```dart
// Validate session before marking complete
final validation = await sessionService.validateSessionIntegrity(sessionId);

if (!validation['valid']) {
  // Show errors to user
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Incomplete Data'),
      content: Text('Missing: ${validation['warnings'].join(', ')}'),
    ),
  );
  return;
}

// Complete session
await sessionService.completeSession(sessionId: sessionId);
```

### 5. Track Offline State

```dart
// Firestore handles offline automatically
// But you can listen to connectivity to inform users

FirebaseFirestore.instance.settings = const Settings(
  persistenceEnabled: true, // Enable offline persistence
);

// Data will sync automatically when online
```

## Migration from Local Storage

If you have existing wellness flow data stored locally, migrate it:

```dart
// Read local wellness flow data
final localData = await getLocalWellnessData();

// Create Firestore session
final sessionId = await sessionService.createSession(
  eventId: localData['eventId'],
  nurseUserId: localData['nurseUserId'],
);

// Save each component
if (localData['consent'] != null) {
  await sessionService.saveConsent(
    sessionId: sessionId,
    consentData: localData['consent'],
  );
}

if (localData['memberDetails'] != null) {
  await sessionService.saveMemberDetails(
    sessionId: sessionId,
    memberData: localData['memberDetails'],
  );
}

// ... migrate other steps

// Mark as completed if it was completed locally
if (localData['status'] == 'completed') {
  await sessionService.completeSession(sessionId: sessionId);
}
```

## Summary

The wellness flow data storage system provides:
- ✅ Complete audit trail of participant journey
- ✅ Data integrity with referential constraints
- ✅ Temporal tracking with timestamps
- ✅ Progress tracking with completed steps
- ✅ Built-in validation
- ✅ Statistics and reporting capabilities
- ✅ Offline support
- ✅ Secure access control

All data is automatically synced to Firestore in real-time, with offline support for unreliable connections.

For implementation details, see:
- `lib/data/services/wellness_session_service.dart` - Core service
- `lib/ui/features/wellness/view_model/wellness_session_persistence.dart` - View model integration
- `DATA_MIGRATION_GUIDE.md` - General Firestore migration guide
