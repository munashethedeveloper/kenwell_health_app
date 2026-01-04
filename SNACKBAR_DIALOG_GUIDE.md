# Snackbar and Dialog Messages Implementation Guide

## Overview

This document describes the comprehensive snackbar and dialog message improvements added to the Kenwell Health App to enhance user feedback and experience.

## New Components Added

### 1. ConfirmationDialog Widget
**Location:** `lib/ui/shared/ui/dialogs/confirmation_dialog.dart`

A reusable confirmation dialog for important user actions.

**Features:**
- Custom title and message
- Configurable button text (confirm/cancel)
- Custom confirmation color
- Optional icon
- Returns boolean (true if confirmed, false otherwise)

**Usage Example:**
```dart
final confirmed = await ConfirmationDialog.show(
  context,
  title: 'Logout',
  message: 'Are you sure you want to logout?',
  confirmText: 'Logout',
  cancelText: 'Cancel',
  confirmColor: Colors.orange,
  icon: Icons.logout,
);

if (confirmed) {
  // Proceed with action
}
```

### 2. InfoDialog Widget
**Location:** `lib/ui/shared/ui/dialogs/info_dialog.dart`

A reusable information dialog for displaying helpful messages.

**Features:**
- Custom title and message
- Configurable button text
- Optional icon with custom color
- Single "Got it" button for dismissal

**Usage Example:**
```dart
await InfoDialog.show(
  context,
  title: 'Member Search Help',
  message: 'You can search for existing members by their name or ID number.',
  icon: Icons.help_outline,
  iconColor: Colors.blue,
);
```

### 3. AppSnackbar Utility Class
**Location:** `lib/ui/shared/ui/snackbars/app_snackbar.dart`

A utility class for displaying consistent snackbars throughout the app.

**Methods:**

#### showSuccess()
Displays a success message with green background and checkmark icon.
```dart
AppSnackbar.showSuccess(
  context,
  'Profile updated successfully',
);
```

#### showError()
Displays an error message with red background and error icon.
```dart
AppSnackbar.showError(
  context,
  'Error saving data: $errorMessage',
);
```

#### showWarning()
Displays a warning message with orange background and warning icon.
```dart
AppSnackbar.showWarning(
  context,
  'Please complete all required fields',
);
```

#### showInfo()
Displays an info message with blue background and info icon.
```dart
AppSnackbar.showInfo(
  context,
  'Searching for member...',
);
```

## Improvements by Screen/Feature

### Authentication Screens

#### Login Screen (`lib/ui/features/auth/widgets/login_screen.dart`)
- **Existing:** Already had error snackbars
- **Status:** No changes needed

#### Register Screen (`lib/ui/features/auth/widgets/register_screen.dart`)
- **Existing:** Already had success/error snackbars
- **Status:** No changes needed

#### Forgot Password Screen (`lib/ui/features/auth/widgets/forgot_password_screen.dart`)
- **Existing:** Already had success/error snackbars
- **Status:** No changes needed

### Calendar & Events

#### Calendar Screen (`lib/ui/features/calendar/widgets/calendar_screen.dart`)
**Improvements:**
- ✅ Added logout confirmation dialog
- ✅ Added success message after logout
- **Before:** Logout happened immediately
- **After:** User confirms logout, sees success message

#### Event Screen (`lib/ui/features/event/widgets/event_screen.dart`)
**Improvements:**
- ✅ Added unsaved changes confirmation on cancel
- ✅ Detects if form has been modified
- ✅ Shows warning dialog before discarding changes
- **Before:** Cancel button discarded changes immediately
- **After:** User is warned about unsaved changes

#### Event Details Screen (`lib/ui/features/event/widgets/event_details_screen.dart`)
- **Existing:** Already had delete confirmation dialog
- **Status:** No changes needed (well implemented)

#### Conduct Event Screen (`lib/ui/features/event/widgets/conduct_event_screen.dart`)
**Improvements:**
- ✅ Added logout confirmation dialog
- ✅ Added success message after logout

### Profile & Settings

#### Profile Screen (`lib/ui/features/profile/widgets/profile_screen.dart`)
**Improvements:**
- ✅ Added logout confirmation dialog
- ✅ Added success message after logout
- ✅ Added unsaved changes confirmation on cancel
- ✅ Tracks original profile values
- ✅ Detects modifications before warning user
- **Before:** Cancel discarded all changes without warning
- **After:** User is alerted to unsaved profile changes

