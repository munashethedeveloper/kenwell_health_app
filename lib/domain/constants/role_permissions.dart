import 'user_roles.dart';

/// Define which roles have access to which routes/features
class RolePermissions {
  const RolePermissions._();

  // Route access permissions - maps routes to allowed roles
  static const Map<String, List<String>> routeAccess = {
    //Routes Accessible to All Roles
    '/login': [...UserRoles.values],
    '/register': [...UserRoles.values],
    '/forgot-password': [...UserRoles.values],
    '/': [...UserRoles.values],
    '/calendar': [...UserRoles.values],
    '/event-details': [...UserRoles.values],
    '/profile': [...UserRoles.values],
    '/my-profile-menu': [...UserRoles.values],
    '/help': [...UserRoles.values],

    // Admin-only routes
    '/user-management': ['ADMIN', 'TOP MANAGEMENT'],
    '/user-management-version-two': ['ADMIN', 'TOP MANAGEMENT'],
    '/add-edit-event': ['ADMIN', 'TOP MANAGEMENT', 'PROJECT COORDINATOR'],
    '/allocate-event': ['ADMIN', 'TOP MANAGEMENT', 'PROJECT COORDINATOR'],
    '/stats': ['ADMIN', 'TOP MANAGEMENT', 'PROJECT COORDINATOR', 'CLIENT'],
    '/detailed-stats': [
      'ADMIN',
      'TOP MANAGEMENT',
      'PROJECT COORDINATOR',
      'CLIENT'
    ],

    //Staff Route Permissions
    '/member-search': [
      'PROJECT COORDINATOR',
      'PROJECT MANAGER',
      'HEALTH PRACTITIONER',
      'ADMIN',
      'TOP MANAGEMENT'
    ],
    '/event-home': [
      'PROJECT COORDINATOR',
      'PROJECT MANAGER',
      'HEALTH PRACTITIONER',
      'ADMIN',
      'TOP MANAGEMENT'
    ],
    '/member-registration': [
      'PROJECT COORDINATOR',
      'PROJECT MANAGER',
      'HEALTH PRACTITIONER',
      'ADMIN',
      'TOP MANAGEMENT'
    ],
    '/consent': [
      'PROJECT COORDINATOR',
      'PROJECT MANAGER',
      'HEALTH PRACTITIONER',
      'ADMIN',
      'TOP MANAGEMENT'
    ],
    '/health-screening': [
      'PROJECT COORDINATOR',
      'PROJECT MANAGER',
      'HEALTH PRACTITIONER',
      'ADMIN',
      'TOP MANAGEMENT'
    ],
    '/health-risk-assessment': [
      'PROJECT COORDINATOR',
      'PROJECT MANAGER',
      'HEALTH PRACTITIONER',
      'ADMIN',
      'TOP MANAGEMENT'
    ],
    '/hiv-test': [
      'PROJECT COORDINATOR',
      'PROJECT MANAGER',
      'HEALTH PRACTITIONER',
      'ADMIN',
      'TOP MANAGEMENT'
    ],
    '/hiv-result': [
      'PROJECT COORDINATOR',
      'PROJECT MANAGER',
      'HEALTH PRACTITIONER',
      'ADMIN',
      'TOP MANAGEMENT'
    ],
    '/tb-testing': [
      'PROJECT COORDINATOR',
      'PROJECT MANAGER',
      'HEALTH PRACTITIONER',
      'ADMIN',
      'TOP MANAGEMENT'
    ],
    '/survey': [
      'PROJECT COORDINATOR',
      'PROJECT MANAGER',
      'HEALTH PRACTITIONER',
      'ADMIN',
      'TOP MANAGEMENT'
    ],
  };

  // Feature access permissions
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
    
    // Statistics and General Permissions
    'view_statistics': ['ADMIN', 'TOP MANAGEMENT', 'PROJECT MANAGER', 'CLIENT'],
    'export_data': ['ADMIN', 'TOP MANAGEMENT', 'PROJECT MANAGER'],
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
    return role == 'ADMIN' || role == 'TOP MANAGEMENT';
  }

  /// Check if user is nurse
  static bool isNurse(String? userRole) {
    return UserRoles.normalize(userRole) == 'NURSE';
  }

  /// Check if user is coordinator
  static bool isCoordinator(String? userRole) {
    return UserRoles.normalize(userRole) == 'PROJECT COORDINATOR';
  }
}
