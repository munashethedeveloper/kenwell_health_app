import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../nurse_interventions/view_model/nurse_intervention_form_mixin.dart';

class HIVTestResultViewModel extends ChangeNotifier
    with NurseInterventionFormMixin {
  // Note: formKey is provided by NurseInterventionFormMixin

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
  @override
  bool get isFormValid {
    // Validate both HIV test result fields and nurse intervention fields
    final baseFormValid = formKey.currentState?.validate() == true;
    // final nurseInterventionValid = super.isFormValid;
    return baseFormValid; //&& nurseInterventionValid;
  }

  /// Converts all HIV test result data to a Map
  Future<Map<String, dynamic>> toMap() async {
    // Combine HIV test result data with nurse intervention data
    //final nurseInterventionData = await super.toMap();
    return {
      'screeningTestName': screeningTestNameController.text,
      'screeningBatchNo': screeningBatchNoController.text,
      'screeningExpiryDate': screeningExpiryDateController.text,
      'screeningResult': screeningResult,
      // Merge nurse intervention data
      //...nurseInterventionData,
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
    //disposeNurseInterventionFields();
    super.dispose();
  }
}
