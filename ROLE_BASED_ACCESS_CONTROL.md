# Role-Based Access Control (RBAC) Implementation Guide

This guide explains how to implement and use role-based access control in the Kenwell Health App.

## Overview

The app supports 6 user roles with different permission levels:
- **ADMIN** - Full access to all features
- **MANAGEMENT** - Administrative access, can manage users and view all data
- **COORDINATOR** - Can coordinate events and access wellness flows
- **DATA CAPTURER** - Can view statistics and export data
- **NURSE** - Can conduct wellness assessments and interventions
- **CLIENT** - Basic user access to calendar and personal profile

## Implementation

### 1. Role Permissions Configuration

The `RolePermissions` class (`lib/domain/constants/role_permissions.dart`) defines:
- Which roles can access which routes
- Which roles can use which features
- Helper methods to check permissions

**Example Route Access:**
```dart
static const Map<String, List<String>> routeAccess = {
  '/user-management': ['ADMIN', 'MANAGEMENT'],
  '/stats-report': ['ADMIN', 'MANAGEMENT', 'COORDINATOR', 'DATA CAPTURER'],
  '/nurse': ['NURSE', 'ADMIN', 'MANAGEMENT'],
  '/calendar': [...UserRoles.values], // All roles
};
```

**Example Feature Access:**
```dart
static const Map<String, List<String>> featureAccess = {
  'create_event': ['ADMIN', 'MANAGEMENT', 'COORDINATOR'],
  'delete_user': ['ADMIN'],
  'conduct_wellness_flow': ['NURSE', 'ADMIN', 'MANAGEMENT'],
};
```

### 2. Route Protection

Use `RoleBasedRouteGuard` to protect navigation:

**Navigate with Permission Check:**
```dart
import 'package:kenwell_health_app/ui/shared/middleware/role_based_route_guard.dart';

// Instead of Navigator.pushNamed()
await RoleBasedRouteGuard.navigateIfAllowed(
  context,
  '/user-management',
  onDenied: () {
    // Optional: Custom handling when access is denied
    print('Access denied');
  },
);
```

**Replace Route with Permission Check:**
```dart
await RoleBasedRouteGuard.replaceIfAllowed(
  context,
  '/stats-report',
);
```

**Manual Permission Check:**
```dart
final canAccess = await RoleBasedRouteGuard.canAccess(context, '/user-management');
if (canAccess) {
  // Show the feature
} else {
  // Hide or disable the feature
}
```

### 3. Conditional UI Elements

Use `RoleBasedWidget` to show/hide UI elements:

**Show Button Only for Admin:**
```dart
RoleBasedWidget(
  requiredRole: 'ADMIN',
  child: ElevatedButton(
    onPressed: () => deleteUser(),
    child: const Text('Delete User'),
  ),
  fallback: const SizedBox.shrink(), // Optional: widget to show when access denied
)
```

**Show Button for Multiple Roles:**
```dart
RoleBasedWidget(
  allowedRoles: ['ADMIN', 'MANAGEMENT', 'COORDINATOR'],
  child: FloatingActionButton(
    onPressed: () => createEvent(),
    child: const Icon(Icons.add),
  ),
)
```

### 4. Feature-Based Widgets

Use `FeatureBasedWidget` for granular feature control:

```dart
FeatureBasedWidget(
  feature: 'create_event',
  child: ElevatedButton(
    onPressed: () => showCreateEventDialog(),
    child: const Text('Create Event'),
  ),
)
```

```dart
FeatureBasedWidget(
  feature: 'export_data',
  child: IconButton(
    icon: const Icon(Icons.download),
    onPressed: () => exportData(),
  ),
)
```

### 5. Helper Methods

Check roles programmatically:

```dart
import 'package:kenwell_health_app/domain/constants/role_permissions.dart';

// Check specific role
if (RolePermissions.isAdmin(userRole)) {
  // Admin-only code
}

if (RolePermissions.isNurse(userRole)) {
  // Nurse-only code
}

// Check route access
if (RolePermissions.canAccessRoute(userRole, '/user-management')) {
  // User can access route
}

// Check feature access
if (RolePermissions.canAccessFeature(userRole, 'delete_user')) {
  // User can use feature
}

// Get all accessible routes
final routes = RolePermissions.getAccessibleRoutes(userRole);

// Get all accessible features
final features = RolePermissions.getAccessibleFeatures(userRole);
```

## Firestore Security Rules

