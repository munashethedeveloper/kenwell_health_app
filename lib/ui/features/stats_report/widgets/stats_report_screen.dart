import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../shared/ui/form/kenwell_section_header.dart';
import '../../event/view_model/event_view_model.dart';
import '../../../shared/ui/app_bar/kenwell_app_bar.dart';
import '../../../shared/ui/form/kenwell_form_card.dart';
import '../../../shared/ui/logo/app_logo.dart';
import '../../../shared/ui/containers/gradient_container.dart';
import '../../../../data/repositories_dcl/firestore_member_repository.dart';
import 'event_stats_detail_screen.dart';

class StatsReportScreen extends StatefulWidget {
  const StatsReportScreen({super.key});

  @override
  State<StatsReportScreen> createState() => _StatsReportScreenState();
}

class _StatsReportScreenState extends State<StatsReportScreen> {
  final _searchController = TextEditingController();
  final _memberRepository = FirestoreMemberRepository();
  int _totalMembers = 0;
  bool _isLoadingMembers = true;

  // Filter states
  String? _selectedStatus;
  String? _selectedProvince;
  DateTime? _startDate;
  DateTime? _endDate;
  bool _isFilterExpanded = false;

  @override
  void initState() {
    super.initState();
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final eventVM = context.watch<EventViewModel>();
    final allEvents = eventVM.events;

    // Filter events based on search query
    final searchQuery = _searchController.text.toLowerCase();
    var events = searchQuery.isEmpty
        ? allEvents
        : allEvents
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
    final sortedMonths = eventsByMonth.keys.toList()..sort();

    return Scaffold(
      appBar: KenwellAppBar(
        title: 'Wellness Statistics',
        titleColor: const Color(0xFF201C58),
        titleStyle: const TextStyle(
          color: Color(0xFF201C58),
          fontWeight: FontWeight.bold,
        ),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh, color: Color(0xFF201C58)),
            onPressed: _refreshData,
          ),
          TextButton.icon(
            onPressed: () {
              if (mounted) {
                context.pushNamed('help');
              }
            },
            icon: const Icon(Icons.help_outline, color: Color(0xFF201C58)),
            label: const Text(
              'Help',
              style: TextStyle(color: Color(0xFF201C58)),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 16),
            const AppLogo(size: 200),
            const SizedBox(height: 16),
            //const KenwellSectionHeader(
            //title: 'Overall Wellness Statistics',
            //subtitle: 'Summary of wellness events and participation metrics.',
            //),
            // const SizedBox(height: 24),
            // Search Field
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search events by title...',
                prefixIcon: Icon(Icons.search, color: theme.primaryColor),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: theme.colorScheme.primary,
                    width: 2,
                  ),
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
            ),
            const SizedBox(height: 16),

