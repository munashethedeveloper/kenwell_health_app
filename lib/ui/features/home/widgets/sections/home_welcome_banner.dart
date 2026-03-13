import 'package:flutter/material.dart';
import 'package:kenwell_health_app/ui/shared/ui/colours/kenwell_colours.dart';

/// Branded welcome banner displayed on the Home screen below the hero header.
///
/// Shows the app name, tagline and a health-and-safety icon.
class HomeWelcomeBanner extends StatelessWidget {
  const HomeWelcomeBanner({super.key, required this.role});

  final String role;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [KenwellColors.secondaryNavy, Color(0xFF2E2880)],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: KenwellColors.secondaryNavy.withValues(alpha: 0.3),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'KenWell365',
                    style: TextStyle(
                      color: KenwellColors.primaryGreenLight,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Corporate Wellness\nManagement Platform',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Empowering organisations to deliver world-class wellness programmes.',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.65),
                      fontSize: 12,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: KenwellColors.primaryGreen.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: KenwellColors.primaryGreen.withValues(alpha: 0.4),
                ),
              ),
              child: const Icon(
                Icons.health_and_safety_rounded,
                color: KenwellColors.primaryGreenLight,
                size: 34,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
