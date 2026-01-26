import 'package:flutter/material.dart';
import 'package:kenwell_health_app/ui/shared/ui/app_bar/kenwell_app_bar.dart';

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
            Text(
              'Select a screening to continue',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // HRA Card
            _ScreeningCard(
              icon: Icons.psychology,
              title: 'Health Risk Assessment',
              subtitle: 'Evaluate your health risks',
              isEnabled: hraEnabled,
              isCompleted: hraCompleted,
              onTap: hraEnabled ? onHraTap : null,
            ),

            const SizedBox(height: 12),

            // HIV Card
            _ScreeningCard(
              icon: Icons.vaccines,
              title: 'HIV Screening',
              subtitle: 'HIV testing and counseling',
              isEnabled: hivEnabled,
              isCompleted: hivCompleted,
              onTap: hivEnabled ? onHivTap : null,
            ),

            const SizedBox(height: 12),

            // TB Card
            _ScreeningCard(
              icon: Icons.healing,
              title: 'TB Screening',
              subtitle: 'Tuberculosis testing',
              isEnabled: tbEnabled,
              isCompleted: tbCompleted,
              onTap: tbEnabled ? onTbTap : null,
            ),

            const SizedBox(height: 24),

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
                    const SizedBox(width: 12),
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
    final theme = Theme.of(context);

    final backgroundColor = isEnabled
        ? theme.primaryColor.withValues(alpha: 0.1)
        : Colors.grey[200]!;
    final iconColor = isEnabled ? theme.primaryColor : Colors.grey[400]!;
    final textColor = isEnabled ? Colors.black87 : Colors.grey[500]!;

    return Card(
      elevation: isEnabled ? 2 : 0,
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
                  color: backgroundColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: textColor,
                      ),
                    ),
                    if (!isEnabled) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Not consented',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: Colors.grey[600],
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                    if (isEnabled && isCompleted) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.check_circle,
                            size: 16,
                            color: Colors.deepPurple[700],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Completed',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: Colors.deepPurple[700],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              if (isCompleted)
                Icon(
                  Icons.check_circle,
                  color: Colors.deepPurple[700],
                  size: 28,
                )
              else if (isEnabled)
                Icon(
                  Icons.chevron_right,
                  color: Colors.grey[600],
                )
              else
                Icon(
                  Icons.lock_outline,
                  color: Colors.grey[400],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
