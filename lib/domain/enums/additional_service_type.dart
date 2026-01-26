/// Additional wellness event services
enum AdditionalServiceType {
  massageTherapy,
  pediatricCare,
  smoothieBar,
  eventSetupAssistance,
  eventManagement,
}

extension AdditionalServiceTypeExtension on AdditionalServiceType {
  /// Human-readable display name
  String get displayName {
    switch (this) {
      case AdditionalServiceType.massageTherapy:
        return 'Massage Therapy';
      case AdditionalServiceType.pediatricCare:
        return 'Pediatric Care';
      case AdditionalServiceType.smoothieBar:
        return 'Smoothie Bar';
      case AdditionalServiceType.eventSetupAssistance:
        return 'Event Setup Assistance';
      case AdditionalServiceType.eventManagement:
        return 'Event Management';
    }
  }

  /// Parse from string (for database/API compatibility)
  static AdditionalServiceType? fromString(String value) {
    try {
      return AdditionalServiceType.values.firstWhere(
        (type) => type.displayName == value,
      );
    } catch (_) {
      return null;
    }
  }

  /// Get all display names as a list
  static List<String> get allDisplayNames {
    return AdditionalServiceType.values.map((e) => e.displayName).toList();
  }
}

/// Helper to convert between enum sets and comma-separated strings
class AdditionalServiceTypeConverter {
  /// Convert Set<AdditionalServiceType> to comma-separated string
  static String toStorageString(Set<AdditionalServiceType> services) {
    if (services.isEmpty) return '';
    return services.map((s) => s.displayName).join(', ');
  }

  /// Convert comma-separated string to Set<AdditionalServiceType>
  static Set<AdditionalServiceType> fromStorageString(String value) {
    if (value.isEmpty) return {};

    final parsed = value
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .map((s) => AdditionalServiceTypeExtension.fromString(s))
        .whereType<AdditionalServiceType>()
        .toSet();

    return parsed;
  }
}
