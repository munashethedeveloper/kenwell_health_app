import 'package:flutter/services.dart';

/// Centralised input formatter helpers used throughout the app
/// to keep validation logic consistent at the widget level.
class AppTextInputFormatters {
  const AppTextInputFormatters._();

  /// Restricts input to numeric characters.
  /// [allowDecimal] permits a decimal separator (.) when true.
  static List<TextInputFormatter> numbersOnly({bool allowDecimal = false}) {
    final buffer = StringBuffer(r'[0-9');
    if (allowDecimal) buffer.write(r'\.');
    buffer.write(']');
    return [FilteringTextInputFormatter.allow(RegExp(buffer.toString()))];
  }

  /// Restricts input to alphabetic characters and whitespace.
  /// [allowHyphen] permits "-" for double-barrel names.
  static List<TextInputFormatter> lettersOnly({bool allowHyphen = false}) {
    final buffer = StringBuffer(r'[a-zA-Z\s');
    if (allowHyphen) buffer.write(r'\-');
    buffer.write(']');
    return [FilteringTextInputFormatter.allow(RegExp(buffer.toString()))];
  }

  /// Live format South African phone numbers.
  /// Converts:
  /// - 0XXXXXXXXX -> +27 XX XXX XXXX
  static TextInputFormatter saPhoneNumberFormatter() {
    return TextInputFormatter.withFunction((oldValue, newValue) {
      String text = newValue.text.replaceAll(RegExp(r'\D'), '');

      if (text.startsWith('0')) text = '27' + text.substring(1);

      if (text.startsWith('27')) {
        String formatted = '+27 ';
        if (text.length > 2)
          formatted += text.substring(2, text.length >= 4 ? 4 : text.length);
        if (text.length >= 5)
          formatted +=
              ' ${text.substring(4, text.length >= 7 ? 7 : text.length)}';
        if (text.length >= 8)
          formatted +=
              ' ${text.substring(7, text.length >= 11 ? 11 : text.length)}';
        text = formatted;
      }

      return TextEditingValue(
        text: text,
        selection: TextSelection.collapsed(offset: text.length),
      );
    });
  }
}
