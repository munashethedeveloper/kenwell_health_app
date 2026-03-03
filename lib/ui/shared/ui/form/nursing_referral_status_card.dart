import 'package:flutter/material.dart';
import 'package:kenwell_health_app/ui/shared/models/nursing_referral_option.dart';

/// Displays a colour-coded status card that reflects the nursing referral
/// decision.  Hidden (returns empty) when no referral has been selected.
///
/// - [NursingReferralOption.patientNotReferred] → green "Healthy" card
/// - [NursingReferralOption.referredToGP]       → orange "Caution" card
/// - [NursingReferralOption.referredToStateClinic] → red "At Risk" card
class NursingReferralStatusCard extends StatelessWidget {
  final NursingReferralOption? referralSelection;

  const NursingReferralStatusCard({
    super.key,
    required this.referralSelection,
  });

  @override
  Widget build(BuildContext context) {
    if (referralSelection == null) return const SizedBox.shrink();

    switch (referralSelection!) {
      case NursingReferralOption.patientNotReferred:
        return const _StatusCard(
          color: Color(0xFF2E7D32),
          backgroundColor: Color(0xFFE8F5E9),
          borderColor: Color(0xFF2E7D32),
          icon: Icons.check_circle,
          title: 'Healthy',
          message: 'Patient is healthy – Patient not referred',
        );
      case NursingReferralOption.referredToGP:
        return const _StatusCard(
          color: Color(0xFFF57C00),
          backgroundColor: Color(0xFFFFF3E0),
          borderColor: Color(0xFFF57C00),
          icon: Icons.warning_amber,
          title: 'Caution',
          message: 'Patient at caution – referred to GP',
        );
      case NursingReferralOption.referredToStateClinic:
        return const _StatusCard(
          color: Color(0xFFB3261E),
          backgroundColor: Color(0xFFFCDAD6),
          borderColor: Color(0xFFB3261E),
          icon: Icons.dangerous,
          title: 'At Risk',
          message: 'Patient is at risk – referred to State clinic',
        );
    }
  }
}

class _StatusCard extends StatelessWidget {
  final Color color;
  final Color backgroundColor;
  final Color borderColor;
  final IconData icon;
  final String title;
  final String message;

  const _StatusCard({
    required this.color,
    required this.backgroundColor,
    required this.borderColor,
    required this.icon,
    required this.title,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: color,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: TextStyle(
                    color: color,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