#### Settings Screen (`lib/ui/features/settings/widgets/settings_screen.dart`)
- **Existing:** Already had success snackbar
- **Status:** No changes needed

### Health & Screening Forms

#### HIV Test Screen & ViewModel
**File:** `lib/ui/features/hiv_test/view_model/hiv_test_view_model.dart`

**Improvements:**
- ✅ Added validation warning (orange snackbar)
- ✅ Added success message (green snackbar with icon)
- ✅ Added error handling with error message (red snackbar with icon)
- **Before:** No user feedback on submission
- **After:** Clear success/error feedback with icons

#### TB Test Screen & ViewModel
**File:** `lib/ui/features/tb_test/view_model/tb_testing_view_model.dart`

**Improvements:**
- ✅ Added validation warning (orange snackbar)
- ✅ Added success message (green snackbar with icon)
- ✅ Added error handling with error message (red snackbar with icon)
- **Before:** No user feedback on submission
- **After:** Clear success/error feedback with icons

#### Health Metrics Screen & ViewModel
**File:** `lib/ui/features/health_metrics/view_model/health_metrics_view_model.dart`

**Improvements:**
- ✅ Added validation warning (orange snackbar)
- ✅ Added success message (green snackbar with icon)
- ✅ Added error handling with error message (red snackbar with icon)
- **Before:** Generic success message
- **After:** Improved messaging with consistent styling

### Wellness Flow

#### Member Registration Screen (`lib/ui/features/wellness/widgets/member_registration_screen.dart`)
**Improvements:**
- ✅ Added search help icon button
- ✅ Added info dialog explaining member search
- ✅ Improved snackbar messages (using AppSnackbar utility)
- **Before:** No guidance for member search
- **After:** Help icon shows detailed search instructions

## Implementation Patterns

### Pattern 1: Logout Confirmation
Used in: Calendar, Profile, Conduct Event screens

```dart
Future<void> _logout() async {
  final confirmed = await ConfirmationDialog.show(
    context,
    title: 'Logout',
    message: 'Are you sure you want to logout?',
    confirmText: 'Logout',
    cancelText: 'Cancel',
    confirmColor: Colors.orange,
    icon: Icons.logout,
  );

  if (!confirmed) return;

  // Proceed with logout
  final authVM = context.read<AuthViewModel>();
  await authVM.logout();
  
  if (!mounted) return;

  AppSnackbar.showSuccess(context, 'Successfully logged out');
  Navigator.pushReplacementNamed(context, RouteNames.login);
}
```

### Pattern 2: Unsaved Changes Confirmation
Used in: Event, Profile screens

```dart
// Track if changes were made
bool _hasUnsavedChanges() {
  return _emailController.text != _originalEmail ||
         _nameController.text != _originalName;
}

// Handle cancel with confirmation
Future<void> _handleCancel() async {
  if (!_hasUnsavedChanges()) {
    Navigator.pop(context);
    return;
  }

  final confirmed = await ConfirmationDialog.show(
    context,
    title: 'Discard Changes?',
    message: 'You have unsaved changes. Are you sure you want to discard them?',
    confirmText: 'Discard',
    cancelText: 'Keep Editing',
    confirmColor: Colors.orange,
    icon: Icons.warning,
  );

  if (confirmed && mounted) {
    Navigator.pop(context);
  }
}
```

### Pattern 3: Form Submission Feedback
Used in: HIV Test, TB Test, Health Metrics ViewModels

```dart
Future<void> submitForm(BuildContext context, {VoidCallback? onNext}) async {
  // Validation
  if (!isFormValid) {
    AppSnackbar.showWarning(context, 'Please complete all required fields');
    return;
  }

  _isSubmitting = true;
  notifyListeners();

  try {
    // Submit data
    await _repository.save(data);

    if (!context.mounted) return;

    // Success feedback
    AppSnackbar.showSuccess(context, 'Data saved successfully');
    onNext?.call();
    
  } catch (e) {
    // Error feedback
    if (context.mounted) {
      AppSnackbar.showError(context, 'Error saving data: $e');
    }
  } finally {
    _isSubmitting = false;
    notifyListeners();
  }
}
```

### Pattern 4: Info/Help Dialogs
Used in: Member Registration screen

```dart
void _showHelp() {
  InfoDialog.show(
    context,
    title: 'Help Title',
    message: 'Detailed help message explaining the feature...',
    icon: Icons.help_outline,
    iconColor: Colors.blue,
  );
}
```

## Design Guidelines

