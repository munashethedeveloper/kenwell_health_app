/// South African provinces
class SouthAfricanProvinces {
  static const List<String> all = [
    'Gauteng',
    'Western Cape',
    'KwaZulu-Natal',
    'Eastern Cape',
    'Limpopo',
    'Mpumalanga',
    'North West',
    'Free State',
    'Northern Cape',
  ];

  /// Check if a province name is valid
  static bool isValid(String province) {
    return all.contains(province);
  }

  /// Try to match a province name (case-insensitive partial match)
  /// Returns the matched province from the list or null if no match found
  static String? match(String provinceName) {
    if (provinceName.isEmpty) return null;
    
    final lowerProvinceName = provinceName.toLowerCase();
    
    // Try exact match first (case-insensitive)
    for (final province in all) {
      if (province.toLowerCase() == lowerProvinceName) {
        return province;
      }
    }
    
    // Try to find province that contains the input (more specific match)
    for (final province in all) {
      if (province.toLowerCase().contains(lowerProvinceName)) {
        return province;
      }
    }
    
    // Try to find input that contains province name (less specific)
    // This handles cases like "North West Province" matching "North West"
    for (final province in all) {
      if (lowerProvinceName.contains(province.toLowerCase())) {
        return province;
      }
    }
    
    return null;
  }
}
