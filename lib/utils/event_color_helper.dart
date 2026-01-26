import 'package:flutter/material.dart';

/// Utility class for event-related UI helpers
class EventColorHelper {
  const EventColorHelper._();

  /// Returns color based on service/category
  static Color getCategoryColor(String servicesRequested) {
    final service = servicesRequested.toLowerCase();

    if (service.contains('hiv') || service.contains('hct')) {
      return const Color(0xFFE53935); // Red
    } else if (service.contains('tb')) {
      return const Color(0xFFFB8C00); // Orange
    } else if (service.contains('dental')) {
      return const Color(0xFF039BE5); // Blue
    } else if (service.contains('eye')) {
      return const Color(0xFF8E24AA); // Purple
    } else if (service.contains('breast') || service.contains('pap')) {
      return const Color(0xFFD81B60); // Pink
    } else if (service.contains('psychological') ||
        service.contains('counselling')) {
      return const Color(0xFF00ACC1); // Cyan
    } else if (service.contains('hra')) {
      return const Color(0xFF43A047); // Green
    } else if (service.contains('psa') || service.contains('prostate')) {
      return const Color(0xFF5E35B1); // Deep Purple
    } else if (service.contains('posture')) {
      return const Color(0xFF7CB342); // Light Green
    }

    return const Color(0xFF90C048); // Default Kenwell green
  }

  /// Returns icon based on service/category
  static IconData getServiceIcon(String service) {
    final lowerService = service.toLowerCase();

    if (lowerService.contains('hiv') || lowerService.contains('screening')) {
      return Icons.medical_services;
    } else if (lowerService.contains('counselling') ||
        lowerService.contains('therapy') ||
        lowerService.contains('psychological')) {
      return Icons.psychology;
    } else if (lowerService.contains('nutrition') ||
        lowerService.contains('diet')) {
      return Icons.restaurant_menu;
    } else if (lowerService.contains('fitness') ||
        lowerService.contains('exercise') ||
        lowerService.contains('posture')) {
      return Icons.fitness_center;
    } else if (lowerService.contains('workshop') ||
        lowerService.contains('training')) {
      return Icons.school;
    } else if (lowerService.contains('dental')) {
      return Icons.medical_services_outlined;
    } else if (lowerService.contains('eye')) {
      return Icons.visibility;
    } else if (lowerService.contains('breast') ||
        lowerService.contains('pap')) {
      return Icons.health_and_safety;
    }

    return Icons.event;
  }
}
