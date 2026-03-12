import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../event/view_model/event_view_model.dart';
import '../../../shared/ui/form/kenwell_form_card.dart';
import '../../../../data/repositories_dcl/firestore_member_repository.dart';
import '../../../../data/repositories_dcl/firestore_hra_repository.dart';
import '../../../../data/repositories_dcl/firestore_cancer_screening_repository.dart';
import '../../../../data/repositories_dcl/firestore_tb_screening_repository.dart';
import '../../../../data/repositories_dcl/firestore_hiv_screening_repository.dart';
import '../../../../domain/models/wellness_event.dart';
import '../../../../domain/models/cander_screening.dart';
import '../../../../domain/enums/service_type.dart';
import 'event_stats_detail_screen.dart';
import 'health_screening_stats_section.dart';
import 'package:kenwell_health_app/ui/shared/ui/colours/kenwell_colours.dart';
import 'package:kenwell_health_app/ui/shared/ui/labels/kenwell_section_label.dart';

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
  final _memberRepository = FirestoreMemberRepository();
  int _totalMembers = 0;
  bool _isLoadingMembers = true;

  // Filter states
  String? _selectedStatus;
  String? _selectedProvince;
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    _loadMemberCount();
    _searchController.addListener(() => setState(() {}));
  }

  Future<void> _loadMemberCount() async {
    try {
      setState(() => _isLoadingMembers = true);
      final members = await _memberRepository.fetchAllMembers();
      if (mounted) {
        setState(() {
          _totalMembers = members.length;
          _isLoadingMembers = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoadingMembers = false);
    }
  }

  Future<void> _refreshData() async {
    await _loadMemberCount();
    if (mounted) {
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.refresh, color: Colors.white, size: 20),
              SizedBox(width: 8),
              Text('Statistics refreshed'),
            ],
          ),
          backgroundColor: Theme.of(context).colorScheme.primary,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
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
            // ── Hero banner ───────────────────────────────────────────────
            // _buildHeroBanner(events.length, participationRate, isLiveTab),
            // const SizedBox(height: 20),

            // ── Search + filter ───────────────────────────────────────────
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
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Material(
                      color:
                          _hasActiveFilters ? theme.primaryColor : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      child: InkWell(
                        onTap: () => _showFilterBottomSheet(
                            context, theme, tabFilteredEvents),
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

            // Active filter chips
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

            if (_searchController.text.isNotEmpty || _hasActiveFilters) ...[
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
                child: _StatCard(
                  icon: Icons.flag_outlined,
                  title: 'Expected',
                  value: totalExpected.toString(),
                  color: KenwellColors.primaryGreen,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  icon: Icons.how_to_reg_outlined,
                  title: 'Registered',
                  value: _isLoadingMembers ? '...' : _totalMembers.toString(),
                  //color: const Color(0xFF6A1B9A),
                  color: KenwellColors.primaryGreen,
                ),
              ),
            ]),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(
                child: _StatCard(
                  icon: Icons.health_and_safety_outlined,
                  title: 'Screened',
                  value: totalScreened.toString(),
                  color: KenwellColors.primaryGreen,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  icon: Icons.person_off_outlined,
                  title: 'No Show',
                  value: (totalExpected - totalScreened).toString(),
                  color: const Color(0xFFBF360C),
                ),
              ),
            ]),
            const SizedBox(height: 24),

            // ── Live screening counts (live only) ─────────────────────────
            if (isLiveTab) ...[
              _LiveScreeningCountsSection(
                eventIds: events.map((e) => e.id).toList(),
                events: events,
              ),
              const SizedBox(height: 24),
            ],

            // ── Health screening analytics ────────────────────────────────
            HealthScreeningStatsSection(
              eventIds: events.map((e) => e.id).toList(),
              sectionSubtitle: isLiveTab
                  ? 'Live screening data from ${events.length} currently running event${events.length != 1 ? "s" : ""}'
                  : 'Screening data from ${events.length} past event${events.length != 1 ? "s" : ""}',
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
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Breakdown header
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: isLiveTab
                                ? [
                                    KenwellColors.primaryGreen,
                                    const Color(0xFF065F46)
                                  ]
                                : [
                                    KenwellColors.secondaryNavy,
                                    const Color(0xFF3B3F86)
                                  ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          isLiveTab ? Icons.play_circle_outline : Icons.history,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        isLiveTab
                            ? 'Live Event Breakdown'
                            : 'Past Event Breakdown',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: KenwellColors.secondaryNavy,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  const Divider(height: 1, color: KenwellColors.neutralDivider),
                  const SizedBox(height: 12),
                  if (events.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(22),
                              decoration: const BoxDecoration(
                                color: KenwellColors.neutralBackground,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(Icons.event_busy,
                                  size: 44, color: Colors.grey[400]),
                            ),
                            const SizedBox(height: 14),
                            Text(
                              isLiveTab ? 'No live events' : 'No past events',
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: KenwellColors.secondaryNavy,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              isLiveTab
                                  ? 'Events currently in progress will appear here'
                                  : 'Completed events will appear here',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF6B7280),
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    ...events.map((event) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      EventStatsDetailScreen(event: event),
                                ),
                              ),
                              borderRadius: BorderRadius.circular(14),
                              child: Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: KenwellColors.neutralBackground,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: KenwellColors.neutralDivider,
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    // Gradient icon
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: isLiveTab
                                              ? [
                                                  KenwellColors.primaryGreen,
                                                  const Color(0xFF065F46)
                                                ]
                                              : [
                                                  KenwellColors.secondaryNavy,
                                                  const Color(0xFF3B3F86)
                                                ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: const Icon(Icons.event,
                                          color: Colors.white, size: 18),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            event.title,
                                            style: const TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                              color:
                                                  KenwellColors.secondaryNavy,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 4),
                                          Row(
                                            children: [
                                              Icon(Icons.calendar_today,
                                                  size: 12,
                                                  color: Colors.grey[500]),
                                              const SizedBox(width: 3),
                                              Text(
                                                '${event.date.day}/${event.date.month}/${event.date.year}',
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  color: Colors.grey[500],
                                                ),
                                              ),
                                              const SizedBox(width: 10),
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 7,
                                                        vertical: 2),
                                                decoration: BoxDecoration(
                                                  color: _getStatusColor(
                                                          event.status)
                                                      .withValues(alpha: 0.12),
                                                  borderRadius:
                                                      BorderRadius.circular(6),
                                                ),
                                                child: Text(
                                                  event.status,
                                                  style: TextStyle(
                                                    fontSize: 9,
                                                    color: _getStatusColor(
                                                        event.status),
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    // Screened count badge
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 14, vertical: 8),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: isLiveTab
                                              ? [
                                                  KenwellColors.primaryGreen,
                                                  const Color(0xFF065F46)
                                                ]
                                              : [
                                                  KenwellColors.secondaryNavy,
                                                  const Color(0xFF3B3F86)
                                                ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Text(
                                        '${event.screenedCount}',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w800,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Icon(Icons.chevron_right,
                                        color: Colors.grey.shade400),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        )),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  /*  Widget _buildHeroBanner(
      int eventCount, String participationRate, bool isLiveTab) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isLiveTab
              ? [
                  KenwellColors.primaryGreenDark,
                  const Color(0xFF065F46),
                  const Color(0xFF064E3B)
                ]
              : [
                  KenwellColors.secondaryNavy,
                  const Color(0xFF2E2880),
                  KenwellColors.primaryGreenDark,
                ],
          stops: const [0.0, 0.55, 1.0],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: (isLiveTab
                    ? const Color(0xFF059669)
                    : KenwellColors.secondaryNavy)
                .withValues(alpha: 0.35),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section label + icon row
          Row(
            children: [
              KenwellSectionLabel(
                  label: isLiveTab ? 'LIVE EVENTS' : 'PAST EVENTS'),
              const Spacer(),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  isLiveTab
                      ? Icons.play_circle_outline_rounded
                      : Icons.history_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Main stats row
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$eventCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 44,
                        fontWeight: FontWeight.w900,
                        height: 1,
                        letterSpacing: -1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Event${eventCount != 1 ? "s" : ""} ${isLiveTab ? "in progress" : "completed"}',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.75),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              // Participation rate badge
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                          color: Colors.white.withValues(alpha: 0.25)),
                    ),
                    child: Column(
                      children: [
                        Text(
                          '$participationRate%',
                          style: const TextStyle(
                            color: KenwellColors.primaryGreenLight,
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            height: 1,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'participation',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.65),
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  } */

  void _showFilterBottomSheet(
      BuildContext context, ThemeData theme, List<WellnessEvent> allEvents) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              padding: EdgeInsets.fromLTRB(
                  20, 12, 20, MediaQuery.of(ctx).viewInsets.bottom + 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(2)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Text(
                        'Filters',
                        style: theme.textTheme.titleLarge
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const Spacer(),
                      if (_hasActiveFilters)
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _selectedStatus = null;
                              _selectedProvince = null;
                              _startDate = null;
                              _endDate = null;
                            });
                            setSheetState(() {});
                          },
                          child: const Text('Clear all'),
                        ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const Divider(),
                  const SizedBox(height: 8),
                  Text(
                    'Status',
                    style: theme.textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w600, color: Colors.grey[700]),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children:
                        ['Scheduled', 'In Progress', 'Completed'].map((status) {
                      final isSelected = _selectedStatus == status;
                      return FilterChip(
                        label: Text(status),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(
                              () => _selectedStatus = selected ? status : null);
                          setSheetState(() {});
                        },
                        backgroundColor: Colors.white,
                        selectedColor:
                            theme.primaryColor.withValues(alpha: 0.2),
                        checkmarkColor: theme.primaryColor,
                        labelStyle: TextStyle(
                          color: isSelected
                              ? theme.primaryColor
                              : Colors.grey[700],
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.normal,
                        ),
                        side: BorderSide(
                          color: isSelected
                              ? theme.primaryColor
                              : Colors.grey.shade300,
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  if (allEvents
                      .map((e) => e.province)
                      .where((p) => p.isNotEmpty)
                      .toSet()
                      .isNotEmpty) ...[
                    Text(
                      'Province',
                      style: theme.textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w600, color: Colors.grey[700]),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: (allEvents
                              .map((e) => e.province)
                              .where((p) => p.isNotEmpty)
                              .toSet()
                              .toList()
                            ..sort())
                          .map((province) {
                        final isSelected = _selectedProvince == province;
                        return FilterChip(
                          label: Text(province),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() =>
                                _selectedProvince = selected ? province : null);
                            setSheetState(() {});
                          },
                          backgroundColor: Colors.white,
                          selectedColor:
                              theme.primaryColor.withValues(alpha: 0.2),
                          checkmarkColor: theme.primaryColor,
                          labelStyle: TextStyle(
                            color: isSelected
                                ? theme.primaryColor
                                : Colors.grey[700],
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                          side: BorderSide(
                            color: isSelected
                                ? theme.primaryColor
                                : Colors.grey.shade300,
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                  ],
                  Text(
                    'Date Range',
                    style: theme.textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w600, color: Colors.grey[700]),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _buildDateButton(
                          label: _startDate == null
                              ? 'Start Date'
                              : '${_startDate!.day}/${_startDate!.month}/${_startDate!.year}',
                          isSet: _startDate != null,
                          theme: theme,
                          onTap: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: _startDate ?? DateTime.now(),
                              firstDate: DateTime(2020),
                              lastDate: DateTime(2030),
                            );
                            if (picked != null) {
                              setState(() => _startDate = picked);
                              setSheetState(() {});
                            }
                          },
                          onClear: _startDate != null
                              ? () {
                                  setState(() => _startDate = null);
                                  setSheetState(() {});
                                }
                              : null,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildDateButton(
                          label: _endDate == null
                              ? 'End Date'
                              : '${_endDate!.day}/${_endDate!.month}/${_endDate!.year}',
                          isSet: _endDate != null,
                          theme: theme,
                          onTap: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: _endDate ?? DateTime.now(),
                              firstDate: DateTime(2020),
                              lastDate: DateTime(2030),
                            );
                            if (picked != null) {
                              setState(() => _endDate = picked);
                              setSheetState(() {});
                            }
                          },
                          onClear: _endDate != null
                              ? () {
                                  setState(() => _endDate = null);
                                  setSheetState(() {});
                                }
                              : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(ctx),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text(
                        'Apply Filters',
                        style: TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 15),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
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

  Widget _buildDateButton({
    required String label,
    required bool isSet,
    required ThemeData theme,
    required VoidCallback onTap,
    VoidCallback? onClear,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            border: Border.all(
                color: isSet ? theme.primaryColor : Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(Icons.calendar_today,
                  size: 16,
                  color: isSet ? theme.primaryColor : Colors.grey[600]),
              const SizedBox(width: 8),
              Expanded(
                child: Text(label,
                    style: TextStyle(
                        fontSize: 13,
                        color: isSet ? theme.primaryColor : Colors.grey[600],
                        fontWeight:
                            isSet ? FontWeight.w600 : FontWeight.normal)),
              ),
              if (onClear != null)
                GestureDetector(
                  onTap: onClear,
                  child: Icon(Icons.close, size: 16, color: Colors.grey[600]),
                ),
            ],
          ),
        ),
      ),
    );
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

// ── Internal sub-widgets ─────────────────────────────────────────────────────

/// Displays live screening count cards.  Only shown on the Live Events view.
class _LiveScreeningCountsSection extends StatefulWidget {
  final List<String> eventIds;
  final List<WellnessEvent> events;

  const _LiveScreeningCountsSection({
    required this.eventIds,
    required this.events,
  });

  @override
  State<_LiveScreeningCountsSection> createState() =>
      _LiveScreeningCountsSectionState();
}

class _LiveScreeningCountsSectionState
    extends State<_LiveScreeningCountsSection> {
  final _hraRepo = FirestoreHraRepository();
  final _cancerRepo = FirestoreCancerScreeningRepository();
  final _tbRepo = FirestoreTbScreeningRepository();
  final _hivRepo = FirestoreHivScreeningRepository();

  bool _isLoading = true;
  int _hraCount = 0;
  int _hctCount = 0;
  int _tbCount = 0;
  int _papSmearCount = 0;
  int _breastScreeningCount = 0;
  int _psaCount = 0;

  Set<ServiceType> get _activeServices {
    final services = <ServiceType>{};
    for (final event in widget.events) {
      services.addAll(
          ServiceTypeConverter.fromStorageString(event.servicesRequested));
    }
    return services;
  }

  @override
  void initState() {
    super.initState();
    _loadCounts();
  }

  @override
  void didUpdateWidget(_LiveScreeningCountsSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    final oldSet = oldWidget.eventIds.toSet();
    final newSet = widget.eventIds.toSet();
    if (oldSet.length != newSet.length || !oldSet.containsAll(newSet)) {
      _loadCounts();
    }
  }

  Future<void> _loadCounts() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final ids = widget.eventIds;
      if (ids.isEmpty) {
        if (mounted) {
          setState(() {
            _hraCount = _hctCount = _tbCount = 0;
            _papSmearCount = _breastScreeningCount = _psaCount = 0;
            _isLoading = false;
          });
        }
        return;
      }
      final results = await Future.wait(<Future<dynamic>>[
        _hraRepo.getHraScreeningsByEvents(ids),
        _cancerRepo.getCancerScreeningsByEvents(ids),
        _tbRepo.getTbScreeningsByEvents(ids),
        _hivRepo.getHivScreeningsByEvents(ids),
      ]);
      final hraList = List<dynamic>.from(results[0] as List);
      final cancerList = List<CancerScreening>.from(results[1] as List);
      final tbList = List<dynamic>.from(results[2] as List);
      final hivList = List<dynamic>.from(results[3] as List);
      final papCount = cancerList
          .where((s) => s.papSmearSpecimenCollected?.toLowerCase() == 'yes')
          .length;
      final breastCount = cancerList
          .where((s) =>
              s.breastLightExamFindings != null &&
              s.breastLightExamFindings!.isNotEmpty)
          .length;
      final psaCount = cancerList
          .where((s) => s.psaResults != null && s.psaResults!.isNotEmpty)
          .length;
      if (mounted) {
        setState(() {
          _hraCount = hraList.length;
          _hctCount = hivList.length;
          _tbCount = tbList.length;
          _papSmearCount = papCount;
          _breastScreeningCount = breastCount;
          _psaCount = psaCount;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('LiveScreeningCounts: failed to load: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final allScreenings = [
      _ScreeningCount(ServiceType.hra, 'HRA', _hraCount,
          Icons.monitor_heart_outlined, Colors.teal.shade600),
      _ScreeningCount(ServiceType.hct, 'HCT', _hctCount,
          Icons.bloodtype_outlined, Colors.red.shade600),
      _ScreeningCount(ServiceType.tbTest, 'TB', _tbCount, Icons.air_outlined,
          Colors.amber.shade700),
      _ScreeningCount(ServiceType.papSmear, 'Pap Smear', _papSmearCount,
          Icons.science_outlined, Colors.purple.shade500),
      _ScreeningCount(ServiceType.breastScreening, 'Breast',
          _breastScreeningCount, Icons.favorite_border, Colors.pink.shade500),
      _ScreeningCount(ServiceType.psa, 'PSA', _psaCount, Icons.biotech_outlined,
          Colors.indigo.shade500),
    ];
    final activeServices = _activeServices;
    final screenings = activeServices.isEmpty
        ? allScreenings
        : allScreenings
            .where((s) => activeServices.contains(s.serviceType))
            .toList();

    return KenwellFormCard(
      useGradient: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.local_hospital_outlined,
                    color: KenwellColors.primaryGreen, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Live Screening Counts',
                      style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: KenwellColors.secondaryNavy),
                    ),
                    Text(
                      'People screened for each requested service',
                      style:
                          TextStyle(fontSize: 12, color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
              if (_isLoading)
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: KenwellColors.primaryGreen),
                ),
            ],
          ),
          const SizedBox(height: 16),
          if (widget.eventIds.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Center(
                child: Text(
                  'No live events to show screening data for',
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
                ),
              ),
            )
          else
            GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 1.05,
              children: screenings
                  .map((s) => _ScreeningCountCard(
                        label: s.label,
                        count: _isLoading ? null : s.count,
                        icon: s.icon,
                        color: s.color,
                      ))
                  .toList(),
            ),
        ],
      ),
    );
  }
}

