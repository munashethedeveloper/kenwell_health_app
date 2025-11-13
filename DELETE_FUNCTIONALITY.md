# Delete Event Functionality

This document describes the delete event functionality added to the Kenwell Health App.

## Overview

Users can now delete wellness events from the app with a reversible undo option. The feature is implemented across both the event detail screen and the calendar list view.

## Features

### 1. Event Details Screen Delete
- **Location**: Event Details Screen (top-right app bar)
- **Icon**: Trash/Delete icon
- **Behavior**: 
  - Tapping the delete icon shows a confirmation dialog
  - Dialog provides "Cancel" and "Delete" options
  - Confirming deletion removes the event and navigates back
  - Shows a Snackbar with "Event deleted" message and "UNDO" action
  - Tapping "UNDO" within 5 seconds restores the event

### 2. Swipe-to-Delete in Calendar List
- **Location**: Events List tab in Calendar Screen
- **Gesture**: Swipe left (end-to-start) on any event item
- **Behavior**:
  - Reveals a red background with delete icon
  - Shows confirmation dialog before actual deletion
  - After confirming, event is removed
  - Shows Snackbar with "Event deleted" and "UNDO" action
  - Tapping "UNDO" within 5 seconds restores the event

## Implementation Details

### Data Layer

#### EventViewModel
- **`deleteEvent(String eventId)`**: Removes event from the list and returns it for undo
- **`restoreEvent(WellnessEvent event)`**: Re-adds a deleted event to the list
- Both methods trigger `notifyListeners()` to update UI immediately

#### EventRepository
- Already had `deleteEvent(String id)` method for persistent deletion
- Returns `Future<void>` and removes event from mock storage

### UI Layer

#### EventDetailsScreen
- Added optional `viewModel` parameter
- Delete button only visible when `viewModel` is provided
- Implements `_showDeleteConfirmation()` for dialog
- Implements `_deleteEvent()` for actual deletion and Snackbar

#### CalendarScreen
- Wrapped event list items with `Dismissible` widget
- Added `confirmDismiss` callback for confirmation dialog
- Implemented `onDismissed` callback for deletion and Snackbar
- Red background with delete icon visible during swipe

#### AppRouter
- Updated `eventDetails` route to pass optional `viewModel` parameter
- Maintains backward compatibility with null viewModel

### State Management

The app uses `ChangeNotifier` pattern with `EventViewModel`:
- Deletion triggers `notifyListeners()`
- All screens listening to the view model update automatically
- Undo restores event and triggers another notification

## Testing

### Unit Tests

#### `event_repository_test.dart`
- Tests repository deleteEvent method
- Verifies event removal and null return on fetch after deletion
- Tests deletion of non-existent events

#### `event_view_model_test.dart`
- Tests deleteEvent returns deleted event
- Tests deleteEvent with non-existent ID returns null
- Tests restoreEvent adds event back to list
- Tests both methods notify listeners

### Widget Tests

#### `event_details_screen_test.dart`
- Tests delete button visibility based on viewModel presence
- Tests confirmation dialog appearance
- Tests cancel functionality
- Tests delete and Snackbar display
- Tests undo functionality restores event

## Error Handling

- Delete operations are null-safe
- Non-existent event IDs handled gracefully
- UI guards against null viewModel
- Confirmation dialogs prevent accidental deletions

## Future Enhancements

Potential improvements for future iterations:
1. Persist deletions to backend/database
2. Add multi-select bulk delete
3. Add "Recently Deleted" section with extended recovery period
4. Add deletion confirmation preference in settings
5. Add delete animations/transitions

## Usage Examples

### For Developers

#### Navigating to EventDetailsScreen with delete capability:
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

#### Manually deleting an event:
```dart
final deletedEvent = eventViewModel.deleteEvent('event-id');
if (deletedEvent != null) {
  // Event was deleted successfully
  // Store deletedEvent for potential undo
}
```

#### Restoring a deleted event:
```dart
eventViewModel.restoreEvent(deletedEvent);
```

## Code Quality

- ✅ Follows existing project structure and naming conventions
- ✅ Null-safety enabled
- ✅ Proper error handling
- ✅ Documented with comments
- ✅ Tested with unit and widget tests
- ✅ Uses existing patterns (ChangeNotifier, Provider)
