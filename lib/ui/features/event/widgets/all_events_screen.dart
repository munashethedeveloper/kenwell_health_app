import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../domain/models/wellness_event.dart';
import '../../../shared/ui/app_bar/kenwell_app_bar.dart';
import '../../../shared/ui/cards/kenwell_empty_state.dart';
import '../../../shared/ui/cards/kenwell_event_day_header.dart';
import '../../../shared/ui/colours/kenwell_colours.dart';
import '../../../shared/ui/headers/kenwell_gradient_header.dart';
import '../../../shared/ui/snackbars/app_snackbar.dart';
import '../../calendar/view_model/calendar_view_model.dart';
import '../../calendar/widgets/event_card.dart';
import '../../event/view_model/event_view_model.dart';
import '../view_model/all_events_view_model.dart';
import 'package:kenwell_health_app/routing/app_routes.dart';

/// Screen that shows all events with:
///   - A gradient section header
///   - A month navigation bar
///   - A search bar + filter button (title / address / status / sort)
///   - Events grouped by day
///
/// Uses [ChangeNotifierProxyProvider] so that the [AllEventsViewModel] is
/// updated whenever the parent [EventViewModel] emits new events — ensuring
/// the list is always in sync with Firestore without requiring a manual reload.
class AllEventsScreen extends StatelessWidget {
  const AllEventsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProxyProvider<EventViewModel, AllEventsViewModel>(
      create: (context) => AllEventsViewModel(
        allEvents: context.read<EventViewModel>().events,
      ),
      update: (context, eventVM, previous) {
        if (previous == null) {
          return AllEventsViewModel(allEvents: eventVM.events);
        }
        previous.updateEvents(eventVM.events);
        return previous;
      },
      child: const _AllEventsBody(),
    );
  }
}

// ── Body ──────────────────────────────────────────────────────────────────────

class _AllEventsBody extends StatelessWidget {
  const _AllEventsBody();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AllEventsViewModel>();
    final grouped = vm.groupedByDay;
    final isSearching = vm.searchController.text.isNotEmpty;
    final hasEvents = grouped.isNotEmpty;

    return Scaffold(
      backgroundColor: KenwellColors.neutralBackground,
      appBar: KenwellAppBar(
        title: 'KenWell365',
        automaticallyImplyLeading: true,
        titleStyle: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () {
              context.read<EventViewModel>().loadEvents();
              AppSnackbar.showSuccess(context, 'Events refreshed',
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Gradient section header ─────────────────────────────────
          const KenwellGradientHeader(
            label: 'EVENTS',
            title: 'All\nEvents',
            subtitle: 'Browse, search and allocate events.',
          ),

          const SizedBox(height: 16),

          // ── Search bar + filter button ──────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(child: _EventSearchBar(vm: vm)),
                const SizedBox(width: 8),
                _FilterButton(vm: vm),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // ── Month navigation (hidden while searching) ───────────────
          if (!isSearching) _MonthNavBar(vm: vm),

          if (!isSearching) const SizedBox(height: 4),

          // ── Events list / empty state ───────────────────────────────
          Expanded(
            child: !hasEvents
                ? KenwellEmptyState(
                    icon: Icons.event_busy_rounded,
                    title: isSearching
                        ? 'No events match your search'
                        : 'No events this month',
                    message: isSearching
                        ? 'Try a different title or address'
                        : 'Navigate to another month or create an event',
                  )
                : _EventList(grouped: grouped),
          ),
        ],
      ),
    );
  }
}

// ── Event list (flat, pre-computed) ──────────────────────────────────────────

/// Builds a flat list of day-header + event-card items from the grouped map.
/// Pre-computing the list avoids the O(n×m) traversal that would occur if
/// we determined the item type on every [ListView.builder] callback.
class _EventList extends StatelessWidget {
  const _EventList({required this.grouped});

  final Map<DateTime, List<WellnessEvent>> grouped;

  @override
  Widget build(BuildContext context) {
    // Build a flat sequence: for each day, one _DayItem then N _EventItems.
    // Store day headers as MapEntry<DateTime, int> (date + event count for
    // the KenwellEventDayHeader badge) and events as WellnessEvent.
    final items = <Object>[];
    for (final entry in grouped.entries) {
      items.add(MapEntry(entry.key, entry.value.length)); // date + count
      items.addAll(entry.value); // WellnessEvent → event card
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        if (item is MapEntry<DateTime, int>) {
          return KenwellEventDayHeader(
            label: DateFormat('EEEE, d MMMM yyyy').format(item.key),
            eventCount: item.value,
          ).animate().fadeIn(duration: 200.ms);
        }
        return Consumer<CalendarViewModel>(
          builder: (context, calVM, _) => EventCard(
            event: item as WellnessEvent,
            viewModel: calVM,
            showBorder: true,
          )
              .animate()
              .fadeIn(duration: 250.ms)
              .slideY(begin: 0.08, end: 0, duration: 250.ms),
        );
      },
    );
  }
}

