// Example: Enhanced Settings Screen with Permission Dialogs
// This is a reference implementation showing how to integrate permission dialogs

import 'package:flutter/material.dart';
import 'package:kenwell_health_app/providers/theme_provider.dart';
import 'package:kenwell_health_app/ui/shared/ui/buttons/custom_primary_button.dart';
import 'package:kenwell_health_app/ui/shared/ui/colours/kenwell_colours.dart';
import 'package:kenwell_health_app/ui/shared/ui/dialogs/permission_dialog.dart';
import 'package:kenwell_health_app/ui/shared/ui/snackbars/app_snackbar.dart';
import 'package:provider/provider.dart';
import '../../../shared/ui/app_bar/kenwell_app_bar.dart';
import '../../../shared/ui/form/kenwell_form_card.dart';
import '../view_model/settings_view_model.dart';

/// Example implementation showing permission dialog integration
/// 
/// Note: This is a reference example. To use in production:
/// 1. Add permission_handler package to pubspec.yaml
/// 2. Configure platform permissions in AndroidManifest.xml and Info.plist
/// 3. Create PermissionHelper utility class for system permissions
class SettingsScreenWithPermissions extends StatelessWidget {
  const SettingsScreenWithPermissions({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => SettingsViewModel(
        initialDarkMode: context.read<ThemeProvider>().isDarkMode,
      ),
      child: Scaffold(
        appBar: const KenwellAppBar(
          title: 'Settings',
          automaticallyImplyLeading: false,
        ),
        body: Consumer2<SettingsViewModel, ThemeProvider>(
          builder: (context, viewModel, themeProvider, _) {
            final colorScheme = Theme.of(context).colorScheme;
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Dark Mode Toggle (no permission needed)
                KenwellFormCard(
                  margin: EdgeInsets.zero,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  child: SwitchListTile.adaptive(
                    title: const Text('Dark Mode'),
                    subtitle: Text(
                      themeProvider.isDarkMode
                          ? 'Using Kenwell Dark theme'
                          : 'Using Kenwell Light theme',
                    ),
                    secondary: Icon(
                      themeProvider.isDarkMode
                          ? Icons.dark_mode
                          : Icons.light_mode,
                      color: colorScheme.secondary,
                    ),
                    value: themeProvider.isDarkMode,
                    onChanged: (value) {
                      themeProvider.toggleDarkMode(value);
                      viewModel.toggleDarkMode(value);
                    },
                  ),
                ),
                const SizedBox(height: 12),

                // Notification Toggle with Permission Dialog
                KenwellFormCard(
                  margin: EdgeInsets.zero,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  child: SwitchListTile(
                    title: const Text('Enable Notifications'),
                    subtitle: Text(
                      viewModel.notificationsEnabled
                          ? 'Receive event reminders'
                          : 'No notifications',
                    ),
                    value: viewModel.notificationsEnabled,
                    onChanged: (value) async {
                      await _handleNotificationToggle(
                        context,
                        viewModel,
                        value,
                      );
                    },
                  ),
                ),
                const SizedBox(height: 12),

                // Language Selection (no permission needed)
                KenwellFormCard(
                  margin: EdgeInsets.zero,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  child: ListTile(
                    title: const Text('Language'),
                    trailing: DropdownButton<String>(
                      value: viewModel.language,
                      items: const [
                        DropdownMenuItem(
                            value: 'English', child: Text('English')),
                        DropdownMenuItem(value: 'Zulu', child: Text('Zulu')),
                        DropdownMenuItem(
                            value: 'Afrikaans', child: Text('Afrikaans')),
                      ],
                      onChanged: (value) {
                        if (value != null) viewModel.changeLanguage(value);
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Save Settings Button
                CustomPrimaryButton(
                  backgroundColor: KenwellColors.primaryGreen,
                  label: 'Save Settings',
                  onPressed: () async {
                    await viewModel.saveSettings();
                    if (!context.mounted) return;
                    AppSnackbar.showSuccess(
                      context,
                      'Settings saved · ${themeProvider.isDarkMode ? 'Dark' : 'Light'} mode active',
                    );
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  /// Handle notification toggle with permission dialog
  Future<void> _handleNotificationToggle(
    BuildContext context,
    SettingsViewModel viewModel,
    bool value,
  ) async {
    if (value) {
      // User wants to enable notifications
      // Step 1: Show custom permission dialog explaining benefits
      final userAgreed = await CommonPermissions.requestNotification(context);

      if (!userAgreed) {
        // User declined in custom dialog
        AppSnackbar.showInfo(
          context,
          'Notifications will remain disabled',
        );
        return;
      }

      // Step 2: Request system permission
      // Note: In production, use permission_handler package
      final systemGranted = await _requestSystemNotificationPermission();

      if (systemGranted) {
        // Permission granted, enable notifications
        viewModel.toggleNotifications(true);
        AppSnackbar.showSuccess(
          context,
          'Notifications enabled successfully',
        );
      } else {
        // System permission denied
        // Check if permanently denied
        final permanentlyDenied = await _isPermissionPermanentlyDenied();

        if (permanentlyDenied) {
          // Show rationale and guide to settings
          await CommonPermissions.showNotificationRationale(
            context,
            onOpenSettings: () async {
              // Open app settings
              await _openAppSettings();
            },
          );
        } else {
          AppSnackbar.showInfo(
            context,
            'Notification permission denied',
          );
        }
      }
    } else {
      // User wants to disable notifications
      viewModel.toggleNotifications(false);
      AppSnackbar.showInfo(context, 'Notifications disabled');
    }
  }

  /// Mock implementation - replace with permission_handler package
  Future<bool> _requestSystemNotificationPermission() async {
    // TODO: Implement using permission_handler package
    // Example:
    // final status = await Permission.notification.request();
    // return status.isGranted;
    
    // For now, simulate user granting permission
    await Future.delayed(const Duration(milliseconds: 500));
    return true; // Mock response
  }

  /// Mock implementation - replace with permission_handler package
  Future<bool> _isPermissionPermanentlyDenied() async {
    // TODO: Implement using permission_handler package
    // Example:
    // final status = await Permission.notification.status;
    // return status.isPermanentlyDenied;
    
    return false; // Mock response
  }

  /// Mock implementation - replace with app_settings package
  Future<void> _openAppSettings() async {
    // TODO: Implement using app_settings or permission_handler package
    // Example:
    // await AppSettings.openAppSettings();
    
    debugPrint('Opening app settings...');
  }
}
