import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kenwell_health_app/domain/constants/role_permissions.dart';
import 'package:kenwell_health_app/domain/models/wellness_event.dart';
import 'package:intl/intl.dart';
import 'package:kenwell_health_app/ui/features/profile/view_model/profile_view_model.dart';
import 'package:kenwell_health_app/ui/shared/ui/colours/kenwell_colours.dart';
import 'package:kenwell_health_app/ui/shared/ui/headers/kenwell_gradient_header.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../../shared/ui/app_bar/kenwell_app_bar.dart';
import '../../../shared/ui/form/kenwell_form_card.dart';
import 'sections/stats_metric_card.dart';
import 'health_screening_stats_section.dart';
import 'package:kenwell_health_app/ui/shared/ui/snackbars/app_snackbar.dart';
import '../services/event_report_exporter.dart';
import 'package:kenwell_health_app/routing/app_routes.dart';

class EventStatsDetailScreen extends StatefulWidget {
  final WellnessEvent event;

  const EventStatsDetailScreen({
    super.key,
    required this.event,
  });

  @override
  State<EventStatsDetailScreen> createState() => _EventStatsDetailScreenState();
}

class _EventStatsDetailScreenState extends State<EventStatsDetailScreen> {
  bool _isExporting = false;

  WellnessEvent get event => widget.event;

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
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () {
              setState(() {});
              AppSnackbar.showSuccess(context, 'Refreshed',
                  duration: const Duration(seconds: 1));
            },
          ),
          TextButton.icon(
            onPressed: () => context.pushNamed(AppRoutes.help),
            icon: const Icon(Icons.help_outline, color: Colors.white),
            label: const Text('Help', style: TextStyle(color: Colors.white)),
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

                  // ── Export Button (management roles only) ─────────────────────
                  if (RolePermissions.canAccessFeature(
                      context.watch<ProfileViewModel>().role,
                      'export_data')) ...[
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _isExporting ? null : _exportToExcel,
                        icon: _isExporting
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.download),
                        label: Text(_isExporting
                            ? 'Exporting…'
                            : 'Export Event Report'),
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
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _exportToExcel() async {
    setState(() => _isExporting = true);
    try {
      final exporter = EventReportExporter();
      final filePath = await exporter.export(event);
      if (!mounted) return;
      _showExportSuccessSheet(filePath);
    } catch (e) {
      if (!mounted) return;
      AppSnackbar.showError(context, 'Export failed: $e');
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  void _showExportSuccessSheet(String filePath) {
    final theme = Theme.of(context);
    final fileName = filePath.split('/').last;

    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Success icon ──────────────────────────────────────────────
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: KenwellColors.primaryGreen.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_circle_outline,
                  size: 40,
                  color: KenwellColors.primaryGreen,
                ),
              ),
              const SizedBox(height: 12),

              // ── Title ─────────────────────────────────────────────────────
              Text(
                'Report Exported!',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: KenwellColors.secondaryNavyDark,
                ),
              ),
              const SizedBox(height: 8),

              // ── Filename ──────────────────────────────────────────────────
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: KenwellColors.neutralBackground,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: KenwellColors.secondaryNavy.withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.table_chart,
                        size: 18, color: KenwellColors.primaryGreen),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        fileName,
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontFamily: 'monospace',
                          color: KenwellColors.secondaryNavyDark,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),

              // ── Location hint ─────────────────────────────────────────────
              Text(
                'Tap "Share File" to open the report in Excel, Google Sheets, '
                'email it, or save it to cloud storage.',
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: Colors.grey.shade600),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),

              // ── Share button ──────────────────────────────────────────────
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    Navigator.of(ctx).pop();
                    await SharePlus.instance.share(
                      ShareParams(
                        files: [XFile(filePath)],
                        subject: '${event.title} – Event Report',
                      ),
                    );
                  },
                  icon: const Icon(Icons.share),
                  label: const Text('Share File'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // ── Dismiss button ────────────────────────────────────────────
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('Dismiss'),
                ),
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

  /* Color _getStatusColor(String status) {
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
  } */
}
