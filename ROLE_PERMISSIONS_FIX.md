# Role Permissions Fix - Event Management

## Problem Report
The `edit_event` permission (and related event permissions like `create_event` and `delete_event`) were not working correctly throughout the application.

## Root Cause Analysis

### Issue 1: Hardcoded Permission Checks
Multiple files contained hardcoded permission checking logic instead of using the centralized `RolePermissions` system:

```dart
// BEFORE: Hardcoded in calendar_screen.dart and day_events_dialog.dart
bool _canAddEvent(String role) {
  final normalized = role.trim().toUpperCase();
  return normalized == 'ADMIN' ||
      normalized == 'TOP MANAGEMENT' ||
      normalized == 'PROJECT MANAGER';
}
```

**Problems:**
- Not using `RolePermissions.canAccessFeature()`
- Duplicated across multiple files
- Inconsistent with the permission system defined in `role_permissions.dart`
- Hard to maintain (changes require updates in multiple places)

### Issue 2: Missing Permission Checks
Several UI components showed edit/delete actions without checking permissions:

- Event details screen showed edit and delete icons for all users
- Event cards allowed swipe-to-delete for all users
- Event list dialog allowed editing for all users

### Issue 3: Wrong Role Source
Components were trying to get the role from `CalendarViewModel` which had an empty `_role` field that was never populated, instead of using `ProfileViewModel` which contains the actual user role.

---

## Solution Implemented

### 1. Centralized Permission Checking

**AFTER: Using RolePermissions system**
```dart
bool _canAddEvent(BuildContext context) {
  final profileVM = context.read<ProfileViewModel>();
  return RolePermissions.canAccessFeature(profileVM.role, 'create_event');
}
```

**Benefits:**
- Uses centralized permission system
- Single source of truth (`RolePermissions.featureAccess` map)
- Gets role from correct source (`ProfileViewModel`)
- Consistent across all components

### 2. Permission Checks Added to All Components

#### calendar_screen.dart
- **Create Event FAB**: Only shown to users with `create_event` permission
- **"Create Event" button**: Only shown to authorized users
- **Role source**: Changed from `CalendarViewModel.role` to `ProfileViewModel.role`

#### day_events_dialog.dart  
- **"Create Event" button**: Only shown to users with `create_event` permission
- **Permission check**: Uses `RolePermissions.canAccessFeature()`

#### event_list_dialog.dart
- **Edit icon**: Only shown if user has `edit_event` permission
- **Event tap action**: Only enabled if user has `edit_event` permission
- **"Add Event" button**: Only shown if user has `create_event` permission

#### event_details_screen.dart
- **Edit icon**: Only shown if user has `edit_event` permission
- **Delete icon**: Only shown if user has `delete_event` permission
- **Gets permissions on build**: Checks both edit and delete permissions

#### event_card.dart
- **Swipe-to-delete**: Only enabled if user has `delete_event` permission
- **Conditional wrapping**: Dismissible widget only wraps content if user can delete
- **Card always viewable**: Users without delete permission can still view event details

---

## Permission Definitions

From `lib/domain/constants/role_permissions.dart`:

```dart
static const Map<String, List<String>> featureAccess = {
  'create_event': ['ADMIN', 'TOP MANAGEMENT', 'PROJECT MANAGER'],
  'edit_event': ['ADMIN', 'TOP MANAGEMENT', 'PROJECT MANAGER'],
  'delete_event': ['ADMIN', 'TOP MANAGEMENT', 'PROJECT MANAGER'],
  // ... other permissions
};
```

### Who Can Do What

| Permission | Allowed Roles |
|------------|---------------|
| `create_event` | ADMIN, TOP MANAGEMENT, PROJECT MANAGER |
| `edit_event` | ADMIN, TOP MANAGEMENT, PROJECT MANAGER |
| `delete_event` | ADMIN, TOP MANAGEMENT, PROJECT MANAGER |
| `view_events` | All roles |

### Roles Not Allowed
- ❌ CLIENT
- ❌ HEALTH PRACTITIONER  
- ❌ PROJECT COORDINATOR

---

## Code Changes Summary

### Files Modified: 5

