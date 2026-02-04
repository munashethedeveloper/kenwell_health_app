# Role Permissions Documentation - User Management and Event Workflow

## Overview
This document describes the role-based permission system for user management and event workflow features in the Kenwell Health App.

## New Permissions Added

### User Management Permissions

#### `reset_user_credentials`
**Purpose:** Reset user passwords  
**Allowed Roles:** ADMIN, TOP MANAGEMENT  
**UI Impact:**
- "Reset Password" option in user actions menu (bottom sheet) only shown to authorized users
- When user lacks permission, option is completely hidden

**Rationale:** Password reset is a sensitive operation that should be limited to top-level management

#### `create_user`
**Purpose:** Create new user accounts  
**Allowed Roles:** ADMIN, TOP MANAGEMENT, PROJECT MANAGER  
**UI Impact:**
- "Create User" tab in User Management screen only shown to authorized users
- Users without permission won't see the tab at all

**Rationale:** User creation requires understanding of roles and permissions

#### `view_users`
**Purpose:** View list of all users in the system  
**Allowed Roles:** ADMIN, TOP MANAGEMENT, PROJECT MANAGER  
**UI Impact:**
- "View Users" tab in User Management screen only shown to authorized users
- Users without permission won't see the tab

**Rationale:** User data is sensitive and should only be visible to management

#### `edit_user`
**Purpose:** Edit existing user information  
**Allowed Roles:** ADMIN, TOP MANAGEMENT, PROJECT MANAGER  
**UI Impact:**
- Edit functionality in user management (future implementation)

**Rationale:** Editing users requires careful consideration of role changes and data integrity

#### `delete_user`
**Purpose:** Permanently delete user accounts  
**Allowed Roles:** ADMIN only  
**UI Impact:**
- "Delete User" option in user actions menu only shown to ADMIN
- Requires confirmation dialog before deletion

**Rationale:** User deletion is irreversible and should be restricted to admins only

### Event Workflow Permissions

#### `allocate_events`
**Purpose:** Assign wellness events to specific users  
**Allowed Roles:** ADMIN, TOP MANAGEMENT, PROJECT COORDINATOR  
**UI Impact:**
- "Allocate Event" button in Event Details screen only shown to authorized users
- Users without permission cannot access event allocation functionality

**Rationale:** Event allocation affects workflow assignments and should be controlled by coordinators and management

#### `view_events`
**Purpose:** View wellness events in the system  
**Allowed Roles:** All roles  
**UI Impact:**
- All users can view events in calendar and event lists

**Rationale:** Events are public information within the organization

#### `conduct_wellness_flow`
**Purpose:** Conduct wellness screening workflow with members  
**Allowed Roles:** HEALTH PRACTITIONER, PROJECT MANAGER, PROJECT COORDINATOR, ADMIN, TOP MANAGEMENT  
**UI Impact:**
- Access to member search, wellness flow screens, and health screening tools
- Routes like `/member-search`, `/hiv-test`, `/tb-testing`, etc.

**Rationale:** Wellness flow requires clinical or coordination expertise

---

## Permission Matrix

### Complete Permission Table

| Permission | ADMIN | TOP MGMT | PROJ MGR | PROJ COORD | HEALTH PRACT | CLIENT |
|------------|:-----:|:--------:|:--------:|:----------:|:------------:|:------:|
| **User Management** |
| create_user | ✅ | ✅ | ✅ | ❌ | ❌ | ❌ |
| view_users | ✅ | ✅ | ✅ | ❌ | ❌ | ❌ |
| edit_user | ✅ | ✅ | ✅ | ❌ | ❌ | ❌ |
| delete_user | ✅ | ❌ | ❌ | ❌ | ❌ | ❌ |
| reset_user_credentials | ✅ | ✅ | ❌ | ❌ | ❌ | ❌ |
| **Event Management** |
| create_event | ✅ | ✅ | ✅ | ❌ | ❌ | ❌ |
| edit_event | ✅ | ✅ | ✅ | ❌ | ❌ | ❌ |
| delete_event | ✅ | ✅ | ✅ | ❌ | ❌ | ❌ |
| view_events | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| allocate_events | ✅ | ✅ | ❌ | ✅ | ❌ | ❌ |
| **Event Workflow** |
| conduct_wellness_flow | ✅ | ✅ | ✅ | ✅ | ✅ | ❌ |
| **Other** |
| view_statistics | ✅ | ✅ | ✅ | ❌ | ❌ | ✅ |
| export_data | ✅ | ✅ | ✅ | ❌ | ❌ | ❌ |
| update_own_profile | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| view_help | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |

### Role Descriptions

**ADMIN**
- Full system access
- Can delete users (only role with this permission)
- Can manage all aspects of users, events, and data

**TOP MANAGEMENT**
- Nearly full access (cannot delete users)
- Can reset passwords, create users, allocate events
- Management oversight capabilities

**PROJECT MANAGER**
- Can manage events (create, edit, delete)
- Can manage users (create, view, edit)
- Cannot reset passwords or delete users
- Cannot allocate events to other users

**PROJECT COORDINATOR**
- Can allocate events to users
- Can conduct wellness flow
- Cannot manage users or create/edit events

**HEALTH PRACTITIONER**
- Can conduct wellness flow (clinical activities)
- Cannot manage users or events
- Limited to clinical workflow

**CLIENT**
- View-only access
- Can view events and statistics
- Can update own profile
- No administrative capabilities

---

## UI Implementation Details

### User Management Screen

#### Dynamic Tab Visibility
The User Management screen shows tabs based on user permissions:

```dart
// Check permissions
final canCreateUser = RolePermissions.canAccessFeature(
  profileVM.role, 
  'create_user'
);
final canViewUsers = RolePermissions.canAccessFeature(
  profileVM.role, 
  'view_users'
);

// Build tabs dynamically
if (canCreateUser) {
  tabs.add(Tab(icon: Icon(Icons.person_add), text: 'Create User'));
}

if (canViewUsers) {
  tabs.add(Tab(icon: Icon(Icons.group), text: 'View Users'));
}
```

**Possible Scenarios:**
1. **Both permissions:** Shows both "Create User" and "View Users" tabs (2 tabs)
2. **Create only:** Shows only "Create User" tab (1 tab)
3. **View only:** Shows only "View Users" tab (1 tab)
4. **No permissions:** Shows "No Access" message with lock icon

#### User Actions Menu (Bottom Sheet)

When clicking on a user in the list, a bottom sheet appears with available actions:

```dart
// Check permissions
final canResetPassword = RolePermissions.canAccessFeature(
  profileVM.role, 
  'reset_user_credentials'
);
final canDelete = RolePermissions.canAccessFeature(
  profileVM.role, 
  'delete_user'
);

// Conditionally show options
if (canResetPassword) {
  // Show "Reset Password" option
}

if (canDelete) {
  // Show "Delete User" option
}

if (!canResetPassword && !canDelete) {
  // Show "No actions available" message
}
```

**Possible Scenarios:**
1. **ADMIN:** Sees both "Reset Password" and "Delete User"
2. **TOP MANAGEMENT:** Sees only "Reset Password"
3. **PROJECT MANAGER:** Sees "No actions available"

### Event Details Screen

#### Allocate Event Button

The "Allocate Event" button is conditionally rendered:

```dart
if (RolePermissions.canAccessFeature(profileVM.role, 'allocate_events'))
  CustomPrimaryButton(
    label: 'Allocate Event',
    onPressed: () {
      // Navigate to allocation screen
    },
  ),
```

**Visible to:**
- ADMIN
- TOP MANAGEMENT
- PROJECT COORDINATOR

**Hidden from:**
- PROJECT MANAGER
- HEALTH PRACTITIONER
- CLIENT

---

## Code Organization

### Permission Definition Location
All permissions are defined in:
```
lib/domain/constants/role_permissions.dart
```

