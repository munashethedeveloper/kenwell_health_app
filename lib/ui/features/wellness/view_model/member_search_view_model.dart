import 'package:flutter/foundation.dart';
import 'package:kenwell_health_app/data/repositories_dcl/firestore_member_repository.dart';
import 'package:kenwell_health_app/domain/models/member.dart';

/// ViewModel for the member search screen.
///
/// Encapsulates all search logic so that [MemberSearchScreen] is a pure UI
/// widget with no direct repository dependencies.
///
/// ## Search strategy
///
/// 1. If the query is a 13-digit all-numeric string, it is treated as a
///    **South African ID number** and the `idNumber` field is queried.
/// 2. Otherwise the query is treated as a **passport number**.
///
/// In both cases [FirestoreMemberRepository] is used, which already implements
/// a **local Drift DB fallback** when Firestore is unreachable.
class MemberSearchViewModel extends ChangeNotifier {
  MemberSearchViewModel({FirestoreMemberRepository? repository})
      : _repository = repository ?? FirestoreMemberRepository();

  final FirestoreMemberRepository _repository;

  // ── State ────────────────────────────────────────────────────────────────

  bool _isSearching = false;

  /// `null` means no search has been run yet.
  /// `true` means a member was found; `false` means no match.
  bool? _memberFound;

  Member? _foundMember;
  String? _errorMessage;

  // ── Public getters ────────────────────────────────────────────────────────

  bool get isSearching => _isSearching;
  bool? get memberFound => _memberFound;
  Member? get foundMember => _foundMember;
  String? get errorMessage => _errorMessage;

  /// Convenience getter: full name of the found member, or `null`.
  String? get foundMemberName => _foundMember != null
      ? '${_foundMember!.name} ${_foundMember!.surname}'
      : null;

  // ── Actions ───────────────────────────────────────────────────────────────

  /// Searches for a member by [query].
  ///
  /// Uses ID-number semantics (13 digits, all numeric) when the query looks
  /// like an SA ID, otherwise falls back to passport-number semantics.
  ///
  /// [FirestoreMemberRepository] handles the Firestore → local-cache fallback
  /// automatically, so this method works in both online and offline mode.
  Future<void> searchMember(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return;

    _isSearching = true;
    _memberFound = null;
    _foundMember = null;
    _errorMessage = null;
    notifyListeners();

    try {
      Member? member;

      final isIdNumber = trimmed.length == 13 && int.tryParse(trimmed) != null;

      if (isIdNumber) {
        member = await _repository.fetchMemberByIdNumber(trimmed);
      } else {
        member = await _repository.fetchMemberByPassportNumber(trimmed);
      }

      _memberFound = member != null;
      _foundMember = member;
    } catch (e) {
      debugPrint('MemberSearchViewModel: search error – $e');
      _errorMessage = 'Error searching for member. Please try again.';
      _memberFound = false;
    } finally {
      _isSearching = false;
      notifyListeners();
    }
  }

  /// Resets the search results so the form is back to its initial state.
  void clearSearch() {
    _memberFound = null;
    _foundMember = null;
    _errorMessage = null;
    notifyListeners();
  }
}
