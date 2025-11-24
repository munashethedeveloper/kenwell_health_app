import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kenwell_health_app/data/local/app_database.dart';
import 'package:kenwell_health_app/data/services/auth_service.dart';

void main() {
  group('AuthService with Drift storage', () {
    late AppDatabase database;
    late AuthService authService;

    setUp(() {
      database = AppDatabase(executor: NativeDatabase.memory());
      authService = AuthService(database);
    });

    tearDown(() async {
      await database.close();
    });

    test('register creates user and prevents duplicates', () async {
      final user = await authService.register(
        email: 'demo@example.com',
        password: 'secret',
        role: 'Admin',
        phoneNumber: '1234567890',
        username: 'demo',
        firstName: 'Demo',
        lastName: 'User',
      );

      expect(user, isNotNull);

      final duplicate = await authService.register(
        email: 'demo@example.com',
        password: 'secret',
        role: 'Admin',
        phoneNumber: '1234567890',
        username: 'demo',
        firstName: 'Demo',
        lastName: 'User',
      );

      expect(duplicate, isNull);
    });

    test('login sets current user and exposes session helpers', () async {
      await authService.register(
        email: 'tester@example.com',
        password: 'letmein',
        role: 'User',
        phoneNumber: '9876543210',
        username: 'tester',
        firstName: 'Test',
        lastName: 'User',
      );

      final loggedIn = await authService.login('tester@example.com', 'letmein');
      expect(loggedIn, isNotNull);
      expect(await authService.isLoggedIn(), isTrue);

      final current = await authService.getCurrentUser();
      expect(current?.email, 'tester@example.com');
      expect(await authService.getStoredPassword(), 'letmein');
    });

    test('logout clears current user state', () async {
      final user = await authService.register(
        email: 'logout@example.com',
        password: 'pass123',
        role: 'Viewer',
        phoneNumber: '5555555555',
        username: 'logoutUser',
        firstName: 'Log',
        lastName: 'Out',
      );

      expect(user, isNotNull);
      await authService.login('logout@example.com', 'pass123');
      expect(await authService.isLoggedIn(), isTrue);

      await authService.logout();
      expect(await authService.isLoggedIn(), isFalse);
      expect(await authService.getCurrentUser(), isNull);
    });
  });
}
