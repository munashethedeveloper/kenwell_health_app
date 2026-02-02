import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../domain/models/wellness_event.dart';

// ViewModel for Event Details Screen
class EventDetailsViewModel extends ChangeNotifier {
  // Current event being viewed
  WellnessEvent? event;

  // ------------------ Event Methods ------------------
  void setEvent(WellnessEvent e) {
    event = e;
    notifyListeners();
  }

  Future<void> deleteEvent() async {
    // Add your delete logic here
    notifyListeners();
  }

  // ------------------ Formatting Methods ------------------
  String formatEventDate(DateTime date) {
    return DateFormat.yMMMMd().format(date);
  }
}
