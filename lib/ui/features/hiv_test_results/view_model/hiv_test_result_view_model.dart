import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HIVTestResultViewModel extends ChangeNotifier {
  // --- Screening Test Controllers ---
  final TextEditingController screeningTestNameController =
      TextEditingController();
  final TextEditingController screeningBatchNoController =
      TextEditingController();
  final TextEditingController screeningExpiryDateController =
      TextEditingController();
  String screeningResult = 'Negative';

  // --- Confirmatory Test Controllers ---
  final TextEditingController confirmatoryTestNameController =
      TextEditingController();
  final TextEditingController confirmatoryBatchNoController =
      TextEditingController();
  final TextEditingController confirmatoryExpiryDateController =
      TextEditingController();
  String confirmatoryResult = 'Negative';

  // --- Final HIV Result ---
  String finalResult = 'Negative';

  bool _isSubmitting = false;
  bool get isSubmitting => _isSubmitting;

  // --- Handle expiry date change (used by KenwellDatePickerField) ---
  void handleExpiryDateChange(DateTime? date, {required bool isScreening}) {
    final formattedDate =
        date != null ? DateFormat('yyyy-MM-dd').format(date) : '';
    if (isScreening) {
      screeningExpiryDateController.text = formattedDate;
    } else {
      confirmatoryExpiryDateController.text = formattedDate;
    }
    notifyListeners();
  }

  // --- Setters ---
  void setScreeningResult(String value) {
    screeningResult = value;
    notifyListeners();
  }

  void setConfirmatoryResult(String value) {
    confirmatoryResult = value;
    notifyListeners();
  }

  void setFinalResult(String value) {
    finalResult = value;
    notifyListeners();
  }

  // --- Form validation ---
  bool get isFormValid {
    if (screeningTestNameController.text.isEmpty ||
        screeningBatchNoController.text.isEmpty ||
        screeningExpiryDateController.text.isEmpty) {
      return false;
    }

    if (confirmatoryTestNameController.text.isEmpty ||
        confirmatoryBatchNoController.text.isEmpty ||
        confirmatoryExpiryDateController.text.isEmpty) {
      return false;
    }

    return true;
  }

  // --- Converts all HIV test result data to a Map ---
  Map<String, dynamic> toMap() {
    return {
      'screeningTestName': screeningTestNameController.text,
      'screeningBatchNo': screeningBatchNoController.text,
      'screeningExpiryDate': screeningExpiryDateController.text,
      'screeningResult': screeningResult,
      'confirmatoryTestName': confirmatoryTestNameController.text,
      'confirmatoryBatchNo': confirmatoryBatchNoController.text,
      'confirmatoryExpiryDate': confirmatoryExpiryDateController.text,
      'confirmatoryResult': confirmatoryResult,
      'finalResult': finalResult,
    };
  }

  // --- Save & continue ---
  Future<void> submitTestResult(VoidCallback? onNext) async {
    if (!isFormValid) return;

    _isSubmitting = true;
    notifyListeners();

    // Simulate save operation
    debugPrint('✅ HIV Test Result Saved:');
    debugPrint(toMap().toString());

    await Future.delayed(const Duration(milliseconds: 500));

    _isSubmitting = false;
    notifyListeners();

    // Move to next step
    onNext?.call();
  }

  @override
  void dispose() {
    screeningTestNameController.dispose();
    screeningBatchNoController.dispose();
    screeningExpiryDateController.dispose();
    confirmatoryTestNameController.dispose();
    confirmatoryBatchNoController.dispose();
    confirmatoryExpiryDateController.dispose();
    super.dispose();
  }
}
