import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../event/view_model/event_view_model.dart';
import '../../../shared/ui/app_bar/kenwell_app_bar.dart';
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

class StatsReportScreen extends StatefulWidget {
  const StatsReportScreen({super.key});

  @override
  State<StatsReportScreen> createState() => _StatsReportScreenState();
}

class _StatsReportScreenState extends State<StatsReportScreen>
    with SingleTickerProviderStateMixin {
  final _searchController = TextEditingController();
  final _memberRepository = FirestoreMemberRepository();
  int _totalMembers = 0;
  bool _isLoadingMembers = true;

  // Tab controller for Live vs Past events
  late TabController _tabController;

  // Filter states
  String? _selectedStatus;
  String? _selectedProvince;
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {});
      }
    });
    _loadMemberCount();
    _searchController.addListener(() {
      setState(() {}); // Rebuild when search text changes
    });
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
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingMembers = false);
      }
    }
  }

  Future<void> _refreshData() async {
    // Reload member count
    await _loadMemberCount();
    // Events are automatically reloaded via EventViewModel's watch
    if (mounted) {
      setState(() {}); // Trigger rebuild
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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
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
    final statusLower = status.toLowerCase();
    if (statusLower == 'scheduled') return Colors.orange;
    if (statusLower == 'in progress' ||
        statusLower == 'in_progress' ||
        statusLower == 'ongoing') {
      return Colors.blue;
    }
    if (statusLower == 'completed' || statusLower == 'finished') {
      return Colors.deepPurple;
    }
    return Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final eventVM = context.watch<EventViewModel>();
    final allEvents = eventVM.events;

    // Filter events based on active tab (Live = in-progress, Past = completed)
    final isLiveTab = _tabController.index == 0;
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

    // Filter events based on search query
    final searchQuery = _searchController.text.toLowerCase();
    var events = searchQuery.isEmpty
        ? tabFilteredEvents
        : tabFilteredEvents
            .where((event) => event.title.toLowerCase().contains(searchQuery))
            .toList();

    // Apply status filter
    if (_selectedStatus != null && _selectedStatus != 'All') {
      events = events.where((event) {
        final status = event.status.toLowerCase();
        if (_selectedStatus == 'Scheduled') {
          return status == 'scheduled';
        } else if (_selectedStatus == 'In Progress') {
          return status == 'in progress' ||
              status == 'in_progress' ||
              status == 'ongoing';
        } else if (_selectedStatus == 'Completed') {
          return status == 'completed' || status == 'finished';
        }
        return true;
      }).toList();
    }

    // Apply province filter
    if (_selectedProvince != null && _selectedProvince != 'All') {
      events =
          events.where((event) => event.province == _selectedProvince).toList();
    }

    // Apply date range filter
    if (_startDate != null) {
      events = events
          .where((event) =>
              event.date.isAfter(_startDate!.subtract(const Duration(days: 1))))
          .toList();
    }
    if (_endDate != null) {
      events = events
          .where((event) =>
              event.date.isBefore(_endDate!.add(const Duration(days: 1))))
          .toList();
    }

    // Calculate statistics
    final totalExpected =
        events.fold<int>(0, (sum, event) => sum + event.expectedParticipation);
    final totalScreened =
        events.fold<int>(0, (sum, event) => sum + event.screenedCount);
    final completedEvents = events
        .where((e) => e.status == 'Completed' || e.status == 'Finished')
        .length;

    // Calculate participation rate
    final participationRate = totalExpected > 0
        ? (totalScreened / totalExpected * 100).toStringAsFixed(1)
        : '0.0';

    // Events by status
    final scheduledEvents =
        events.where((e) => e.status.toLowerCase() == 'scheduled').length;
    final inProgressEvents = events
        .where((e) =>
            e.status.toLowerCase() == 'in progress' ||
            e.status.toLowerCase() == 'in_progress' ||
            e.status.toLowerCase() == 'ongoing')
        .length;

    // Geographic distribution (by province)
    final Map<String, int> eventsByProvince = {};
    for (var event in events) {
      final province = event.province.isNotEmpty ? event.province : 'Unknown';
      eventsByProvince[province] = (eventsByProvince[province] ?? 0) + 1;
    }

    // Monthly trend - events by month
    final Map<String, int> eventsByMonth = {};
    for (var event in events) {
      final monthYear =
          '${event.date.year}-${event.date.month.toString().padLeft(2, '0')}';
      eventsByMonth[monthYear] = (eventsByMonth[monthYear] ?? 0) + 1;
    }
    //final sortedMonths = eventsByMonth.keys.toList()..sort();

    return Scaffold(
        appBar: KenwellAppBar(
          title: 'KenWell365',
          //titleColor: const Color(0xFF201C58),
          titleStyle: const TextStyle(
            //color: Color(0xFF201C58),
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
          automaticallyImplyLeading: false,
          actions: [
            IconButton(
              tooltip: 'Refresh',
              icon: const Icon(Icons.refresh, color: Colors.white),
              onPressed: _refreshData,
            ),
            TextButton.icon(
              onPressed: () {
                if (mounted) {
                  context.pushNamed('help');
                }
              },
              icon: const Icon(Icons.help_outline, color: Colors.white),
              label: const Text(
                'Help',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        body: RefreshIndicator(
          onRefresh: _refreshData,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── Page title row ─────────────────────────────────────────
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color:
                            KenwellColors.primaryGreen.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.analytics_outlined,
                        color: KenwellColors.secondaryNavy,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Wellness Statistics',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: KenwellColors.secondaryNavy,
                              fontSize: 22,
                            ),
                          ),
                          Text(
                            'Events and participation overview',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // ── Hero summary banner ────────────────────────────────────
                _buildHeroBanner(events.length, participationRate, isLiveTab),

                const SizedBox(height: 20),

                // ── Tab bar ────────────────────────────────────────────────
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.all(4),
                  child: TabBar(
                    controller: _tabController,
                    tabs: const [
                      Tab(
                        icon: Icon(Icons.play_circle_outline, size: 20),
                        text: 'Live Events',
                        iconMargin: EdgeInsets.only(bottom: 2),
                      ),
                      Tab(
                        icon: Icon(Icons.history, size: 20),
                        text: 'Past Events',
                        iconMargin: EdgeInsets.only(bottom: 2),
                      ),
                    ],
                    labelColor: KenwellColors.secondaryNavy,
                    unselectedLabelColor: Colors.grey.shade500,
                    labelStyle: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                    unselectedLabelStyle: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 13,
                    ),
                    indicatorSize: TabBarIndicatorSize.tab,
                    indicator: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(9),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    dividerColor: Colors.transparent,
                    splashFactory: NoSplash.splashFactory,
                  ),
                ),

                const SizedBox(height: 16),

                // Search bar with inline filter button
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Search events...',
                          hintStyle: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 14,
                          ),
                          prefixIcon: const Icon(Icons.search),
                          suffixIcon: searchQuery.isNotEmpty
                              ? IconButton(
                                  icon: Icon(
                                    Icons.clear,
                                    color: Colors.grey.shade600,
                                    size: 20,
                                  ),
                                  onPressed: () {
                                    _searchController.clear();
                                  },
                                )
                              : null,
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                                color: Colors.grey.shade300, width: 1),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                                color: Colors.grey.shade300, width: 1),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: theme.colorScheme.primary,
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Small filter button with active count badge
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Material(
                          color: _hasActiveFilters
                              ? theme.primaryColor
                              : Colors.white,
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
                                border:
                                    Border.all(color: Colors.white, width: 1.5),
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
                // Active filter chips shown below search bar
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
                const SizedBox(height: 8),

                // Search results indicator
                if (_searchController.text.isNotEmpty || _hasActiveFilters)
                  Container(
                    margin: const EdgeInsets.only(bottom: 0),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: theme.primaryColor.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: theme.primaryColor.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.filter_list_alt,
                          color: theme.primaryColor,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${events.length} event${events.length != 1 ? 's' : ''} found',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.primaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 20),

                // ── Stat Cards ────────────────────────────────────────────
                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        icon: Icons.flag_outlined,
                        title: 'Expected',
                        value: totalExpected.toString(),
                        color: KenwellColors.secondaryNavy,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatCard(
                        icon: Icons.how_to_reg_outlined,
                        title: 'Registered',
                        value: _isLoadingMembers
                            ? '...'
                            : _totalMembers.toString(),
                        color: const Color(0xFF6A1B9A),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        icon: Icons.health_and_safety_outlined,
                        title: 'Screened',
                        value: totalScreened.toString(),
                        color: KenwellColors.primaryGreenDark,
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
                  ],
                ),
                const SizedBox(height: 24),

                // ── Live Screening Counts (live tab only) ─────────────────
                if (isLiveTab) ...[
                  _LiveScreeningCountsSection(
                    eventIds: events.map((e) => e.id).toList(),
                    events: events,
                  ),
                  const SizedBox(height: 24),
                ],

                // ── Health Screening Analytics (scoped to current tab) ────
                HealthScreeningStatsSection(
                  eventIds: events.map((e) => e.id).toList(),
                  sectionSubtitle: isLiveTab
                      ? 'Live screening data from '
                          '${events.length} currently running '
                          'event${events.length != 1 ? "s" : ""}'
                      : 'Screening data from '
                          '${events.length} past '
                          'event${events.length != 1 ? "s" : ""}',
                ),
                const SizedBox(height: 24),

                // ── Events by Status (only when filters are active) ───────
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

                // ── Geographic Distribution (only when filters active) ─────
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

                // ── Event Breakdown ───────────────────────────────────────
                KenwellFormCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            isLiveTab
                                ? Icons.play_circle_outline
                                : Icons.history,
                            color: theme.primaryColor,
                            size: 24,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            isLiveTab
                                ? 'Live Event Breakdown'
                                : 'Past Event Breakdown',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      if (events.isEmpty)
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(32),
                            child: Column(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(24),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade100,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.event_busy,
                                    size: 48,
                                    color: Colors.grey[400],
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  isLiveTab
                                      ? 'No live events'
                                      : 'No past events',
                                  style: theme.textTheme.bodyLarge?.copyWith(
                                    color: Colors.grey[600],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  isLiveTab
                                      ? 'Events currently in progress will appear here'
                                      : 'Completed events will appear here',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: Colors.grey[500],
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        )
                      else
                        ...events.map((event) => Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            EventStatsDetailScreen(
                                          event: event,
                                        ),
                                      ),
                                    );
                                  },
                                  borderRadius: BorderRadius.circular(12),
                                  child: Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: theme.primaryColor
                                          .withValues(alpha: 0.05),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: theme.primaryColor
                                            .withValues(alpha: 0.15),
                                        width: 1.5,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(10),
                                          decoration: BoxDecoration(
                                            color: theme.primaryColor
                                                .withValues(alpha: 0.1),
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          child: Icon(
                                            Icons.event,
                                            color: theme.primaryColor,
                                            size: 20,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                event.title,
                                                style: theme
                                                    .textTheme.bodyMedium
                                                    ?.copyWith(
                                                  fontWeight: FontWeight.w600,
                                                  color: theme.primaryColor,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Row(
                                                children: [
                                                  Icon(
                                                    Icons.calendar_today,
                                                    size: 14,
                                                    color: Colors.grey[600],
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    '${event.date.day}/${event.date.month}/${event.date.year}',
                                                    style: theme
                                                        .textTheme.bodySmall
                                                        ?.copyWith(
                                                      color: Colors.grey[600],
                                                    ),
                                                  ),
                                                  const SizedBox(width: 12),
                                                  Container(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                      horizontal: 8,
                                                      vertical: 2,
                                                    ),
                                                    decoration: BoxDecoration(
                                                      color: _getStatusColor(
                                                              event.status)
                                                          .withValues(
                                                              alpha: 0.15),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              4),
                                                    ),
                                                    child: Text(
                                                      event.status,
                                                      style: theme
                                                          .textTheme.labelSmall
                                                          ?.copyWith(
                                                        color: _getStatusColor(
                                                            event.status),
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 16, vertical: 8),
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [
                                                theme.primaryColor,
                                                theme.primaryColor
                                                    .withValues(alpha: 0.8),
                                              ],
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            boxShadow: [
                                              BoxShadow(
                                                color: theme.primaryColor
                                                    .withValues(alpha: 0.3),
                                                blurRadius: 8,
                                                offset: const Offset(0, 2),
                                              ),
                                            ],
                                          ),
                                          child: Text(
                                            event.screenedCount.toString(),
                                            style: theme.textTheme.labelLarge
                                                ?.copyWith(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Icon(
                                          Icons.chevron_right,
                                          color: theme.primaryColor,
                                        ),
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
        ));
  }

  Widget _buildHeroBanner(
      int eventCount, String participationRate, bool isLiveTab) {
    return Container(
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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isLiveTab ? 'Live Events' : 'Past Events',
                  style: const TextStyle(
                    color: Colors.white60,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$eventCount Event${eventCount != 1 ? "s" : ""}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: KenwellColors.primaryGreen.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: KenwellColors.primaryGreen.withValues(alpha: 0.5),
                    ),
                  ),
                  child: Text(
                    isLiveTab ? 'In Progress' : 'Completed',
                    style: const TextStyle(
                      color: KenwellColors.primaryGreen,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text(
                'Participation',
                style: TextStyle(color: Colors.white60, fontSize: 12),
              ),
              const SizedBox(height: 2),
              Text(
                '$participationRate%',
                style: const TextStyle(
                  color: KenwellColors.primaryGreen,
                  fontSize: 34,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const Text(
                'Rate',
                style: TextStyle(color: Colors.white60, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showFilterBottomSheet(
      BuildContext context, ThemeData theme, List<dynamic> allEvents) {
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
                  // Handle bar
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Header
                  Row(
                    children: [
                      Text(
                        'Filters',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
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
                  // Status
                  Text(
                    'Status',
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[700],
                    ),
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
                  // Province
                  if (allEvents
                      .map((e) => e.province)
                      .where((p) => p.isNotEmpty)
                      .toSet()
                      .isNotEmpty) ...[
                    Text(
                      'Province',
                      style: theme.textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[700],
                      ),
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
                  // Date Range
                  Text(
                    'Date Range',
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[700],
                    ),
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
                  // Apply button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(ctx),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Apply Filters',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
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
        label: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: theme.primaryColor,
            fontWeight: FontWeight.w500,
          ),
        ),
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
              color: isSet ? theme.primaryColor : Colors.grey.shade300,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(
                Icons.calendar_today,
                size: 16,
                color: isSet ? theme.primaryColor : Colors.grey[600],
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    color: isSet ? theme.primaryColor : Colors.grey[600],
                    fontWeight: isSet ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
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
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              label,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  color.withValues(alpha: 0.2),
                  color.withValues(alpha: 0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: color.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Text(
              count.toString(),
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Displays live screening count cards for the requested service types.
/// Only shown on the Live Events tab. Cards are filtered to only show
/// the services actually requested across the active live events.
class _LiveScreeningCountsSection extends StatefulWidget {
  final List<String> eventIds;

  /// The live events whose requested services determine which cards are shown.
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

  /// Returns the union of all service types across every live event.
  /// An empty set means no service info — show all cards as fallback.
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
            _hraCount = 0;
            _hctCount = 0;
            _tbCount = 0;
            _papSmearCount = 0;
            _breastScreeningCount = 0;
            _psaCount = 0;
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

      // Pap Smear: cancer records where specimen was collected
      final papCount = cancerList
          .where((s) => s.papSmearSpecimenCollected?.toLowerCase() == 'yes')
          .length;

      // Breast Screening: cancer records where a breast light exam was performed
      final breastCount = cancerList
          .where((s) =>
              s.breastLightExamFindings != null &&
              s.breastLightExamFindings!.isNotEmpty)
          .length;

      // PSA: cancer records where PSA results were recorded
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
      debugPrint('LiveScreeningCounts: failed to load counts: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Full set of possible screening cards, each tagged with its ServiceType.
    final allScreenings = [
      _ScreeningCount(
        serviceType: ServiceType.hra,
        label: 'HRA',
        count: _hraCount,
        icon: Icons.monitor_heart_outlined,
        color: Colors.teal.shade600,
      ),
      _ScreeningCount(
        serviceType: ServiceType.hct,
        label: 'HCT',
        count: _hctCount,
        icon: Icons.bloodtype_outlined,
        color: Colors.red.shade600,
      ),
      _ScreeningCount(
        serviceType: ServiceType.tbTest,
        label: 'TB',
        count: _tbCount,
        icon: Icons.air_outlined,
        color: Colors.amber.shade700,
      ),
      _ScreeningCount(
        serviceType: ServiceType.papSmear,
        label: 'Pap Smear',
        count: _papSmearCount,
        icon: Icons.science_outlined,
        color: Colors.purple.shade500,
      ),
      _ScreeningCount(
        serviceType: ServiceType.breastScreening,
        label: 'Breast',
        count: _breastScreeningCount,
        icon: Icons.favorite_border,
        color: Colors.pink.shade500,
      ),
      _ScreeningCount(
        serviceType: ServiceType.psa,
        label: 'PSA',
        count: _psaCount,
        icon: Icons.biotech_outlined,
        color: Colors.indigo.shade500,
      ),
    ];

    // Filter to only the services requested across live events.
    // If we have no service info (empty set) fall back to showing all cards.
    final activeServices = _activeServices;
    final screenings = activeServices.isEmpty
        ? allScreenings
        : allScreenings
            .where((s) => activeServices.contains(s.serviceType))
            .toList();

    return KenwellFormCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.local_hospital_outlined,
                  color: KenwellColors.primaryGreen,
                  size: 20,
                ),
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
                        color: KenwellColors.secondaryNavy,
                      ),
                    ),
                    Text(
                      'People screened for each requested service',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              if (_isLoading)
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: KenwellColors.primaryGreen,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),

          // Grid of screening cards — only the services relevant to live events
          if (widget.eventIds.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Center(
                child: Text(
                  'No live events to show screening data for',
                  style: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 13,
                  ),
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

/// Simple data class for a single screening type's count metadata.
class _ScreeningCount {
  final ServiceType serviceType;
  final String label;
  final int count;
  final IconData icon;
  final Color color;

  const _ScreeningCount({
    required this.serviceType,
    required this.label,
    required this.count,
    required this.icon,
    required this.color,
  });
}

/// Compact card showing icon + count + label for one screening type.
class _ScreeningCountCard extends StatelessWidget {
  final String label;
  final int? count; // null while loading
  final IconData icon;

  /// Accent colour used for the icon only. Card background matches the
  /// breakdown cards for a unified look.
  final Color color;

  const _ScreeningCountCard({
    required this.label,
    required this.count,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: theme.primaryColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.primaryColor.withValues(alpha: 0.15),
          width: 1.5,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 6),
          count == null
              ? SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: color,
                  ),
                )
              : Text(
                  count.toString(),
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: KenwellColors.secondaryNavy,
                    fontSize: 22,
                  ),
                ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey.shade700,
              fontWeight: FontWeight.w600,
            ),
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

  /// Accent colour used for the icon badge. The card background itself always
  /// uses the same subtle primary-colour tint as the breakdown cards.
  final Color color;

  const _StatCard({
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
        color: theme.primaryColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.primaryColor.withValues(alpha: 0.15),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
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
