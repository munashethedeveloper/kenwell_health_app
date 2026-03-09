import 'package:flutter/material.dart';
import 'package:kenwell_health_app/domain/models/wellness_event.dart';
import 'package:intl/intl.dart';
import 'package:kenwell_health_app/ui/shared/ui/colours/kenwell_colours.dart';
import '../../../shared/ui/app_bar/kenwell_app_bar.dart';
import '../../../shared/ui/form/kenwell_form_card.dart';
import 'health_screening_stats_section.dart';

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
        title: 'Event Statistics',
        subtitle: event.title,
        titleStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
        backgroundColor: KenwellColors.secondaryNavy,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Event Header Card ─────────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    KenwellColors.secondaryNavy,
                    KenwellColors.secondaryNavyLight,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: KenwellColors.secondaryNavy.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: _getStatusColor(event.status)
                          .withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: _getStatusColor(event.status)
                            .withValues(alpha: 0.5),
                      ),
                    ),
                    child: Text(
                      event.status,
                      style: TextStyle(
                        color: _getStatusColor(event.status),
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Event title
                  Text(
                    event.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Date + venue row
                  Row(
                    children: [
                      const Icon(Icons.calendar_today,
                          color: Colors.white60, size: 14),
                      const SizedBox(width: 6),
                      Text(
                        DateFormat('MMM dd, yyyy').format(event.date),
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 13),
                      ),
                      const SizedBox(width: 16),
                      const Icon(Icons.location_on,
                          color: Colors.white60, size: 14),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          event.venue,
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 13),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.access_time,
                          color: Colors.white60, size: 14),
                      const SizedBox(width: 6),
                      Text(
                        '${event.startTime} – ${event.endTime}',
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 13),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ── Key Metrics ───────────────────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: _MetricCard(
                    icon: Icons.flag_outlined,
                    title: 'Expected',
                    value: event.expectedParticipation.toString(),
                    color: Colors.blue.shade600,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _MetricCard(
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
                  child: _MetricCard(
                    icon: Icons.health_and_safety_outlined,
                    title: 'Screened',
                    value: event.screenedCount.toString(),
                    color: Colors.teal.shade600,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _MetricCard(
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
                      _buildDetailRow('Email', event.aeContactEmail, theme),
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
                              padding:
                                  const EdgeInsets.only(bottom: 6),
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
                title: Text('Export as CSV',
                    style: theme.textTheme.bodyMedium),
                subtitle: const Text('Export event data as CSV file'),
                onTap: () {
                  Navigator.of(ctx).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('CSV export coming soon'),
                    ),
                  );
                },
              ),
              ListTile(
                leading:
                    const Icon(Icons.picture_as_pdf, color: Colors.red),
                title: Text('Export as PDF',
                    style: theme.textTheme.bodyMedium),
                subtitle: const Text('Export event report as PDF'),
                onTap: () {
                  Navigator.of(ctx).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('PDF export coming soon'),
                    ),
                  );
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

class _MetricCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color color;

  const _MetricCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: KenwellColors.secondaryNavy,
              fontSize: 26,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
