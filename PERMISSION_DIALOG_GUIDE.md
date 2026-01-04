# Permission Dialog Integration Guide

## Overview

This guide explains how to integrate Material Design compliant permission dialogs into the Kenwell Health App. Permission dialogs are essential for maintaining user trust and complying with platform guidelines when requesting sensitive permissions.

## Material Design Principles

Permission dialogs should follow these Material Design guidelines:

### 1. **Up-Front Permissions**
Only request permissions when the user takes an action that requires them.
- ❌ **Bad:** Request all permissions on app launch
- ✅ **Good:** Request notification permission when user enables notifications in settings

### 2. **Educate Before Asking**
Explain the benefit before showing the system permission dialog.
- ❌ **Bad:** Show system dialog immediately without context
- ✅ **Good:** Show custom dialog explaining benefits, then show system dialog

### 3. **Clear Value Proposition**
Make it clear what the user gains by granting the permission.
- ❌ **Bad:** "This app needs camera access"
- ✅ **Good:** "Take photos for your profile or scan health documents"

### 4. **Handle Denial Gracefully**
Don't block functionality completely; offer alternatives.
- ❌ **Bad:** Show error and prevent feature use
- ✅ **Good:** Explain impact and offer manual alternatives

---

## Implementation

### Component: PermissionDialog

**Location:** `lib/ui/shared/ui/dialogs/permission_dialog.dart`

The `PermissionDialog` component provides a Material Design compliant dialog for requesting permissions.

#### Features:
- Large icon for visual recognition
- Clear title and description
- Benefit explanation with highlighted box
- Allow/Deny buttons with proper styling
- Non-dismissible (user must choose)

---

## Common Permission Types

The `CommonPermissions` helper class provides pre-configured dialogs for common permission types:

### 1. Notification Permission

**When to request:**
- When user toggles "Enable Notifications" in Settings
- Before scheduling first notification

**Usage Example:**
```dart
// In settings_screen.dart or notification setup
Future<void> _enableNotifications() async {
  // Show custom permission dialog first
  final granted = await CommonPermissions.requestNotification(context);
  
  if (granted) {
    // Now request system permission
    final systemGranted = await requestSystemNotificationPermission();
    
    if (systemGranted) {
      // Enable notifications
      await settingsViewModel.toggleNotifications(true);
      AppSnackbar.showSuccess(context, 'Notifications enabled');
    } else {
      AppSnackbar.showInfo(context, 'Notification permission denied');
    }
  } else {
    // User declined in custom dialog
    AppSnackbar.showInfo(context, 'Notifications will remain disabled');
  }
}
```

**Implementation in Settings Screen:**
```dart
// lib/ui/features/settings/widgets/settings_screen.dart

import 'package:kenwell_health_app/ui/shared/ui/dialogs/permission_dialog.dart';

// Modify the notification switch
SwitchListTile(
  title: const Text('Enable Notifications'),
  value: viewModel.notificationsEnabled,
  onChanged: (value) async {
    if (value && !viewModel.notificationsEnabled) {
      // Requesting to enable notifications
      final granted = await CommonPermissions.requestNotification(context);
      
      if (granted) {
        // User agreed, now check system permission
        // Add permission_handler package for this
        viewModel.toggleNotifications(value);
        AppSnackbar.showSuccess(context, 'Notifications enabled');
      } else {
        AppSnackbar.showInfo(context, 'Notification permission denied');
      }
    } else {
      // Disabling notifications
      viewModel.toggleNotifications(value);
    }
  },
),
```

---

### 2. Storage Permission

**When to request:**
- Before saving signature to device
- Before exporting health reports
- Before saving documents locally

**Usage Example:**
```dart
// In signature saving logic
Future<void> _saveSignature() async {
  final granted = await CommonPermissions.requestStorage(context);
  
  if (granted) {
    // Request system permission
    final systemGranted = await requestSystemStoragePermission();
    
    if (systemGranted) {
      await saveSignatureToDevice();
      AppSnackbar.showSuccess(context, 'Signature saved');
    } else {
      // Show rationale for denied permission
      await CommonPermissions.showStorageRationale(
        context,
        onOpenSettings: () => openAppSettings(),
      );
    }
  }
}
```

**Implementation in Nursing Intervention Forms:**
```dart
// lib/ui/features/hiv_test_nursing_intervention/widgets/hiv_test_nursing_intervention_screen.dart

import 'package:kenwell_health_app/ui/shared/ui/dialogs/permission_dialog.dart';

Future<void> _exportSignature() async {
  // Show custom permission dialog
  final granted = await CommonPermissions.requestStorage(context);
  
  if (!granted) {
    AppSnackbar.showInfo(context, 'Storage permission required to save signature');
    return;
  }
  
  // Proceed with saving signature
  try {
    await viewModel.saveSignature();
    AppSnackbar.showSuccess(context, 'Signature saved successfully');
  } catch (e) {
    AppSnackbar.showError(context, 'Failed to save signature');
  }
}
```