// ── Filter button ─────────────────────────────────────────────────────────────

class _FilterButton extends StatelessWidget {
  const _FilterButton({required this.vm});

  final AllEventsViewModel vm;

  @override
  Widget build(BuildContext context) {
    final hasFilter = vm.hasActiveFilter;
    return GestureDetector(
      onTap: () => _showFilterSheet(context),
      child: Container(
        width: 46,
        height: 46,
        decoration: BoxDecoration(
          color: hasFilter ? KenwellColors.primaryGreen : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color:
                hasFilter ? KenwellColors.primaryGreen : Colors.grey.shade200,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          Icons.tune_rounded,
          size: 20,
          color: hasFilter ? Colors.white : KenwellColors.secondaryNavy,
        ),
      ),
    );
  }

  void _showFilterSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ChangeNotifierProvider.value(
        value: vm,
        child: const _FilterSheet(),
      ),
    );
  }
}

// ── Filter bottom sheet ───────────────────────────────────────────────────────

class _FilterSheet extends StatelessWidget {
  const _FilterSheet();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AllEventsViewModel>();
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Row(
            children: [
              const Text(
                'Filter & Sort',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: KenwellColors.secondaryNavy,
                ),
              ),
              const Spacer(),
              if (vm.hasActiveFilter)
                TextButton(
                  onPressed: () {
                    vm.clearFilters();
                    Navigator.of(context).pop();
                  },
                  child: const Text('Clear all',
                      style: TextStyle(color: KenwellColors.primaryGreen)),
                ),
            ],
          ),
          const SizedBox(height: 16),

          // Status filter
          const Text('Status',
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: KenwellColors.secondaryNavy)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _StatusChip(vm: vm, label: 'All', value: null),
              _StatusChip(vm: vm, label: 'Scheduled', value: 'scheduled'),
              _StatusChip(vm: vm, label: 'In Progress', value: 'in_progress'),
              _StatusChip(vm: vm, label: 'Completed', value: 'completed'),
            ],
          ),

          const SizedBox(height: 20),

          // Sort
          const Text('Sort by',
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: KenwellColors.secondaryNavy)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              _SortChip(vm: vm, label: 'Date', field: EventSortField.date),
              _SortChip(
                  vm: vm, label: 'Title (A–Z)', field: EventSortField.title),
            ],
          ),

          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: KenwellColors.primaryGreen,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Apply',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip(
      {required this.vm, required this.label, required this.value});

  final AllEventsViewModel vm;
  final String label;
  final String? value;

  @override
  Widget build(BuildContext context) {
    final isSelected = vm.statusFilter == value;
    return GestureDetector(
      onTap: () => vm.setStatusFilter(value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? KenwellColors.primaryGreen : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color:
                isSelected ? KenwellColors.primaryGreen : Colors.grey.shade200,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : KenwellColors.secondaryNavy,
          ),
        ),
      ),
    );
  }
}

class _SortChip extends StatelessWidget {
  const _SortChip({required this.vm, required this.label, required this.field});

  final AllEventsViewModel vm;
  final String label;
  final EventSortField field;

  @override
  Widget build(BuildContext context) {
    final isSelected = vm.sortField == field;
    return GestureDetector(
      onTap: () => vm.setSortField(field),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color:
              isSelected ? KenwellColors.secondaryNavy : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color:
                isSelected ? KenwellColors.secondaryNavy : Colors.grey.shade200,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : KenwellColors.secondaryNavy,
          ),
        ),
      ),
    );
  }
}

// ── Month navigation bar ──────────────────────────────────────────────────────

class _MonthNavBar extends StatelessWidget {
  const _MonthNavBar({required this.vm});

