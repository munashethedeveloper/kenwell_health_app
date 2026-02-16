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
    
    // Try exact match first
    final exactMatch = all.firstWhere(
      (p) => p.toLowerCase() == provinceName.toLowerCase(),
      orElse: () => '',
    );
    if (exactMatch.isNotEmpty) return exactMatch;
    
    // Try partial match (case-insensitive)
    try {
      return all.firstWhere(
        (p) => p.toLowerCase().contains(provinceName.toLowerCase()) ||
               provinceName.toLowerCase().contains(p.toLowerCase()),
      );
    } catch (e) {
      return null;
    }
  }
}
