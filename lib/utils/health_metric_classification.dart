import 'package:flutter/material.dart';

/// Risk classification levels for health metrics.
enum HealthMetricStatus { green, orange, red }

extension HealthMetricStatusExtension on HealthMetricStatus {
  Color get color {
    switch (this) {
      case HealthMetricStatus.green:
        return const Color(0xFF2E7D32);
      case HealthMetricStatus.orange:
        return const Color(0xFFF57C00);
      case HealthMetricStatus.red:
        return const Color(0xFFB3261E);
    }
  }

  String get label {
    switch (this) {
      case HealthMetricStatus.green:
        return 'Healthy';
      case HealthMetricStatus.orange:
        return 'Caution';
      case HealthMetricStatus.red:
        return 'Danger – Referral Required';
    }
  }

  IconData get icon {
    switch (this) {
      case HealthMetricStatus.green:
        return Icons.check_circle;
      case HealthMetricStatus.orange:
        return Icons.warning_amber;
      case HealthMetricStatus.red:
        return Icons.dangerous;
    }
  }
}

/// Classifies health metrics into green / orange / red risk levels.
///
/// Thresholds:
/// - Systolic BP : 90–129 green, <90 or 130–159 orange, ≥160 red
/// - Diastolic BP: 60–79  green, <60 or 80–89  orange, ≥90  red
/// - Blood glucose: 3.9–7.79 green, <3.9 or 7.8–10.9 orange, ≥11 red
/// - Cholesterol  : 3.0–5.19 green, <3.0 or 5.2–6.9 orange, ≥7  red
class HealthMetricClassifier {
  const HealthMetricClassifier._();

  /// Blood Pressure Systolic (mmHg)
  static HealthMetricStatus classifySystolic(double value) {
    if (value < 90) return HealthMetricStatus.orange;
    if (value <= 129) return HealthMetricStatus.green;
    if (value <= 159) return HealthMetricStatus.orange;
    return HealthMetricStatus.red;
  }

  /// Blood Pressure Diastolic (mmHg)
  static HealthMetricStatus classifyDiastolic(double value) {
    if (value < 60) return HealthMetricStatus.orange;
    if (value <= 79) return HealthMetricStatus.green;
    if (value <= 89) return HealthMetricStatus.orange;
    return HealthMetricStatus.red;
  }

  /// Blood Glucose / Blood Sugar (mmol/L)
  static HealthMetricStatus classifyBloodGlucose(double value) {
    if (value < 3.9) return HealthMetricStatus.orange;
    if (value < 7.8) return HealthMetricStatus.green;
    if (value < 11.0) return HealthMetricStatus.orange;
    return HealthMetricStatus.red;
  }

  /// Cholesterol (mmol/L)
  static HealthMetricStatus classifyCholesterol(double value) {
    if (value < 3.0) return HealthMetricStatus.orange;
    if (value < 5.2) return HealthMetricStatus.green;
    if (value < 7.0) return HealthMetricStatus.orange;
    return HealthMetricStatus.red;
  }

  /// Parses [value] and applies [classifier]; returns null if the value is
  /// empty or cannot be parsed.
  static HealthMetricStatus? classifyFromString(
    String? value,
    HealthMetricStatus Function(double) classifier,
  ) {
    if (value == null || value.isEmpty) return null;
    final parsed = double.tryParse(value);
    if (parsed == null) return null;
    return classifier(parsed);
  }
}