1. **lib/ui/features/calendar/widgets/calendar_screen.dart**
   - Added import: `role_permissions.dart`, `profile_view_model.dart`
   - Changed `_canAddEvent(String role)` to `_canAddEvent(BuildContext context)`
   - Updated 3 call sites to pass context instead of role

2. **lib/ui/features/calendar/widgets/day_events_dialog.dart**
   - Added imports: `provider`, `role_permissions.dart`, `profile_view_model.dart`
   - Changed `_canAddEvent(String role)` to `_canAddEvent(BuildContext context)`
   - Updated call site to pass context

3. **lib/ui/features/calendar/widgets/event_list_dialog.dart**
   - Added imports: `provider`, `role_permissions.dart`, `profile_view_model.dart`
   - Added `canEdit` and `canCreate` checks in build method
   - Made edit icon and action conditional on `canEdit`
   - Made "Add Event" button conditional on `canCreate`

4. **lib/ui/features/event/widgets/event_details_screen.dart**
   - Added imports: `role_permissions.dart`, `profile_view_model.dart`
   - Added `canEdit` and `canDelete` permission checks
   - Made edit icon conditional on `canEdit`
   - Made delete icon conditional on `canDelete`

5. **lib/ui/features/calendar/widgets/event_card.dart**
   - Added imports: `role_permissions.dart`, `profile_view_model.dart`
   - Added `canDelete` permission check
   - Extracted card content to `_buildCardContent()` method
   - Made Dismissible wrapper conditional on `canDelete`

### Lines Changed
- **Added**: ~40 lines (imports, permission checks, conditional logic)
- **Modified**: ~50 lines (function signatures, calls, conditions)
- **Removed**: ~10 lines (hardcoded checks)
- **Net change**: ~80 lines

---

## Testing Guide

### Test Case 1: ADMIN User
**Expected Behavior:**
- ✅ Should see "Add Event" floating action button
- ✅ Should see "Create Event" buttons in dialogs
- ✅ Should see edit icon in event details
- ✅ Should see delete icon in event details
- ✅ Should be able to swipe events to delete
- ✅ Should see edit icon in event list

**Steps:**
1. Login as user with ADMIN role
2. Navigate to Calendar screen
3. Verify FAB is visible
4. Click on a day with events
5. Verify "Create Event" button appears
6. Click "View Events"
7. Verify edit icons appear
8. Click on an event
9. Verify edit and delete icons in app bar
10. Go back to calendar
11. Try swiping an event card
12. Verify delete confirmation appears

### Test Case 2: PROJECT MANAGER User
**Expected Behavior:**
- ✅ Same as ADMIN (has all event permissions)

**Steps:**
Same as Test Case 1

### Test Case 3: CLIENT User  
**Expected Behavior:**
- ❌ Should NOT see "Add Event" FAB
- ❌ Should NOT see "Create Event" buttons
- ❌ Should NOT see edit icon in event details
- ❌ Should NOT see delete icon in event details
- ❌ Should NOT be able to swipe to delete
- ❌ Should NOT see edit icons in event list
- ✅ Should still be able to VIEW events

**Steps:**
1. Login as user with CLIENT role
2. Navigate to Calendar screen
3. Verify no FAB appears
4. Click on a day with events
5. Verify no "Create Event" button
6. Click "View Events"
7. Verify no edit icons
8. Click on an event
9. Verify no edit/delete icons in app bar
10. Go back to calendar
11. Try swiping an event card
12. Verify swipe doesn't trigger delete

### Test Case 4: HEALTH PRACTITIONER User
**Expected Behavior:**
- ❌ Same as CLIENT (no event management permissions)

**Steps:**
Same as Test Case 3

### Test Case 5: PROJECT COORDINATOR User
**Expected Behavior:**
According to `role_permissions.dart`, PROJECT COORDINATOR should NOT have event management permissions despite having access to `/add-edit-event` route.

**Note:** There may be an inconsistency between route access and feature access:
- Route `/add-edit-event` allows PROJECT COORDINATOR
- Feature `create_event` does NOT allow PROJECT COORDINATOR

**Recommendation:** Verify the intended behavior with stakeholders.

---

## Inconsistency Found

### Route vs Feature Permission Mismatch

**In `role_permissions.dart`:**