---

### 3. Camera Permission

**When to request:**
- Before opening camera for profile photo
- Before scanning documents
- Before QR code scanning

**Usage Example:**
```dart
// In profile screen for taking photo
Future<void> _takeProfilePhoto() async {
  final granted = await CommonPermissions.requestCamera(context);
  
  if (granted) {
    // Request system permission
    final systemGranted = await requestSystemCameraPermission();
    
    if (systemGranted) {
      final image = await ImagePicker().pickImage(source: ImageSource.camera);
      if (image != null) {
        await uploadProfilePhoto(image);
        AppSnackbar.showSuccess(context, 'Profile photo updated');
      }
    } else {
      AppSnackbar.showWarning(
        context,
        'Camera permission is required to take photos',
      );
    }
  }
}
```

---

### 4. Location Permission

**When to request:**
- Before showing nearby events on map
- Before getting directions to event venue
- Before finding closest health facility

**Usage Example:**
```dart
// In event map view
Future<void> _showNearbyEvents() async {
  final granted = await CommonPermissions.requestLocation(context);
  
  if (granted) {
    final systemGranted = await requestSystemLocationPermission();
    
    if (systemGranted) {
      final location = await getCurrentLocation();
      final nearbyEvents = await findEventsNearLocation(location);
      // Display events
    } else {
      AppSnackbar.showInfo(
        context,
        'Location access needed to show nearby events',
      );
    }
  }
}
```

---

## Custom Permission Dialogs

For app-specific permissions, create custom dialogs:

```dart
Future<bool> _requestCustomPermission() async {
  return await PermissionDialog.show(
    context,
    permissionName: 'Health Data Access',
    title: 'Share Health Data?',
    description: 'Allow sharing your health metrics with your healthcare provider for better care.',
    benefit: 'Your healthcare provider can give personalized recommendations based on your health data.',
    icon: Icons.health_and_safety,
    allowText: 'Share',
    denyText: 'Keep Private',
  );
}
```

---

## Permission Rationale

When permission is denied, show a rationale explaining why it's needed:

```dart
// After permission is denied
if (!permissionGranted) {
  await PermissionDialog.showRationale(
    context,
    permissionName: 'Notifications',
    title: 'Notifications Disabled',
    message: 'To receive reminders about wellness events and health screenings, please enable notifications.',
    icon: Icons.notifications_off,
    onOpenSettings: () {
      // Open app settings
      AppSettings.openAppSettings();
    },
  );
}
```

---

## Best Practices

### ✅ DO:

1. **Request at the right time**
   - When user initiates action requiring permission
   - Not on app launch or first screen

2. **Explain the benefit**
   - Use clear, user-focused language
   - Highlight what user gains

3. **Provide context**
   - Show custom dialog before system dialog
   - Explain why permission is needed

4. **Handle denial gracefully**
   - Offer alternatives
   - Don't show error messages
   - Guide to settings if needed

5. **Remember user choice**
   - Don't ask repeatedly
   - Store denial to avoid spam

### ❌ DON'T:

1. **Request all upfront**
   - Don't ask for permissions on app launch
   - Don't request unnecessary permissions

2. **Use technical jargon**
   - Avoid "The app needs storage access"
   - Use user-friendly language

3. **Block features completely**
   - Provide manual alternatives
   - Degrade gracefully

4. **Show error dialogs**
   - Use info/warning snackbars instead
   - Guide user positively

5. **Spam users**
   - Don't ask repeatedly if denied
   - Respect user's choice

---

## Integration Steps

### Step 1: Add Permission Handler Package

Add to `pubspec.yaml`:
```yaml
dependencies:
  permission_handler: ^11.0.0
```

### Step 2: Configure Platform Permissions

**Android** (`android/app/src/main/AndroidManifest.xml`):
```xml
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.POST_NOTIFICATIONS" />
```

**iOS** (`ios/Runner/Info.plist`):
```xml
<key>NSCameraUsageDescription</key>
<string>Take photos for your profile or scan health documents</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>Save signatures and health documents</string>
<key>NSLocationWhenInUseUsageDescription</key>
<string>Find wellness events near you</string>
```

### Step 3: Create Permission Helper