  final AllEventsViewModel vm;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [KenwellColors.secondaryNavy, Color(0xFF2E2880)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left_rounded),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
            onPressed: vm.goToPreviousMonth,
            style: IconButton.styleFrom(
              backgroundColor: theme.colorScheme.surface,
              foregroundColor: KenwellColors.secondaryNavy,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
          ),
          const SizedBox(width: 16),
          Text(
            vm.getMonthYearTitle(),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(width: 16),
          IconButton(
            icon: const Icon(Icons.chevron_right_rounded),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
            onPressed: vm.goToNextMonth,
            style: IconButton.styleFrom(
              backgroundColor: theme.colorScheme.surface,
              foregroundColor: KenwellColors.secondaryNavy,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Search bar ────────────────────────────────────────────────────────────────

class _EventSearchBar extends StatelessWidget {
  const _EventSearchBar({required this.vm});

  final AllEventsViewModel vm;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return TextField(
      controller: vm.searchController,
      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
      decoration: InputDecoration(
        hintText: 'Search by event title or address…',
        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
        prefixIcon: Icon(
          Icons.search_rounded,
          color: theme.colorScheme.primary,
          size: 20,
        ),
        suffixIcon: vm.searchController.text.isNotEmpty
            ? IconButton(
                icon: Icon(Icons.close_rounded,
                    color: Colors.grey.shade500, size: 18),
                onPressed: vm.clearSearch,
              )
            : null,
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: KenwellColors.primaryGreen, width: 1.5),
        ),
      ),
    );
  }
}

// ── Event card ────────────────────────────────────────────────────────────────

/* class _AllEventCard extends StatelessWidget {
  const _AllEventCard({required this.event});

  final WellnessEvent event;

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'in_progress':
      case 'in progress':
      case 'ongoing':
        return Colors.blue.shade600;
      case 'completed':
      case 'finished':
        return Colors.green.shade600;
      default:
        return Colors.orange.shade600;
    }
  }

  String _statusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'in_progress':
      case 'in progress':
      case 'ongoing':
        return 'In Progress';
      case 'completed':
      case 'finished':
        return 'Completed';
      default:
        return 'Scheduled';
    }
  }

  void _openAllocate(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider(
          create: (_) => UserManagementViewModel(),
          child: AllocateEventScreen(
            event: event,
            onAllocate: (ids) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Assigned to ${ids.length} user(s)'),
                    backgroundColor: KenwellColors.primaryGreen,
                  ),
                );
              }
            },
          ),
        ),
      ),
    );
  }

  void _openStats(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => EventStatsDetailScreen(event: event),
      ),
    );
  }

  /// Returns true if the event is in the past or completed/finished.
  ///
  /// Delegates to [WellnessEvent.isPast] — the business rule lives in the
  /// domain model, not in the UI widget.
  bool get _isPastEvent => event.isPast;

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(event.status);

    return GestureDetector(
      onTap: () => _isPastEvent ? _openStats(context) : _openAllocate(context),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: KenwellColors.secondaryNavy.withValues(alpha: 0.07),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Left accent bar
                Container(width: 5, color: KenwellColors.primaryGreen),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title row + status chip
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Icon badge
                            Container(
                              width: 42,
                              height: 42,
                              decoration: BoxDecoration(
                                color: KenwellColors.primaryGreen
                                    .withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.event_rounded,
                                  color: KenwellColors.primaryGreen, size: 20),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    event.title,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14,
                                      color: KenwellColors.secondaryNavy,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 3),
                                  Row(
                                    children: [
                                      const Icon(Icons.location_on_outlined,
                                          size: 12,
                                          color: KenwellColors.neutralGrey),
                                      const SizedBox(width: 3),
                                      Expanded(
                                        child: Text(
                                          event.address,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: KenwellColors.neutralGrey,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Status chip
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: statusColor.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                _statusLabel(event.status),
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: statusColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        const Divider(height: 1, color: Color(0xFFEEEEF5)),
                        const SizedBox(height: 8),
                        // Meta row
                        Row(
                          children: [
                            _MetaChip(
                              icon: Icons.access_time_rounded,
                              label: event.startTime.isNotEmpty
                                  ? event.startTime
                                  : '—',
                            ),
                            const Spacer(),
                            Text(
                              _isPastEvent ? 'View Stats' : 'Tap to allocate',
                              style: TextStyle(
                                fontSize: 11,
                                color: _isPastEvent
                                    ? Colors.blue.shade600
                                    : KenwellColors.primaryGreen,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 2),
                            Icon(
                              _isPastEvent
                                  ? Icons.bar_chart_rounded
                                  : Icons.arrow_forward_ios_rounded,
                              size: 11,
                              color: _isPastEvent
                                  ? Colors.blue.shade600
                                  : KenwellColors.primaryGreen,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
} */

// ── Meta chip ─────────────────────────────────────────────────────────────────

/* class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: KenwellColors.neutralBackground,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFEEEEF5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: KenwellColors.secondaryNavy),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: KenwellColors.secondaryNavy,
            ),
          ),
        ],
      ),
    );
  }
}
 */
