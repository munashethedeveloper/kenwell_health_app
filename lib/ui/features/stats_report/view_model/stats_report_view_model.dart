import 'package:flutter/material.dart';
import '../../../../utils/extensions.dart';

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
      builder: (context, child) => MediaQuery(
        // Force 24-hour clock regardless of device locale
        data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
        child: child!,
      ),
    );

    if (picked != null && context.mounted) {
      // Use fixed 24-hour HH:mm format (locale-independent) for consistency
      // with the 24-hour picker dialog configured above.
      controller.text = picked.toHHmm();
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
