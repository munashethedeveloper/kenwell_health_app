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

  // Cache lowercase province names for efficient matching
  // Using late final for lazy initialization - only computed when match() is first called
  static late final List<String> _lowerCaseProvinces = 
      all.map((p) => p.toLowerCase()).toList();

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
    for (int i = 0; i < all.length; i++) {
      if (_lowerCaseProvinces[i] == lowerProvinceName) {
        return all[i];
      }
    }
    
    // Try to find province that contains the input (more specific match)
    for (int i = 0; i < all.length; i++) {
      if (_lowerCaseProvinces[i].contains(lowerProvinceName)) {
        return all[i];
      }
    }
    
    // Try to find input that contains province name (less specific)
    // This handles cases like "North West Province" matching "North West"
    for (int i = 0; i < all.length; i++) {
      if (lowerProvinceName.contains(_lowerCaseProvinces[i])) {
        return all[i];
      }
    }
    
    return null;
  }
}
