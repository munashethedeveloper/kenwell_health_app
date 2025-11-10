import 'package:flutter/foundation.dart';

class AppLogger {
  static void info(String message) {
    if (kDebugMode) debugPrint('ℹ️ INFO: $message');
  }

  static void error(String message, [Object? error]) {
    debugPrint('❌ ERROR: $message');
    if (error != null) debugPrint('Details: $error');
  }
}
