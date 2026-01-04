import 'user_roles.dart';

/// Define which roles have access to which routes/features
class RolePermissions {
  const RolePermissions._();

  // Route access permissions - maps routes to allowed roles
  static const Map<String, List<String>> routeAccess = {
    // Authentication routes - accessible to all
    '/login': [...UserRoles.values],
    '/register': [...UserRoles.values],
    '/forgot-password': [...UserRoles.values],

    // Admin-only routes
    '/user-management': ['ADMIN', 'MANAGEMENT'],
    '/user-management-version-two': ['ADMIN', 'MANAGEMENT'],

    // Stats and reports - Admin, Management, Coordinator, Data Capturer
    '/stats-report': ['ADMIN', 'MANAGEMENT', 'COORDINATOR', 'DATA CAPTURER'],

    // Calendar - All roles
    '/': [...UserRoles.values], // Main navigation
    '/calendar': [...UserRoles.values],
    '/event': ['ADMIN', 'MANAGEMENT', 'COORDINATOR'], // Create/Edit events
    '/event-details': [...UserRoles.values], // View events

    // Profile and settings - All roles
    '/profile': [...UserRoles.values],
    '/settings': [...UserRoles.values],
    '/help': [...UserRoles.values],

    // Nurse-specific routes
    '/nurse': ['NURSE', 'ADMIN', 'MANAGEMENT'],
    '/hiv-test': ['NURSE', 'ADMIN', 'MANAGEMENT'],
    '/hiv-result': ['NURSE', 'ADMIN', 'MANAGEMENT'],
    '/tb-testing': ['NURSE', 'ADMIN', 'MANAGEMENT'],
    '/survey': ['NURSE', 'ADMIN', 'MANAGEMENT'],

    // Consent forms - Coordinator, Nurse, Admin, Management
    '/consent': ['COORDINATOR', 'NURSE', 'ADMIN', 'MANAGEMENT'],
    '/personal-details': ['COORDINATOR', 'NURSE', 'ADMIN', 'MANAGEMENT'],
  };

  // Feature access permissions
  static const Map<String, List<String>> featureAccess = {
    'create_event': ['ADMIN', 'MANAGEMENT', 'COORDINATOR'],
    'edit_event': ['ADMIN', 'MANAGEMENT', 'COORDINATOR'],
    'delete_event': ['ADMIN', 'MANAGEMENT'],
    'view_events': [...UserRoles.values],

    'create_user': ['ADMIN', 'MANAGEMENT'],
    'edit_user': ['ADMIN', 'MANAGEMENT'],
    'delete_user': ['ADMIN'],
    'view_users': ['ADMIN', 'MANAGEMENT', 'COORDINATOR'],

    'conduct_wellness_flow': ['NURSE', 'ADMIN', 'MANAGEMENT'],
    'view_statistics': ['ADMIN', 'MANAGEMENT', 'COORDINATOR', 'DATA CAPTURER'],
    'export_data': ['ADMIN', 'MANAGEMENT', 'DATA CAPTURER'],

    'update_own_profile': [...UserRoles.values],
    'view_help': [...UserRoles.values],
  };

  /// Check if a role has access to a specific route
  static bool canAccessRoute(String? userRole, String route) {
    if (userRole == null || userRole.isEmpty) return false;

    final normalizedRole = UserRoles.normalize(userRole);
    final allowedRoles = routeAccess[route];

    if (allowedRoles == null) {
      // If route not defined, allow access (fail open for undefined routes)
      return true;
    }

    return allowedRoles.contains(normalizedRole);
  }

  /// Check if a role has access to a specific feature
  static bool canAccessFeature(String? userRole, String feature) {
    if (userRole == null || userRole.isEmpty) return false;

    final normalizedRole = UserRoles.normalize(userRole);
    final allowedRoles = featureAccess[feature];

    if (allowedRoles == null) {
      // If feature not defined, deny access (fail closed for undefined features)
      return false;
    }

    return allowedRoles.contains(normalizedRole);
  }

  /// Get all accessible routes for a role
  static List<String> getAccessibleRoutes(String? userRole) {
    if (userRole == null || userRole.isEmpty) return [];

    final normalizedRole = UserRoles.normalize(userRole);
    final accessibleRoutes = <String>[];

    routeAccess.forEach((route, allowedRoles) {
      if (allowedRoles.contains(normalizedRole)) {
        accessibleRoutes.add(route);
      }
    });

    return accessibleRoutes;
  }

  /// Get all accessible features for a role
  static List<String> getAccessibleFeatures(String? userRole) {
    if (userRole == null || userRole.isEmpty) return [];

    final normalizedRole = UserRoles.normalize(userRole);
    final accessibleFeatures = <String>[];

    featureAccess.forEach((feature, allowedRoles) {
      if (allowedRoles.contains(normalizedRole)) {
        accessibleFeatures.add(feature);
      }
    });

    return accessibleFeatures;
  }

  /// Check if user is admin
  static bool isAdmin(String? userRole) {
    return UserRoles.normalize(userRole) == 'ADMIN';
  }

  /// Check if user is management
  static bool isManagement(String? userRole) {
    final role = UserRoles.normalize(userRole);
    return role == 'ADMIN' || role == 'MANAGEMENT';
  }

  /// Check if user is nurse
  static bool isNurse(String? userRole) {
    return UserRoles.normalize(userRole) == 'NURSE';
  }

  /// Check if user is coordinator
  static bool isCoordinator(String? userRole) {
    return UserRoles.normalize(userRole) == 'COORDINATOR';
  }
}