### featureAccess Map Structure
```dart
static const Map<String, List<String>> featureAccess = {
  // Event Management Permissions
  'create_event': ['ADMIN', 'TOP MANAGEMENT', 'PROJECT MANAGER'],
  'edit_event': ['ADMIN', 'TOP MANAGEMENT', 'PROJECT MANAGER'],
  'delete_event': ['ADMIN', 'TOP MANAGEMENT', 'PROJECT MANAGER'],
  'view_events': [...UserRoles.values],
  'allocate_events': ['ADMIN', 'TOP MANAGEMENT', 'PROJECT COORDINATOR'],
  
  // User Management Permissions
  'create_user': ['ADMIN', 'TOP MANAGEMENT', 'PROJECT MANAGER'],
  'edit_user': ['ADMIN', 'TOP MANAGEMENT', 'PROJECT MANAGER'],
  'delete_user': ['ADMIN'],
  'view_users': ['ADMIN', 'TOP MANAGEMENT', 'PROJECT MANAGER'],
  'reset_user_credentials': ['ADMIN', 'TOP MANAGEMENT'],
  
  // Event Workflow Permissions
  'conduct_wellness_flow': [
    'HEALTH PRACTITIONER',
    'PROJECT MANAGER',
    'PROJECT COORDINATOR',
    'ADMIN',
    'TOP MANAGEMENT'
  ],
  
  // ... other permissions
};
```

### Permission Checking Usage

**Standard Pattern:**
```dart
// 1. Get user's role from ProfileViewModel
final profileVM = context.read<ProfileViewModel>();

// 2. Check permission
final hasPermission = RolePermissions.canAccessFeature(
  profileVM.role,
  'permission_name'
);

// 3. Conditionally render UI or enable functionality
if (hasPermission) {
  // Show button, menu item, or enable feature
}
```

---

## Testing Guide

### Test Scenarios by Role

#### Test Case 1: ADMIN User
**Expected Behavior:**
- ✅ See "Create User" tab
- ✅ See "View Users" tab
- ✅ See "Reset Password" option in user actions
- ✅ See "Delete User" option in user actions
- ✅ See "Allocate Event" button in event details

**Steps:**
1. Login as ADMIN
2. Navigate to User Management
3. Verify both tabs are visible
4. Click on a user in View Users tab
5. Verify both "Reset Password" and "Delete User" options appear
6. Navigate to an event detail page
7. Verify "Allocate Event" button is visible

#### Test Case 2: TOP MANAGEMENT User
**Expected Behavior:**
- ✅ See "Create User" tab
- ✅ See "View Users" tab
- ✅ See "Reset Password" option in user actions
- ❌ NOT see "Delete User" option
- ✅ See "Allocate Event" button

**Steps:**
1. Login as TOP MANAGEMENT
2. Navigate to User Management
3. Verify both tabs are visible
4. Click on a user
5. Verify only "Reset Password" option appears (no delete)
6. Navigate to event details
7. Verify "Allocate Event" button is visible

#### Test Case 3: PROJECT MANAGER User
**Expected Behavior:**
- ✅ See "Create User" tab
- ✅ See "View Users" tab
- ❌ See "No actions available" in user actions menu
- ❌ NOT see "Allocate Event" button

**Steps:**
1. Login as PROJECT MANAGER
2. Navigate to User Management
3. Verify both tabs are visible
4. Click on a user
5. Verify "No actions available" message appears
6. Navigate to event details
7. Verify "Allocate Event" button is NOT visible

#### Test Case 4: PROJECT COORDINATOR User
**Expected Behavior:**
- ❌ See "No Access" message in User Management
- ✅ See "Allocate Event" button in event details

**Steps:**
1. Login as PROJECT COORDINATOR
2. Navigate to User Management
3. Verify "No Access" message with lock icon
4. Navigate to event details
5. Verify "Allocate Event" button is visible

#### Test Case 5: HEALTH PRACTITIONER User
**Expected Behavior:**
- ❌ See "No Access" message in User Management
- ❌ NOT see "Allocate Event" button
- ✅ Can access wellness flow screens

