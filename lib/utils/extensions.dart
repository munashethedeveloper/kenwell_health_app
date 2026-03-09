extension StringExtensions on String {
  bool get isEmail {
    final regex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return regex.hasMatch(this);
  }

  String capitalize() {
    if (isEmpty) return this;
    return this[0].toUpperCase() + substring(1);
  }
}

extension TimeOfDayFormatting on TimeOfDay {
  /// Returns a zero-padded 24-hour string, e.g. "09:05" or "14:30".
  String toHHmm() =>
      '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
}
