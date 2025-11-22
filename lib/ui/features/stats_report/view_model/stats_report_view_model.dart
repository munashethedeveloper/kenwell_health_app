import 'package:flutter/material.dart';

class StatsReportViewModel extends ChangeNotifier {
  StatsReportViewModel() {
    for (final controller in _allControllers) {
      controller.addListener(_onFieldChanged);
    }
  }

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

  Future<void> pickTime(
      BuildContext context, TextEditingController controller) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (picked != null && context.mounted) {
      controller.text = picked.format(context);
      notifyListeners();
    }
  }

  Future<bool> generateReport() async {
    if (!canSubmit) return false;

    isLoading = true;
    notifyListeners();

    try {
      // In a real app: Save to Firestore or generate downloadable report here.
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
