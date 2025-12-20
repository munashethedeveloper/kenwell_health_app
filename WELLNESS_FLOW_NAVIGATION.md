# Wellness Flow Navigation Structure

## Overview
The wellness flow has been refactored to start with a **Current Event Details Screen** that shows four section cards in a 2x2 grid layout. Users can navigate to different sections based on their selection.

## Section Cards
1. **Consent** - Navigate to consent form
2. **Member Registration** - Navigate to member registration screen with search functionality
3. **Health Screenings** - Navigate to consent form to select screenings
4. **Survey** - Navigate directly to survey

## Navigation Flows

### Flow 1: Health Screening (via Consent or Health Screenings card)
```
CurrentEventDetailsScreen
  ↓ (click "Consent" or "Health Screenings")
ConsentScreen
  ↓ (select screenings and click Next)
PersonalDetailsScreen
  ↓ (if HRA selected)
RiskAssessmentScreen
  ↓ (if HIV selected)
HIVTestScreen
  ↓
HIVTestResultScreen
  ↓ (if TB selected)
TBTestingScreen
  ↓
SurveyScreen
  ↓ (submit)
Back to CurrentEventDetailsScreen
```

### Flow 2: Member Registration
```
CurrentEventDetailsScreen
  ↓ (click "Member Registration")
MemberRegistrationScreen
  ├─ Search for members
  └─ (click "Go to Member Details")
      ↓
    PersonalDetailsScreen
      ↓ (can continue with other flows if needed)
```

### Flow 3: Direct Survey
```
CurrentEventDetailsScreen
  ↓ (click "Survey")
SurveyScreen
  ↓ (submit)
Back to CurrentEventDetailsScreen
```

## Back Navigation
- From any screen (except CurrentEventDetailsScreen), clicking Back/Previous navigates to the previous screen in the flow
- From ConsentScreen, clicking Cancel returns to CurrentEventDetailsScreen
- From MemberRegistrationScreen, clicking Back returns to CurrentEventDetailsScreen
- Completing and submitting the survey returns to CurrentEventDetailsScreen

## Screen Components

### CurrentEventDetailsScreen
- App Logo (200px)
- 2x2 Grid of section cards:
  - Consent (assignment icon)
  - Member Registration (person_add icon)
  - Health Screenings (medical_services icon)
  - Survey (assignment_turned_in icon)

### MemberRegistrationScreen
- App Logo (200px)
- Search bar with placeholder "Enter member name or ID"
- Search button
- "Go to Member Details" button
- Back button

## Implementation Files
- `lib/ui/features/wellness/widgets/current_event_details_screen.dart` - New first screen
- `lib/ui/features/wellness/widgets/member_registration_screen.dart` - New member registration screen
- `lib/ui/features/wellness/view_model/wellness_flow_view_model.dart` - Updated with new navigation methods
- `lib/ui/features/wellness/widgets/wellness_flow_screen.dart` - Updated to handle new screens
