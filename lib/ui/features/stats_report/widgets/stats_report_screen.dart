import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kenwell_health_app/ui/shared/ui/colours/kenwell_colours.dart';
import 'package:kenwell_health_app/ui/shared/ui/cards/kenwell_action_card.dart';
import 'package:kenwell_health_app/ui/shared/ui/form/kenwell_modern_section_header.dart';

/// Statistics dashboard screen.
///
/// Shows two action cards – one for live (in-progress) event statistics and one
/// for past (completed) event statistics.  Tapping each card navigates to the
/// dedicated [LiveEventsScreen] or [PastEventsScreen].
class StatsReportScreen extends StatelessWidget {
  const StatsReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KenwellColors.neutralBackground,
      body: CustomScrollView(
        slivers: [
          // ── Gradient header ───────────────────────────────────────────
          SliverToBoxAdapter(child: const _StatsHeader()),
          // ── Dashboard cards ───────────────────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const KenwellModernSectionHeader(
                  title: 'Wellness Statistics',
                  subtitle: 'Events and participation overview',
                  padding: EdgeInsets.zero,
                ),
                const SizedBox(height: 20),
                KenwellActionCard(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF059669), Color(0xFF065F46)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  icon: Icons.play_circle_outline_rounded,
                  title: 'Live Statistics',
                  subtitle:
                      'View real-time stats for events currently in progress.',
                  badgeLabel: 'Live',
                  onTap: () => context.pushNamed('liveEvents'),
                ),
                const SizedBox(height: 16),
                KenwellActionCard(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF201C58), Color(0xFF3B3F86)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  icon: Icons.history_rounded,
                  title: 'Past Events',
                  subtitle:
                      'Review statistics and outcomes from completed events.',
                  badgeLabel: 'History',
                  onTap: () => context.pushNamed('pastEvents'),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Gradient header ──────────────────────────────────────────────────────────

class _StatsHeader extends StatelessWidget {
  const _StatsHeader();
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            KenwellColors.secondaryNavy,
            Color(0xFF2E2880),
            KenwellColors.primaryGreenDark,
          ],
          stops: [0.0, 0.55, 1.0],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 36),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Section label
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: KenwellColors.primaryGreen.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: KenwellColors.primaryGreen.withValues(alpha: 0.5),
                  ),
                ),
                child: const Text(
                  'ANALYTICS',
                  style: TextStyle(
                    color: KenwellColors.primaryGreenLight,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Stats &\nReports',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  height: 1.2,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Select a category to explore wellness event data.',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
