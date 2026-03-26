import '../../data/repositories_dcl/firestore_member_repository.dart';
import '../models/member.dart';

/// Encapsulates the "fetch all members" business action.
///
/// [FirestoreMemberRepository] already handles the Firestore → local-cache
/// fallback automatically, so this use case works in both online and offline
/// mode without any additional logic.
class LoadMembersUseCase {
  LoadMembersUseCase({FirestoreMemberRepository? repository})
      : _repository = repository ?? FirestoreMemberRepository();

  final FirestoreMemberRepository _repository;

  Future<List<Member>> call() => _repository.fetchAllMembers();
}
