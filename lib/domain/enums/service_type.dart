/// Available wellness screening services
enum ServiceType {
  breastScreening,
  dentalScreening,
  eyeTest,
  hct,
  hivTest,
  hra,
  papSmear,
  psychologicalAssessment,
  postureScreening,
  psa,
  psychologicalScreening,
  tbTest,
}

extension ServiceTypeExtension on ServiceType {
  /// Human-readable display name
  String get displayName {
    switch (this) {
      case ServiceType.breastScreening:
        return 'Breast Screening';
      case ServiceType.dentalScreening:
        return 'Dental Screening';
      case ServiceType.eyeTest:
        return 'Eye Test';
      case ServiceType.hct:
        return 'HCT';
      case ServiceType.hivTest:
        return 'HIV Test';
      case ServiceType.hra:
        return 'HRA';
      case ServiceType.papSmear:
        return 'Pap Smear';
      case ServiceType.psychologicalAssessment:
        return 'Psychological Assessment';
      case ServiceType.postureScreening:
        return 'Posture Screening';
      case ServiceType.psa:
        return 'PSA';
      case ServiceType.psychologicalScreening:
        return 'Psychological Screening';
      case ServiceType.tbTest:
        return 'TB Test';
    }
  }

  /// Parse from string (for database/API compatibility)
  static ServiceType? fromString(String value) {
    try {
      return ServiceType.values.firstWhere(
        (type) => type.displayName == value,
      );
    } catch (_) {
      return null;
    }
  }

  /// Get all display names as a list
  static List<String> get allDisplayNames {
    return ServiceType.values.map((e) => e.displayName).toList();
  }
}

/// Helper to convert between enum sets and comma-separated strings
class ServiceTypeConverter {
  /// Convert Set<ServiceType> to comma-separated string
  static String toStorageString(Set<ServiceType> services) {
    if (services.isEmpty) return '';
    return services.map((s) => s.displayName).join(', ');
  }

  /// Convert comma-separated string to Set<ServiceType>
  static Set<ServiceType> fromStorageString(String value) {
    if (value.isEmpty) return {};

    final parsed = value
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .map((s) => ServiceTypeExtension.fromString(s))
        .whereType<ServiceType>()
        .toSet();

    return parsed;
  }
}
