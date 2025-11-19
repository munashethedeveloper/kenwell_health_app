import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HIVTestResultViewModel extends ChangeNotifier {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

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

  // --- Pick expiry date ---
  Future<void> pickExpiryDate(BuildContext context,
      {required bool isScreening}) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      String formattedDate = DateFormat('yyyy-MM-dd').format(picked);
      if (isScreening) {
        screeningExpiryDateController.text = formattedDate;
      } else {
        confirmatoryExpiryDateController.text = formattedDate;
      }
      notifyListeners();
    }
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
    return formKey.currentState?.validate() == true;
  }

  /// Converts all HIV test result data to a Map
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

    debugPrint('✅ HIV Test Result Saved:');
    debugPrint(toMap().toString());

    await Future.delayed(const Duration(milliseconds: 500));

    _isSubmitting = false;
    notifyListeners();

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
