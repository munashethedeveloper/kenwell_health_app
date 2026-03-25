import 'package:flutter/material.dart';
import '../../../../data/repositories_dcl/firestore_member_repository.dart';
import '../../../../data/repositories_dcl/firestore_member_event_repository.dart';

class StatsReportViewModel extends ChangeNotifier {
  StatsReportViewModel({
    FirestoreMemberRepository? memberRepository,
    FirestoreMemberEventRepository? memberEventRepository,
  })  : _memberRepository = memberRepository ?? FirestoreMemberRepository(),
        _memberEventRepository =
            memberEventRepository ?? FirestoreMemberEventRepository() {
    for (final controller in _allControllers) {
      controller.addListener(_onFieldChanged);
    }
  }

  final FirestoreMemberRepository _memberRepository;
  final FirestoreMemberEventRepository _memberEventRepository;

  final formKey = GlobalKey<FormState>();

  final TextEditingController eventTitleController = TextEditingController();
  final TextEditingController eventDateController = TextEditingController();
  final TextEditingController startTimeController = TextEditingController();
  final TextEditingController endTimeController = TextEditingController();
  final TextEditingController expectedParticipationController =
      TextEditingController();
  final TextEditingController registeredController = TextEditingController();
  final TextEditingController screenedController = TextEditingController();

  DateTime? eventDate;
  bool isLoading = false;

  // ── Member count ──────────────────────────────────────────────────────────

  int _memberCount = 0;
  bool _isLoadingMemberCount = false;

  int get memberCount => _memberCount;
  bool get isLoadingMemberCount => _isLoadingMemberCount;

  int _registeredCount = 0;
  bool _isLoadingRegisteredCount = false;

  int get registeredCount => _registeredCount;
  bool get isLoadingRegisteredCount => _isLoadingRegisteredCount;

  /// Fetches the number of members registered (via member_events) for the
  /// given [eventIds]. Use this on the live stats screen instead of the
  /// global member count.
  Future<void> loadRegisteredCountForEvents(List<String> eventIds) async {
    if (eventIds.isEmpty) {
      _registeredCount = 0;
      notifyListeners();
      return;
    }
    _isLoadingRegisteredCount = true;
    notifyListeners();
    try {
      _registeredCount =
          await _memberEventRepository.countRegisteredMembersForEvents(eventIds);
    } catch (_) {
      // Non-fatal — keep previous count.
    } finally {
      _isLoadingRegisteredCount = false;
      notifyListeners();
    }
  }

  /// Fetches the total number of registered members and notifies listeners.
  Future<void> loadMemberCount() async {
    _isLoadingMemberCount = true;
    notifyListeners();
    try {
      final members = await _memberRepository.fetchAllMembers();
      _memberCount = members.length;
    } catch (_) {
      // Non-fatal — keep previous count.
    } finally {
      _isLoadingMemberCount = false;
      notifyListeners();
    }
  }

  List<TextEditingController> get _allControllers => [
        eventTitleController,
        eventDateController,
        startTimeController,
        endTimeController,
        expectedParticipationController,
        registeredController,
        screenedController,
      ];

  bool get canSubmit =>
      eventTitleController.text.trim().isNotEmpty && eventDate != null;

  void _onFieldChanged() {
    notifyListeners();
  }

  void setEventDate(DateTime date) {
    eventDate = date;
    notifyListeners();
  }

  /// Stores a time string (HH:mm) in [controller] and notifies listeners.
  /// Call this from the UI after showing a [showTimePicker] dialog.
  void setTimeFromPicked(TimeOfDay picked, TextEditingController controller) {
    final hh = picked.hour.toString().padLeft(2, '0');
    final mm = picked.minute.toString().padLeft(2, '0');
    controller.text = '$hh:$mm';
    notifyListeners();
  }

  Future<bool> generateReport() async {
    if (!canSubmit) return false;

    isLoading = true;
    notifyListeners();

    try {
      await Future.delayed(const Duration(seconds: 1));
      debugPrint(
        'Stats report generated for ${eventTitleController.text} on $eventDate',
      );
      return true;
    } catch (e, stackTrace) {
      debugPrint('Error generating report: $e\n$stackTrace');
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    for (final controller in _allControllers) {
      controller
        ..removeListener(_onFieldChanged)
        ..dispose();
    }
    super.dispose();
  }
}
