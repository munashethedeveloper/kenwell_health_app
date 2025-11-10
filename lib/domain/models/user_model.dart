class UserModel {
  final String id;
  final String email;
  final String role;
  final String phoneNumber;
  final String username;
  final String firstName;
  final String lastName;

  UserModel({
    required this.id,
    required this.email,
    required this.role,
    required this.phoneNumber,
    required this.username,
    required this.firstName,
    required this.lastName,
  });

  factory UserModel.fromMap(Map<String, dynamic> data) {
    return UserModel(
      id: data['id'],
      email: data['email'],
      role: data['role'],
      phoneNumber: data['phoneNumber'],
      username: data['username'],
      firstName: data['firstName'],
      lastName: data['lastName'],
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'email': email,
        'role': role,
        'phoneNumber': phoneNumber,
        'username': username,
        'firstName': firstName,
        'lastName': lastName,
      };
}
