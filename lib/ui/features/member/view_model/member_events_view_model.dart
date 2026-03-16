import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import '../../../../data/repositories_dcl/firestore_member_repository.dart';
import '../../../../domain/models/member.dart';

/// ViewModel for [MemberEventsScreen].
///
/// Owns the [FirestoreMemberRepository] dependency and all data-loading logic,
/// so the screen itself is a pure UI widget.
class MemberEventsViewModel extends ChangeNotifier {
  MemberEventsViewModel({
    required Member member,
    FirestoreMemberRepository? repository,
  })  : _member = member,
        _repository = repository ?? FirestoreMemberRepository();

  final Member _member;
  final FirestoreMemberRepository _repository;

  // ── State ────────────────────────────────────────────────────────────────

  List<Map<String, dynamic>> _events = [];
  bool _isLoading = true;
  String? _errorMessage;

  // ── Getters ───────────────────────────────────────────────────────────────

  List<Map<String, dynamic>> get events =>
      List.unmodifiable(_events);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // ── Actions ───────────────────────────────────────────────────────────────

  /// Loads the events attended by [_member] from Firestore.
  Future<void> loadMemberEvents() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _events = await _repository.fetchMemberEvents(_member);
    } catch (e) {
      _errorMessage = 'Failed to load events: $e';
      debugPrint('MemberEventsViewModel.loadMemberEvents: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  /// Formats a Firestore [Timestamp], [String], or [DateTime] date value for
  /// display.
  String formatDate(dynamic date) {
    if (date == null) return 'Date not available';
    try {
      final DateTime dt;
      if (date is Timestamp) {
        dt = date.toDate();
      } else if (date is String) {
        dt = DateTime.parse(date);
      } else if (date is DateTime) {
        dt = date;
      } else {
        return 'Invalid date';
      }
      return DateFormat('dd MMM yyyy').format(dt);
    } catch (_) {
      return 'Date format error';
    }
  }
}
