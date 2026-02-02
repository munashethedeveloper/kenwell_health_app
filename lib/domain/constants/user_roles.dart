/// User roles enum
enum UserRole {
  admin('ADMIN'),
  management('MANAGEMENT'),
  coordinator('COORDINATOR'),
  dataCapturer('DATA CAPTURER'),
  nurse('NURSE'),
  client('CLIENT');

  final String value;
  const UserRole(this.value);

  static UserRole? fromString(String? role) {
    if (role == null) return null;
    final normalized = role.trim().toUpperCase();
    return UserRole.values.firstWhere(
      (e) => e.value == normalized,
      orElse: () => UserRole.client,
    );
  }

  static String normalize(String? role) {
    final normalized = (role ?? '').trim().toUpperCase();
    return normalized;
  }

  static String? ifValid(String? role) {
    final normalized = normalize(role);
    return UserRole.values.any((e) => e.value == normalized) ? normalized : null;
  }
}

/// Legacy UserRoles class for backward compatibility
/// @deprecated Use UserRole enum instead
class UserRoles {
  const UserRoles._();

  static List<String> get values => UserRole.values.map((e) => e.value).toList();

  static String normalize(String? role) => UserRole.normalize(role);

  static String? ifValid(String? role) => UserRole.ifValid(role);
}