            // Modern Filter Section
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: Colors.grey.shade300,
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  // Filter Header
                  InkWell(
                    onTap: () {
                      setState(() {
                        _isFilterExpanded = !_isFilterExpanded;
                      });
                    },
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: theme.primaryColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.tune,
                              color: theme.primaryColor,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Filters',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (_hasActiveFilters) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: theme.primaryColor,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                _getActiveFilterCount().toString(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                          const Spacer(),
                          if (_hasActiveFilters)
                            TextButton.icon(
                              onPressed: () {
                                setState(() {
                                  _selectedStatus = null;
                                  _selectedProvince = null;
                                  _startDate = null;
                                  _endDate = null;
                                });
                              },
                              icon: const Icon(Icons.clear_all, size: 16),
                              label: const Text('Clear'),
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                              ),
                            ),
                          Icon(
                            _isFilterExpanded
                                ? Icons.expand_less
                                : Icons.expand_more,
                            color: Colors.grey[600],
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Filter Content
                  if (_isFilterExpanded)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: const BorderRadius.vertical(
                          bottom: Radius.circular(12),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Status Filter Chips
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
                            children: ['Scheduled', 'In Progress', 'Completed']
                                .map((status) {
                              final isSelected = _selectedStatus == status;
                              return FilterChip(
                                label: Text(status),
                                selected: isSelected,
                                onSelected: (selected) {
                                  setState(() {
                                    _selectedStatus = selected ? status : null;
                                  });
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

                          // Province Filter Chips
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
                                final isSelected =
                                    _selectedProvince == province;
                                return FilterChip(
                                  label: Text(province),
                                  selected: isSelected,
                                  onSelected: (selected) {
                                    setState(() {
                                      _selectedProvince =
                                          selected ? province : null;
                                    });
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

                          // Date Range Filter
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
                                child: Material(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                  child: InkWell(
                                    onTap: () async {
                                      final picked = await showDatePicker(
                                        context: context,
                                        initialDate:
                                            _startDate ?? DateTime.now(),
                                        firstDate: DateTime(2020),
                                        lastDate: DateTime(2030),
                                      );
                                      if (picked != null) {
                                        setState(() {
                                          _startDate = picked;
                                        });
                                      }
                                    },
                                    borderRadius: BorderRadius.circular(8),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 12,
                                      ),
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: _startDate != null
                                              ? theme.primaryColor
                                              : Colors.grey.shade300,
                                        ),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.calendar_today,
                                            size: 16,
                                            color: _startDate != null
                                                ? theme.primaryColor
                                                : Colors.grey[600],
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              _startDate == null
                                                  ? 'Start Date'
                                                  : '${_startDate!.day}/${_startDate!.month}/${_startDate!.year}',
                                              style: TextStyle(
                                                fontSize: 13,
                                                color: _startDate != null
                                                    ? theme.primaryColor
                                                    : Colors.grey[600],
                                                fontWeight: _startDate != null
                                                    ? FontWeight.w600
                                                    : FontWeight.normal,
                                              ),
                                            ),
                                          ),
                                          if (_startDate != null)
                                            GestureDetector(
                                              onTap: () {
                                                setState(() {
                                                  _startDate = null;
                                                });
                                              },
                                              child: Icon(
                                                Icons.close,
                                                size: 16,
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Material(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                  child: InkWell(
                                    onTap: () async {
                                      final picked = await showDatePicker(
                                        context: context,
                                        initialDate: _endDate ?? DateTime.now(),
                                        firstDate: DateTime(2020),
                                        lastDate: DateTime(2030),
                                      );
                                      if (picked != null) {
                                        setState(() {
                                          _endDate = picked;
                                        });
                                      }
                                    },
                                    borderRadius: BorderRadius.circular(8),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 12,
                                      ),
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: _endDate != null
                                              ? theme.primaryColor
                                              : Colors.grey.shade300,
                                        ),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.calendar_today,
                                            size: 16,
                                            color: _endDate != null
                                                ? theme.primaryColor
                                                : Colors.grey[600],
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              _endDate == null
                                                  ? 'End Date'
                                                  : '${_endDate!.day}/${_endDate!.month}/${_endDate!.year}',
                                              style: TextStyle(
                                                fontSize: 13,
                                                color: _endDate != null
                                                    ? theme.primaryColor
                                                    : Colors.grey[600],
                                                fontWeight: _endDate != null
                                                    ? FontWeight.w600
                                                    : FontWeight.normal,
                                              ),
                                            ),
                                          ),
                                          if (_endDate != null)
                                            GestureDetector(
                                              onTap: () {
                                                setState(() {
                                                  _endDate = null;
                                                });
                                              },
                                              child: Icon(
                                                Icons.close,
                                                size: 16,
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Search results indicator
            if (_searchController.text.isNotEmpty || _hasActiveFilters)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text(
                  'Found ${events.length} event${events.length != 1 ? 's' : ''}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            const SizedBox(height: 8),
            const KenwellSectionHeader(
              title: 'Overall Wellness Statistics',
              subtitle: 'Summary of wellness events and participation metrics.',
            ),
            const SizedBox(height: 24),

            // Stat Cards Row 1 - Total Members Expected and Registered
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    icon: Icons.flag,
                    title: 'Total Members Expected',
                    value: totalExpected.toString(),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    icon: Icons.person_add,
                    title: 'Total Members Registered',
                    value: _isLoadingMembers ? '...' : _totalMembers.toString(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Stat Cards Row 2 - Total Members Screened and No Show
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    icon: Icons.people,
                    title: 'Total Members Screened',
                    value: totalScreened.toString(),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    icon: Icons.person_off,
                    title: 'Total Members No Show',
                    value: (totalExpected - totalScreened).toString(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Stat Cards Row 3 - Total Events and Participation Rate
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    icon: Icons.event,
                    title: 'Total Events',
                    value: events.length.toString(),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    icon: Icons.trending_up,
                    title: 'Participation Rate',
                    value: '$participationRate%',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // HIGH PRIORITY: Events by Status - Only show when filters are active
            if (_hasActiveFilters) ...[
              KenwellFormCard(
                title: 'Events by Status',
                child: Column(
                  children: [
                    _buildDetailRow('Scheduled', scheduledEvents,
                        Icons.schedule, Colors.orange, theme),
                    const Divider(),
                    _buildDetailRow('In Progress', inProgressEvents,
                        Icons.play_circle, Colors.blue, theme),
                    const Divider(),
                    _buildDetailRow('Completed', completedEvents,
                        Icons.check_circle, Colors.deepPurple, theme),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // MEDIUM PRIORITY: Geographic Distribution - Only show when filters are active
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
                        if (!isLast) const Divider(),
                      ],
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Event Breakdown Card - Only show when search or filters are active
            if (_searchController.text.isNotEmpty || _hasActiveFilters)
              KenwellFormCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Event Breakdown',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (events.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Text(
                            'No event data yet',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[600],
                            ),
                          ),
                        ),
                      )
                    else
                      ...events.map((event) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
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
                              borderRadius: BorderRadius.circular(8),
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: theme.primaryColor
                                      .withValues(alpha: 0.05),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: theme.primaryColor
                                        .withValues(alpha: 0.2),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.event,
                                        color: theme.primaryColor, size: 20),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            event.title,
                                            style: theme.textTheme.bodyMedium
                                                ?.copyWith(
                                              fontWeight: FontWeight.w600,
                                              color: theme.primaryColor,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            '${event.screenedCount} screened',
                                            style: theme.textTheme.bodySmall
                                                ?.copyWith(
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: theme.primaryColor
                                            .withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        event.screenedCount.toString(),
                                        style: theme.textTheme.labelLarge
                                            ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: theme.primaryColor,
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

  Widget _buildDetailRow(
      String label, int count, IconData icon, Color color, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              count.toString(),
              style: theme.textTheme.labelLarge?.copyWith(
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

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _StatCard({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GradientContainer.purpleGreen(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.white, size: 32),
          const SizedBox(height: 12),
          Text(
            value,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
