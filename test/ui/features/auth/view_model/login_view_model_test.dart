import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:kenwell_health_app/data/repositories_dcl/auth_repository_dcl.dart';
import 'package:kenwell_health_app/data/services/firebase_auth_service.dart';
import 'package:kenwell_health_app/domain/models/user_model.dart';
import 'package:kenwell_health_app/ui/features/auth/view_models/login_view_model.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

class MockFirebaseAuthService extends Mock implements FirebaseAuthService {}

UserModel _verifiedUser() => UserModel(
      id: 'u-1',
      email: 'test@ex.com',
      role: 'nurse',
      phoneNumber: '0821234567',
      firstName: 'Alice',
      lastName: 'Smith',
      emailVerified: true,
    );

UserModel _unverifiedUser() => UserModel(
      id: 'u-2',
      email: 'test@ex.com',
      role: 'nurse',
      phoneNumber: '0821234567',
      firstName: 'Bob',
      lastName: 'Jones',
      emailVerified: false,
    );

void main() {
  late MockAuthRepository mockRepo;
  late MockFirebaseAuthService mockAuthService;
  late LoginViewModel viewModel;

  setUp(() {
    mockRepo = MockAuthRepository();
    mockAuthService = MockFirebaseAuthService();
    viewModel = LoginViewModel(mockRepo, authService: mockAuthService);
  });

  tearDown(() => viewModel.dispose());

  group('LoginViewModel – initial state', () {
    test('isLoading is false', () => expect(viewModel.isLoading, isFalse));
    test('errorMessage is null', () => expect(viewModel.errorMessage, isNull));
    test('navigationTarget is null',
        () => expect(viewModel.navigationTarget, isNull));
    test('needsEmailVerification is false',
        () => expect(viewModel.needsEmailVerification, isFalse));
    test('isLockedOut is false', () => expect(viewModel.isLockedOut, isFalse));
  });

  group('LoginViewModel – login success', () {
    test('sets navigationTarget to mainNavigation on valid credentials',
        () async {
      when(() => mockRepo.login(any(), any()))
          .thenAnswer((_) async => _verifiedUser());

      await viewModel.login('test@ex.com', 'password');

      expect(viewModel.navigationTarget, LoginNavigationTarget.mainNavigation);
      expect(viewModel.errorMessage, isNull);
      expect(viewModel.isLoading, isFalse);
    });
  });

  group('LoginViewModel – login failure', () {
    test('sets errorMessage when repository returns null', () async {
      when(() => mockRepo.login(any(), any())).thenAnswer((_) async => null);

      await viewModel.login('wrong@ex.com', 'wrongpass');

      expect(viewModel.errorMessage, isNotNull);
      expect(viewModel.navigationTarget, isNull);
      expect(viewModel.isLoading, isFalse);
    });

    test('sets errorMessage when repository throws', () async {
      when(() => mockRepo.login(any(), any()))
          .thenThrow(Exception('network error'));

      await viewModel.login('test@ex.com', 'password');

      expect(viewModel.errorMessage, isNotNull);
      expect(viewModel.isLoading, isFalse);
    });

    test('sets needsEmailVerification for unverified user', () async {
      when(() => mockRepo.login(any(), any()))
          .thenAnswer((_) async => _unverifiedUser());

      await viewModel.login('test@ex.com', 'password');

      expect(viewModel.needsEmailVerification, isTrue);
      expect(viewModel.errorMessage, isNotNull);
    });
  });

  group('LoginViewModel – lockout', () {
    test('locks out after maxFailedAttempts failures', () async {
      when(() => mockRepo.login(any(), any())).thenAnswer((_) async => null);

      for (var i = 0; i < LoginViewModel.maxFailedAttempts; i++) {
        await viewModel.login('x@x.com', 'bad');
      }

      expect(viewModel.isLockedOut, isTrue);
    });

    test('rejects login while locked out', () async {
      when(() => mockRepo.login(any(), any())).thenAnswer((_) async => null);

      for (var i = 0; i < LoginViewModel.maxFailedAttempts; i++) {
        await viewModel.login('x@x.com', 'bad');
      }

      // Reset call count so we can verify no new call is made.
      clearInteractions(mockRepo);
      await viewModel.login('x@x.com', 'bad');

      verifyNever(() => mockRepo.login(any(), any()));
      expect(viewModel.errorMessage, contains('Please wait'));
    });
  });

  group('LoginViewModel – clearError', () {
    test('clears errorMessage and needsEmailVerification', () async {
      when(() => mockRepo.login(any(), any()))
          .thenAnswer((_) async => _unverifiedUser());
      await viewModel.login('test@ex.com', 'password');

      viewModel.clearError();

      expect(viewModel.errorMessage, isNull);
      expect(viewModel.needsEmailVerification, isFalse);
    });
  });

  group('LoginViewModel – clearNavigationTarget', () {
    test('sets navigationTarget to null', () async {
      when(() => mockRepo.login(any(), any()))
          .thenAnswer((_) async => _verifiedUser());
      await viewModel.login('test@ex.com', 'password');

      viewModel.clearNavigationTarget();

      expect(viewModel.navigationTarget, isNull);
    });
  });

  group('LoginViewModel – resendVerificationEmail', () {
    test('calls authService.sendEmailVerification', () async {
      when(() => mockAuthService.sendEmailVerification())
          .thenAnswer((_) async {});

      await viewModel.resendVerificationEmail();

      verify(() => mockAuthService.sendEmailVerification()).called(1);
    });

    test('does not throw when sendEmailVerification fails', () async {
      when(() => mockAuthService.sendEmailVerification())
          .thenThrow(Exception('mail error'));

      await expectLater(viewModel.resendVerificationEmail(), completes);
    });
  });
}
