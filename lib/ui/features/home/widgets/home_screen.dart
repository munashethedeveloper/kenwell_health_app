import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kenwell_health_app/ui/features/calendar/view_model/calendar_view_model.dart';
import 'package:kenwell_health_app/ui/features/profile/view_model/profile_view_model.dart';
import 'package:kenwell_health_app/ui/shared/ui/app_bar/kenwell_app_bar.dart';
import 'package:kenwell_health_app/ui/shared/ui/colours/kenwell_colours.dart';
import 'package:kenwell_health_app/ui/shared/ui/headers/kenwell_gradient_header.dart';
import 'package:provider/provider.dart';
import 'sections/home_notifications_section.dart';

/// Home screen — shows a personalised greeting and smart notification strip.
///
/// Private widget classes extracted to `sections/`:
/// - [HomeHeroHeader]          — gradient name/role card (kept for future use)
/// - [HomeWelcomeBanner]       — branded banner (kept for future use)
/// - [HomeNotificationsSection] — derives alerts from app state
/// - [HomeNotifCard]           — single notification card
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
        final firstName = profileVM.firstName;

        return Scaffold(
          backgroundColor: KenwellColors.neutralBackground,
          appBar: KenwellAppBar(
            title: 'KenWell365',
            titleStyle: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            automaticallyImplyLeading: false,
            actions: [
              IconButton(
                tooltip: 'Help',
                icon: const Icon(Icons.help_outline, color: Colors.white),
                onPressed: () => context.pushNamed('help'),
              ),
            ],
          ),
          body: RefreshIndicator(
            onRefresh: () async {
              await calendarVM.loadEvents();
            },
            color: KenwellColors.primaryGreen,
            child: CustomScrollView(
              slivers: [
                // ── Header ───────────────────────────────────────────────
                const SliverToBoxAdapter(
                  child: KenwellGradientHeader(
                    title: 'Home Dashboard',
                    subtitle: 'Wellness 365 days a year',
                  ),
                ),
                // ── Personalised greeting ─────────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding:
                        const EdgeInsets.only(top: 10, bottom: 20, left: 20),
                    child: Text(
                      '${_greeting()}, ${firstName.isNotEmpty ? firstName : 'there'}',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: KenwellColors.secondaryNavy,
                      ),
                    ),
                  ),
                ),
                // ── Notifications ─────────────────────────────────────
                SliverToBoxAdapter(
                  child: HomeNotificationsSection(
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
