import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../../../../domain/models/wellness_event.dart';
import '../../../shared/ui/app_bar/kenwell_app_bar.dart';
import '../../../shared/ui/cards/kenwell_empty_state.dart';
import '../../../shared/ui/colours/kenwell_colours.dart';
import '../../event/view_model/event_view_model.dart';
import '../../user_management/viewmodel/user_management_view_model.dart';
import '../view_model/all_events_view_model.dart';
import 'allocate_event_screen.dart';

/// Screen that shows all events with a search bar (title / address).
/// Tapping an event card opens the [AllocateEventScreen] for that event.
class AllEventsScreen extends StatelessWidget {
  const AllEventsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Consume the global EventViewModel so we always have the latest events.
    return Consumer<EventViewModel>(
      builder: (context, eventVM, _) {
        return ChangeNotifierProvider(
          create: (_) => AllEventsViewModel(allEvents: eventVM.events),
          child: const _AllEventsBody(),
        );
      },
    );
  }
}

class _AllEventsBody extends StatelessWidget {
  const _AllEventsBody();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AllEventsViewModel>();
    final events = vm.filteredEvents;

    return Scaffold(
      backgroundColor: KenwellColors.neutralBackground,
      appBar: const KenwellAppBar(
        title: 'All Events',
        automaticallyImplyLeading: true,
        titleStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      body: Column(
        children: [
          // ── Search bar ─────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: _EventSearchBar(vm: vm),
          ),

          // ── List / empty state ─────────────────────────────────────────
          Expanded(
            child: events.isEmpty
                ? KenwellEmptyState(
                    icon: Icons.event_busy_rounded,
                    title: vm.searchController.text.isNotEmpty
                        ? 'No events match your search'
                        : 'No events yet',
                    message: vm.searchController.text.isNotEmpty
                        ? 'Try a different title or address'
                        : 'Events will appear here once created',
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    itemCount: events.length,
                    itemBuilder: (context, index) => _AllEventCard(
                      event: events[index],
                    )
                        .animate()
                        .fadeIn(duration: 250.ms)
                        .slideY(begin: 0.08, end: 0, duration: 250.ms),
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

class _AllEventCard extends StatelessWidget {
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusColor = _statusColor(event.status);

    return GestureDetector(
      onTap: () => _openAllocate(context),
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
                Container(
                  width: 5,
                  color: KenwellColors.primaryGreen,
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title row with status chip
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
                              child: const Icon(
                                Icons.event_rounded,
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
                                      const Icon(
                                        Icons.location_on_outlined,
                                        size: 12,
                                        color: KenwellColors.neutralGrey,
                                      ),
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
                              icon: Icons.calendar_today_outlined,
                              label:
                                  '${event.date.day}/${event.date.month}/${event.date.year}',
                            ),
                            const SizedBox(width: 6),
                            _MetaChip(
                              icon: Icons.access_time_rounded,
                              label: event.startTime.isNotEmpty
                                  ? event.startTime
                                  : '—',
                            ),
                            const Spacer(),
                            Text(
                              'Tap to allocate',
                              style: TextStyle(
                                fontSize: 11,
                                color: KenwellColors.primaryGreen,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 2),
                            const Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: 11,
                              color: KenwellColors.primaryGreen,
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
}

class _MetaChip extends StatelessWidget {
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
