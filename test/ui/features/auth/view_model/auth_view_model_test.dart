import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:kenwell_health_app/data/services/firebase_auth_service.dart';
import 'package:kenwell_health_app/domain/models/user_model.dart';
import 'package:kenwell_health_app/ui/features/auth/view_models/auth_view_model.dart';

class MockFirebaseAuthService extends Mock implements FirebaseAuthService {}

UserModel _user({bool verified = true}) => UserModel(
      id: 'u-1',
      email: 'test@ex.com',
      role: 'nurse',
      phoneNumber: '0821234567',
      firstName: 'Alice',
      lastName: 'Smith',
      emailVerified: verified,
    );

void main() {
  late MockFirebaseAuthService mockAuthService;

  setUp(() {
    mockAuthService = MockFirebaseAuthService();
    // AuthViewModel calls _checkLoginStatus() in constructor.
    when(() => mockAuthService.isLoggedIn()).thenReturn(false);
  });

  group('AuthViewModel – construction', () {
    test('calls isLoggedIn on construction and sets isLoggedIn', () {
      when(() => mockAuthService.isLoggedIn()).thenReturn(true);

      final vm = AuthViewModel(authService: mockAuthService);
      // isLoading starts true, then becomes false after async check
      expect(vm.isLoggedIn, isTrue);
      vm.dispose();
    });

    test('isLoading becomes false after status check', () async {
      when(() => mockAuthService.isLoggedIn()).thenReturn(false);
      final vm = AuthViewModel(authService: mockAuthService);
      await Future.microtask(() {});
      expect(vm.isLoading, isFalse);
      vm.dispose();
    });
  });

  group('AuthViewModel – login', () {
    test('returns true and sets isLoggedIn when login succeeds', () async {
      when(() => mockAuthService.isLoggedIn()).thenReturn(false);
      when(() => mockAuthService.login(any(), any()))
          .thenAnswer((_) async => _user());

      final vm = AuthViewModel(authService: mockAuthService);
      final result = await vm.login('test@ex.com', 'password');

      expect(result, isTrue);
      expect(vm.isLoggedIn, isTrue);
      expect(vm.isLoading, isFalse);
      vm.dispose();
    });

    test('returns false and isLoggedIn is false when login returns null',
        () async {
      when(() => mockAuthService.isLoggedIn()).thenReturn(false);
      when(() => mockAuthService.login(any(), any()))
          .thenAnswer((_) async => null);

      final vm = AuthViewModel(authService: mockAuthService);
      final result = await vm.login('test@ex.com', 'wrongpass');

      expect(result, isFalse);
      expect(vm.isLoggedIn, isFalse);
      expect(vm.isLoading, isFalse);
      vm.dispose();
    });
  });

  group('AuthViewModel – logout', () {
    test('sets isLoggedIn to false after logout', () async {
      when(() => mockAuthService.isLoggedIn()).thenReturn(true);
      when(() => mockAuthService.logout()).thenAnswer((_) async {});

      final vm = AuthViewModel(authService: mockAuthService);
      await vm.logout();

      expect(vm.isLoggedIn, isFalse);
      expect(vm.isLoading, isFalse);
      vm.dispose();
    });
  });

  group('AuthViewModel – checkLoginStatus', () {
    test('updates isLoggedIn based on service state', () async {
      when(() => mockAuthService.isLoggedIn()).thenReturn(false);
      final vm = AuthViewModel(authService: mockAuthService);
      await vm.checkLoginStatus();
      expect(vm.isLoggedIn, isFalse);

      when(() => mockAuthService.isLoggedIn()).thenReturn(true);
      await vm.checkLoginStatus();
      expect(vm.isLoggedIn, isTrue);

      vm.dispose();
    });
  });
}
