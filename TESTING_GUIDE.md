# Next Steps for Completing Event Logic Refactoring

This document outlines the remaining steps needed to complete and test the event logic refactoring.

## Required Build Step

**IMPORTANT**: Before testing, you MUST regenerate the database code because we added a new column to the schema.

### Step 1: Regenerate Database Code

Run the following command in the project root directory:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

This will regenerate `lib/data/local/app_database.g.dart` to include the new `screenedCount` column.

### Step 2: Clean Build (Recommended)

For best results, do a clean build:

```bash
flutter clean
flutter pub get
flutter run
```

## Testing Instructions

### Test 1: Verify Database Migration Works

**Purpose**: Ensure existing events aren't lost and get the new `screenedCount` field

**Steps**:
1. If you have existing events in the app, note them down
2. Build and run the app with the new code
3. Navigate to Conduct Event screen
4. **Expected**: All existing events should still be visible
5. **Expected**: Screened count should show as 0 for existing events

**If this fails**: The migration may have failed. Check the console logs for errors.

---

### Test 2: Create New Event and Verify Display

**Purpose**: Confirm newly created events appear on Conduct Event screen

**Steps**:
1. Open the app
2. Navigate to Calendar tab (bottom navigation, 3rd icon)
3. Tap on today's date
4. Tap "Add Event" button
5. Fill in all required fields:
   - Event Title: "Test Event"
   - Venue: "Test Venue"
   - Address: "Test Address"
   - All contact information
   - Select at least one service
   - Set times (Setup, Start, End, Strike Down)
6. Tap "Save Event"
7. Navigate to "Conduct Event" tab (bottom navigation, 5th icon)
8. **Expected**: The new event should appear in the "This Week" section
9. **Expected**: Event details should be displayed correctly

**If this fails**: 
- Check if the event was created (go back to Calendar)
- Check console logs for errors
- The reload mechanism may not be working

---

### Test 3: Week Filtering - Current Week Events

**Purpose**: Verify "This Week" filter shows correct events

**Steps**:
1. Note what day of the week it is (Sunday = start of week)
2. Create events for:
   - Today
   - This coming Saturday (last day of this week)
   - This Sunday (if today is not Sunday)
3. Navigate to Conduct Event screen
4. Ensure "This week" is selected
5. **Expected**: All three events should appear
6. **Expected**: Date range shown should be Sunday to Saturday of current week

**If this fails**: The week calculation logic has an issue

---

### Test 4: Week Filtering - Next Week Events

**Purpose**: Verify "Next Week" filter shows correct events

**Steps**:
1. Create events for:
   - Next Sunday (first day of next week)
   - Next Wednesday (middle of next week)
   - Next Saturday (last day of next week)
2. Navigate to Conduct Event screen
3. Tap "Next week" button
4. **Expected**: All three events should appear
5. **Expected**: Date range shown should be Sunday to Saturday of next week
6. **Expected**: Events from "This Week" should NOT appear

**If this fails**: The week filtering logic has an issue

---

### Test 5: Boundary Date Testing

**Purpose**: Verify events on week boundaries are correctly categorized

**Steps**:
1. Identify this Sunday's date
2. Create an event exactly on this Sunday
3. Navigate to Conduct Event screen
4. **Expected**: Event appears in "This Week" 
5. Switch to "Next Week"
6. **Expected**: Event does NOT appear in "Next Week"
7. Now create an event for next Sunday
8. **Expected**: Event appears in "Next Week"
9. **Expected**: Event does NOT appear in "This Week"

**If this fails**: Boundary date logic needs adjustment

---

### Test 6: Screened Count Persistence

**Purpose**: Confirm screened count is saved and persists across sessions

**Steps**:
1. Create a new event for today
2. Navigate to Conduct Event screen
3. Tap "Start Event" on the event
4. Complete the wellness flow for at least 2 participants
5. Return to Conduct Event screen
6. **Expected**: Screened count shows "Screened: 2 participants"
7. Close the app completely (force quit)
8. Reopen the app
9. Navigate to Conduct Event screen
10. **Expected**: Screened count still shows "Screened: 2 participants"

**If this fails**: Database persistence or mapping has an issue

---

### Test 7: Navigation and Reload

**Purpose**: Verify events reload when navigating between tabs

**Steps**:
1. Navigate to Conduct Event tab
2. Note the events displayed
3. Navigate to Calendar tab
4. Create a new event
5. Navigate back to Conduct Event tab
6. **Expected**: The new event should appear within 500ms
7. Navigate to another tab (e.g., Statistics)
8. Navigate back to Conduct Event tab
9. **Expected**: Events are still displayed correctly

**If this fails**: The reload mechanism may have issues

---

### Test 8: Multiple Week Changes

**Purpose**: Verify week toggling doesn't cause errors

**Steps**:
1. Create events in both this week and next week
2. Navigate to Conduct Event screen
3. Toggle between "This Week" and "Next Week" 5 times rapidly
4. **Expected**: No errors or crashes
5. **Expected**: Correct events displayed for each week
6. **Expected**: No duplicate events

**If this fails**: State management has an issue

---

## Common Issues and Solutions

### Issue: "Build runner failed"
**Solution**: 
1. Make sure all dependencies are installed: `flutter pub get`
2. Try: `flutter pub run build_runner clean`
3. Then: `flutter pub run build_runner build --delete-conflicting-outputs`

### Issue: "No events showing up"
**Solution**:
1. Check console logs for database errors
2. Verify EventViewModel is properly provided in main.dart
3. Try clearing app data and recreating events

### Issue: "Week filtering shows wrong events"
**Solution**:
1. Check your device timezone settings
2. Verify the date calculations in debug logs
3. Check that dates are being normalized correctly

### Issue: "Screened count not persisting"
**Solution**:
1. Verify build_runner was executed
2. Check that app_database.g.dart includes screenedCount
3. Check database migration logs

## Success Criteria

All tests should pass with these results:
- ✅ New events appear on Conduct Event screen immediately
- ✅ "This Week" shows only current week events (Sun-Sat)
- ✅ "Next Week" shows only next week events (Sun-Sat)
- ✅ Boundary dates are correctly categorized
- ✅ Screened count persists across app restarts
- ✅ No layout errors or crashes
- ✅ Events reload when navigating between tabs

## Reporting Issues

If any test fails, please provide:
1. Which test failed
2. What was expected vs what happened
3. Console/debug logs (if available)
4. Screenshots (if UI-related)
5. Device and OS version

## Performance Verification

While testing, monitor for:
- App should remain responsive during tab switches
- No noticeable lag when displaying events
- Database queries should complete quickly (< 100ms)
- No memory leaks or crashes during extended use

## Code Quality Verification

After all tests pass:
1. Review code changes one more time
2. Ensure all console debug prints are removed or conditional
3. Verify no TODO comments were left unaddressed
4. Check that comments accurately describe the code

## Final Checklist

- [ ] Build runner executed successfully
- [ ] All 8 tests completed and passed
- [ ] No console errors or warnings
- [ ] App performance is acceptable
- [ ] Code reviewed and cleaned up
- [ ] Documentation is accurate

## Additional Notes

- The 500ms debounce on event reload is intentional to prevent excessive database queries
- Week starts on Sunday (weekday % 7 calculation)
- All dates are normalized to midnight for comparison
- Database schema version is now 13

Good luck with testing! 🚀
