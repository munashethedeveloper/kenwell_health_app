import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:kenwell_health_app/domain/usecases/delete_member_usecase.dart';
import 'package:kenwell_health_app/domain/usecases/load_members_usecase.dart';
import 'package:kenwell_health_app/domain/usecases/register_member_usecase.dart';
import 'package:kenwell_health_app/domain/models/member.dart';
import 'package:kenwell_health_app/ui/features/member/view_model/member_registration_view_model.dart';

class MockRegisterMemberUseCase extends Mock implements RegisterMemberUseCase {}

class MockDeleteMemberUseCase extends Mock implements DeleteMemberUseCase {}

class MockLoadMembersUseCase extends Mock implements LoadMembersUseCase {}

Member _member({String id = 'm-1'}) => Member(
      id: id,
      name: 'Alice',
      surname: 'Smith',
      idDocumentType: 'ID',
      createdAt: DateTime(2025, 1, 1),
      updatedAt: DateTime(2025, 1, 1),
    );

void main() {
  late MockRegisterMemberUseCase mockRegister;
  late MockDeleteMemberUseCase mockDelete;
  late MockLoadMembersUseCase mockLoad;
  late MemberDetailsViewModel viewModel;

  setUp(() {
    mockRegister = MockRegisterMemberUseCase();
    mockDelete = MockDeleteMemberUseCase();
    mockLoad = MockLoadMembersUseCase();
    viewModel = MemberDetailsViewModel(
      registerMemberUseCase: mockRegister,
      deleteMemberUseCase: mockDelete,
      loadMembersUseCase: mockLoad,
    );
  });

  tearDown(() => viewModel.dispose());

  group('MemberDetailsViewModel – initial state', () {
    test('members is empty', () => expect(viewModel.members, isEmpty));
    test('isLoading is false', () => expect(viewModel.isLoading, isFalse));
    test('errorMessage is null', () => expect(viewModel.errorMessage, isNull));
    test('searchQuery is empty', () => expect(viewModel.searchQuery, isEmpty));
    test(
        'selectedFilter is All', () => expect(viewModel.selectedFilter, 'All'));
  });

  group('MemberDetailsViewModel – loadMembers', () {
    test('populates members list on success', () async {
      when(() => mockLoad.call()).thenAnswer((_) async => [_member()]);

      await viewModel.loadMembers();

      expect(viewModel.members, hasLength(1));
      expect(viewModel.isLoading, isFalse);
      expect(viewModel.errorMessage, isNull);
    });

    test('sets errorMessage when use case throws', () async {
      when(() => mockLoad.call()).thenThrow(Exception('load error'));

      await viewModel.loadMembers();

      expect(viewModel.errorMessage, isNotNull);
      expect(viewModel.isLoading, isFalse);
    });
  });

  group('MemberDetailsViewModel – search', () {
    test('setSearchQuery updates searchQuery', () {
      viewModel.setSearchQuery('alice');
      expect(viewModel.searchQuery, 'alice');
    });

    test('setFilter updates selectedFilter', () {
      viewModel.setFilter('ID');
      expect(viewModel.selectedFilter, 'ID');
    });
  });
}
