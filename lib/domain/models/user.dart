class User {
  final String id;
  final String name;
  final String email;
  final String role;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
  });

  factory User.fromMap(Map<String, dynamic> data) {
    return User(
      id: data['id'] ?? '',
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      role: data['role'] ?? '',
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'email': email,
        'role': role,
      };
}
