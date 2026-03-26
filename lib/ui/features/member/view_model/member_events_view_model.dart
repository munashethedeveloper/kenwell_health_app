import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import '../../../../domain/models/member.dart';
import '../../../../domain/usecases/load_member_event_referrals_usecase.dart';

/// ViewModel for [MemberEventsScreen].
///
/// Delegates all multi-repository orchestration to
/// [LoadMemberEventReferralsUseCase] so the ViewModel only manages UI state.
class MemberEventsViewModel extends ChangeNotifier {
  MemberEventsViewModel({
    required Member member,
    LoadMemberEventReferralsUseCase? loadMemberEventReferralsUseCase,
  })  : _member = member,
        _loadMemberEventReferralsUseCase = loadMemberEventReferralsUseCase ??
            LoadMemberEventReferralsUseCase();

  final Member _member;
  final LoadMemberEventReferralsUseCase _loadMemberEventReferralsUseCase;

  // ── State ────────────────────────────────────────────────────────────────

  List<Map<String, dynamic>> _events = [];
  bool _isLoading = true;
  String? _errorMessage;

  /// Map of eventId → referral summary, populated after loadMemberEvents().
  Map<String, EventReferralSummary> _referralSummaries = {};

  // ── Getters ───────────────────────────────────────────────────────────────

  List<Map<String, dynamic>> get events => List.unmodifiable(_events);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Returns the referral summary for [eventId], or null if not available.
  EventReferralSummary? referralFor(String eventId) =>
      _referralSummaries[eventId];

  // ── Actions ───────────────────────────────────────────────────────────────

  /// Loads the events attended by [_member] and derives per-event referral
  /// outcomes. Delegates to [LoadMemberEventReferralsUseCase].
  Future<void> loadMemberEvents() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _loadMemberEventReferralsUseCase(_member);
      _events = result.events;
      _referralSummaries = result.referralSummaries;
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
