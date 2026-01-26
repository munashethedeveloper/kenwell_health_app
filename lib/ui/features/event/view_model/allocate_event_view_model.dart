import 'package:flutter/material.dart';
import 'package:kenwell_health_app/models/user.dart';

class AllocateEventViewModel extends ChangeNotifier {
  final List<User> allUsers;
  final Set<String> selectedUserIds = {};

  AllocateEventViewModel({required this.allUsers});

  void toggleUser(String userId) {
    if (selectedUserIds.contains(userId)) {
      selectedUserIds.remove(userId);
    } else {
      selectedUserIds.add(userId);
    }
    notifyListeners();
  }

  void assignUsersToEvent(Function(List<String>) onAssign) {
    onAssign(selectedUserIds.toList());
  }
}
