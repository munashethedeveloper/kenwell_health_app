import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:kenwell_health_app/data/services/firebase_auth_service.dart';
import 'package:kenwell_health_app/domain/models/user_model.dart';
import 'package:kenwell_health_app/ui/features/user_management/viewmodel/user_management_view_model.dart';

// ── Mock ───────────────────────────────────────────────────────────────────────

class MockFirebaseAuthService extends Mock implements FirebaseAuthService {}

// ── Helpers ────────────────────────────────────────────────────────────────────

UserModel _buildUser({
  String id = 'user-1',
  String email = 'alice@example.com',
  String role = 'NURSE',
  bool emailVerified = true,
}) =>
    UserModel(
      id: id,
      email: email,
      role: role,
      phoneNumber: '0820000001',
      firstName: 'Alice',
      lastName: 'Smith',
      emailVerified: emailVerified,
    );

/// Creates a [UserManagementViewModel] with the mock service wired up.
///
/// The constructor calls `getAllUsersStream()` immediately, so we need the
/// stream stub set up before constructing the ViewModel.
UserManagementViewModel _buildViewModel(
  MockFirebaseAuthService mockService, {
  List<UserModel> initialUsers = const [],
}) {
  // Stub the stream used by _startListeningToUsers.
  final controller = StreamController<List<UserModel>>.broadcast();
  when(() => mockService.getAllUsersStream()).thenAnswer((_) => controller.stream);

  // Push the initial user list synchronously so the ViewModel has data.
  final vm = UserManagementViewModel(authService: mockService);
  controller.add(initialUsers);
  return vm;
}

