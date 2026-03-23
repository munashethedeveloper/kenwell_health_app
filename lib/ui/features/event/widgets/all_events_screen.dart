import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../../../../domain/models/wellness_event.dart';
import '../../../shared/ui/app_bar/kenwell_app_bar.dart';
import '../../../shared/ui/cards/kenwell_empty_state.dart';
import '../../../shared/ui/colours/kenwell_colours.dart';
import '../../../shared/ui/banners/offline_banner.dart';
import '../../../shared/ui/headers/kenwell_gradient_header.dart';
import '../../event/view_model/event_view_model.dart';
import '../../user_management/viewmodel/user_management_view_model.dart';
import '../view_model/all_events_view_model.dart';
import 'allocate_event_screen.dart';

/// Screen that shows all events with:
///   - A gradient section header
///   - A month navigation bar
///   - A search bar (title / address)
///   - Event cards that open [AllocateEventScreen] on tap
class AllEventsScreen extends StatelessWidget {
  const AllEventsScreen({super.key});

  @override
  Widget build(BuildContext context) {
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

// ── Body ──────────────────────────────────────────────────────────────────────

class _AllEventsBody extends StatelessWidget {
  const _AllEventsBody();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AllEventsViewModel>();
    final events = vm.filteredEvents;
    final isSearching = vm.searchController.text.isNotEmpty;

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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Offline indicator ────────────────────────────────────────
          const OfflineBanner(),

          // ── Gradient section header ─────────────────────────────────
          const KenwellGradientHeader(
            label: 'EVENTS',
            title: 'All\nEvents',
            subtitle: 'Browse, search and allocate events.',
          ),

          const SizedBox(height: 16),

          // ── Search bar ──────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _EventSearchBar(vm: vm),
          ),

          const SizedBox(height: 12),

          // ── Month navigation (hidden while searching) ───────────────
          if (!isSearching) _MonthNavBar(vm: vm),

          if (!isSearching) const SizedBox(height: 4),

          // ── Events list / empty state ───────────────────────────────
          Expanded(
            child: events.isEmpty
                ? KenwellEmptyState(
                    icon: Icons.event_busy_rounded,
                    title: isSearching
                        ? 'No events match your search'
                        : 'No events this month',
                    message: isSearching
                        ? 'Try a different title or address'
                        : 'Navigate to another month or create an event',
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
          // Previous month
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
          // Next month
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
          borderSide:
              BorderSide(color: KenwellColors.primaryGreen, width: 1.5),
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
                            const Text(
                              'Tap to allocate',
                              style: TextStyle(
                                fontSize: 11,
                                color: KenwellColors.primaryGreen,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 2),
                            const Icon(Icons.arrow_forward_ios_rounded,
                                size: 11, color: KenwellColors.primaryGreen),
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

// ── Meta chip ─────────────────────────────────────────────────────────────────

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

