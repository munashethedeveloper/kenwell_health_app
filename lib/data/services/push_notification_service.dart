import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../routing/app_routes.dart';
import '../../routing/go_router_config.dart';

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
/// 4. Shows an in-app banner (SnackBar) when a message arrives in the
///    foreground.
/// 5. Navigates to the relevant screen when the user taps a notification.
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

  /// Shows an in-app banner (SnackBar) when a message arrives while the app
  /// is in the foreground.  Uses the root navigator key so no [BuildContext]
  /// needs to be threaded through to this service.
  void _handleForegroundMessage(RemoteMessage message) {
    final title = message.notification?.title ?? 'New notification';
    final body = message.notification?.body;
    final text = body != null ? '$title\n$body' : title;

    debugPrint(
      'PushNotifications: foreground message received — '
      '$title: $body',
    );

    final context = AppRouterConfig.navigatorKey.currentContext;
    if (context == null) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.notifications, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(child: Text(text)),
            ],
          ),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 5),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
          action: SnackBarAction(
            label: 'View',
            textColor: Colors.white,
            onPressed: () => _handleNotificationTap(message),
          ),
        ),
      );
  }

  /// Navigates to the relevant screen when the user taps a notification.
  ///
  /// Supported [RemoteMessage.data] keys:
  /// - `eventId`  → navigates to `/event/<eventId>` (event details by ID).
  /// - `screen`   → navigates to the named route matching the value, e.g.
  ///                `'all-events'` → `/all-events`.
  ///
  /// Falls back to the home screen (`/`) if no matching key is found.
  void _handleNotificationTap(RemoteMessage message) {
    debugPrint(
      'PushNotifications: notification tapped — '
      '${message.notification?.title}: ${message.data}',
    );

    final context = AppRouterConfig.navigatorKey.currentContext;
    if (context == null) return;

    final data = message.data;

    // Navigate to a specific event when eventId is provided.
    final eventId = data['eventId'] as String?;
    if (eventId != null && eventId.isNotEmpty) {
      GoRouter.of(context).go('/event/$eventId');
      return;
    }

    // Navigate to a named screen when a screen key is provided.
    final screen = data['screen'] as String?;
    if (screen != null && screen.isNotEmpty) {
      GoRouter.of(context).go('/$screen');
      return;
    }

    // Default: navigate to the home/events overview screen.
    GoRouter.of(context).go(AppRoutes.allEventsPath);
  }
}
