import 'package:flutter/services.dart';

/// Centralised input formatter helpers used throughout the app to keep
/// validation logic consistent at the widget level.
class AppTextInputFormatters {
  const AppTextInputFormatters._();

  /// Restricts input to numeric characters.
  ///
  /// [allowDecimal] permits a decimal separator (.) when true.
  static List<TextInputFormatter> numbersOnly({bool allowDecimal = false}) {
    final buffer = StringBuffer(r'[0-9');
    if (allowDecimal) {
      buffer.write(r'\.');
    }
    buffer.write(']');
    return [FilteringTextInputFormatter.allow(RegExp(buffer.toString()))];
  }

  /// Restricts input to alphabetic characters and whitespace.
  ///
  /// [allowHyphen] permits the "-" character (useful for double-barrel names).
  static List<TextInputFormatter> lettersOnly({bool allowHyphen = false}) {
    final buffer = StringBuffer(r'[a-zA-Z\s');
    if (allowHyphen) {
      buffer.write(r'\-');
    }
    buffer.write(']');
    return [FilteringTextInputFormatter.allow(RegExp(buffer.toString()))];
  }
}
