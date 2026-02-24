import 'package:flutter/material.dart';
import 'package:kenwell_health_app/utils/health_metric_classification.dart';

/// Colour-coded badge shown beneath a health metric input field.
class HealthMetricStatusBadge extends StatelessWidget {
  final HealthMetricStatus? status;

  const HealthMetricStatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    if (status == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 4, left: 4, bottom: 4),
      child: Row(
        children: [
          Icon(status!.icon, color: status!.color, size: 16),
          const SizedBox(width: 4),
          Text(
            status!.label,
            style: TextStyle(
              color: status!.color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// Alert banner displayed when one or more metrics are in the red (danger) zone.
class HealthMetricRedAlert extends StatelessWidget {
  const HealthMetricRedAlert({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFCDAD6),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFB3261E), width: 1),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.dangerous, color: Color(0xFFB3261E), size: 20),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'One or more health metrics are in the danger zone (red). '
              'This member has been automatically referred to a State clinic.',
              style: TextStyle(
                color: Color(0xFFB3261E),
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
