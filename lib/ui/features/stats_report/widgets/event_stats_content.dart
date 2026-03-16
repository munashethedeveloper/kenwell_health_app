import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../event/view_model/event_view_model.dart';
import '../../../shared/ui/form/kenwell_form_card.dart';
import '../../../../domain/models/wellness_event.dart';
import 'health_screening_stats_section.dart';
import 'package:kenwell_health_app/ui/shared/ui/colours/kenwell_colours.dart';
import 'sections/event_stats_list_section.dart';
import 'sections/live_screening_counts_section.dart';
import 'sections/stats_filter_sheet.dart';
import 'sections/stats_stat_card.dart';
import '../view_model/stats_report_view_model.dart';
import 'package:kenwell_health_app/ui/shared/ui/snackbars/app_snackbar.dart';

/// Reusable event-statistics body.
///
/// Pass [isLiveTab: true] for live (in-progress) events or
/// [isLiveTab: false] for past (completed) events.
/// This widget is used by both [LiveEventsScreen] and [PastEventsScreen].
class EventStatsContent extends StatefulWidget {
  const EventStatsContent({super.key, required this.isLiveTab});

  final bool isLiveTab;

  @override
  State<EventStatsContent> createState() => _EventStatsContentState();
}

class _EventStatsContentState extends State<EventStatsContent> {
  final _searchController = TextEditingController();

  // Filter states
  String? _selectedStatus;
  String? _selectedProvince;
  DateTime? _startDate;
  DateTime? _endDate;

