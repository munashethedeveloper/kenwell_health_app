import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Utility class for handling logout functionality across the app
class LogoutHelper {
  const LogoutHelper._();

  /// Shows confirmation dialog and performs logout if confirmed
  static Future<bool> confirmAndLogout(
    BuildContext context, {
    required Future<void> Function() onLogout,
    required void Function() onComplete,
  }) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        icon: const Icon(Icons.logout, color: Colors.orange),
        actions: [
          TextButton(
            onPressed: () => context.pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => context.pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.orange,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirmed != true) return false;

    await onLogout();

    if (!context.mounted) return true;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Successfully logged out'),
        duration: Duration(seconds: 2),
      ),
    );

    onComplete();
    return true;
  }
}
