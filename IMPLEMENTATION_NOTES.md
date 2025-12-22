# Event Conducting Flow Refactor - Implementation Notes

## Overview
This refactor changes how events are conducted by starting with member registration and adding database persistence for members.

## Major Changes

### 1. Database Schema Changes
- **New Table**: `Members` table added to store participant information
- **Schema Version**: Updated from 12 to 13
- **Migration**: Automatic migration added in `app_database.dart`

### 2. New Flow Structure
**Before:**
```
Start Event → Current Event Details → Select Section → Complete Section
```

**After:**
```
Start Event → Member Registration → 
  ├─ Member Found → Current Event Details → Select Section
  └─ Member Not Found → Member Details Form → Current Event Details → Select Section
```

### 3. Member Registration Screen Enhancements
- Added ID/Passport dropdown selector
- Dynamic field labels based on selection (RSA ID Number vs Passport Number)
- Database search functionality
- Conditional button display:
  - "Continue to Event Details" shown when member is found
  - "Go to Member Details" shown when member needs registration

### 4. Current Event Details Screen Updates
- Added completion indicators (green checkmarks) for:
  - Consent
  - Member Registration  
  - Health Screenings
  - Survey
- These indicators help users track their progress

### 5. Member Data Persistence
- `MemberDetailsViewModel` now saves to database via `MemberRepository`
- Member data persists across app sessions
- Search functionality uses actual database queries

## Files Modified

### New Files
- `lib/domain/models/member.dart` - Member domain model
- `lib/data/repositories_dcl/member_repository.dart` - Repository for member operations
- `regenerate_db.sh` - Helper script to regenerate database code

### Modified Files
- `lib/data/local/app_database.dart` - Added Members table and CRUD operations
- `lib/ui/features/wellness/view_model/wellness_flow_view_model.dart` - Flow logic changes
- `lib/ui/features/wellness/widgets/wellness_flow_screen.dart` - Screen navigation updates
- `lib/ui/features/wellness/widgets/member_registration_screen.dart` - UI and search logic
- `lib/ui/features/wellness/widgets/current_event_details_screen.dart` - Completion indicators
- `lib/ui/features/member/view_model/member_details_view_model.dart` - Database persistence
- `lib/ui/features/member/widgets/member_details_screen.dart` - Flow integration

## Required Setup Steps

### 1. Regenerate Database Code
**Important:** After pulling these changes, you MUST regenerate the Drift database code:

```bash
# Option 1: Use the provided script
./regenerate_db.sh

# Option 2: Manual commands
flutter clean
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
```

This generates the `app_database.g.dart` file with the new Members table definitions.

### 2. Database Migration
The database will automatically migrate to schema version 13 on first app launch after updating. The Members table will be created automatically.

## Testing Checklist

- [ ] Start/Resume event navigates to Member Registration screen
- [ ] ID/Passport dropdown changes field label appropriately
- [ ] Search by ID number finds existing members
- [ ] Search by Passport number finds existing members
- [ ] Search for non-existent member shows "Go to Member Details" button
- [ ] Search for existing member shows "Continue to Event Details" button
- [ ] Member Details form saves to database successfully
- [ ] After saving member, user navigates to Event Details screen
- [ ] Completion checkmarks appear on Event Details cards after completing sections
- [ ] Member Registration checkmark appears after registering/finding a member
- [ ] Consent checkmark appears after completing consent
- [ ] Screenings checkmark appears after completing screening flow
- [ ] Survey checkmark appears after completing survey

## Known Limitations

1. **Build Runner Required**: The database code generation requires running `build_runner`. This cannot be done automatically in this environment without Flutter SDK.

2. **Search Functionality**: Currently searches by exact ID/Passport match. Future enhancements could include:
   - Fuzzy search
   - Search by name
   - Search by partial ID

3. **Member Updates**: The current implementation creates new members but doesn't handle updating existing member information.

## Future Enhancements

1. **Dependency Injection**: Refactor to inject MemberRepository instead of creating instances directly in view models and widgets
2. **Database Indexing**: Add indices on frequently searched columns (name, surname, idNumber, passportNumber) for better search performance
3. **Member Update Flow**: Allow editing existing member information
4. **Search History**: Show recently searched members
5. **Offline Sync**: Handle cases where database queries fail
6. **Validation**: Add more robust validation for ID numbers and passport formats
7. **Member List**: Add a screen to view all registered members
8. **Full-Text Search**: Consider implementing full-text search for better search performance with large datasets

## Database Schema

### Members Table
```sql
CREATE TABLE members (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  surname TEXT NOT NULL,
  id_number TEXT,
  passport_number TEXT,
  id_document_type TEXT NOT NULL,
  date_of_birth TEXT,
  gender TEXT,
  marital_status TEXT,
  nationality TEXT,
  citizenship_status TEXT,
  email TEXT,
  cell_number TEXT,
  medical_aid_status TEXT,
  medical_aid_name TEXT,
  medical_aid_number TEXT,
  created_at INTEGER NOT NULL,
  updated_at INTEGER NOT NULL
);
```

## Troubleshooting

### "Table members doesn't exist" error
Run the database regeneration script: `./regenerate_db.sh`

### "Import not found" errors
Ensure all dependencies are installed: `flutter pub get`

### Database migration fails
Delete the app and reinstall to force recreation of database with new schema