Add these rules to Firebase Console → Firestore → Rules:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // Helper function to check if user is authenticated
    function isAuthenticated() {
      return request.auth != null;
    }
    
    // Helper function to get user's role from their profile
    function getUserRole() {
      return get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role;
    }
    
    // Helper function to check if user has specific role
    function hasRole(role) {
      return isAuthenticated() && getUserRole() == role;
    }
    
    // Helper function to check if user has any of the roles
    function hasAnyRole(roles) {
      return isAuthenticated() && getUserRole() in roles;
    }
    
    // Users collection
    match /users/{userId} {
      // Users can read their own profile
      allow read: if isAuthenticated() && request.auth.uid == userId;
      
      // Only admins and management can read all users
      allow list: if hasAnyRole(['ADMIN', 'MANAGEMENT']);
      
      // Users can update their own profile (except role)
      allow update: if isAuthenticated() 
                    && request.auth.uid == userId 
                    && request.resource.data.role == resource.data.role;
      
      // Only admins and management can create users
      allow create: if hasAnyRole(['ADMIN', 'MANAGEMENT']);
      
      // Only admins can delete users
      allow delete: if hasRole('ADMIN');
    }
    
    // Events collection
    match /events/{eventId} {
      // All authenticated users can read events
      allow read: if isAuthenticated();
      
      // Admin, Management, and Coordinators can create/update events
      allow create, update: if hasAnyRole(['ADMIN', 'MANAGEMENT', 'COORDINATOR']);
      
      // Only Admin and Management can delete events
      allow delete: if hasAnyRole(['ADMIN', 'MANAGEMENT']);
    }
    
    // Wellness assessments (HIV/TB tests, surveys, etc.)
    match /assessments/{assessmentId} {
      // Nurses, Admin, and Management can read/write
      allow read, write: if hasAnyRole(['NURSE', 'ADMIN', 'MANAGEMENT']);
    }
    
    // Statistics and reports
    match /reports/{reportId} {
      // Admin, Management, Coordinator, and Data Capturers can read
      allow read: if hasAnyRole(['ADMIN', 'MANAGEMENT', 'COORDINATOR', 'DATA CAPTURER']);
      
      // Only Admin and Management can write
      allow write: if hasAnyRole(['ADMIN', 'MANAGEMENT']);
    }
  }
}
```

## Usage Examples

### Example 1: Protect Navigation Menu Items

```dart
// In MainNavigationScreen or menu drawer
Widget build(BuildContext context) {
  return Drawer(
    child: ListView(
      children: [
        // Always visible
        ListTile(
          title: const Text('Calendar'),
          onTap: () => Navigator.pushNamed(context, '/calendar'),
        ),
        
        // Only for Admin and Management
        RoleBasedWidget(
          allowedRoles: ['ADMIN', 'MANAGEMENT'],
          child: ListTile(
            title: const Text('User Management'),
            onTap: () => RoleBasedRouteGuard.navigateIfAllowed(
              context,
              '/user-management',
            ),
          ),
        ),
        
        // Only for Nurses
        RoleBasedWidget(
          requiredRole: 'NURSE',
          child: ListTile(
            title: const Text('Conduct Assessment'),
            onTap: () => Navigator.pushNamed(context, '/nurse'),
          ),
        ),
      ],
    ),
  );
}
```

### Example 2: Protect Bottom Navigation

```dart
// Filter navigation destinations based on role
final List<NavigationDestination> _getFilteredDestinations(String userRole) {
  final allDestinations = [
    if (RolePermissions.canAccessRoute(userRole, '/user-management'))
      const NavigationDestination(
        icon: Icon(Icons.person),
        label: 'User Management',
      ),
    if (RolePermissions.canAccessRoute(userRole, '/stats-report'))
      const NavigationDestination(
        icon: Icon(Icons.bar_chart),
        label: 'Statistics',
      ),
    // Calendar is always visible
    const NavigationDestination(
      icon: Icon(Icons.calendar_today),
      label: 'Planner',
    ),
    // ... more destinations
  ];
  
  return allDestinations;
}
```

### Example 3: Protect Actions in Event Details

```dart
// In EventDetailsScreen
Widget _buildActionButtons(String userRole) {
  return Row(
    children: [
      // Edit button - only for Admin, Management, Coordinator
      FeatureBasedWidget(
        feature: 'edit_event',
        child: ElevatedButton.icon(
          icon: const Icon(Icons.edit),
          label: const Text('Edit'),
          onPressed: () => editEvent(),
        ),
      ),
      const SizedBox(width: 8),
      
      // Delete button - only for Admin, Management
      FeatureBasedWidget(
        feature: 'delete_event',
        child: ElevatedButton.icon(
          icon: const Icon(Icons.delete),
          label: const Text('Delete'),
          onPressed: () => deleteEvent(),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
          ),
        ),
      ),
    ],
  );
}
```

### Example 4: Protect Form Fields

```dart
// In ProfileScreen
Widget _buildRoleField(UserModel user, String currentUserRole) {
  // Only admins and management can change roles
  final canEditRole = RolePermissions.canAccessFeature(
    currentUserRole, 
    'edit_user',
  );
  
  return KenwellDropdownField<String>(
    label: 'Role',
    value: user.role,
    items: UserRoles.values,
    enabled: canEditRole,
    onChanged: canEditRole ? (value) => updateRole(value) : null,
  );
}
```

## Role Hierarchy

The roles are designed with a hierarchy in mind:

```
ADMIN (Highest)
  ├─ All permissions
  └─ Can manage all users
  