**Steps:**
1. Login as HEALTH PRACTITIONER
2. Navigate to User Management
3. Verify "No Access" message
4. Navigate to event details
5. Verify "Allocate Event" button is NOT visible
6. Navigate to wellness flow
7. Verify access to member search and wellness screening

#### Test Case 6: CLIENT User
**Expected Behavior:**
- ❌ See "No Access" message in User Management
- ❌ NOT see "Allocate Event" button
- ✅ Can view events

**Steps:**
1. Login as CLIENT
2. Navigate to User Management
3. Verify "No Access" message
4. Navigate to calendar/events
5. Verify can view events
6. Navigate to event details
7. Verify "Allocate Event" button is NOT visible

---

## Security Considerations

### Client-Side vs Server-Side Validation

**Important:** The permissions implemented are **UI-level** controls. They hide/show buttons and options based on user roles, but **do not replace server-side validation**.

**Best Practices:**
1. ✅ **UI Controls:** Hide unauthorized actions from users (implemented)
2. ⚠️ **API Validation:** Server must also validate permissions before executing actions
3. ⚠️ **Route Guards:** GoRouter redirect logic should prevent unauthorized route access

**Current Implementation:**
- ✅ UI-level permission checks using `RolePermissions.canAccessFeature()`
- ✅ Dynamic UI rendering based on permissions
- ⚠️ Server-side validation should also be implemented in Firebase Functions or backend API

### Permission Bypass Prevention

Users should not be able to:
- Bypass UI controls by manually navigating to routes
- Execute API calls without proper authorization
- Manipulate their role on the client side

**Recommendations:**
1. Implement permission checks in GoRouter's redirect callback
2. Add permission validation in all API endpoints
3. Use Firebase Security Rules to enforce permissions at database level
4. Audit user actions for compliance

---

## Future Enhancements

### Planned Improvements

1. **Dynamic Permission Loading**
   - Load permissions from backend instead of hardcoding
   - Allow runtime permission updates

2. **Permission Groups**
   - Create permission groups/profiles
   - Assign multiple permission sets to users

3. **Granular Permissions**
   - Per-user permission overrides
   - Temporary permission grants

4. **Audit Logging**
   - Log all permission checks
   - Track who accessed what features

5. **Permission Testing Tools**
   - Automated tests for all role combinations
   - Permission matrix validation

---

## Troubleshooting

### Common Issues

**Issue: User can't see expected tabs/buttons**
- **Check:** Verify user's role is correctly set in ProfileViewModel
- **Check:** Ensure role string matches exactly (case-sensitive, normalized)
- **Solution:** Use `UserRoles.normalize()` to standardize role strings

**Issue: Permission check returns false unexpectedly**
- **Check:** Role spelling in featureAccess map
- **Check:** ProfileViewModel is properly loaded
- **Solution:** Add debug logging to permission check

**Issue: "No Access" message shown to authorized users**
- **Check:** All required permissions are granted
- **Check:** User role is in the allowed list for at least one permission
- **Solution:** Verify featureAccess map configuration

---

## Summary

### What Was Implemented

✅ **New Permissions:**
- `reset_user_credentials` for password resets
- `allocate_events` for event allocation

✅ **Permission Checks:**
- User Management screen: Dynamic tabs based on create/view permissions
- User actions menu: Conditional reset password and delete options
- Event details: Conditional allocate event button

✅ **UI/UX:**
- "No Access" message when users lack all permissions
- "No actions available" message when users lack specific action permissions
- Clean, permission-based UI that only shows what users can do

✅ **Code Quality:**
- Organized featureAccess map with clear sections
- Consistent permission checking pattern
- Reusable RolePermissions utility class

### Benefits

1. **Security:** Users can't see or access unauthorized features
2. **UX:** Clean UI that doesn't confuse users with disabled options
3. **Maintainability:** Single source of truth for permissions
4. **Scalability:** Easy to add new permissions and roles
5. **Clarity:** Clear permission matrix and documentation

---

**Implementation Complete!** All requested user management and event workflow permissions have been added and properly enforced in the UI.
