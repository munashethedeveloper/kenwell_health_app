import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

/// Application-wide logger.
///
/// ## Crashlytics integration
/// | Build    | info/warning            | error                              |
/// |----------|-------------------------|------------------------------------|
/// | debug    | console + breadcrumb    | console + breadcrumb               |
/// | release  | (silent)                | non-fatal Crashlytics event        |
///
/// Breadcrumbs appear in the Crashlytics "Logs" section of each crash report,
/// giving developers a trail of what happened before a crash even in debug.
class AppLogger {
  static void info(String message) {
    debugPrint('ℹ️ INFO: $message');
    if (kDebugMode) {
      FirebaseCrashlytics.instance.log('INFO: $message');
    }
  }

  static void warning(String message) {
    debugPrint('⚠️ WARNING: $message');
    if (kDebugMode) {
      FirebaseCrashlytics.instance.log('WARNING: $message');
    }
  }

  /// Logs an error message.
  ///
  /// - **Debug**: prints to console + adds a Crashlytics breadcrumb.
  /// - **Release**: records as a *non-fatal* Crashlytics event so it appears
  ///   in the Firebase console without counting as a crash.
  static void error(String message, [Object? error, StackTrace? stackTrace]) {
    debugPrint('❌ ERROR: $message');
    if (error != null) debugPrint('  Details: $error');
    if (stackTrace != null && kDebugMode) {
      debugPrintStack(stackTrace: stackTrace);
    }
    if (!kDebugMode) {
      // Record as a non-fatal issue in production.
      FirebaseCrashlytics.instance.recordError(
        error ?? message,
        stackTrace,
        reason: message,
        fatal: false,
      );
    } else {
      // In debug mode add a breadcrumb-style log entry.
      FirebaseCrashlytics.instance
          .log('ERROR: $message${error != null ? ' | $error' : ''}');
    }
  }
}
