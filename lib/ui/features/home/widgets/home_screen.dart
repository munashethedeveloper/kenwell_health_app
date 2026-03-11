import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kenwell_health_app/ui/features/calendar/view_model/calendar_view_model.dart';
import 'package:kenwell_health_app/ui/features/profile/view_model/profile_view_model.dart';
import 'package:kenwell_health_app/ui/shared/ui/app_bar/kenwell_app_bar.dart';
import 'package:kenwell_health_app/ui/shared/ui/colours/kenwell_colours.dart';
import 'package:kenwell_health_app/ui/shared/ui/labels/kenwell_section_label.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<CalendarViewModel>().loadEvents();
        context.read<ProfileViewModel>().loadProfile();
      }
    });
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<ProfileViewModel, CalendarViewModel>(
      builder: (context, profileVM, calendarVM, _) {
        final role = profileVM.role;
        final firstName = profileVM.firstName;
        final now = DateTime.now();

        return Scaffold(
          backgroundColor: KenwellColors.neutralBackground,
          appBar: const KenwellAppBar(
            title: 'KenWell365',
            automaticallyImplyLeading: false,
          ),
          body: RefreshIndicator(
            onRefresh: () async {
              await calendarVM.loadEvents();
            },
            color: KenwellColors.primaryGreen,
            child: CustomScrollView(
              slivers: [
                // ── Hero Header ──────────────────────────────────────────
                SliverToBoxAdapter(
                  child: _HeroHeader(
                    greeting: _greeting(),
                    firstName: firstName.isNotEmpty ? firstName : 'there',
                    role: role,
                    date: now,
                  ),
                ),

                // ── Welcome Banner ───────────────────────────────────────
                SliverToBoxAdapter(
                  child: _WelcomeBanner(role: role),
                ),

                // ── Notifications Section ────────────────────────────────
                SliverToBoxAdapter(
                  child: _NotificationsSection(
                    profileVM: profileVM,
                    calendarVM: calendarVM,
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 32)),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Hero Header
// ─────────────────────────────────────────────────────────────────────────────

class _HeroHeader extends StatelessWidget {
  const _HeroHeader({
    required this.greeting,
    required this.firstName,
    required this.role,
    required this.date,
  });

  final String greeting;
  final String firstName;
  final String role;
  final DateTime date;

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat('EEEE, d MMMM yyyy').format(date);

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      padding: const EdgeInsets.all(10),
      // width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            KenwellColors.secondaryNavy,
            Color(0xFF2E2880),
            KenwellColors.primaryGreenDark,
          ],
          stops: [0.0, 0.6, 1.0],
          //stops: [0.0, 0.55, 1.0],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section label
            // const KenwellSectionLabel(label: 'HOME'),
            // const SizedBox(height: 10),
            // Date chip
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.2),
                ),
              ),
              child: Text(
                formattedDate,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 14),

            // Greeting
            Text(
              greeting,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.75),
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              firstName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.w800,
                height: 1.2,
                letterSpacing: -0.5,
              ),
            ),
            if (role.isNotEmpty) ...[
              const SizedBox(height: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                decoration: BoxDecoration(
                  color: KenwellColors.primaryGreen.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: KenwellColors.primaryGreen.withValues(alpha: 0.5),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.verified_rounded,
                      color: KenwellColors.primaryGreen,
                      size: 13,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      role.toUpperCase(),
                      style: const TextStyle(
                        color: KenwellColors.primaryGreenLight,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Welcome Banner
// ─────────────────────────────────────────────────────────────────────────────

class _WelcomeBanner extends StatelessWidget {
  const _WelcomeBanner({required this.role});

  final String role;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              KenwellColors.secondaryNavy,
              Color(0xFF2E2880),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: KenwellColors.secondaryNavy.withValues(alpha: 0.3),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'KenWell365',
                    style: TextStyle(
                      color: KenwellColors.primaryGreenLight,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Corporate Wellness\nManagement Platform',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Empowering organisations to deliver world-class wellness programmes.',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.65),
                      fontSize: 12,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: KenwellColors.primaryGreen.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: KenwellColors.primaryGreen.withValues(alpha: 0.4),
                ),
              ),
              child: const Icon(
                Icons.health_and_safety_rounded,
                color: KenwellColors.primaryGreenLight,
                size: 34,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Notifications Section
// ─────────────────────────────────────────────────────────────────────────────

/// Notification priority / visual style.
enum _NotifType { info, warning, success, urgent }

/// A single notification item to display.
class _NotifItem {
  final IconData icon;
  final String title;
  final String body;
  final _NotifType type;

  const _NotifItem({
    required this.icon,
    required this.title,
    required this.body,
    required this.type,
  });
}

/// Smart notifications section that derives alerts from live app state.
///
/// ## How notification data is sourced
///
/// | Category               | Data source                             | How to extend                                               |
/// |------------------------|-----------------------------------------|-------------------------------------------------------------|
/// | Profile completeness   | [ProfileViewModel] fields               | Add a `isVerified` bool to the user Firestore doc and check it here. |
/// | Event allocations      | [CalendarViewModel.events]              | Filter events by the current user's ID once user-event linking is supported. |
/// | Verification status    | (Future) `users/{uid}.isVerified` field | Expose via ProfileViewModel, then add a notification below. |
///
/// ## Notification persistence
/// These notifications are **ephemeral** – they are recomputed each time the
/// home screen rebuilds (e.g., on pull-to-refresh or returning from another
/// screen).  There is no dedicated persistence layer, which keeps the
/// implementation simple:
/// - *Profile* notifications disappear once the user fills in their details.
/// - *Event* notifications disappear the day after the event passes.
/// - *Verification* notifications persist until the Firestore flag is set.
///
/// For long-lived push notifications, integrate Firebase Cloud Messaging and
/// write notification records to a `notifications/{uid}` subcollection.
class _NotificationsSection extends StatelessWidget {
  const _NotificationsSection({
    required this.profileVM,
    required this.calendarVM,
  });

  final ProfileViewModel profileVM;
  final CalendarViewModel calendarVM;

  List<_NotifItem> _buildNotifications() {
    final items = <_NotifItem>[];
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // ── 1. Profile completeness ──────────────────────────────────────────────
    if (profileVM.firstName.isEmpty || profileVM.lastName.isEmpty) {
      items.add(const _NotifItem(
        icon: Icons.person_outline_rounded,
        title: 'Complete your profile',
        body:
            'Your profile is missing key details. Tap "Edit Profile" under your account to update your information.',
        type: _NotifType.warning,
      ));
    }

    // ── 2. Events today ──────────────────────────────────────────────────────
    final todayEvents = calendarVM.events.where((e) {
      final d = e.date.toLocal();
      return DateTime(d.year, d.month, d.day).isAtSameMomentAs(today);
    }).toList();
    if (todayEvents.isNotEmpty) {
      final count = todayEvents.length;
      items.add(_NotifItem(
        icon: Icons.event_available_rounded,
        title: 'You have $count event${count > 1 ? 's' : ''} today',
        body: count == 1
            ? '${todayEvents.first.title} — stay prepared and ready to go!'
            : '${todayEvents.first.title} and ${count - 1} more event${count - 1 > 1 ? 's' : ''} scheduled for today.',
        type: _NotifType.urgent,
      ));
    }

    // ── 3. Upcoming events this week (excluding today) ────────────────────────
    final weekEnd = today.add(const Duration(days: 7));
    final weekEvents = calendarVM.events.where((e) {
      final d = e.date.toLocal();
      final eventDay = DateTime(d.year, d.month, d.day);
      return eventDay.isAfter(today) && eventDay.isBefore(weekEnd);
    }).toList();
    if (weekEvents.isNotEmpty) {
      final count = weekEvents.length;
      items.add(_NotifItem(
        icon: Icons.calendar_month_rounded,
        title: '$count upcoming event${count > 1 ? 's' : ''} this week',
        body:
            'Stay prepared – you have events scheduled in the next 7 days. Review details in the Calendar.',
        type: _NotifType.info,
      ));
    }

    // ── 4. No events allocated ───────────────────────────────────────────────
    if (!calendarVM.isLoading && calendarVM.events.isEmpty) {
      items.add(const _NotifItem(
        icon: Icons.event_busy_rounded,
        title: 'No events allocated',
        body:
            'You currently have no wellness events assigned to you. Contact your administrator to be allocated to an event.',
        type: _NotifType.info,
      ));
    }

    // ── 5. All clear ─────────────────────────────────────────────────────────
    if (items.isEmpty) {
      items.add(const _NotifItem(
        icon: Icons.check_circle_outline_rounded,
        title: "You're all set!",
        body:
            'No pending actions at the moment. Everything is up to date. Keep up the great work!',
        type: _NotifType.success,
      ));
    }

    return items;
  }

  Color _typeColor(_NotifType type) {
    switch (type) {
      case _NotifType.warning:
        return const Color(0xFFF59E0B);
      case _NotifType.urgent:
        return const Color(0xFFEF4444);
      case _NotifType.success:
        return KenwellColors.primaryGreen;
      case _NotifType.info:
        return const Color(0xFF3B82F6);
    }
  }

  Color _typeBg(_NotifType type) {
    switch (type) {
      case _NotifType.warning:
        return const Color(0xFFFFFBEB);
      case _NotifType.urgent:
        return const Color(0xFFFEF2F2);
      case _NotifType.success:
        return const Color(0xFFF0FDF4);
      case _NotifType.info:
        return const Color(0xFFEFF6FF);
    }
  }

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
                    'Notifications',
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
            (notif) => _NotifCard(
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

class _NotifCard extends StatelessWidget {
  const _NotifCard({
    required this.item,
    required this.accentColor,
    required this.bgColor,
  });

  final _NotifItem item;
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
