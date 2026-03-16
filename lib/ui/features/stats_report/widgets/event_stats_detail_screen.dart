import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kenwell_health_app/domain/models/wellness_event.dart';
import 'package:intl/intl.dart';
import 'package:kenwell_health_app/ui/shared/ui/colours/kenwell_colours.dart';
import 'package:kenwell_health_app/ui/shared/ui/headers/kenwell_gradient_header.dart';
import '../../../shared/ui/app_bar/kenwell_app_bar.dart';
import '../../../shared/ui/form/kenwell_form_card.dart';
import 'sections/stats_metric_card.dart';
import 'health_screening_stats_section.dart';
import 'package:kenwell_health_app/ui/shared/ui/snackbars/app_snackbar.dart';

class EventStatsDetailScreen extends StatelessWidget {
  final WellnessEvent event;

  const EventStatsDetailScreen({
    super.key,
    required this.event,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: KenwellAppBar(
        title: 'KenWell365',
        titleStyle: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        automaticallyImplyLeading: true,
        actions: [
          IconButton(
            tooltip: 'Help',
            icon: const Icon(Icons.help_outline, color: Colors.white),
            onPressed: () => context.pushNamed('help'),
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Gradient section header ─────────────────────────────
          KenwellGradientHeader(
            label: 'STATISTICS',
            title: '${event.title}\nStatistics',
            subtitle:
                '${DateFormat('MMM dd, yyyy').format(event.date)} · ${event.venue}',
          ),
          // ── Scrollable content ──────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ── Key Metrics ───────────────────────────────────────────────
                  Row(
                    children: [
                      Expanded(
                        child: StatsMetricCard(
                          icon: Icons.flag_outlined,
                          title: 'Expected',
                          value: event.expectedParticipation.toString(),
                          color: Colors.blue.shade600,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: StatsMetricCard(
                          icon: Icons.how_to_reg_outlined,
                          title: 'Registered',
                          value: event.expectedParticipation.toString(),
                          color: KenwellColors.primaryGreen,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: StatsMetricCard(
                          icon: Icons.health_and_safety_outlined,
                          title: 'Screened',
                          value: event.screenedCount.toString(),
                          color: Colors.teal.shade600,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: StatsMetricCard(
                          icon: Icons.person_off_outlined,
                          title: 'No Show',
                          value: (event.expectedParticipation -
                                  event.screenedCount)
                              .toString(),
                          color: Colors.orange.shade700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // ── Client Organization ────────────────────────────────────────
                  KenwellFormCard(
                    title: 'Client Organization',
                    child: Column(
                      children: [
                        _buildDetailRow('Event Title', event.title, theme),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ── Date & Time ───────────────────────────────────────────────
                  KenwellFormCard(
                    title: 'Date & Time',
                    child: Column(
                      children: [
                        _buildDetailRow(
                            'Date',
                            DateFormat('MMM dd, yyyy').format(event.date),
                            theme),
                        const Divider(),
                        _buildDetailRow('Start Time', event.startTime, theme),
                        const Divider(),
                        _buildDetailRow('End Time', event.endTime, theme),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ── Event Location ────────────────────────────────────────────
                  KenwellFormCard(
                    title: 'Event Location',
                    child: Column(
                      children: [
                        _buildDetailRow('Venue', event.venue, theme),
                        const Divider(),
                        _buildDetailRow('Address', event.address, theme),
                        const Divider(),
                        _buildDetailRow('Town/City', event.townCity, theme),
                        const Divider(),
                        _buildDetailRow('Province', event.province, theme),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ── On-site Contact ───────────────────────────────────────────
                  KenwellFormCard(
                    title: 'On-site Contact',
                    child: Column(
                      children: [
                        _buildDetailRow(
                          'Name',
                          '${event.onsiteContactFirstName} ${event.onsiteContactLastName}',
                          theme,
                        ),
                        const Divider(),
                        _buildDetailRow(
                            'Contact Number', event.onsiteContactNumber, theme),
                        if (event.onsiteContactEmail.isNotEmpty) ...[
                          const Divider(),
                          _buildDetailRow(
                              'Email', event.onsiteContactEmail, theme),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ── AE Facilitator (if available) ─────────────────────────────
                  if (event.aeContactFirstName.isNotEmpty) ...[
                    KenwellFormCard(
                      title: 'AE Facilitator',
                      child: Column(
                        children: [
                          _buildDetailRow(
                            'Name',
                            '${event.aeContactFirstName} ${event.aeContactLastName}',
                            theme,
                          ),
                          const Divider(),
                          _buildDetailRow(
                              'Contact Number', event.aeContactNumber, theme),
                          if (event.aeContactEmail.isNotEmpty) ...[
                            const Divider(),
                            _buildDetailRow(
                                'Email', event.aeContactEmail, theme),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // ── Services Offered ──────────────────────────────────────────
                  if (event.servicesRequested.isNotEmpty) ...[
                    KenwellFormCard(
                      title: 'Services Offered',
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ...event.servicesRequested
                              .split(',')
                              .map((service) => Padding(
                                    padding: const EdgeInsets.only(bottom: 6),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.check_circle,
                                          size: 16,
                                          color: theme.primaryColor,
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            service.trim(),
                                            style: theme.textTheme.bodyMedium,
                                          ),
                                        ),
                                      ],
                                    ),
                                  )),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // ── Health Screening Analytics ────────────────────────────────
                  HealthScreeningStatsSection(eventIds: [event.id]),
                  const SizedBox(height: 24),

                  // ── Export Button ─────────────────────────────────────────────
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _showExportSheet(context),
                      icon: const Icon(Icons.download),
                      label: const Text('Export Event Report'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.all(16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showExportSheet(BuildContext context) {
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.table_chart, color: theme.primaryColor),
                title: Text('Export as CSV', style: theme.textTheme.bodyMedium),
                subtitle: const Text('Export event data as CSV file'),
                onTap: () {
                  Navigator.of(ctx).pop();
                  AppSnackbar.showInfo(context, 'CSV export coming soon');
                },
              ),
              ListTile(
                leading: const Icon(Icons.picture_as_pdf, color: Colors.red),
                title: Text('Export as PDF', style: theme.textTheme.bodyMedium),
                subtitle: const Text('Export event report as PDF'),
                onTap: () {
                  Navigator.of(ctx).pop();
                  AppSnackbar.showInfo(context, 'PDF export coming soon');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: KenwellColors.secondaryNavyDark,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
      case 'finished':
        return Colors.deepPurple;
      case 'in progress':
      case 'in_progress':
      case 'ongoing':
        return Colors.blue;
      case 'cancelled':
        return Colors.red;
      case 'scheduled':
      case 'upcoming':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
}
