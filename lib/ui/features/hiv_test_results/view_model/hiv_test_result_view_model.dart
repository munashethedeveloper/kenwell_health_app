import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HIVTestResultViewModel extends ChangeNotifier {
  // Note: formKey is defined here
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  // --- Screening Test Controllers ---
  final TextEditingController screeningTestNameController =
      TextEditingController();
  final TextEditingController screeningBatchNoController =
      TextEditingController();
  final TextEditingController screeningExpiryDateController =
      TextEditingController();
  String screeningResult = 'Negative';

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
      }
      notifyListeners();
    }
  }

  // --- Setters ---
  void setScreeningResult(String value) {
    screeningResult = value;
    notifyListeners();
  }

  // --- Form validation ---
  bool get isFormValid {
    // Validate HIV test result fields
    final baseFormValid = formKey.currentState?.validate() == true;
    return baseFormValid;
  }

  /// Converts all HIV test result data to a Map
  Future<Map<String, dynamic>> toMap() async {
    return {
      'screeningTestName': screeningTestNameController.text,
      'screeningBatchNo': screeningBatchNoController.text,
      'screeningExpiryDate': screeningExpiryDateController.text,
      'screeningResult': screeningResult,
    };
  }

  // --- Save & continue ---
  Future<void> submitTestResult(VoidCallback? onNext) async {
    if (!isFormValid) return;

    _isSubmitting = true;
    notifyListeners();

    try {
      final data = await toMap();
      debugPrint('✅ HIV Test Result Saved:');
      debugPrint(data.toString());

      await Future.delayed(const Duration(milliseconds: 500));

      _isSubmitting = false;
      notifyListeners();

      onNext?.call();
    } catch (e) {
      debugPrint("Error submitting HIV Test Result: $e");
      _isSubmitting = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    screeningTestNameController.dispose();
    screeningBatchNoController.dispose();
    screeningExpiryDateController.dispose();
    super.dispose();
  }
}
