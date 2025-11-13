# Edit Event Functionality Implementation

This document describes the edit event functionality added to the Kenwell Health App, following the same patterns established in PR #5 for delete functionality.

## Overview

Users can now edit wellness events from the event details screen. The feature includes:
- Edit button (pencil icon) in the event details screen
- Reuse of existing event form for editing
- Undo capability that restores previous values within 5 seconds
- Full preservation of event data through copyWith pattern

## Features

### 1. Event Details Screen Edit
- **Location**: Event Details Screen (top-right app bar, left of delete button)
- **Icon**: Pencil/Edit icon
- **Behavior**: 
  - Tapping the edit icon navigates to the event form
  - Form is prefilled with current event values
  - AppBar shows "Edit Event" instead of "Add Event"
  - Saving updates the event and navigates back
  - Shows a Snackbar with "Event updated" message and "UNDO" action
  - Tapping "UNDO" within 5 seconds restores the previous event state

### 2. Event Form Dual Mode
- **Location**: Event Screen (accessed via calendar or edit)
- **Behavior**:
  - Automatically detects if editing (existingEvent parameter provided)
  - Shows "Edit Event" or "Add Event" title accordingly
  - Prefills all form fields when editing
  - Preserves event ID when saving edits
  - Clears controllers after save

## Implementation Details

### Data Layer

#### WellnessEvent Model
- **`copyWith()`**: Creates a new event instance with specified fields updated
  - Supports updating any combination of fields
  - Preserves unchanged fields from original
  - Maintains immutability pattern
- **`operator ==`**: Compares all fields for equality
- **`hashCode`**: Generates hash based on all fields

#### EventRepository
- **`updateEvent(WellnessEvent updatedEvent)`**: Updates event in mock storage
  - Finds event by ID
  - Replaces event in list with updated version
  - Returns `Future<void>` (async pattern)
  - Handles non-existent events gracefully

### View Model Layer

#### EventViewModel
- **`updateEvent(WellnessEvent updatedEvent)`**: Updates event and returns previous state
  - Finds event in list by ID
  - Saves reference to previous event
  - Updates event in list
  - Calls `notifyListeners()` to update UI
  - Returns previous event for undo functionality
  - Returns null if event not found
- **`restoreEvent(WellnessEvent event)`**: Already existed from PR #5
  - Re-adds event to list
  - Triggers `notifyListeners()`
  - Used for both delete and edit undo
- **`loadExistingEvent(WellnessEvent? event)`**: Already existed
  - Loads event data into form controllers
  - Sets dropdown values appropriately
  - Used when entering edit mode

### UI Layer

#### EventDetailsScreen
- Added Edit button to AppBar actions
  - Only visible when `viewModel` is provided
  - Positioned before delete button
  - Uses pencil icon (`Icons.edit`)
- Implemented `_navigateToEditEvent()` method
  - Navigates to event form route
  - Passes event data via `existingEvent` argument
  - Provides onSave callback for handling update
- Implemented `_updateEvent()` method
  - Calls `viewModel.updateEvent()`
  - Captures previous event for undo
  - Shows Snackbar with "Event updated" and "UNDO" action
  - Navigates back after update
  - Undo restores previous event by calling updateEvent again

#### EventScreen
- Added `existingEvent` parameter (optional)
  - Used alongside existing `existingEvents` parameter
  - Prioritizes `existingEvent` over `existingEvents[0]`
- Added `isEditMode` flag
  - Computed based on presence of event to edit
  - Controls AppBar title and save behavior
- Updated AppBar title
  - Shows "Edit Event" when editing
  - Shows "Add Event" when creating
- Updated Save button logic
  - Preserves event ID when editing (uses copyWith)
  - Creates new event ID when adding
  - Calls onSave callback with proper event

#### AppRouter
- Updated event route
  - Added support for `existingEvent` argument
  - Maintains backward compatibility
  - Passes parameter to EventScreen

### State Management

The app uses `ChangeNotifier` pattern with `EventViewModel`:
- Updates trigger `notifyListeners()`
- All screens listening to the view model update automatically
- Undo uses updateEvent to restore previous state
- Pattern matches delete functionality from PR #5

## Testing

### Unit Tests