```dart
// lib/utils/permission_helper.dart

import 'package:permission_handler/permission_handler.dart';

class PermissionHelper {
  static Future<bool> requestNotificationPermission() async {
    final status = await Permission.notification.request();
    return status.isGranted;
  }

  static Future<bool> requestStoragePermission() async {
    final status = await Permission.storage.request();
    return status.isGranted;
  }

  static Future<bool> requestCameraPermission() async {
    final status = await Permission.camera.request();
    return status.isGranted;
  }

  static Future<bool> requestLocationPermission() async {
    final status = await Permission.locationWhenInUse.request();
    return status.isGranted;
  }

  static Future<bool> isPermissionDeniedPermanently(Permission permission) async {
    final status = await permission.status;
    return status.isPermanentlyDenied;
  }

  static Future<void> openAppSettings() async {
    await openAppSettings();
  }
}
```

### Step 4: Implement in Settings Screen

```dart
// lib/ui/features/settings/widgets/settings_screen.dart

import 'package:kenwell_health_app/ui/shared/ui/dialogs/permission_dialog.dart';
import 'package:kenwell_health_app/ui/shared/ui/snackbars/app_snackbar.dart';
import 'package:kenwell_health_app/utils/permission_helper.dart';

// Update notification toggle
SwitchListTile(
  title: const Text('Enable Notifications'),
  value: viewModel.notificationsEnabled,
  onChanged: (value) async {
    if (value) {
      // Show custom permission dialog
      final userAgreed = await CommonPermissions.requestNotification(context);
      
      if (userAgreed) {
        // Request system permission
        final granted = await PermissionHelper.requestNotificationPermission();
        
        if (granted) {
          viewModel.toggleNotifications(true);
          AppSnackbar.showSuccess(context, 'Notifications enabled');
        } else {
          // Check if permanently denied
          final permanentlyDenied = await PermissionHelper.isPermissionDeniedPermanently(
            Permission.notification,
          );
          
          if (permanentlyDenied) {
            await CommonPermissions.showNotificationRationale(
              context,
              onOpenSettings: PermissionHelper.openAppSettings,
            );
          } else {
            AppSnackbar.showInfo(context, 'Notification permission denied');
          }
        }
      }
    } else {
      viewModel.toggleNotifications(false);
      AppSnackbar.showInfo(context, 'Notifications disabled');
    }
  },
),
```

---

## Complete Example: Signature Saving with Permission

```dart
// In nursing intervention form

import 'package:kenwell_health_app/ui/shared/ui/dialogs/permission_dialog.dart';
import 'package:kenwell_health_app/ui/shared/ui/snackbars/app_snackbar.dart';
import 'package:kenwell_health_app/utils/permission_helper.dart';

Future<void> _saveSignatureToDevice() async {
  // Step 1: Show custom permission dialog
  final userAgreed = await CommonPermissions.requestStorage(context);
  
  if (!userAgreed) {
    AppSnackbar.showInfo(context, 'Signature will not be saved to device');
    return;
  }
  
  // Step 2: Request system permission
  final granted = await PermissionHelper.requestStoragePermission();
  
  if (!granted) {
    // Step 3: Check if permanently denied
    final permanentlyDenied = await PermissionHelper.isPermissionDeniedPermanently(
      Permission.storage,
    );
    
    if (permanentlyDenied) {
      // Step 4: Show rationale and guide to settings
      await CommonPermissions.showStorageRationale(
        context,
        onOpenSettings: PermissionHelper.openAppSettings,
      );
    } else {
      AppSnackbar.showWarning(
        context,
        'Storage permission is needed to save signatures',
      );
    }
    return;
  }
  
  // Step 5: Permission granted, proceed with saving
  try {
    await viewModel.exportSignature();
    AppSnackbar.showSuccess(context, 'Signature saved to device');
  } catch (e) {
    AppSnackbar.showError(context, 'Failed to save signature: $e');
  }
}
```

---

## Testing Checklist

- [ ] Permission dialog shows before system dialog
- [ ] Benefit explanation is clear and user-focused
- [ ] Allow button grants permission correctly
- [ ] Deny button doesn't show error
- [ ] Rationale shows after permanent denial
- [ ] Open Settings button works
- [ ] Feature degrades gracefully without permission
- [ ] No spam if user denies multiple times
- [ ] Dialog is not dismissible by tapping outside
- [ ] Icons and colors match app theme

---

## Summary

Permission dialogs are essential for:
1. **Building Trust** - Users understand why permissions are needed
2. **Platform Compliance** - Following Material Design guidelines
3. **Better UX** - Clear communication and graceful degradation
4. **User Control** - Respecting user choices

By implementing these permission dialogs, the Kenwell Health App provides a professional, user-friendly experience that builds trust and complies with platform best practices.

---

**Next Steps:**
1. Add `permission_handler` package
2. Implement notification permission in Settings
3. Add storage permission for signature saving
4. Consider camera/location for future features
5. Test on both Android and iOS devices
