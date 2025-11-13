# Edit Event Functionality

This document describes the edit event functionality added to the Kenwell Health App.

## Overview

Users can now edit wellness events with a reversible undo option. The feature follows the same pattern as the delete functionality (PR #5), providing consistency across the app.

## Features

### 1. Event Details Screen Edit
- **Location**: Event Details Screen (top-right app bar, left of delete button)
- **Icon**: Pencil/Edit icon
- **Behavior**: 
  - Tapping the edit icon navigates to the event form with all fields prefilled
  - Form title changes to "Edit Event" (vs "Add Event")
  - Save button changes to "Update Event"
  - After updating, shows a SnackBar with "Event updated" message and "UNDO" action
  - Tapping "UNDO" within 5 seconds restores the previous event values
  - Edit button only appears when viewModel is provided (backward compatible)

## Implementation Details

### Data Layer

#### WellnessEvent Model
- **`copyWith(...)`**: Creates a copy of the event with optionally updated fields
- Supports immutable updates for all event properties
- Preserves the event ID when creating copies

#### EventRepository
- **`updateEvent(WellnessEvent updatedEvent)`**: Updates event in persistent storage
- Returns the previous version of the event for undo functionality
- Returns `Future<WellnessEvent?>` (null if event not found)
- Simulates 300ms delay for realistic async behavior

### State Management

#### EventViewModel
- **`updateEvent(WellnessEvent updatedEvent)`**: Updates event in the in-memory list
- Returns the previous version of the event for undo
- Triggers `notifyListeners()` for reactive UI updates
- Returns `WellnessEvent?` (null if event not found)
- **`buildEvent(DateTime date, {String? existingId})`**: Enhanced to accept optional ID
  - When `existingId` is provided, uses it for the created event (update case)
  - When `existingId` is null, auto-generates new ID (create case)

### UI Layer

#### EventDetailsScreen
- Added Edit icon button in AppBar (before Delete icon)
- Edit button only visible when `viewModel != null`
- Navigates to EventScreen with `eventToEdit` parameter
- Maintains backward compatibility with screens that don't provide viewModel

#### EventScreen (Event Form)
- Added optional `eventToEdit` parameter
- Detects edit mode: `isEditMode = eventToEdit != null`
- Dynamic AppBar title based on mode:
  - Edit mode: "Edit Event"
  - Add mode: "Add Event"
- Dynamic button text based on mode:
  - Edit mode: "Update Event"
  - Add mode: "Save Event"
- Edit mode behavior:
  - Pre-fills all form fields using `viewModel.loadExistingEvent(eventToEdit)`
  - On save: calls `viewModel.updateEvent()` instead of creating new event
  - Shows SnackBar with UNDO action
  - UNDO calls `viewModel.updateEvent(previousEvent)` to restore

#### AppRouter
- Updated `RouteNames.event` route to accept `eventToEdit` parameter
- Maintains backward compatibility with add event flow
- Passes `eventToEdit` to EventScreen when provided

## Undo Functionality

The undo mechanism works as follows:

1. **Update Event**:
   - `viewModel.updateEvent(updatedEvent)` returns the previous event
   - Previous event is captured for potential undo

2. **Show SnackBar**:
   - SnackBar appears with "Event updated" message
   - Includes "UNDO" action button
   - Visible for 5 seconds

3. **Undo Action**:
   - If user taps "UNDO" within 5 seconds:
     - Calls `viewModel.updateEvent(previousEvent)`
     - Restores all previous field values
     - UI updates reactively via `notifyListeners()`

## Testing

### Unit Tests

#### `event_repository_test.dart`
- Tests `updateEvent` returns previous event and updates storage
- Tests `updateEvent` with non-existent ID returns null
- Verifies updated event can be fetched with new values

#### `event_view_model_test.dart`
- Tests `updateEvent` returns previous event
- Tests `updateEvent` updates in-memory list
- Tests `updateEvent` with non-existent ID returns null
- Tests `updateEvent` notifies listeners
- Tests complete update + undo flow

### Widget Tests

#### `event_details_screen_test.dart`
- Tests Edit button visibility based on viewModel presence
- Tests Edit button is hidden when viewModel is null
- Tests Edit button navigation to edit form
- Tests event is passed correctly for editing

## Usage Examples

### For Developers

#### Navigating to Edit Form:
```dart
Navigator.pushNamed(
  context,
  RouteNames.event,
  arguments: {
    'date': event.date,
    'eventToEdit': event,
    'onSave': (_) {}, // Not used in edit mode
  },
);
```

#### Updating an Event:
```dart
final updatedEvent = originalEvent.copyWith(
  title: 'New Title',
  venue: 'New Venue',
);
final previousEvent = eventViewModel.updateEvent(updatedEvent);
// previousEvent contains the old values for undo
```

#### Implementing Undo:
```dart
if (previousEvent != null) {
  eventViewModel.updateEvent(previousEvent);
  // Event is restored to previous state
}
```

## Consistency with Delete Pattern

This implementation follows the same patterns established in PR #5 (Delete Functionality):

| Aspect | Delete | Edit |
|--------|--------|------|
| Icon Location | AppBar (EventDetailsScreen) | AppBar (EventDetailsScreen) |
| Visibility | Only when viewModel provided | Only when viewModel provided |
| Confirmation | Dialog before action | None (non-destructive) |
| SnackBar | "Event deleted" | "Event updated" |
| Undo Duration | 5 seconds | 5 seconds |
| Undo Method | `restoreEvent()` | `updateEvent(previousEvent)` |
| Return Value | Previous event | Previous event |
| Listener Notification | Yes | Yes |

## Error Handling

- Update operations are null-safe
- Non-existent event IDs handled gracefully (returns null)
- UI guards against null viewModel
- Form validation inherited from existing EventScreen implementation

## Future Enhancements

Potential improvements for future iterations:
1. Add confirmation dialog for significant changes
2. Highlight changed fields in the form
3. Add "Discard changes" confirmation when navigating back
4. Track edit history for audit purposes
5. Add optimistic updates with rollback on failure
6. Persist undo capability beyond SnackBar duration

## Code Quality

- ✅ Follows existing project structure and naming conventions
- ✅ Null-safety enabled throughout
- ✅ Proper error handling
- ✅ Documented with comments
- ✅ Tested with unit and widget tests
- ✅ Uses existing patterns (ChangeNotifier, Provider)
- ✅ Backward compatible with existing flows
- ✅ Consistent with delete functionality pattern
