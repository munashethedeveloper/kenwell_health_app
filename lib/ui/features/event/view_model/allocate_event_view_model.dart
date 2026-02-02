import 'package:flutter/material.dart';
import 'package:kenwell_health_app/models/user.dart';

// ViewModel for allocating users to an event
class AllocateEventViewModel extends ChangeNotifier {
  // List of all users available for allocation
  final List<User> allUsers;
  final Set<String> selectedUserIds = {};

  // Constructor
  AllocateEventViewModel({required this.allUsers});

  // Toggle user selection
  void toggleUser(String userId) {
    if (selectedUserIds.contains(userId)) {
      selectedUserIds.remove(userId);
    } else {
      selectedUserIds.add(userId);
    }
    notifyListeners();
  }

  // Assign selected users to the event
  void assignUsersToEvent(Function(List<String>) onAssign) {
    onAssign(selectedUserIds.toList());
  }
}