class _ScreeningCount {
  final ServiceType serviceType;
  final String label;
  final int count;
  final IconData icon;
  final Color color;
  const _ScreeningCount(
      this.serviceType, this.label, this.count, this.icon, this.color);
}

class _ScreeningCountCard extends StatelessWidget {
  final String label;
  final int? count;
  final IconData icon;
  final Color color;
  const _ScreeningCountCard(
      {required this.label,
      required this.count,
      required this.icon,
      required this.color});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: theme.primaryColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            // color: const Color(0xFF6A1B9A).withValues(alpha: 0.45), width: 1.5),
            color: KenwellColors.primaryGreen.withValues(alpha: 0.45),
            width: 1.5),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 6),
          count == null
              ? SizedBox(
                  width: 18,
                  height: 18,
                  child:
                      CircularProgressIndicator(strokeWidth: 2, color: color))
              : Text(
                  count.toString(),
                  style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: KenwellColors.secondaryNavy,
                      fontSize: 22),
                ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
                fontSize: 11,
                color: Colors.grey.shade700,
                fontWeight: FontWeight.w600),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color color;
  const _StatCard(
      {required this.icon,
      required this.title,
      required this.value,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: color.withValues(alpha: 0.2), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Gradient icon container
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color, color.withValues(alpha: 0.7)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.3),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: KenwellColors.secondaryNavy,
              height: 1,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            title,
            style: const TextStyle(
              fontSize: 11,
              color: Color(0xFF6B7280),
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}
