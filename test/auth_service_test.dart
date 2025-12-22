import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:kenwell_health_app/data/local/app_database.dart';
import 'package:kenwell_health_app/data/services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('AuthService', () {
    late AuthService authService;
    late AppDatabase database;

    setUp(() async {
      // Set up in-memory database for testing
      database = AppDatabase.forTesting(NativeDatabase.memory());
      
      // Initialize SharedPreferences with empty data
      SharedPreferences.setMockInitialValues({});
      final prefs = SharedPreferences.getInstance();
      
      authService = AuthService(
        database: database,
        preferences: prefs,
      );
    });

    tearDown(() async {
      await database.close();
    });

    test('register creates a new user and stores it in database', () async {
      // Act: Register a new user
      final user = await authService.register(
        email: 'test@example.com',
        password: 'Test@1234',
        role: 'Admin',
        phoneNumber: '0123456789',
        firstName: 'John',
        lastName: 'Doe',
      );

      // Assert: User was created successfully
      expect(user, isNotNull);
      expect(user!.email, 'test@example.com');
      expect(user.firstName, 'John');
      expect(user.lastName, 'Doe');
      expect(user.role, 'Admin');
      expect(user.phoneNumber, '0123456789');
    });

    test('getAllUsers returns all registered users', () async {
      // Arrange: Register multiple users
      await authService.register(
        email: 'user1@example.com',
        password: 'Pass@1234',
        role: 'Admin',
        phoneNumber: '0111111111',
        firstName: 'User',
        lastName: 'One',
      );

      await authService.register(
        email: 'user2@example.com',
        password: 'Pass@5678',
        role: 'Coordinator',
        phoneNumber: '0222222222',
        firstName: 'User',
        lastName: 'Two',
      );

      // Act: Get all users
      final users = await authService.getAllUsers();

      // Assert: Both users are returned
      expect(users.length, 2);
      expect(users[0].email, 'user1@example.com');
      expect(users[1].email, 'user2@example.com');
    });

    test('getAllUsers returns empty list when no users exist', () async {
      // Act: Get all users from empty database
      final users = await authService.getAllUsers();

      // Assert: Empty list is returned
      expect(users, isEmpty);
    });

    test('register returns null when email already exists', () async {
      // Arrange: Register first user
      await authService.register(
        email: 'duplicate@example.com',
        password: 'Pass@1234',
        role: 'Admin',
        phoneNumber: '0123456789',
        firstName: 'First',
        lastName: 'User',
      );

      // Act: Try to register second user with same email
      final duplicateUser = await authService.register(
        email: 'duplicate@example.com',
        password: 'Pass@5678',
        role: 'Coordinator',
        phoneNumber: '0987654321',
        firstName: 'Second',
        lastName: 'User',
      );

      // Assert: Registration should fail
      expect(duplicateUser, isNull);
    });

    test('login returns user when credentials are correct', () async {
      // Arrange: Register a user
      await authService.register(
        email: 'login@example.com',
        password: 'Pass@1234',
        role: 'Admin',
        phoneNumber: '0123456789',
        firstName: 'Login',
        lastName: 'Test',
      );

      // Act: Login with correct credentials
      final user = await authService.login('login@example.com', 'Pass@1234');

      // Assert: User is returned
      expect(user, isNotNull);
      expect(user!.email, 'login@example.com');
    });

    test('login returns null when credentials are incorrect', () async {
      // Arrange: Register a user
      await authService.register(
        email: 'login@example.com',
        password: 'Pass@1234',
        role: 'Admin',
        phoneNumber: '0123456789',
        firstName: 'Login',
        lastName: 'Test',
      );

      // Act: Login with incorrect password
      final user = await authService.login('login@example.com', 'WrongPass');

      // Assert: Login should fail
      expect(user, isNull);
    });
  });
}
