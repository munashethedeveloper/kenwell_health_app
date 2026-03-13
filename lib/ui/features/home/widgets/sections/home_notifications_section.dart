import 'package:flutter/material.dart';
import 'package:kenwell_health_app/ui/features/calendar/view_model/calendar_view_model.dart';
import 'package:kenwell_health_app/ui/features/profile/view_model/profile_view_model.dart';
import 'package:kenwell_health_app/ui/shared/ui/colours/kenwell_colours.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Data types
// ─────────────────────────────────────────────────────────────────────────────

/// Visual priority / colour theme for a notification item.
enum NotifType { info, warning, success, urgent }

/// Immutable data class for a single notification entry.
class NotifItem {
  const NotifItem({
    required this.icon,
    required this.title,
    required this.body,
    required this.type,
  });

  final IconData icon;
  final String title;
  final String body;
  final NotifType type;
}

// ─────────────────────────────────────────────────────────────────────────────
// Section widget
// ─────────────────────────────────────────────────────────────────────────────

/// Smart notification strip that derives alerts from live app state.
///
/// ## Data sources
///
/// | Category              | Source                                  |
/// |-----------------------|-----------------------------------------|
/// | Profile completeness  | [ProfileViewModel] fields               |
/// | Events today          | [CalendarViewModel.events]              |
/// | Upcoming events       | [CalendarViewModel.events]              |
/// | No events allocated   | [CalendarViewModel.events] (empty)      |
///
/// ## Persistence
/// Notifications are **ephemeral** – recomputed on every rebuild.
/// Profile notifications disappear once the user fills in their details;
/// event notifications disappear automatically based on dates.
///
/// For push notifications, integrate Firebase Cloud Messaging and store
/// records in a `notifications/{uid}` Firestore subcollection.
class HomeNotificationsSection extends StatelessWidget {
  const HomeNotificationsSection({
    super.key,
    required this.profileVM,
    required this.calendarVM,
  });

  final ProfileViewModel profileVM;
  final CalendarViewModel calendarVM;

  // ── Notification builder ──────────────────────────────────────────────────

  List<NotifItem> _buildNotifications() {
    final items = <NotifItem>[];
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // 1. Profile completeness
    if (profileVM.firstName.isEmpty || profileVM.lastName.isEmpty) {
      items.add(const NotifItem(
        icon: Icons.person_outline_rounded,
        title: 'Complete your profile',
        body: 'Your profile is missing key details. '
            'Tap "Edit Profile" under your account to update your information.',
        type: NotifType.warning,
      ));
    }

    // 2. Events today
    final todayEvents = calendarVM.events.where((e) {
      final d = e.date.toLocal();
      return DateTime(d.year, d.month, d.day).isAtSameMomentAs(today);
    }).toList();
    if (todayEvents.isNotEmpty) {
      final count = todayEvents.length;
      items.add(NotifItem(
        icon: Icons.event_available_rounded,
        title: 'You have $count event${count > 1 ? 's' : ''} today',
        body: count == 1
            ? '${todayEvents.first.title} — stay prepared and ready to go!'
            : '${todayEvents.first.title} and ${count - 1} more event${count - 1 > 1 ? 's' : ''} scheduled for today.',
        type: NotifType.urgent,
      ));
    }

    // 3. Upcoming events this week (excluding today)
    final weekEnd = today.add(const Duration(days: 7));
    final weekEvents = calendarVM.events.where((e) {
      final d = e.date.toLocal();
      final eventDay = DateTime(d.year, d.month, d.day);
      return eventDay.isAfter(today) && eventDay.isBefore(weekEnd);
    }).toList();
    if (weekEvents.isNotEmpty) {
      final count = weekEvents.length;
      items.add(NotifItem(
        icon: Icons.calendar_month_rounded,
        title: '$count upcoming event${count > 1 ? 's' : ''} this week',
        body: 'Stay prepared – you have events scheduled in the next 7 days. '
            'Review details in the Calendar.',
        type: NotifType.info,
      ));
    }

    // 4. No events allocated
    if (!calendarVM.isLoading && calendarVM.events.isEmpty) {
      items.add(const NotifItem(
        icon: Icons.event_busy_rounded,
        title: 'No events allocated',
        body: 'You currently have no wellness events assigned to you. '
            'Contact your administrator to be allocated to an event.',
        type: NotifType.info,
      ));
    }

    // 5. Offline / stale cache banner
    if (calendarVM.isOffline && calendarVM.events.isNotEmpty) {
      items.add(const NotifItem(
        icon: Icons.cloud_off_rounded,
        title: 'Showing cached data',
        body: 'Could not reach the server. '
            'You are viewing locally cached events. Pull to refresh when online.',
        type: NotifType.warning,
      ));
    }

    // 6. All clear
    if (items.isEmpty) {
      items.add(const NotifItem(
        icon: Icons.check_circle_outline_rounded,
        title: "You're all set!",
        body: 'No pending actions at the moment. '
            'Everything is up to date. Keep up the great work!',
        type: NotifType.success,
      ));
    }

    return items;
  }

  // ── Colour helpers ────────────────────────────────────────────────────────

  Color _typeColor(NotifType type) => switch (type) {
        NotifType.warning => const Color(0xFFF59E0B),
        NotifType.urgent => const Color(0xFFEF4444),
        NotifType.success => KenwellColors.primaryGreen,
        NotifType.info => const Color(0xFF3B82F6),
      };

  Color _typeBg(NotifType type) => switch (type) {
        NotifType.warning => const Color(0xFFFFFBEB),
        NotifType.urgent => const Color(0xFFFEF2F2),
        NotifType.success => const Color(0xFFF0FDF4),
        NotifType.info => const Color(0xFFEFF6FF),
      };

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final notifications = _buildNotifications();

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section heading
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: KenwellColors.primaryGreen.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.notifications_outlined,
                  color: KenwellColors.primaryGreen,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Pending Notifications',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: KenwellColors.secondaryNavy,
                      letterSpacing: -0.3,
                    ),
                  ),
                  Text(
                    '${notifications.length} alert${notifications.length != 1 ? 's' : ''}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Notification cards
          ...notifications.map(
            (notif) => HomeNotifCard(
              item: notif,
              accentColor: _typeColor(notif.type),
              bgColor: _typeBg(notif.type),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Notification card
// ─────────────────────────────────────────────────────────────────────────────

/// A single notification card rendered inside [HomeNotificationsSection].
class HomeNotifCard extends StatelessWidget {
  const HomeNotifCard({
    super.key,
    required this.item,
    required this.accentColor,
    required this.bgColor,
  });

  final NotifItem item;
  final Color accentColor;
  final Color bgColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: accentColor.withValues(alpha: 0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: accentColor.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(item.icon, color: accentColor, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: accentColor.withValues(alpha: 0.9),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.body,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF374151),
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
