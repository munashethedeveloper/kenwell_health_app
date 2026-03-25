import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

class AppLogger {
  static void info(String message) {
    if (kDebugMode) debugPrint('ℹ️ INFO: $message');
  }

  /// Logs an error message and, in non-debug builds, records it as a
  /// *non-fatal* Crashlytics event so it appears in the Firebase console
  /// without counting as a crash.
  static void error(String message, [Object? error, StackTrace? stackTrace]) {
    debugPrint('❌ ERROR: $message');
    if (error != null) debugPrint('  Details: $error');
    if (stackTrace != null && kDebugMode) {
      debugPrintStack(stackTrace: stackTrace);
    }
    // Record as a non-fatal issue in production so the team can track it.
    if (!kDebugMode) {
      FirebaseCrashlytics.instance.recordError(
        error ?? message,
        stackTrace,
        reason: message,
        fatal: false,
      );
    } else {
      // In debug mode just add a breadcrumb-style log entry.
      FirebaseCrashlytics.instance.log('ERROR: $message');
    }
  }

  static void warning(String message) {
    if (kDebugMode) debugPrint('⚠️ WARNING: $message');
  }
}
