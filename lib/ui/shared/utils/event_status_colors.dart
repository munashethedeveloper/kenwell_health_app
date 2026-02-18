import 'package:flutter/material.dart';

/// Utility class for event status color mappings
class EventStatusColors {
  /// Get color for event status badge
  static Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'scheduled':
        return Colors.orange;
      case 'in progress':
      case 'inprogress':
        return Colors.blue;
      case 'completed':
        return Colors.deepPurple;
      default:
        return Colors.grey;
    }
  }
}
