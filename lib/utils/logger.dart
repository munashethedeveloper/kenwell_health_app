import 'package:flutter/foundation.dart';

class AppLogger {
  static void info(String message) {
    if (kDebugMode) debugPrint('ℹ️ INFO: $message');
  }

  /// Logs an error message.  Unlike [info], error messages are printed in
  /// both debug and release builds so that problems remain visible in
  /// platform logs (Logcat / Xcode console) when debugging production issues.
  static void error(String message, [Object? error, StackTrace? stackTrace]) {
    debugPrint('❌ ERROR: $message');
    if (error != null) debugPrint('  Details: $error');
    if (stackTrace != null && kDebugMode) {
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  static void warning(String message) {
    if (kDebugMode) debugPrint('⚠️ WARNING: $message');
  }
}
