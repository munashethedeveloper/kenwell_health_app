/// Custom exception for when user creation succeeds but password reset email fails
class PasswordResetEmailFailedException implements Exception {
  final String userId;
  final String userEmail;
  final String message;
  final dynamic originalError;

  PasswordResetEmailFailedException({
    required this.userId,
    required this.userEmail,
    required this.message,
    this.originalError,
  });

  @override
  String toString() => 'PasswordResetEmailFailedException: $message';
}