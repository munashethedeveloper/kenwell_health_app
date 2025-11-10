import 'package:flutter/material.dart';

class StatsReportViewModel extends ChangeNotifier {
  // Fields
  String eventTitle = '';
  DateTime? eventDate;
  String startTime = '';
  String endTime = '';
  int expectedParticipation = 0;
  int registered = 0;
  int screened = 0;

  bool isLoading = false;

  /// Update event date
  void setEventDate(DateTime date) {
    eventDate = date;
    notifyListeners();
  }

  /// Save or generate report logic
  Future<void> generateReport() async {
    if (eventTitle.isEmpty || eventDate == null) return;

    isLoading = true;
    notifyListeners();

    try {
      // In a real app: Save to Firestore or generate downloadable report here
      await Future.delayed(const Duration(seconds: 1)); // Simulated delay
      debugPrint('Stats report generated successfully');
    } catch (e) {
      debugPrint('Error generating report: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
