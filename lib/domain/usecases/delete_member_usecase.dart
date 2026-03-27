import '../../data/local/app_database.dart';
import '../../data/repositories_dcl/firestore_member_repository.dart';
import '../../data/repositories_dcl/member_repository.dart';

/// Encapsulates the "delete a member" business action.
///
/// Deleting a member must be reflected in two stores:
///  1. **Firestore** — the authoritative remote record.
///  2. **Local SQLite** — the cached offline copy.
///
/// Both deletes are treated as fatal: if either fails the caller receives the
/// exception and can display an appropriate error message.
class DeleteMemberUseCase {
  DeleteMemberUseCase({
    FirestoreMemberRepository? firestoreRepository,
    MemberRepository? localRepository,
  })  : _firestoreRepository =
            firestoreRepository ?? FirestoreMemberRepository(),
        _localRepository =
            localRepository ?? MemberRepository(AppDatabase.instance);

  final FirestoreMemberRepository _firestoreRepository;
  final MemberRepository _localRepository;

  /// Deletes the member identified by [memberId] from both Firestore and the
  /// local SQLite database.
  Future<void> call(String memberId) async {
    await _firestoreRepository.deleteMember(memberId);
    await _localRepository.deleteMember(memberId);
  }
}
