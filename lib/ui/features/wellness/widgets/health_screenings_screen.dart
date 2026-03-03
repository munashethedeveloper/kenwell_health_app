import 'package:flutter/material.dart';
import 'package:kenwell_health_app/ui/shared/ui/app_bar/kenwell_app_bar.dart';

import '../../../shared/ui/form/kenwell_modern_section_header.dart';

class HealthScreeningsScreen extends StatelessWidget {
  final bool hraEnabled;
  //final bool hivEnabled;
  final bool hctEnabled;
  final bool tbEnabled;
  final bool cancerEnabled;
  final bool hraCompleted;
  //final bool hivCompleted;
  final bool hctCompleted;
  final bool tbCompleted;
  final bool cancerCompleted;
  final VoidCallback? onHraTap;
  //final VoidCallback? onHivTap;
  final VoidCallback? onHctTap;
  final VoidCallback? onTbTap;
  final VoidCallback? onCancerTap;
  final PreferredSizeWidget? appBar;

  const HealthScreeningsScreen({
    super.key,
    required this.hraEnabled,
    //required this.hivEnabled,
    required this.hctEnabled,
    required this.tbEnabled,
    this.cancerEnabled = false,
    this.hraCompleted = false,
    //this.hivCompleted = false,
    this.hctCompleted = false,
    this.tbCompleted = false,
    this.cancerCompleted = false,
    this.onHraTap,
    //this.onHivTap,
    this.onHctTap,
    this.onTbTap,
    this.onCancerTap,
    this.appBar,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: appBar ??
          const KenwellAppBar(
            title: 'Health Screenings',
          ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const KenwellModernSectionHeader(
              title: 'Section C: Health Screenings',
              subtitle: 'Complete the health screenings you have consented to.',
              icon: Icons.medical_services,
            ),
            const SizedBox(height: 24),
            Text(
              'Select a screening to continue:',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            if (hraEnabled) ...[
              _ScreeningCard(
                icon: Icons.psychology,
                title: 'Health Risk Assessment',
                isEnabled: hraEnabled,
                isCompleted: hraCompleted,
                onTap: onHraTap,
              ),
            ],
            if (hctEnabled) ...[
              _ScreeningCard(
                icon: Icons.vaccines,
                title: 'HCT Screening',
                isEnabled: hctEnabled,
                isCompleted: hctCompleted,
                onTap: onHctTap,
              ),
            ],
            if (tbEnabled) ...[
              _ScreeningCard(
                icon: Icons.healing,
                title: 'TB Screening',
                isEnabled: tbEnabled,
                isCompleted: tbCompleted,
                onTap: onTbTap,
              ),
              if (!cancerEnabled) const SizedBox(height: 24),
            ],
            if (cancerEnabled) ...[
              _ScreeningCard(
                icon: Icons.biotech,
                title: 'Cancer Screening',
                isEnabled: cancerEnabled,
                isCompleted: cancerCompleted,
                onTap: onCancerTap,
              ),
              const SizedBox(height: 24),
            ],
          ],
        ),
      ),
    );
  }
}

class _ScreeningCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool isEnabled;
  final bool isCompleted;
  final VoidCallback? onTap;

  const _ScreeningCard({
    required this.icon,
    required this.title,
    required this.isEnabled,
    this.isCompleted = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color iconContainerColor;
    Color iconColor;
    Color statusTextColor;
    String statusText;

    if (isCompleted) {
      iconContainerColor = const Color(0xFF90C048).withValues(alpha: 0.15);
      iconColor = const Color(0xFF90C048);
      statusTextColor = const Color(0xFF90C048);
      statusText = 'Completed';
    } else if (isEnabled) {
      iconContainerColor = Colors.grey.shade200;
      iconColor = Colors.grey.shade600;
      statusTextColor = Colors.grey.shade600;
      statusText = 'Tap to begin';
    } else {
      iconContainerColor = Colors.grey.shade200;
      iconColor = Colors.grey.shade400;
      statusTextColor = Colors.grey.shade400;
      statusText = 'Not consented';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.shade200,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isEnabled ? onTap : null,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: iconContainerColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    icon,
                    color: iconColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF201C58),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        statusText,
                        style: TextStyle(
                          fontSize: 13,
                          color: statusTextColor,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isCompleted)
                  const Icon(
                    Icons.check_circle,
                    color: Color(0xFF90C048),
                    size: 24,
                  )
                else if (isEnabled)
                  Icon(
                    Icons.chevron_right,
                    color: Colors.grey.shade400,
                    size: 24,
                  )
                else
                  Icon(
                    Icons.lock_outline,
                    color: Colors.grey.shade400,
                    size: 24,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
