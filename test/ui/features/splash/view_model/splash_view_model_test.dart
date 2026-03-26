import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:kenwell_health_app/data/services/firebase_auth_service.dart';
import 'package:kenwell_health_app/ui/features/auth/view_models/auth_view_model.dart';
import 'package:kenwell_health_app/ui/features/splash/view_model/splash_view_model.dart';

class MockFirebaseAuthService extends Mock implements FirebaseAuthService {}

void main() {
  late SplashViewModel viewModel;

  setUp(() {
    viewModel = SplashViewModel();
  });

  tearDown(() => viewModel.dispose());

  group('SplashViewModel – initial state', () {
    test('isInitializing is true initially', () {
      expect(viewModel.isInitializing, isTrue);
    });

    test('navigationTarget is null initially', () {
      expect(viewModel.navigationTarget, isNull);
    });
  });

  group('SplashViewModel – initializeApp', () {
    test('navigates to mainNavigation when user is logged in', () async {
      final mockService = MockFirebaseAuthService();
      when(() => mockService.isLoggedIn()).thenReturn(true);
      final authVm = AuthViewModel(authService: mockService);

      await viewModel.initializeApp(authVm);

      expect(viewModel.navigationTarget,
          SplashNavigationTarget.mainNavigation);
      expect(viewModel.isInitializing, isFalse);

      authVm.dispose();
    });

    test('navigates to authWrapper when user is not logged in', () async {
      final mockService = MockFirebaseAuthService();
      when(() => mockService.isLoggedIn()).thenReturn(false);
      final authVm = AuthViewModel(authService: mockService);

      await viewModel.initializeApp(authVm);

      expect(viewModel.navigationTarget,
          SplashNavigationTarget.authWrapper);
      expect(viewModel.isInitializing, isFalse);

      authVm.dispose();
    });

    test('sets isInitializing to false after completion', () async {
      final mockService = MockFirebaseAuthService();
      when(() => mockService.isLoggedIn()).thenReturn(false);
      final authVm = AuthViewModel(authService: mockService);

      await viewModel.initializeApp(authVm);

      expect(viewModel.isInitializing, isFalse);
      authVm.dispose();
    });
  });

  group('SplashViewModel – clearNavigationTarget', () {
    test('sets navigationTarget to null', () async {
      final mockService = MockFirebaseAuthService();
      when(() => mockService.isLoggedIn()).thenReturn(true);
      final authVm = AuthViewModel(authService: mockService);
      await viewModel.initializeApp(authVm);

      viewModel.clearNavigationTarget();

      expect(viewModel.navigationTarget, isNull);
      authVm.dispose();
    });
  });
}