#### `event_repository_test.dart`
- Tests `updateEvent()` updates event in repository
- Tests fetching event returns updated values
- Tests updating non-existent event completes without error
- Tests all field changes persist correctly

#### `event_view_model_test.dart`
- Tests `updateEvent()` returns previous event
- Tests `updateEvent()` updates in-memory list
- Tests `updateEvent()` with non-existent ID returns null
- Tests `updateEvent()` notifies listeners
- Tests restore after update returns to previous state

### Widget Tests

#### `event_details_screen_test.dart`
- Tests edit button visibility based on viewModel presence
- Tests edit button not visible when viewModel is null
- Tests tapping edit button navigates to event form

#### `event_edit_flow_test.dart` (New File)
- Tests EventScreen shows "Edit Event" title when editing
- Tests EventScreen shows "Add Event" title when creating
- Tests form prefills all fields when editing
- Tests saving edit preserves event ID
- Tests UNDO restores previous event values
- Tests multiple field updates are preserved
- Tests copyWith creates proper event copy

## Error Handling

- Update operations are null-safe
- Non-existent event IDs handled gracefully
- UI guards against null viewModel
- copyWith maintains immutability
- All optional parameters handled correctly

## Patterns & Consistency

This implementation follows the same patterns as PR #5 (delete functionality):
1. **Icon button in AppBar**: Both edit and delete use conditional rendering with `if (viewModel != null)`
2. **ViewModel methods return previous state**: Both `deleteEvent()` and `updateEvent()` return the previous event for undo
3. **SnackBar with UNDO**: Both show 5-second duration SnackBar with UNDO action
4. **restoreEvent pattern**: Edit undo uses `updateEvent(previousEvent)` similar to delete using `restoreEvent()`
5. **Null-safety**: All optional parameters properly handled
6. **Testing structure**: Comprehensive unit and widget tests matching delete test patterns

## Usage Examples

### For Developers

#### Navigating to EventDetailsScreen with edit capability:
```dart
Navigator.pushNamed(
  context,
  RouteNames.eventDetails,
  arguments: {
    'event': myEvent,
    'viewModel': myEventViewModel,
  },
);
```

#### Manually updating an event:
```dart
final updatedEvent = event.copyWith(
  title: 'New Title',
  venue: 'New Venue',
);
final previousEvent = eventViewModel.updateEvent(updatedEvent);
if (previousEvent != null) {
  // Event was updated successfully
  // Store previousEvent for potential undo
}
```

#### Undoing an edit:
```dart
// Restore by updating back to previous state
eventViewModel.updateEvent(previousEvent);
```

#### Using copyWith:
```dart
// Create modified copy of event
final modifiedEvent = originalEvent.copyWith(
  title: 'Updated Title',
  expectedParticipation: 150,
);
// Original event remains unchanged
```

## Code Quality

- ✅ Follows existing project structure and naming conventions
- ✅ Null-safety enabled throughout
- ✅ Proper error handling
- ✅ Documented with comments
- ✅ Tested with comprehensive unit and widget tests
- ✅ Uses existing patterns (ChangeNotifier, Provider)
- ✅ Reuses existing UI components and forms
- ✅ Maintains backward compatibility

## Files Changed

1. **lib/domain/models/wellness_event.dart**: Added copyWith, ==, and hashCode
2. **lib/data/repositories_dcl/event_repository.dart**: Added updateEvent method
3. **lib/ui/features/event/view_model/event_view_model.dart**: Added updateEvent method
4. **lib/ui/features/event/widgets/event_details_screen.dart**: Added edit button and navigation
5. **lib/ui/features/event/widgets/event_screen.dart**: Added edit mode support
6. **lib/routing/app_router.dart**: Added existingEvent parameter support
7. **test/event_repository_test.dart**: Added update tests
8. **test/event_view_model_test.dart**: Added update tests
9. **test/event_details_screen_test.dart**: Added edit button tests
10. **test/event_edit_flow_test.dart**: New comprehensive edit flow tests

Total: 10 files changed, 901 insertions(+), 5 deletions(-)

## Future Enhancements

Potential improvements for future iterations:
1. Persist updates to backend/database
2. Add validation before allowing save
3. Add confirmation dialog if unsaved changes exist
4. Track edit history for events
5. Add bulk edit capability
6. Add field-level undo (instead of entire event)
7. Add edit animations/transitions
