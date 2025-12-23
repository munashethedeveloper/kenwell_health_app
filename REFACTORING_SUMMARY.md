# Event Logic Refactoring - Summary of Changes

## Overview
This refactoring addresses two main issues:
1. Newly created events not displaying on the Conduct Event screen
2. Incorrect filtering of events for the selected week (This Week / Next Week)

## Changes Made

### 1. Database Schema Updates

#### Added `screenedCount` Column
- **File**: `lib/data/local/app_database.dart`
- **Changes**:
  - Added `IntColumn get screenedCount => integer().withDefault(const Constant(0))();` to Events table
  - Incremented schema version from 12 to 13
  - Added migration logic in `onUpgrade` to handle the new column for existing databases

**Why**: The WellnessEvent model had a `screenedCount` field, but it wasn't being persisted to the database. This caused the count to reset every time the app restarted.

### 2. Repository Mapping Updates

#### Updated EventRepository
- **File**: `lib/data/repositories_dcl/event_repository.dart`
- **Changes**:
  - Added `screenedCount: entity.screenedCount ?? 0` to `_mapEntityToDomain`
  - Added `screenedCount: Value(event.screenedCount)` to `_mapDomainToCompanion`

**Why**: Ensures the `screenedCount` field is properly mapped between the database entity and domain model in both directions.

### 3. Week Filtering Logic Fixes

#### Fixed Date Calculation and Comparison
- **File**: `lib/ui/features/event/widgets/conduct_event_screen.dart`
- **Changes**:
  1. Updated `_startOfWeek` to normalize dates to midnight (0:00:00.000)
  2. Updated `_endOfWeek` to normalize dates to midnight  
  3. Added `_normalizeDate` helper method for consistent date comparisons
  4. Fixed week filtering logic to use normalized dates with explicit boundary checks:
     ```dart
     (eventDate.isAfter(weekStartDate) || eventDate.isAtSameMomentAs(weekStartDate)) &&
     (eventDate.isBefore(weekEndDate) || eventDate.isAtSameMomentAs(weekEndDate))
     ```

**Why**: 
- The original logic used `!(ev.isBefore(selectedStart) || ev.isAfter(selectedEnd))`, which is logically equivalent but harder to read and potentially error-prone
- DateTime comparisons were failing because event dates had different time components
- Normalizing to midnight ensures accurate date-only comparisons

### 4. UI Layout Fix

#### Removed Invalid Expanded Widget
- **File**: `lib/ui/features/event/widgets/conduct_event_screen.dart`
- **Changes**: Replaced `Expanded` widget with `Padding` in the empty state display

**Why**: `Expanded` cannot be used inside `SingleChildScrollView` because it needs bounded constraints. This was causing layout errors.

### 5. Event Reload Mechanism

#### Added Automatic Refresh on Screen Visibility
- **File**: `lib/ui/features/event/widgets/conduct_event_screen.dart`
- **Changes**:
  1. Added `_lastReloadTime` field to track last reload
  2. Created `_reloadEventsIfNeeded()` method with 2-second debounce
  3. Called reload in both `initState` and `didChangeDependencies`

**Why**: 
- The app uses two separate ViewModels (CalendarViewModel and EventViewModel) that maintain independent event lists
- When an event is created in CalendarScreen, EventViewModel doesn't automatically know about it
- The ConductEventScreen is kept alive in an IndexedStack, so `initState` only runs once
- Reloading in `didChangeDependencies` ensures fresh data when the user navigates back to the screen
- The debounce prevents excessive database queries

## Root Cause Analysis

### Issue 1: Newly Created Events Not Displaying

**Root Cause**: Architectural inconsistency
- CalendarViewModel and EventViewModel are separate instances
- Both maintain their own in-memory event lists  
- Both load from the same repository, but don't communicate with each other
- When CalendarViewModel adds an event, EventViewModel's list isn't updated
- ConductEventScreen uses EventViewModel, so it doesn't see CalendarViewModel's changes

**Solution**: 
- Short-term: Reload events from database when ConductEventScreen becomes visible
- Long-term: Consider unifying the ViewModels or using a shared event service

### Issue 2: Week Filtering Not Working

**Root Causes**:
1. Date normalization: Event dates stored with time components were compared against date-only boundaries
2. Week calculation: `_startOfWeek` and `_endOfWeek` didn't consistently normalize to midnight
3. Comparison logic: Original logic was correct but not explicit about boundary inclusion

**Solution**: 
- Normalize all dates to midnight before comparison
- Use explicit boundary checks that clearly show inclusive ranges

## Testing Checklist

### Before Testing
1. Run `flutter pub run build_runner build --delete-conflicting-outputs` to regenerate database code
2. Clean build: `flutter clean && flutter pub get`

### Test Scenarios

#### Test 1: Event Creation and Display
1. Open the app and navigate to Calendar screen
2. Create a new event for today
3. Navigate to Conduct Event screen (bottom navigation)
4. **Expected**: Event should appear in "This Week" section

#### Test 2: Week Filtering
1. Create events for:
   - Today (should be in "This Week")
   - Next Sunday (boundary test)
   - Next Monday (should be in "Next Week")
   - Two weeks from now (should not appear in either week)
2. Navigate to Conduct Event screen
3. **Expected**: 
   - "This Week" shows only events from Sunday to Saturday of current week
   - "Next Week" shows only events from Sunday to Saturday of next week
   - Date range display is accurate

#### Test 3: Screened Count Persistence
1. Start an event
2. Complete at least one participant screening
3. Exit the event
4. Close and restart the app
5. **Expected**: Screened count should persist across app restarts

#### Test 4: Multiple Navigation
1. Create an event in Calendar
2. Navigate to Conduct Event (should show the new event)
3. Navigate back to Calendar
4. Navigate to Conduct Event again
5. **Expected**: Event still displays (no duplicate or missing)

#### Test 5: Event Status
1. Create an event
2. In Conduct Event screen, start the event
3. Navigate away and back
4. **Expected**: Event status is preserved (shows "Resume Event")

## Migration Notes

### Database Schema Version
- Previous version: 12
- New version: 13
- Migration: Automatically adds `screenedCount` column with default value of 0

### Breaking Changes
None. All changes are backward compatible.

### Rollback Procedure
If issues arise:
1. Revert to previous commit
2. Run `flutter pub run build_runner build --delete-conflicting-outputs`
3. Database schema will need manual downgrade (not recommended)

## Future Improvements

### Short-term
1. Add pull-to-refresh gesture on Conduct Event screen
2. Add visual indicator when data is being reloaded
3. Consider adding event change notifications across ViewModels

### Long-term
1. **Unified Event Service**: Create a single EventService that both ViewModels use
2. **Reactive State Management**: Consider using Riverpod or BLoC for better state synchronization
3. **Stream-based Updates**: Use Drift's `watch()` methods for real-time updates
4. **Optimistic Updates**: Update UI immediately, sync with database in background

## Performance Considerations

- Event reload is debounced to maximum once per 2 seconds
- Database queries are efficient (indexed by ID)
- No impact on app startup time
- Minimal memory overhead from additional state tracking

## Known Limitations

1. 2-second debounce means very rapid navigation might not show immediate updates
2. IndexedStack keeps all tabs in memory - consider lazy loading for large datasets
3. Two separate ViewModels create data duplication - not ideal for large event lists
