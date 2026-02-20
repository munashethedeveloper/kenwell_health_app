import 'package:flutter/material.dart';
import 'package:kenwell_health_app/ui/shared/ui/app_bar/kenwell_app_bar.dart';

import '../../../shared/ui/form/kenwell_modern_section_header.dart';

class HealthScreeningsScreen extends StatelessWidget {
  final bool hraEnabled;
  final bool hivEnabled;
  final bool tbEnabled;
  final bool hraCompleted;
  final bool hivCompleted;
  final bool tbCompleted;
  final VoidCallback? onHraTap;
  final VoidCallback? onHivTap;
  final VoidCallback? onTbTap;
  final VoidCallback? onSubmitAll;
  final PreferredSizeWidget? appBar;

  const HealthScreeningsScreen({
    super.key,
    required this.hraEnabled,
    required this.hivEnabled,
    required this.tbEnabled,
    this.hraCompleted = false,
    this.hivCompleted = false,
    this.tbCompleted = false,
    this.onHraTap,
    this.onHivTap,
    this.onTbTap,
    this.onSubmitAll,
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
                subtitle: 'Evaluate your health risks',
                isEnabled: hraEnabled,
                isCompleted: hraCompleted,
                onTap: onHraTap,
              ),
              const SizedBox(height: 12),
            ],

            if (hivEnabled) ...[
              _ScreeningCard(
                icon: Icons.vaccines,
                title: 'HIV Screening',
                subtitle: 'HIV testing and counseling',
                isEnabled: hivEnabled,
                isCompleted: hivCompleted,
                onTap: onHivTap,
              ),
              const SizedBox(height: 12),
            ],

            if (tbEnabled) ...[
              _ScreeningCard(
                icon: Icons.healing,
                title: 'TB Screening',
                subtitle: 'Tuberculosis testing',
                isEnabled: tbEnabled,
                isCompleted: tbCompleted,
                onTap: onTbTap,
              ),
              const SizedBox(height: 24),
            ],

            // Submit All Button
            if (onSubmitAll != null &&
                _allEnabledScreeningsCompleted(
                  hraEnabled: hraEnabled,
                  hivEnabled: hivEnabled,
                  tbEnabled: tbEnabled,
                  hraCompleted: hraCompleted,
                  hivCompleted: hivCompleted,
                  tbCompleted: tbCompleted,
                ))
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: onSubmitAll,
                  icon: const Icon(Icons.check_circle),
                  label: const Text('Complete & Save All Screenings'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),

            if (onSubmitAll != null &&
                !_allEnabledScreeningsCompleted(
                  hraEnabled: hraEnabled,
                  hivEnabled: hivEnabled,
                  tbEnabled: tbEnabled,
                  hraCompleted: hraCompleted,
                  hivCompleted: hivCompleted,
                  tbCompleted: tbCompleted,
                ))
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: theme.colorScheme.outline.withValues(alpha: 0.5),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: theme.colorScheme.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      child: Text(
                        'Complete all consented screenings to submit',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  bool _allEnabledScreeningsCompleted({
    required bool hraEnabled,
    required bool hivEnabled,
    required bool tbEnabled,
    required bool hraCompleted,
    required bool hivCompleted,
    required bool tbCompleted,
  }) {
    // Check if all enabled screenings are completed
    if (hraEnabled && !hraCompleted) return false;
    if (hivEnabled && !hivCompleted) return false;
    if (tbEnabled && !tbCompleted) return false;
    return true;
  }
}

class _ScreeningCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isEnabled;
  final bool isCompleted;
  final VoidCallback? onTap;

  const _ScreeningCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isEnabled,
    this.isCompleted = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color iconContainerColor;
    Color iconColor;
    Color titleColor;
    Color subtitleColor;

    if (!isEnabled) {
      iconContainerColor = Colors.grey.shade200;
      iconColor = Colors.grey[600]!;
      titleColor = Colors.grey.shade600;
      subtitleColor = Colors.grey.shade500;
    } else {
      iconContainerColor = const Color(0xFF90C048).withValues(alpha: 0.15);
      iconColor = const Color(0xFF201C58);
      titleColor = const Color(0xFF201C58);
      subtitleColor = Colors.grey.shade600;
    }

    return Container(
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
          onTap: onTap,
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
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: titleColor,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 13,
                          color: subtitleColor,
                        ),
                      ),
                      if (!isEnabled) ...[
                        const SizedBox(height: 2),
                        Text(
                          'Not consented',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade500,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                      if (isEnabled && isCompleted) ...[
                        const SizedBox(height: 2),
                        Text(
                          'Completed',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.deepPurple[700],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (isEnabled)
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
