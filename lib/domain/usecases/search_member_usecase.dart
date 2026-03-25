import '../../data/repositories_dcl/firestore_member_repository.dart';
import '../models/member.dart';

/// Encapsulates the "search for a member by ID number or passport" business
/// action.
///
/// ## Search strategy
///
/// 1. A query of exactly 13 numeric digits is treated as a South African ID
///    number and the `idNumber` Firestore field is queried.
/// 2. Any other non-empty query is treated as a passport number.
///
/// [FirestoreMemberRepository] handles the Firestore → local-cache fallback
/// automatically, so this use case works in both online and offline mode.
class SearchMemberUseCase {
  SearchMemberUseCase({FirestoreMemberRepository? repository})
      : _repository = repository ?? FirestoreMemberRepository();

  final FirestoreMemberRepository _repository;

  /// Returns the matching [Member], or `null` when no member is found.
  Future<Member?> call(String query) {
    final trimmed = query.trim();

    final isIdNumber =
        trimmed.length == 13 && int.tryParse(trimmed) != null;

    if (isIdNumber) {
      return _repository.fetchMemberByIdNumber(trimmed);
    }
    return _repository.fetchMemberByPassportNumber(trimmed);
  }
}