  // Selected screening type for the analytics detail panel.
  // Null means no card is selected (detail panel is hidden).
  String? _selectedScreeningType;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StatsReportViewModel>().loadMemberCount();
    });
    _searchController.addListener(() {
      if (mounted) setState(() {});
    });
  }

  Future<void> _refreshData() async {
    context.read<StatsReportViewModel>().loadMemberCount();
    if (mounted) {
      setState(() {});
      AppSnackbar.showSuccess(context, 'Statistics refreshed',
          duration: const Duration(seconds: 2));
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  int _getActiveFilterCount() {
    int count = 0;
    if (_selectedStatus != null) count++;
    if (_selectedProvince != null) count++;
    if (_startDate != null) count++;
    if (_endDate != null) count++;
    return count;
  }

  bool get _hasActiveFilters => _getActiveFilterCount() > 0;

  Color _getStatusColor(String status) {
    final s = status.toLowerCase();
    if (s == 'scheduled') return Colors.orange;
    if (s == 'in progress' || s == 'in_progress' || s == 'ongoing') {
      return Colors.blue;
    }
    if (s == 'completed' || s == 'finished') return Colors.deepPurple;
    return Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final eventVM = context.watch<EventViewModel>();
    final allEvents = eventVM.events;
    final isLiveTab = widget.isLiveTab;

    // Filter by live/past status
    final tabFilteredEvents = isLiveTab
        ? allEvents.where((e) {
            final s = e.status.toLowerCase();
            return s == WellnessEventStatus.inProgress ||
                s == 'in progress' ||
                s == 'ongoing';
          }).toList()
        : allEvents.where((e) {
            final s = e.status.toLowerCase();
            return s == WellnessEventStatus.completed || s == 'finished';
          }).toList();

    // Search filter
    final searchQuery = _searchController.text.toLowerCase();
    var events = searchQuery.isEmpty
        ? tabFilteredEvents
        : tabFilteredEvents
            .where((e) => e.title.toLowerCase().contains(searchQuery))
            .toList();

    // Status filter
    if (_selectedStatus != null && _selectedStatus != 'All') {
      events = events.where((event) {
        final status = event.status.toLowerCase();
        if (_selectedStatus == 'Scheduled') return status == 'scheduled';
        if (_selectedStatus == 'In Progress') {
          return status == 'in progress' ||
              status == 'in_progress' ||
              status == 'ongoing';
        }
        if (_selectedStatus == 'Completed') {
          return status == 'completed' || status == 'finished';
        }
        return true;
      }).toList();
    }

    // Province filter
    if (_selectedProvince != null && _selectedProvince != 'All') {
      events = events.where((e) => e.province == _selectedProvince).toList();
    }

    // Date range filter
    if (_startDate != null) {
      events = events
          .where((e) =>
              e.date.isAfter(_startDate!.subtract(const Duration(days: 1))))
          .toList();
    }
    if (_endDate != null) {
      events = events
          .where((e) => e.date.isBefore(_endDate!.add(const Duration(days: 1))))
          .toList();
    }

    // Statistics
    final totalExpected =
        events.fold<int>(0, (s, e) => s + e.expectedParticipation);
    final totalScreened = events.fold<int>(0, (s, e) => s + e.screenedCount);
    final completedEvents = events
        .where((e) => e.status == 'Completed' || e.status == 'Finished')
        .length;
    final participationRate = totalExpected > 0
        ? (totalScreened / totalExpected * 100).toStringAsFixed(1)
        : '0.0';
    final scheduledEvents =
        events.where((e) => e.status.toLowerCase() == 'scheduled').length;
    final inProgressEvents = events
        .where((e) =>
            e.status.toLowerCase() == 'in progress' ||
            e.status.toLowerCase() == 'in_progress' ||
            e.status.toLowerCase() == 'ongoing')
        .length;
    final Map<String, int> eventsByProvince = {};
    for (final event in events) {
      final p = event.province.isNotEmpty ? event.province : 'Unknown';
      eventsByProvince[p] = (eventsByProvince[p] ?? 0) + 1;
    }

    return RefreshIndicator(
      onRefresh: _refreshData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Search + filter button ────────────────────────────────────
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w500),
                    decoration: InputDecoration(
                      hintText: 'Search events...',
                      hintStyle:
                          TextStyle(color: Colors.grey.shade500, fontSize: 14),
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: searchQuery.isNotEmpty
                          ? IconButton(
                              icon: Icon(Icons.clear,
                                  color: Colors.grey.shade600, size: 20),
                              onPressed: () => _searchController.clear(),
                            )
                          : null,
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            BorderSide(color: Colors.grey.shade300, width: 1),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            BorderSide(color: Colors.grey.shade300, width: 1),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                            color: theme.colorScheme.primary, width: 2),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Filter button with active-count badge
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Material(
                      color:
                          _hasActiveFilters ? theme.primaryColor : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      child: InkWell(
                        onTap: () => StatsFilterSheet.show(
                          context: context,
                          allEvents: tabFilteredEvents,
                          selectedStatus: _selectedStatus,
                          selectedProvince: _selectedProvince,
                          startDate: _startDate,
                          endDate: _endDate,
                          onStatusChanged: (v) =>
                              setState(() => _selectedStatus = v),
                          onProvinceChanged: (v) =>
                              setState(() => _selectedProvince = v),
                          onStartDateChanged: (v) =>
                              setState(() => _startDate = v),
                          onEndDateChanged: (v) => setState(() => _endDate = v),
                          onClearAll: () => setState(() {
                            _selectedStatus = null;
                            _selectedProvince = null;
                            _startDate = null;
                            _endDate = null;
                          }),
                        ),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: _hasActiveFilters
                                  ? theme.primaryColor
                                  : Colors.grey.shade300,
                            ),
                          ),
                          child: Icon(
                            Icons.tune,
                            size: 22,
                            color: _hasActiveFilters
                                ? Colors.white
                                : Colors.grey[700],
                          ),
                        ),
                      ),
                    ),
                    if (_hasActiveFilters)
                      Positioned(
                        right: -4,
                        top: -4,
                        child: Container(
                          width: 18,
                          height: 18,
                          decoration: BoxDecoration(
                            color: Colors.red.shade600,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 1.5),
                          ),
                          child: Center(
                            child: Text(
                              _getActiveFilterCount().toString(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),

            // ── Active filter chips ───────────────────────────────────────
            if (_hasActiveFilters) ...[
              const SizedBox(height: 10),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    if (_selectedStatus != null)
                      _buildActiveFilterChip(
                        'Status: $_selectedStatus',
                        () => setState(() => _selectedStatus = null),
                        theme,
                      ),
                    if (_selectedProvince != null)
                      _buildActiveFilterChip(
                        'Province: $_selectedProvince',
                        () => setState(() => _selectedProvince = null),
                        theme,
                      ),
                    if (_startDate != null)
                      _buildActiveFilterChip(
                        'From: ${_startDate!.day}/${_startDate!.month}/${_startDate!.year}',
                        () => setState(() => _startDate = null),
                        theme,
                      ),
                    if (_endDate != null)
                      _buildActiveFilterChip(
                        'To: ${_endDate!.day}/${_endDate!.month}/${_endDate!.year}',
                        () => setState(() => _endDate = null),
                        theme,
                      ),
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: () => setState(() {
                        _selectedStatus = null;
                        _selectedProvince = null;
                        _startDate = null;
                        _endDate = null;
                      }),
                      child: Text(
                        'Clear all',
                        style: TextStyle(
                          fontSize: 12,
                          color: theme.primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            if (searchQuery.isNotEmpty || _hasActiveFilters) ...[
              const SizedBox(height: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: theme.primaryColor.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                      color: theme.primaryColor.withValues(alpha: 0.2)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.filter_list_alt,
                        color: theme.primaryColor, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      '${events.length} event${events.length != 1 ? "s" : ""} found',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 20),

            // ── Stat cards ────────────────────────────────────────────────
            Row(children: [
              Expanded(
                child: StatsStatCard(
                  icon: Icons.flag_outlined,
                  title: 'Expected',
                  value: totalExpected.toString(),
                  color: KenwellColors.primaryGreen,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: StatsStatCard(
                  icon: Icons.how_to_reg_outlined,
                  title: 'Registered',
                  value:
                      context.watch<StatsReportViewModel>().isLoadingMemberCount
                          ? '...'
                          : context
                              .watch<StatsReportViewModel>()
                              .memberCount
                              .toString(),
                  color: KenwellColors.primaryGreen,
                ),
              ),
            ]),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(
                child: StatsStatCard(
                  icon: Icons.health_and_safety_outlined,
                  title: 'Screened',
                  value: totalScreened.toString(),
                  color: KenwellColors.primaryGreen,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: StatsStatCard(
                  icon: Icons.person_off_outlined,
                  title: 'No Show',
                  value: (totalExpected - totalScreened).toString(),
                  color: const Color(0xFFBF360C),
                ),
              ),
            ]),
            const SizedBox(height: 24),

            // ── Screening counts (live tab = "Live Counts",
            //                     past tab  = "Health Screening Analytics") ─
            LiveScreeningCountsSection(
              eventIds: events.map((e) => e.id).toList(),
              events: events,
              isLiveTab: isLiveTab,
              selectedServiceType: _selectedScreeningType,
              onCardTapped: (key) {
                setState(() => _selectedScreeningType = key);
              },
            ),
            const SizedBox(height: 16),

            // ── Per-service analytics (shown only when a card is selected) ─
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              transitionBuilder: (child, animation) => FadeTransition(
                opacity: animation,
                child: SizeTransition(
                  sizeFactor: animation,
                  axisAlignment: -1,
                  child: child,
                ),
              ),
              child: _selectedScreeningType != null
                  ? Padding(
                      // Use a stable key so the HealthScreeningStatsSection
                      // widget persists across type changes (avoids re-fetching
                      // Firestore data on each card tap).
                      key: const ValueKey('analytics_panel'),
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding:
                                const EdgeInsets.only(left: 4, bottom: 12),
                            child: Row(
                              children: [
                                Text(
                                  '${_screeningTypeLabel(_selectedScreeningType!)} Analytics',
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF201C58),
                                  ),
                                ),
                                const Spacer(),
                                TextButton.icon(
                                  onPressed: () => setState(
                                      () => _selectedScreeningType = null),
                                  icon: const Icon(Icons.close, size: 16),
                                  label: const Text('Close'),
                                  style: TextButton.styleFrom(
                                    foregroundColor: Colors.grey.shade600,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          HealthScreeningStatsSection(
                            eventIds: events.map((e) => e.id).toList(),
                            selectedType: _selectedScreeningType,
                            sectionSubtitle: isLiveTab
                                ? 'Live screening data from ${events.length} running event${events.length != 1 ? "s" : ""}'
                                : 'Screening data from ${events.length} past event${events.length != 1 ? "s" : ""}',
                          ),
                        ],
                      ),
                    )
                  : const SizedBox.shrink(key: ValueKey('empty')),
            ),
            const SizedBox(height: 24),

            // ── Events by status (filters active only) ────────────────────
            if (_hasActiveFilters) ...[
              KenwellFormCard(
                title: 'Events by Status',
                child: Column(
                  children: [
                    _buildDetailRow('Scheduled', scheduledEvents,
                        Icons.schedule, Colors.orange, theme),
                    const Divider(height: 24),
                    _buildDetailRow('In Progress', inProgressEvents,
                        Icons.play_circle, Colors.blue, theme),
                    const Divider(height: 24),
                    _buildDetailRow('Completed', completedEvents,
                        Icons.check_circle, Colors.deepPurple, theme),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // ── Geographic distribution (filters active only) ─────────────
            if (_hasActiveFilters && eventsByProvince.isNotEmpty) ...[
              KenwellFormCard(
                title: 'Geographic Distribution',
                child: Column(
                  children: eventsByProvince.entries.map((entry) {
                    final isLast = entry == eventsByProvince.entries.last;
                    return Column(
                      children: [
                        _buildDetailRow(entry.key, entry.value,
                            Icons.location_on, Colors.red, theme),
                        if (!isLast) const Divider(height: 24),
                      ],
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // ── Event breakdown list ──────────────────────────────────────
            EventStatsListSection(
              events: events,
              isLiveTab: isLiveTab,
              getStatusColor: _getStatusColor,
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveFilterChip(
      String label, VoidCallback onRemove, ThemeData theme) {
    return Container(
      margin: const EdgeInsets.only(right: 6),
      child: Chip(
        label: Text(label,
            style: TextStyle(
                fontSize: 12,
                color: theme.primaryColor,
                fontWeight: FontWeight.w500)),
        deleteIcon: Icon(Icons.close, size: 14, color: theme.primaryColor),
        onDeleted: onRemove,
        backgroundColor: theme.primaryColor.withValues(alpha: 0.1),
        side: BorderSide(color: theme.primaryColor.withValues(alpha: 0.3)),
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        visualDensity: VisualDensity.compact,
      ),
    );
  }

  /// Maps internal service type keys to display labels for the analytics panel.
  String _screeningTypeLabel(String key) {
    const labels = {
      'hra': 'HRA (Health Risk)',
      'hct': 'HCT (HIV Testing)',
      'tb': 'TB Screening',
      'cancer': 'Cancer Screening',
    };
    return labels[key.toLowerCase()] ?? key.toUpperCase();
  }

  Widget _buildDetailRow(
      String label, int count, IconData icon, Color color, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(label,
                style: theme.textTheme.bodyLarge
                    ?.copyWith(fontWeight: FontWeight.w600)),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [
                color.withValues(alpha: 0.2),
                color.withValues(alpha: 0.1),
              ]),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
            ),
            child: Text(
              count.toString(),
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold, color: color),
            ),
          ),
        ],
      ),
    );
  }
}
