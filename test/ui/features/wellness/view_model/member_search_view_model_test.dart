import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:kenwell_health_app/domain/models/member.dart';
import 'package:kenwell_health_app/domain/usecases/search_member_usecase.dart';
import 'package:kenwell_health_app/ui/features/wellness/view_model/member_search_view_model.dart';

class MockSearchMemberUseCase extends Mock implements SearchMemberUseCase {}

Member _member() => Member(
      id: 'm-1',
      name: 'Alice',
      surname: 'Smith',
      idNumber: '9001011234567',
      idDocumentType: 'ID',
      createdAt: DateTime(2025, 1, 1),
      updatedAt: DateTime(2025, 1, 1),
    );

void main() {
  late MockSearchMemberUseCase mockUseCase;
  late MemberSearchViewModel viewModel;

  setUp(() {
    mockUseCase = MockSearchMemberUseCase();
    viewModel = MemberSearchViewModel(searchMemberUseCase: mockUseCase);
  });

  tearDown(() => viewModel.dispose());

  group('MemberSearchViewModel – initial state', () {
    test('isSearching is false', () => expect(viewModel.isSearching, isFalse));
    test('memberFound is null', () => expect(viewModel.memberFound, isNull));
    test('foundMember is null', () => expect(viewModel.foundMember, isNull));
    test('errorMessage is null',
        () => expect(viewModel.errorMessage, isNull));
    test('foundMemberName is null',
        () => expect(viewModel.foundMemberName, isNull));
  });

  group('MemberSearchViewModel – searchMember', () {
    test('ignores empty query', () async {
      await viewModel.searchMember('  ');
      verifyNever(() => mockUseCase(any()));
    });

    test('sets memberFound=true and foundMember when member exists', () async {
      when(() => mockUseCase(any())).thenAnswer((_) async => _member());

      await viewModel.searchMember('9001011234567');

      expect(viewModel.memberFound, isTrue);
      expect(viewModel.foundMember, isNotNull);
      expect(viewModel.foundMember!.name, 'Alice');
      expect(viewModel.isSearching, isFalse);
      expect(viewModel.errorMessage, isNull);
    });

    test('sets memberFound=false when no member found', () async {
      when(() => mockUseCase(any())).thenAnswer((_) async => null);

      await viewModel.searchMember('0000000000000');

      expect(viewModel.memberFound, isFalse);
      expect(viewModel.foundMember, isNull);
      expect(viewModel.isSearching, isFalse);
    });

    test('sets errorMessage when use case throws', () async {
      when(() => mockUseCase(any())).thenThrow(Exception('db error'));

      await viewModel.searchMember('passport-123');

      expect(viewModel.errorMessage, isNotNull);
      expect(viewModel.memberFound, isFalse);
      expect(viewModel.isSearching, isFalse);
    });
  });

  group('MemberSearchViewModel – foundMemberName', () {
    test('returns full name when member is found', () async {
      when(() => mockUseCase(any())).thenAnswer((_) async => _member());
      await viewModel.searchMember('9001011234567');

      expect(viewModel.foundMemberName, 'Alice Smith');
    });
  });
}
