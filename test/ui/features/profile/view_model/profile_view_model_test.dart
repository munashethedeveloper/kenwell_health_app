import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:kenwell_health_app/data/repositories_dcl/auth_repository_dcl.dart';
import 'package:kenwell_health_app/domain/models/user_model.dart';
import 'package:kenwell_health_app/ui/features/profile/view_model/profile_view_model.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

UserModel _user() => UserModel(
      id: 'u-1',
      email: 'alice@ex.com',
      role: 'nurse',
      phoneNumber: '0821234567',
      firstName: 'Alice',
      lastName: 'Smith',
      emailVerified: true,
    );

void main() {
  late MockAuthRepository mockRepo;
  late ProfileViewModel viewModel;

  setUp(() {
    mockRepo = MockAuthRepository();
    viewModel = ProfileViewModel(authRepository: mockRepo);
  });

  tearDown(() => viewModel.dispose());

  group('ProfileViewModel – initial state', () {
    test('all fields are empty strings', () {
      expect(viewModel.email, isEmpty);
      expect(viewModel.firstName, isEmpty);
      expect(viewModel.lastName, isEmpty);
      expect(viewModel.phoneNumber, isEmpty);
      expect(viewModel.role, isEmpty);
    });

    test('isLoading is false', () => expect(viewModel.isLoading, isFalse));
    test('errorMessage is null',
        () => expect(viewModel.errorMessage, isNull));
    test('successMessage is null',
        () => expect(viewModel.successMessage, isNull));
  });

  group('ProfileViewModel – loadProfile', () {
    test('populates fields on success', () async {
      when(() => mockRepo.getCurrentUser())
          .thenAnswer((_) async => _user());

      await viewModel.loadProfile();

      expect(viewModel.email, 'alice@ex.com');
      expect(viewModel.firstName, 'Alice');
      expect(viewModel.lastName, 'Smith');
      expect(viewModel.phoneNumber, '0821234567');
      expect(viewModel.isLoading, isFalse);
      expect(viewModel.errorMessage, isNull);
    });

    test('sets errorMessage when user is null', () async {
      when(() => mockRepo.getCurrentUser()).thenAnswer((_) async => null);

      await viewModel.loadProfile();

      expect(viewModel.errorMessage, isNotNull);
      expect(viewModel.isLoading, isFalse);
    });

    test('sets errorMessage when repository throws', () async {
      when(() => mockRepo.getCurrentUser()).thenThrow(Exception('db error'));

      await viewModel.loadProfile();

      expect(viewModel.errorMessage, isNotNull);
      expect(viewModel.isLoading, isFalse);
    });
  });

  group('ProfileViewModel – updateProfile', () {
    test('returns false and sets error when firstName is empty', () async {
      final result = await viewModel.updateProfile(
        firstName: '',
        lastName: 'Smith',
        phoneNumber: '0821234567',
        email: 'alice@ex.com',
      );

      expect(result, isFalse);
      expect(viewModel.errorMessage, isNotNull);
    });

    test('returns false and sets error when email is invalid', () async {
      final result = await viewModel.updateProfile(
        firstName: 'Alice',
        lastName: 'Smith',
        phoneNumber: '0821234567',
        email: 'not-an-email',
      );

      expect(result, isFalse);
      expect(viewModel.errorMessage, isNotNull);
    });

    test('returns false when user not loaded', () async {
      final result = await viewModel.updateProfile(
        firstName: 'Alice',
        lastName: 'Smith',
        phoneNumber: '0821234567',
        email: 'alice@ex.com',
      );

      expect(result, isFalse);
    });

    test('returns true and sets successMessage on valid update', () async {
      when(() => mockRepo.getCurrentUser())
          .thenAnswer((_) async => _user());
      when(() => mockRepo.updateUser(
                userId: any(named: 'userId'),
                email: any(named: 'email'),
                phoneNumber: any(named: 'phoneNumber'),
                firstName: any(named: 'firstName'),
                lastName: any(named: 'lastName'),
              ))
          .thenAnswer((_) async {});

      await viewModel.loadProfile();
      final result = await viewModel.updateProfile(
        firstName: 'Alice',
        lastName: 'Smith',
        phoneNumber: '0821234567',
        email: 'alice@ex.com',
      );

      expect(result, isTrue);
      expect(viewModel.successMessage, isNotNull);
      expect(viewModel.errorMessage, isNull);
    });

    test('returns false and sets error when updateUser throws', () async {
      when(() => mockRepo.getCurrentUser())
          .thenAnswer((_) async => _user());
      when(() => mockRepo.updateUser(
                userId: any(named: 'userId'),
                email: any(named: 'email'),
                phoneNumber: any(named: 'phoneNumber'),
                firstName: any(named: 'firstName'),
                lastName: any(named: 'lastName'),
              ))
          .thenThrow(Exception('update error'));

      await viewModel.loadProfile();
      final result = await viewModel.updateProfile(
        firstName: 'Alice',
        lastName: 'Smith',
        phoneNumber: '0821234567',
        email: 'alice@ex.com',
      );

      expect(result, isFalse);
      expect(viewModel.errorMessage, isNotNull);
    });
  });

  group('ProfileViewModel – validation', () {
    test('validateEmail returns null for valid email', () {
      expect(viewModel.validateEmail('user@example.com'), isNull);
    });

    test('validateEmail returns error for invalid email', () {
      expect(viewModel.validateEmail('not-an-email'), isNotNull);
    });

    test('validateEmail returns error for empty string', () {
      expect(viewModel.validateEmail(''), isNotNull);
    });

    test('validatePhone returns null for valid SA number', () {
      expect(viewModel.validatePhone('0821234567'), isNull);
    });

    test('validatePhone returns error for short number', () {
      expect(viewModel.validatePhone('123'), isNotNull);
    });

    test('validateRequired returns null when non-empty', () {
      expect(viewModel.validateRequired('Alice', 'First Name'), isNull);
    });

    test('validateRequired returns error for empty string', () {
      expect(viewModel.validateRequired('', 'First Name'), isNotNull);
    });
  });

  group('ProfileViewModel – clearMessages', () {
    test('clears both errorMessage and successMessage', () async {
      when(() => mockRepo.getCurrentUser()).thenAnswer((_) async => null);
      await viewModel.loadProfile(); // triggers errorMessage

      viewModel.clearMessages();

      expect(viewModel.errorMessage, isNull);
      expect(viewModel.successMessage, isNull);
    });
  });

  group('ProfileViewModel – availableRoles', () {
    test('returns a non-empty list', () {
      expect(viewModel.availableRoles, isNotEmpty);
    });
  });
}
