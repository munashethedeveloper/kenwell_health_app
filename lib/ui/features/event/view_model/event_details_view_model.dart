import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../domain/models/wellness_event.dart';

class EventDetailsViewModel extends ChangeNotifier {
  WellnessEvent? event;

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