### Snackbar Colors
- **Green (#4CAF50):** Success messages
- **Red (#F44336):** Error messages
- **Orange (#FF9800):** Warning messages
- **Blue (#2196F3):** Info messages

### Snackbar Duration
- **Success:** 3 seconds (default)
- **Error:** 4 seconds (longer to ensure user sees it)
- **Warning:** 3 seconds
- **Info:** 3 seconds

### Dialog Button Colors
- **Destructive actions (Delete, Discard):** Red or Orange
- **Neutral actions (Logout):** Orange
- **Positive actions (Save, Confirm):** Primary Green
- **Cancel actions:** Secondary (outlined)

### Icons
All snackbars include relevant icons:
- Success: `Icons.check_circle`
- Error: `Icons.error`
- Warning: `Icons.warning`
- Info: `Icons.info`

All dialogs can have optional icons that appear next to the title.

## Best Practices

### When to Use Snackbars
✅ **DO use snackbars for:**
- Operation success confirmations
- Validation errors
- Network/API errors
- Brief informational messages
- Temporary status updates

❌ **DON'T use snackbars for:**
- Critical errors requiring immediate action
- Long-form information
- Multiple simultaneous messages
- Permanent information

### When to Use Dialogs
✅ **DO use dialogs for:**
- Confirming destructive actions
- Showing help/info content
- Requiring user decision before proceeding
- Displaying important warnings

❌ **DON'T use dialogs for:**
- Every minor confirmation
- Success messages (use snackbar)
- Non-blocking information

### Implementation Checklist
When adding user feedback to a new feature:

- [ ] Identify all user actions that need feedback
- [ ] Add validation warnings for incomplete forms
- [ ] Add success messages for completed actions
- [ ] Add error handling with user-friendly messages
- [ ] Add confirmations for destructive actions
- [ ] Add info/help where users might be confused
- [ ] Use consistent colors and icons
- [ ] Test all feedback messages
- [ ] Ensure messages are concise and helpful

## Testing Recommendations

### Manual Testing
1. **Snackbars:**
   - Verify correct color and icon appear
   - Check duration is appropriate
   - Ensure message is readable
   - Test on different screen sizes

2. **Dialogs:**
   - Test cancel and confirm actions
   - Verify dialog dismisses properly
   - Check text wraps correctly
   - Test with long messages

3. **User Flow:**
   - Try to perform action and cancel
   - Verify unsaved changes are detected
   - Test error scenarios
   - Ensure help dialogs are helpful

### Edge Cases to Test
- Rapidly dismissing multiple snackbars
- Multiple dialogs in quick succession
- Rotating screen with dialog open
- Network errors during submission
- User navigating away during long operations

## Files Changed

1. **New Files Created:**
   - `lib/ui/shared/ui/dialogs/confirmation_dialog.dart`
   - `lib/ui/shared/ui/dialogs/info_dialog.dart`
   - `lib/ui/shared/ui/snackbars/app_snackbar.dart`

2. **Files Modified:**
   - `lib/ui/features/calendar/widgets/calendar_screen.dart`
   - `lib/ui/features/event/widgets/conduct_event_screen.dart`
   - `lib/ui/features/event/widgets/event_screen.dart`
   - `lib/ui/features/profile/widgets/profile_screen.dart`
   - `lib/ui/features/hiv_test/view_model/hiv_test_view_model.dart`
   - `lib/ui/features/tb_test/view_model/tb_testing_view_model.dart`
   - `lib/ui/features/health_metrics/view_model/health_metrics_view_model.dart`
   - `lib/ui/features/wellness/widgets/member_registration_screen.dart`

## Future Enhancements

Potential improvements for future iterations:

1. **Analytics:** Track snackbar/dialog interactions
2. **Accessibility:** Add screen reader support for messages
3. **Customization:** User preferences for message duration
4. **Theming:** Dark mode variants for snackbars
5. **Animations:** Smoother transitions for dialogs
6. **Queue:** Better handling of multiple simultaneous messages
7. **Localization:** Multi-language support for all messages
8. **Templates:** Pre-defined message templates for common scenarios

## Summary

This implementation significantly improves the user experience by:
- Providing clear, consistent feedback for all user actions
- Preventing accidental data loss with unsaved changes warnings
- Confirming destructive actions before execution
- Offering helpful information where users might be confused
- Using consistent styling with Material Design principles
- Maintaining a professional, polished feel throughout the app

All components are reusable, well-documented, and follow Flutter best practices.
