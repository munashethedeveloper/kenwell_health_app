class UserRoles {
  const UserRoles._();

  static const List<String> values = [
    'ADMIN',
    'TOP MANAGEMENT',
    'PROJECT MANAGER',
    'COORDINATOR',
    'NURSE',
    'CLIENT',
  ];

  static String normalize(String? role) {
    final normalized = (role ?? '').trim().toUpperCase();
    return normalized;
  }

  static String? ifValid(String? role) {
    final normalized = normalize(role);
    return values.contains(normalized) ? normalized : null;
  }
}