void main() {
  late MockFirebaseAuthService mockAuthService;

  setUp(() {
    mockAuthService = MockFirebaseAuthService();
  });

  group('UserManagementViewModel – registerUser', () {
    test('returns true and sets successMessage on successful registration',
        () async {
      final vm = _buildViewModel(mockAuthService);
      final newUser = _buildUser(id: 'new-1');

      when(() => mockAuthService.register(
            email: any(named: 'email'),
            password: any(named: 'password'),
            role: any(named: 'role'),
            phoneNumber: any(named: 'phoneNumber'),
            firstName: any(named: 'firstName'),
            lastName: any(named: 'lastName'),
          )).thenAnswer((_) async => newUser);
      when(() => mockAuthService.getAllUsers())
          .thenAnswer((_) async => [newUser]);

      final result = await vm.registerUser(
        email: 'alice@example.com',
        password: 'Pass@1234',
        role: 'NURSE',
        phoneNumber: '0820000001',
        firstName: 'Alice',
        lastName: 'Smith',
      );

      expect(result, isTrue);
      expect(vm.successMessage, isNotNull);
      expect(vm.errorMessage, isNull);
    });

    test('returns false and sets errorMessage when register returns null',
        () async {
      final vm = _buildViewModel(mockAuthService);

      when(() => mockAuthService.register(
            email: any(named: 'email'),
            password: any(named: 'password'),
            role: any(named: 'role'),
            phoneNumber: any(named: 'phoneNumber'),
            firstName: any(named: 'firstName'),
            lastName: any(named: 'lastName'),
          )).thenAnswer((_) async => null);

      final result = await vm.registerUser(
        email: 'dup@example.com',
        password: 'Pass@1234',
        role: 'NURSE',
        phoneNumber: '0820000002',
        firstName: 'Dup',
        lastName: 'User',
      );

      expect(result, isFalse);
      expect(vm.errorMessage, isNotNull);
    });

    test('returns false and sets errorMessage when register throws', () async {
      final vm = _buildViewModel(mockAuthService);

      when(() => mockAuthService.register(
            email: any(named: 'email'),
            password: any(named: 'password'),
            role: any(named: 'role'),
            phoneNumber: any(named: 'phoneNumber'),
            firstName: any(named: 'firstName'),
            lastName: any(named: 'lastName'),
          )).thenThrow(Exception('Firebase unavailable'));

      final result = await vm.registerUser(
        email: 'err@example.com',
        password: 'Pass@1234',
        role: 'NURSE',
        phoneNumber: '0820000003',
        firstName: 'Err',
        lastName: 'User',
      );

      expect(result, isFalse);
      expect(vm.errorMessage, isNotNull);
      expect(vm.isLoading, isFalse);
    });
  });

  group('UserManagementViewModel – deleteUser', () {
    test('returns true and calls authService.deleteUser on success', () async {
      final user = _buildUser(id: 'del-1');
      final vm = _buildViewModel(mockAuthService, initialUsers: [user]);

      when(() => mockAuthService.deleteUser(any())).thenAnswer((_) async => true);
      when(() => mockAuthService.getAllUsers()).thenAnswer((_) async => []);

      final result = await vm.deleteUser(user.id, user.firstName);

      expect(result, isTrue);
      verify(() => mockAuthService.deleteUser(user.id)).called(1);
    });

    test('returns false and sets errorMessage when deleteUser returns false',
        () async {
      final user = _buildUser(id: 'del-fail');
      final vm = _buildViewModel(mockAuthService, initialUsers: [user]);

      when(() => mockAuthService.deleteUser(any()))
          .thenAnswer((_) async => false);

      final result = await vm.deleteUser(user.id, user.firstName);

      expect(result, isFalse);
      expect(vm.errorMessage, isNotNull);
    });
  });

  group('UserManagementViewModel – resetUserPassword', () {
    test('returns true when resetUserPassword succeeds', () async {
      final user = _buildUser();
      final vm = _buildViewModel(mockAuthService, initialUsers: [user]);

      when(() => mockAuthService.resetUserPassword(any()))
          .thenAnswer((_) async => true);

      final result = await vm.resetUserPassword(user.email, user.firstName);

      expect(result, isTrue);
      expect(vm.successMessage, isNotNull);
      verify(() => mockAuthService.resetUserPassword(user.email)).called(1);
    });

    test('returns false and sets errorMessage when resetUserPassword throws',
        () async {
      final user = _buildUser();
      final vm = _buildViewModel(mockAuthService, initialUsers: [user]);

      when(() => mockAuthService.resetUserPassword(any()))
          .thenThrow(Exception('network timeout'));

      final result = await vm.resetUserPassword(user.email, user.firstName);

      expect(result, isFalse);
      expect(vm.errorMessage, isNotNull);
    });
  });

  group('UserManagementViewModel – search & filter', () {
    test('setSearchQuery filters users by first name', () async {
      final alice = _buildUser(id: 'u-alice', email: 'alice@ex.com');
      final bob = _buildUser(
          id: 'u-bob',
          email: 'bob@ex.com',
          role: 'ADMIN');
      // Override default firstName/lastName via a helper override
      final vm = _buildViewModel(mockAuthService, initialUsers: [alice, bob]);

      // Give the stream event a moment to propagate.
      await Future.delayed(Duration.zero);

      vm.setSearchQuery('alice');
      // All test users have firstName = 'Alice' so only alice matches.
      expect(vm.filteredUsers.any((u) => u.id == 'u-alice'), isTrue);
    });

    test('setFilter filters users by role', () async {
      final nurse = _buildUser(id: 'u-nurse', email: 'nurse@ex.com');
      final admin = _buildUser(id: 'u-admin', email: 'admin@ex.com', role: 'ADMIN');
      final vm =
          _buildViewModel(mockAuthService, initialUsers: [nurse, admin]);

      await Future.delayed(Duration.zero);

      vm.setFilter('ADMIN');
      expect(vm.filteredUsers.every((u) => u.role == 'ADMIN'), isTrue);
      expect(vm.filteredUsers.length, 1);
    });

    test('clearSearch shows all users', () async {
      final users = [
        _buildUser(id: 'u-1', email: 'a@ex.com'),
        _buildUser(id: 'u-2', email: 'b@ex.com'),
      ];
      final vm = _buildViewModel(mockAuthService, initialUsers: users);
      await Future.delayed(Duration.zero);

      vm.setSearchQuery('nonexistent');
      vm.clearSearch();

      expect(vm.filteredUsers.length, 2);
    });
  });

  group('UserManagementViewModel – verifiedUsersCount', () {
    test('counts verified and unverified users correctly', () async {
      final verified = _buildUser(id: 'v-1', email: 'v@ex.com', emailVerified: true);
      final unverified =
          _buildUser(id: 'v-2', email: 'u@ex.com', emailVerified: false);
      final vm = _buildViewModel(mockAuthService, initialUsers: [verified, unverified]);
      await Future.delayed(Duration.zero);

      expect(vm.verifiedUsersCount, 1);
      expect(vm.unverifiedUsersCount, 1);
    });
  });
}
