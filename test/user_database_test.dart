import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:kenwell_health_app/data/local/app_database.dart';

void main() {
  group('AppDatabase User Operations', () {
    late AppDatabase database;

    setUp(() {
      database = AppDatabase.forTesting(NativeDatabase.memory());
    });

    tearDown(() async {
      await database.close();
    });

    test('createUser inserts user into database', () async {
      // Act: Create a user
      final user = await database.createUser(
        id: 'test-id-1',
        email: 'test@example.com',
        password: 'password123',
        role: 'Admin',
        phoneNumber: '0123456789',
        firstName: 'John',
        lastName: 'Doe',
      );

      // Assert: User was created
      expect(user.id, 'test-id-1');
      expect(user.email, 'test@example.com');
      expect(user.firstName, 'John');
      expect(user.lastName, 'Doe');
    });

    test('getAllUsers returns all users from database', () async {
      // Arrange: Create multiple users
      await database.createUser(
        id: 'user-1',
        email: 'user1@example.com',
        password: 'pass1',
        role: 'Admin',
        phoneNumber: '0111111111',
        firstName: 'User',
        lastName: 'One',
      );

      await database.createUser(
        id: 'user-2',
        email: 'user2@example.com',
        password: 'pass2',
        role: 'Coordinator',
        phoneNumber: '0222222222',
        firstName: 'User',
        lastName: 'Two',
      );

      await database.createUser(
        id: 'user-3',
        email: 'user3@example.com',
        password: 'pass3',
        role: 'Nurse',
        phoneNumber: '0333333333',
        firstName: 'User',
        lastName: 'Three',
      );

      // Act: Get all users
      final users = await database.getAllUsers();

      // Assert: All users are returned
      expect(users.length, 3);
      expect(users[0].email, 'user1@example.com');
      expect(users[1].email, 'user2@example.com');
      expect(users[2].email, 'user3@example.com');
    });

    test('getAllUsers returns empty list when no users exist', () async {
      // Act: Get all users from empty database
      final users = await database.getAllUsers();

      // Assert: Empty list is returned
      expect(users, isEmpty);
    });

    test('getUserByEmail returns correct user', () async {
      // Arrange: Create users
      await database.createUser(
        id: 'user-1',
        email: 'find@example.com',
        password: 'pass1',
        role: 'Admin',
        phoneNumber: '0111111111',
        firstName: 'Find',
        lastName: 'Me',
      );

      // Act: Get user by email
      final user = await database.getUserByEmail('find@example.com');

      // Assert: Correct user is returned
      expect(user, isNotNull);
      expect(user!.email, 'find@example.com');
      expect(user.firstName, 'Find');
      expect(user.lastName, 'Me');
    });

    test('getUserById returns correct user', () async {
      // Arrange: Create a user
      await database.createUser(
        id: 'unique-id-123',
        email: 'user@example.com',
        password: 'pass',
        role: 'Admin',
        phoneNumber: '0123456789',
        firstName: 'Test',
        lastName: 'User',
      );

      // Act: Get user by ID
      final user = await database.getUserById('unique-id-123');

      // Assert: Correct user is returned
      expect(user, isNotNull);
      expect(user!.id, 'unique-id-123');
      expect(user.email, 'user@example.com');
    });

    test('updateUser modifies existing user', () async {
      // Arrange: Create a user
      await database.createUser(
        id: 'update-id',
        email: 'original@example.com',
        password: 'pass',
        role: 'Nurse',
        phoneNumber: '0111111111',
        firstName: 'Original',
        lastName: 'Name',
      );

      // Act: Update the user
      final updatedUser = await database.updateUser(
        id: 'update-id',
        email: 'updated@example.com',
        password: 'newpass',
        role: 'Admin',
        phoneNumber: '0222222222',
        firstName: 'Updated',
        lastName: 'Name',
      );

      // Assert: User was updated
      expect(updatedUser, isNotNull);
      expect(updatedUser!.email, 'updated@example.com');
      expect(updatedUser.firstName, 'Updated');
      expect(updatedUser.role, 'Admin');
      expect(updatedUser.phoneNumber, '0222222222');
    });
  });
}
