import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

/// Handles Firebase Cloud Messaging initialisation, FCM token management,
/// and foreground/background notification callbacks.
///
/// ### Integration
/// Call [PushNotificationService.instance.initialize] once, after Firebase is
/// initialised (in [main]), to set up all notification handlers:
///
/// ```dart
/// await PushNotificationService.instance.initialize();
/// ```
///
/// The service automatically:
/// 1. Requests notification permission (iOS / Android 13+).
/// 2. Retrieves the FCM token and stores it in the current user's Firestore
///    document under the `fcmTokens` array.
/// 3. Refreshes the token when it rotates.
/// 4. Logs foreground messages via [debugPrint] (extend to show in-app
///    banners as needed).
class PushNotificationService {
  PushNotificationService._();

  static final PushNotificationService instance = PushNotificationService._();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  StreamSubscription<String>? _tokenRefreshSub;

  /// Initialises the push notification pipeline.
  /// Safe to call multiple times; subsequent calls are no-ops.
  Future<void> initialize() async {
    // Skip on web — FCM web requires a service worker not configured here.
    if (kIsWeb) return;

    // 1. Request permission (required on iOS; advisory on Android 13+).
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    debugPrint(
        'PushNotifications: permission = ${settings.authorizationStatus}');
    if (settings.authorizationStatus == AuthorizationStatus.denied) return;

    // 2. Save initial token.
    final token = await _messaging.getToken();
    if (token != null) await _saveToken(token);

    // 3. Refresh token when it rotates.
    _tokenRefreshSub?.cancel();
    _tokenRefreshSub = _messaging.onTokenRefresh.listen(_saveToken);

    // 4. Handle foreground messages.
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // 5. Handle tap on notification that opened the app from background.
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);

    // 6. Check whether the app was launched from a terminated-state notification.
    final initial = await _messaging.getInitialMessage();
    if (initial != null) _handleNotificationTap(initial);
  }

  /// Disposes the token-refresh listener.  Call in [dispose] of long-lived
  /// objects that own this service.
  void dispose() {
    _tokenRefreshSub?.cancel();
  }

  // ── Private helpers ───────────────────────────────────────────────────────

  Future<void> _saveToken(String token) async {
    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) return;

      // Store token in an array so multiple devices are supported per user.
      await _firestore.collection('users').doc(uid).set(
        {
          'fcmTokens': FieldValue.arrayUnion([token]),
          'fcmTokenUpdatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
      debugPrint('PushNotifications: FCM token saved for $uid');
    } catch (e) {
      debugPrint('PushNotifications: failed to save token – $e');
    }
  }

  void _handleForegroundMessage(RemoteMessage message) {
    debugPrint(
      'PushNotifications: foreground message received — '
      '${message.notification?.title}: ${message.notification?.body}',
    );
    // TODO(future): show an in-app banner using a SnackBar or overlay.
  }

  void _handleNotificationTap(RemoteMessage message) {
    debugPrint(
      'PushNotifications: notification tapped — '
      '${message.notification?.title}: ${message.data}',
    );
    // TODO(future): navigate to the relevant event/screen based on message.data.
  }
}