```dart
// Route access
'/add-edit-event': ['ADMIN', 'TOP MANAGEMENT', 'PROJECT COORDINATOR'],

// Feature access
'create_event': ['ADMIN', 'TOP MANAGEMENT', 'PROJECT MANAGER'],
```

**Issue:** 
- PROJECT COORDINATOR can access the `/add-edit-event` route
- PROJECT COORDINATOR cannot use `create_event` feature
- PROJECT MANAGER can use `create_event` feature
- PROJECT MANAGER is NOT listed in `/add-edit-event` route

**Recommendation:**
Decide which is correct and update accordingly:

**Option 1: PROJECT COORDINATOR should create events**
```dart
'create_event': ['ADMIN', 'TOP MANAGEMENT', 'PROJECT COORDINATOR'],
'edit_event': ['ADMIN', 'TOP MANAGEMENT', 'PROJECT COORDINATOR'],
'delete_event': ['ADMIN', 'TOP MANAGEMENT', 'PROJECT COORDINATOR'],
```

**Option 2: PROJECT COORDINATOR should NOT access route**
```dart
'/add-edit-event': ['ADMIN', 'TOP MANAGEMENT', 'PROJECT MANAGER'],
```

---

## Before vs After Comparison

### Before
```dart
// Hardcoded in multiple files
bool _canAddEvent(String role) {
  final normalized = role.trim().toUpperCase();
  return normalized == 'ADMIN' ||
      normalized == 'TOP MANAGEMENT' ||
      normalized == 'PROJECT MANAGER';
}

// No checks on edit/delete buttons
IconButton(
  icon: const Icon(Icons.edit),
  onPressed: () => _navigateToEditEvent(context),
),
```

### After
```dart
// Centralized permission check
bool _canAddEvent(BuildContext context) {
  final profileVM = context.read<ProfileViewModel>();
  return RolePermissions.canAccessFeature(profileVM.role, 'create_event');
}

// Permission-protected edit button
if (canEdit)
  IconButton(
    icon: const Icon(Icons.edit),
    onPressed: () => _navigateToEditEvent(context),
  ),
```

---

## Impact Assessment

### Security
- ✅ **Improved**: Unauthorized users can no longer edit or delete events through UI
- ✅ **Consistent**: All event management actions now use the same permission system
- ⚠️ **Note**: Backend API should still validate permissions

### User Experience
- ✅ **Better**: Users only see actions they can perform
- ✅ **Clearer**: UI reflects actual capabilities
- ✅ **Consistent**: Same behavior across all event-related screens

### Maintainability
- ✅ **Single source of truth**: `RolePermissions.featureAccess`
- ✅ **Easier updates**: Change permissions in one place
- ✅ **Less duplication**: No hardcoded checks scattered around
- ✅ **Type-safe**: Using defined feature strings

### Performance
- ✅ **Negligible impact**: Permission checks are O(1) lookups
- ✅ **No extra queries**: Uses already-loaded ProfileViewModel

---

## Recommendations

### Immediate Actions
1. ✅ **Done**: Fix hardcoded permission checks
2. ✅ **Done**: Add permission checks to all event UI components
3. ⏳ **Todo**: Resolve PROJECT COORDINATOR permission inconsistency
4. ⏳ **Todo**: Test all role combinations
5. ⏳ **Todo**: Verify backend API also checks permissions

### Future Improvements
1. **Add integration tests** for permission checking
2. **Create permission testing utility** to verify all role combinations
3. **Document permission model** in developer guide
4. **Consider permission caching** if ProfileViewModel reloads frequently
5. **Add permission change notifications** if roles can change at runtime

---

## Summary

**Problem:** Role permissions for event management were not working correctly

**Root Cause:** Hardcoded permission checks bypassed the centralized RolePermissions system

**Solution:** 
- Replaced all hardcoded checks with `RolePermissions.canAccessFeature()`
- Added missing permission checks to event UI components
- Fixed role source to use `ProfileViewModel` instead of `CalendarViewModel`

**Result:** 
- ✅ Consistent permission enforcement across all event features
- ✅ Users only see actions they're authorized to perform
- ✅ Easier to maintain and update permissions
- ✅ Better security and user experience

**Status:** Implementation complete, ready for testing

**Next Steps:** 
1. Test with different user roles
2. Resolve PROJECT COORDINATOR permission inconsistency
3. Verify backend validation
