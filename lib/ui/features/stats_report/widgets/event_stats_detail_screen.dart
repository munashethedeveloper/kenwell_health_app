import 'dart:core';
import 'package:flutter/material.dart';
import 'package:kenwell_health_app/domain/models/wellness_event.dart';
import 'package:intl/intl.dart';
import '../../../shared/ui/app_bar/kenwell_app_bar.dart';
import '../../../shared/ui/containers/gradient_container.dart';
import '../../../shared/ui/form/kenwell_form_card.dart';
import '../../../shared/ui/form/kenwell_section_header.dart';

class EventStatsDetailScreen extends StatelessWidget {
  final WellnessEvent event;

  const EventStatsDetailScreen({
    super.key,
    required this.event,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screeningPercentage = event.expectedParticipation > 0
        ? (event.screenedCount / event.expectedParticipation * 100)
            .toStringAsFixed(1)
        : '0.0';

    return Scaffold(
      appBar: KenwellAppBar(
        title: 'Event Statistics: ${event.title}',
        titleColor: Colors.white,
        titleStyle: const TextStyle(
          color: Colors.white,
          //fontWeight: FontWeight.bold,
        ),
        backgroundColor: const Color(0xFF201C58),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const KenwellSectionHeader(
              title: 'Event Details',
              subtitle: 'Detailed information about the wellness event',
              uppercase: true,
            ),
            const SizedBox(height: 24),

            // Event Title Card
            GradientContainer.purpleGreen(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.event, color: Colors.white, size: 32),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          event.title,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _buildInfoRow(
                    Icons.location_on,
                    event.venue,
                    theme,
                  ),
                  const SizedBox(height: 4),
                  _buildInfoRow(
                    Icons.calendar_today,
                    DateFormat('MMM dd, yyyy').format(event.date),
                    theme,
                  ),
                  const SizedBox(height: 4),
                  _buildInfoRow(
                    Icons.access_time,
                    '${event.startTime} - ${event.endTime}',
                    theme,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Status Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: _getStatusColor(event.status).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: _getStatusColor(event.status),
                  width: 2,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _getStatusIcon(event.status),
                    color: _getStatusColor(event.status),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Status: ${event.status}',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: _getStatusColor(event.status),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Key Metrics
            Row(
              children: [
                Expanded(
                  child: _MetricCard(
                    icon: Icons.people,
                    title: 'Screened',
                    value: event.screenedCount.toString(),
                    color: theme.primaryColor,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _MetricCard(
                    icon: Icons.flag,
                    title: 'Expected',
                    value: event.expectedParticipation.toString(),
                    color: Colors.orange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _MetricCard(
                    icon: Icons.trending_up,
                    title: 'Completion',
                    value: '$screeningPercentage%',
                    color: Colors.deepPurple,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _MetricCard(
                    icon: Icons.group,
                    title: 'Remaining',
                    value: (event.expectedParticipation - event.screenedCount)
                        .toString(),
                    color: Colors.red,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Event Details
            KenwellFormCard(
              title: 'Event Details',
              child: Column(
                children: [
                  _buildDetailRow('Town/City', event.townCity, theme),
                  const Divider(),
                  _buildDetailRow('Address', event.address, theme),
                  const Divider(),
                  _buildDetailRow(
                    'On-site Contact',
                    '${event.onsiteContactFirstName} ${event.onsiteContactLastName}',
                    theme,
                  ),
                  const Divider(),
                  _buildDetailRow(
                      'Contact Number', event.onsiteContactNumber, theme),
                  if (event.onsiteContactEmail.isNotEmpty) ...[
                    const Divider(),
                    _buildDetailRow(
                        'Contact Email', event.onsiteContactEmail, theme),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Services Offered
            if (event.servicesRequested.isNotEmpty ||
                event.additionalServicesRequested.isNotEmpty) ...[
              KenwellFormCard(
                title: 'Services Offered',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (event.servicesRequested.isNotEmpty) ...[
                      Text(
                        'Primary Services:',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...event.servicesRequested
                          .split(',')
                          .map((service) => Padding(
                                padding: const EdgeInsets.only(bottom: 4),
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
                    if (event.servicesRequested.isNotEmpty &&
                        event.additionalServicesRequested.isNotEmpty)
                      const SizedBox(height: 16),
                    if (event.additionalServicesRequested.isNotEmpty) ...[
                      Text(
                        'Additional Services:',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...event.additionalServicesRequested
                          .split(',')
                          .map((service) => Padding(
                                padding: const EdgeInsets.only(bottom: 4),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.check_circle_outline,
                                      size: 16,
                                      color: Colors.grey[600],
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
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // AE Facilitator Info (if available)
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
            ],
            const SizedBox(height: 24),

            // Export Button
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

  /* Future<File?> _exportEventAsExcel(BuildContext context) async {
    final excel = Excel.Excel.createExcel(); // create a new excel document
    final sheet = excel['Event Details'];

    // Helper to convert any value to String
    String cv(dynamic value) => value?.toString() ?? '';

    // Append header row
    sheet.appendRow([cv('Field'), cv('Value')]);

    final event = this.event; // assuming this is in your class

    // Prepare data list
    final List<List<dynamic>> details = [
      ['Title', event.title],
      ['Date', DateFormat('yyyy-MM-dd').format(event.date)],
      ['Venue', event.venue],
      ['Address', event.address],
      ['Town/City', event.townCity],
      ['Province', event.province],
      [
        'Onsite Contact Name',
        '${event.onsiteContactFirstName} ${event.onsiteContactLastName}'
      ],
      ['Onsite Contact Number', event.onsiteContactNumber],
      ['Onsite Contact Email', event.onsiteContactEmail],
      [
        'AE Contact Name',
        '${event.aeContactFirstName} ${event.aeContactLastName}'
      ],
      ['AE Contact Number', event.aeContactNumber],
      ['AE Contact Email', event.aeContactEmail],
      [
        'Services Requested',
        event.servicesRequested is List
            ? (event.servicesRequested as List).join(', ')
            : event.servicesRequested.toString()
      ],
      [
        'Additional Services',
        event.additionalServicesRequested is List
            ? (event.additionalServicesRequested as List).join(', ')
            : event.additionalServicesRequested.toString()
      ],
      ['Expected Participation', event.expectedParticipation.toString()],
      ['Nurses', event.nurses.toString()],
      ['Coordinators', event.coordinators.toString()],
      ['Set Up Time', event.setUpTime.toString()],
      ['Start Time', event.startTime.toString()],
      ['End Time', event.endTime.toString()],
      ['Strike Down Time', event.strikeDownTime.toString()],
      ['Medical Aid', event.medicalAid == true ? 'Yes' : 'No'],
      ['Mobile Booths', event.mobileBooths == true ? 'Yes' : 'No'],
      ['Description', event.description ?? ''],
      ['Status', event.status],
      [
        'Actual Start Time',
        event.actualStartTime != null
            ? DateFormat('yyyy-MM-dd HH:mm').format(event.actualStartTime!)
            : ''
      ],
      [
        'Actual End Time',
        event.actualEndTime != null
            ? DateFormat('yyyy-MM-dd HH:mm').format(event.actualEndTime!)
            : ''
      ],
      ['Screened Count', event.screenedCount.toString()],
    ];

    // Append data rows
    for (final row in details) {
      sheet.appendRow([
        cv(row[0]),
        cv(row[1]),
      ]);
    }

    // Encode to bytes
    final fileBytes = excel.encode();
    if (fileBytes == null) return null;

    // Save to file
    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/event_${event.id}.xlsx';
    final file = File(path);
    await file.writeAsBytes(fileBytes, flush: true);

    return file;
  } */

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
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('CSV export coming soon'),
                    ),
                  );
                },
              ),
              /*     ListTile(
                leading: const Icon(Icons.grid_on, color: Colors.green),
                title: Text('Export as Excel Spreadsheet',
                    style: theme.textTheme.bodyMedium),
                subtitle:
                    const Text('Export event data as an Excel (.xlsx) file'),
                onTap: () async {
                  Navigator.of(ctx).pop();
                  try {
                    final file = await _exportEventAsExcel(context);
                    if (file != null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Excel file saved: ${file.path}'),
                          action: SnackBarAction(
                            label: 'Open',
                            onPressed: () {
                              // Optionally implement file opening
                            },
                          ),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Failed to export Excel file.'),
                        ),
                      );
                    }
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error exporting Excel: $e')),
                    );
                  }
                },
              ), */
              ListTile(
                leading: const Icon(Icons.picture_as_pdf, color: Colors.red),
                title: Text('Export as PDF', style: theme.textTheme.bodyMedium),
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

  Widget _buildInfoRow(IconData icon, String text, ThemeData theme) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.white.withValues(alpha: 0.9)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
        ),
      ],
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
                color: Colors.grey[700],
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

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
      case 'finished':
        return Icons.check_circle;
      case 'in progress':
      case 'ongoing':
        return Icons.timelapse;
      case 'cancelled':
        return Icons.cancel;
      case 'scheduled':
      case 'upcoming':
        return Icons.schedule;
      default:
        return Icons.info;
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
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              value,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