MANAGEMENT
  ├─ Most permissions
  ├─ Can manage users (except admins)
  └─ Can view all data
  
COORDINATOR
  ├─ Can manage events
  ├─ Can conduct wellness flows
  └─ Can view statistics
  
DATA CAPTURER
  ├─ Can view statistics
  └─ Can export data
  
NURSE
  ├─ Can conduct wellness assessments
  ├─ Can perform HIV/TB tests
  └─ Can complete surveys
  
CLIENT (Lowest)
  ├─ Can view calendar
  ├─ Can update own profile
  └─ Basic access only
```

## Customization

### Adding New Roles

1. Add role to `UserRoles.values` in `user_roles.dart`:
```dart
static const List<String> values = [
  'ADMIN',
  'MANAGEMENT',
  'COORDINATOR',
  'DATA CAPTURER',
  'NURSE',
  'CLIENT',
  'NEW_ROLE', // Add here
];
```

2. Update `RolePermissions.routeAccess` and `RolePermissions.featureAccess`
3. Update Firestore security rules

### Adding New Routes

Add to `RolePermissions.routeAccess`:
```dart
'/new-route': ['ADMIN', 'MANAGEMENT'], // Allowed roles
```

### Adding New Features

Add to `RolePermissions.featureAccess`:
```dart
'new_feature': ['ADMIN', 'NURSE'], // Allowed roles
```

## Testing

### Test Role Access

```dart
void testRoleAccess() {
  // Admin can access everything
  assert(RolePermissions.canAccessRoute('ADMIN', '/user-management'));
  assert(RolePermissions.canAccessFeature('ADMIN', 'delete_user'));
  
  // Nurse can access nurse routes but not admin routes
  assert(RolePermissions.canAccessRoute('NURSE', '/nurse'));
  assert(!RolePermissions.canAccessRoute('NURSE', '/user-management'));
  
  // Client has limited access
  assert(RolePermissions.canAccessRoute('CLIENT', '/calendar'));
  assert(!RolePermissions.canAccessRoute('CLIENT', '/stats-report'));
}
```

## Best Practices

1. **Always check permissions on both client and server**
   - Use `RoleBasedRouteGuard` on client
   - Use Firestore security rules on server

2. **Fail securely**
   - Default to denying access if role is unclear
   - Show user-friendly error messages

3. **Use feature-based permissions**
   - More flexible than role-based
   - Easier to maintain as app grows

4. **Cache user role**
   - Avoid repeated Firebase calls
   - Update cache when user logs in/out

5. **Test all permission combinations**
   - Test each role's access
   - Test boundary cases

6. **Keep permissions documented**
   - Update this guide when adding roles/features
   - Document in code comments

## Troubleshooting

**User sees "Permission denied" but should have access:**
- Check user's role in Firestore Console
- Verify role spelling (must be uppercase)
- Check `RolePermissions` configuration
- Check Firestore security rules

**User can access route they shouldn't:**
- Add route to `RolePermissions.routeAccess`
- Update Firestore security rules
- Clear app cache and restart

**Firestore security rules fail:**
- Test rules in Firebase Console Rules Playground
- Check that user document exists with role field
- Ensure role field matches expected values

## Summary

The role-based access control system provides:
- ✅ Route-level protection
- ✅ Feature-level granular control
- ✅ UI element visibility control
- ✅ Server-side security via Firestore rules
- ✅ Easy to extend and maintain
- ✅ Type-safe with helper methods

For questions or issues, refer to the code comments in:
- `lib/domain/constants/role_permissions.dart`
- `lib/ui/shared/middleware/role_based_route_guard.dart`
