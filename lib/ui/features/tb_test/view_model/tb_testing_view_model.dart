import 'package:flutter/material.dart';

class TBTestingViewModel extends ChangeNotifier {
  // --- TB screening questions ---
  String? coughTwoWeeks;
  String? sputumColour;
  String? bloodInSputum;
  String? weightLoss;
  String? nightSweats;
  String? feverChills;
  String? chestPain;
  String? swellings;

  void setCoughTwoWeeks(String? value) {
    if (coughTwoWeeks == value) return;
    coughTwoWeeks = value;
    notifyListeners();
  }

  void setSputumColour(String? value) {
    if (sputumColour == value) return;
    sputumColour = value;
    notifyListeners();
  }

  void setBloodInSputum(String? value) {
    if (bloodInSputum == value) return;
    bloodInSputum = value;
    notifyListeners();
  }

  void setWeightLoss(String? value) {
    if (weightLoss == value) return;
    weightLoss = value;
    notifyListeners();
  }

  void setNightSweats(String? value) {
    if (nightSweats == value) return;
    nightSweats = value;
    notifyListeners();
  }

  void setFeverChills(String? value) {
    if (feverChills == value) return;
    feverChills = value;
    notifyListeners();
  }

  void setChestPain(String? value) {
    if (chestPain == value) return;
    chestPain = value;
    notifyListeners();
  }

  void setSwellings(String? value) {
    if (swellings == value) return;
    swellings = value;
    notifyListeners();
  }

  // --- TB history ---
  String? treatedBefore;
  TextEditingController treatedDateController = TextEditingController();
  String? completedTreatment;
  String? contactWithTB;

  void setTreatedBefore(String? value) {
    if (treatedBefore == value) return;
    treatedBefore = value;
    if (value != 'Yes') {
      treatedDateController.clear();
    }
    notifyListeners();
  }

  void setCompletedTreatment(String? value) {
    if (completedTreatment == value) return;
    completedTreatment = value;
    notifyListeners();
  }

  void setContactWithTB(String? value) {
    if (contactWithTB == value) return;
    contactWithTB = value;
    notifyListeners();
  }

  bool _isSubmitting = false;
  bool get isSubmitting => _isSubmitting;

  // --- Form validation ---
  bool get isFormValid {
    return coughTwoWeeks != null &&
        sputumColour != null &&
        bloodInSputum != null &&
        weightLoss != null &&
        nightSweats != null &&
        feverChills != null &&
        chestPain != null &&
        swellings != null &&
        treatedBefore != null &&
        completedTreatment != null &&
        contactWithTB != null &&
        (treatedBefore == 'Yes' ? treatedDateController.text.isNotEmpty : true);
  }

  /// ✅ Converts all TB Test data to a Map
  Map<String, dynamic> toMap() {
    return {
      'coughTwoWeeks': coughTwoWeeks,
      'sputumColour': sputumColour,
      'bloodInSputum': bloodInSputum,
      'weightLoss': weightLoss,
      'nightSweats': nightSweats,
      'feverChills': feverChills,
      'chestPain': chestPain,
      'swellings': swellings,
      'treatedBefore': treatedBefore,
      'treatedDate': treatedDateController.text,
      'completedTreatment': completedTreatment,
      'contactWithTB': contactWithTB,
    };
  }

  // --- Submit & continue ---
  Future<void> submitTBTest(BuildContext context,
      {VoidCallback? onNext}) async {
    if (!isFormValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please complete all required fields.')),
      );
      return;
    }

    _isSubmitting = true;
    notifyListeners();

    debugPrint("✅ TB Test Submitted:");
    debugPrint(toMap().toString());

    await Future.delayed(const Duration(milliseconds: 800));
    _isSubmitting = false;
    notifyListeners();

    if (!context.mounted) return;

    // ✅ Callback for workflow navigation
    if (onNext != null) {
      onNext();
    }
  }

  @override
  void dispose() {
    treatedDateController.dispose();
    super.dispose();
  }
}
