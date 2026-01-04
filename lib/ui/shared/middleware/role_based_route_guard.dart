import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../features/auth/view_models/auth_view_model.dart';
import '../../data/services/firebase_auth_service.dart';
import '../../../domain/constants/role_permissions.dart';

/// Middleware to protect routes based on user roles
class RoleBasedRouteGuard {
  /// Check if current user can access a route
  static Future<bool> canAccess(BuildContext context, String route) async {
    try {
      // Get current user from Firebase
      final authService = FirebaseAuthService();
      final user = await authService.currentUser();

      if (user == null) {
        return false;
      }

      // Check route access
      return RolePermissions.canAccessRoute(user.role, route);
    } catch (e) {
      debugPrint('Error checking route access: $e');
      return false;
    }
  }

  /// Navigate to route only if user has permission
  static Future<void> navigateIfAllowed(
    BuildContext context,
    String route, {
    Object? arguments,
    void Function()? onDenied,
  }) async {
    final canNavigate = await canAccess(context, route);

    if (canNavigate) {
      if (context.mounted) {
        Navigator.pushNamed(context, route, arguments: arguments);
      }
    } else {
      // Show access denied message
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('You do not have permission to access this page'),
            backgroundColor: Colors.red,
          ),
        );
      }

      // Call custom denied handler if provided
      onDenied?.call();
    }
  }

  /// Replace current route only if user has permission
  static Future<void> replaceIfAllowed(
    BuildContext context,
    String route, {
    Object? arguments,
    void Function()? onDenied,
  }) async {
    final canNavigate = await canAccess(context, route);

    if (canNavigate) {
      if (context.mounted) {
        Navigator.pushReplacementNamed(context, route, arguments: arguments);
      }
    } else {
      // Show access denied message
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('You do not have permission to access this page'),
            backgroundColor: Colors.red,
          ),
        );
      }

      // Call custom denied handler if provided
      onDenied?.call();
    }
  }
}

/// Widget wrapper that conditionally shows content based on user role
class RoleBasedWidget extends StatelessWidget {
  final String? requiredRole;
  final List<String>? allowedRoles;
  final Widget child;
  final Widget? fallback;

  const RoleBasedWidget({
    super.key,
    this.requiredRole,
    this.allowedRoles,
    required this.child,
    this.fallback,
  }) : assert(
          requiredRole != null || allowedRoles != null,
          'Either requiredRole or allowedRoles must be provided',
        );

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _checkAccess(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox.shrink(); // Or loading indicator
        }

        final hasAccess = snapshot.data ?? false;

        if (hasAccess) {
          return child;
        } else {
          return fallback ?? const SizedBox.shrink();
        }
      },
    );
  }

  Future<bool> _checkAccess() async {
    try {
      final authService = FirebaseAuthService();
      final user = await authService.currentUser();

      if (user == null) return false;

      final userRole = user.role;

      // Check if user has required role
      if (requiredRole != null) {
        return userRole.toUpperCase() == requiredRole!.toUpperCase();
      }

      // Check if user has any of the allowed roles
      if (allowedRoles != null) {
        return allowedRoles!.any(
          (role) => userRole.toUpperCase() == role.toUpperCase(),
        );
      }

      return false;
    } catch (e) {
      debugPrint('Error checking role access: $e');
      return false;
    }
  }
}

/// Widget that shows/hides based on feature permission
class FeatureBasedWidget extends StatelessWidget {
  final String feature;
  final Widget child;
  final Widget? fallback;

  const FeatureBasedWidget({
    super.key,
    required this.feature,
    required this.child,
    this.fallback,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _checkFeatureAccess(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox.shrink();
        }

        final hasAccess = snapshot.data ?? false;

        if (hasAccess) {
          return child;
        } else {
          return fallback ?? const SizedBox.shrink();
        }
      },
    );
  }

  Future<bool> _checkFeatureAccess() async {
    try {
      final authService = FirebaseAuthService();
      final user = await authService.currentUser();

      if (user == null) return false;

      return RolePermissions.canAccessFeature(user.role, feature);
    } catch (e) {
      debugPrint('Error checking feature access: $e');
      return false;
    }
  }
}
