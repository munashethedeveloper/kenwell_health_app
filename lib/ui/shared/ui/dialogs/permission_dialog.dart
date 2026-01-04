import 'package:flutter/material.dart';
import '../buttons/custom_primary_button.dart';
import '../buttons/custom_secondary_button.dart';

/// A Material Design compliant permission dialog that follows best practices
/// for requesting app permissions from users.
///
/// Based on Material Design guidelines:
/// https://material.io/design/platform-guidance/android-permissions.html
class PermissionDialog extends StatelessWidget {
  final String permissionName;
  final String title;
  final String description;
  final String benefit;
  final IconData icon;
  final VoidCallback onAllow;
  final VoidCallback? onDeny;
  final String allowText;
  final String denyText;

  const PermissionDialog({
    super.key,
    required this.permissionName,
    required this.title,
    required this.description,
    required this.benefit,
    required this.icon,
    required this.onAllow,
    this.onDeny,
    this.allowText = 'Allow',
    this.denyText = 'Deny',
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      icon: Icon(icon, size: 48, color: Theme.of(context).primaryColor),
      title: Text(title, textAlign: TextAlign.center),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            description,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.lightbulb_outline,
                  color: Theme.of(context).primaryColor,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    benefit,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        CustomSecondaryButton(
          label: denyText,
          minHeight: 40,
          fullWidth: false,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          onPressed: () {
            Navigator.of(context).pop(false);
            onDeny?.call();
          },
        ),
        CustomPrimaryButton(
          label: allowText,
          minHeight: 40,
          fullWidth: false,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          onPressed: () {
            Navigator.of(context).pop(true);
            onAllow();
          },
        ),
      ],
    );
  }

  /// Shows a permission dialog following Material Design guidelines
  ///
  /// Returns true if permission is granted, false if denied
  static Future<bool> show(
    BuildContext context, {
    required String permissionName,
    required String title,
    required String description,
    required String benefit,
    required IconData icon,
    String allowText = 'Allow',
    String denyText = 'Deny',
  }) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false, // User must explicitly choose
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          icon: Icon(icon, size: 48, color: Theme.of(context).primaryColor),
          title: Text(title, textAlign: TextAlign.center),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                description,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.lightbulb_outline,
                      color: Theme.of(context).primaryColor,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        benefit,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            CustomSecondaryButton(
              label: denyText,
              minHeight: 40,
              fullWidth: false,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              onPressed: () => Navigator.of(dialogContext).pop(false),
            ),
            CustomPrimaryButton(
              label: allowText,
              minHeight: 40,
              fullWidth: false,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              onPressed: () => Navigator.of(dialogContext).pop(true),
            ),
          ],
        );
      },
    );
    return result ?? false;
  }

  /// Shows a rationale dialog when permission was previously denied
  ///
  /// This explains why the permission is needed and guides user to settings
  static Future<void> showRationale(
    BuildContext context, {
    required String permissionName,
    required String title,
    required String message,
    required IconData icon,
    VoidCallback? onOpenSettings,
  }) async {
    await showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          icon: Icon(icon, size: 48, color: Colors.orange),
          title: Text(title, textAlign: TextAlign.center),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(message),
              const SizedBox(height: 16),
              Text(
                'You can enable this permission in Settings.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
          actions: [
            CustomSecondaryButton(
              label: 'Not Now',
              minHeight: 40,
              fullWidth: false,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
            if (onOpenSettings != null)
              CustomPrimaryButton(
                label: 'Open Settings',
                minHeight: 40,
                fullWidth: false,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                  onOpenSettings();
                },
              ),
          ],
        );
      },
    );
  }
}

/// Helper class to manage common permission types with pre-defined messages
class CommonPermissions {
  /// Notification permission
  static Future<bool> requestNotification(BuildContext context) async {
    return await PermissionDialog.show(
      context,
      permissionName: 'Notification',
      title: 'Enable Notifications?',
      description:
          'Get timely reminders about upcoming wellness events and health screenings.',
      benefit:
          'Never miss an important health check or wellness event with push notifications.',
      icon: Icons.notifications_active,
    );
  }

  /// Storage permission (for saving signatures, documents)
  static Future<bool> requestStorage(BuildContext context) async {
    return await PermissionDialog.show(
      context,
      permissionName: 'Storage',
      title: 'Access Storage?',
      description:
          'Save signatures and health documents securely on your device.',
      benefit:
          'Keep your health records safe and accessible offline with local storage.',
      icon: Icons.folder_open,
    );
  }

  /// Camera permission (for scanning documents, profile photos)
  static Future<bool> requestCamera(BuildContext context) async {
    return await PermissionDialog.show(
      context,
      permissionName: 'Camera',
      title: 'Use Camera?',
      description:
          'Take photos for your profile or scan health-related documents.',
      benefit:
          'Quickly capture and attach documents or update your profile picture.',
      icon: Icons.camera_alt,
    );
  }

  /// Location permission (for finding nearby events)
  static Future<bool> requestLocation(BuildContext context) async {
    return await PermissionDialog.show(
      context,
      permissionName: 'Location',
      title: 'Access Location?',
      description:
          'Find wellness events and health services near you for easier access.',
      benefit:
          'Discover nearby wellness events and get directions to event venues.',
      icon: Icons.location_on,
    );
  }

  /// Show rationale for notification permission
  static Future<void> showNotificationRationale(
    BuildContext context, {
    VoidCallback? onOpenSettings,
  }) async {
    await PermissionDialog.showRationale(
      context,
      permissionName: 'Notification',
      title: 'Notifications Disabled',
      message:
          'To receive reminders about wellness events and health screenings, please enable notifications.',
      icon: Icons.notifications_off,
      onOpenSettings: onOpenSettings,
    );
  }

  /// Show rationale for storage permission
  static Future<void> showStorageRationale(
    BuildContext context, {
    VoidCallback? onOpenSettings,
  }) async {
    await PermissionDialog.showRationale(
      context,
      permissionName: 'Storage',
      title: 'Storage Access Disabled',
      message:
          'To save signatures and health documents, please enable storage access.',
      icon: Icons.folder_off,
      onOpenSettings: onOpenSettings,
    );
  }
}
