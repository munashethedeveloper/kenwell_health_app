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
    
    // Try partial match (case-insensitive)
    for (final province in all) {
      final lowerProvince = province.toLowerCase();
      if (lowerProvince.contains(lowerProvinceName) ||
          lowerProvinceName.contains(lowerProvince)) {
        return province;
      }
    }
    
    return null;
  }
}
