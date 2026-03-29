import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kenwell_health_app/ui/shared/ui/cards/kenwell_action_card.dart';
import 'package:kenwell_health_app/ui/shared/ui/colours/kenwell_colours.dart';
import 'package:kenwell_health_app/ui/shared/ui/app_bar/kenwell_app_bar.dart';
import 'package:provider/provider.dart';
import '../view_model/help_screen_view_model.dart';
import 'package:kenwell_health_app/routing/app_routes.dart';

// HelpScreen provides help and support information to users
class HelpScreen extends StatelessWidget {
  // Constructor
  const HelpScreen({super.key});

  // Build method
  @override
  Widget build(BuildContext context) {
    // Provide HelpScreenViewModel to the widget tree
    return ChangeNotifierProvider(
      create: (_) => HelpScreenViewModel(),
      child: Scaffold(
        appBar: const KenwellAppBar(
          title: 'KenWell365',
          titleStyle: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
          automaticallyImplyLeading: true,
        ),
        // Body of the screen
        body: Consumer<HelpScreenViewModel>(
          builder: (context, viewModel, _) {
            return CustomScrollView(
              slivers: [
                // ── Gradient section header ───────────────────────────────
                const SliverToBoxAdapter(child: _HelpHeader()),
                // ── Help action cards ─────────────────────────────────────
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      /*  KenwellActionCard(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF201C58), Color(0xFF3B3F86)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        icon: Icons.info_outline_rounded,
                        title: 'About the App',
                        subtitle:
                            'Version: ${viewModel.appVersion} · Developer: ${viewModel.developer}',
                        badgeLabel: 'Info',
                        onTap: () {},
                      ),
                      const SizedBox(height: 16), */
                      KenwellActionCard(
                        gradient: const LinearGradient(
                          colors: [
                            KenwellColors.secondaryNavy,
                            Color(0xFF2E2880),
                          ],
                          //colors: [Color(0xFF90C048), Color(0xFF5E8C1F)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        icon: Icons.email_outlined,
                        title: 'Contact Support',
                        subtitle: 'mapiyem@kenwellhealthcare.co.za',
                        badgeLabel: 'Email',
                        onTap: viewModel.contactSupport,
                      ),
                      const SizedBox(height: 16),
                      KenwellActionCard(
                        gradient: const LinearGradient(
                          colors: [
                            KenwellColors.secondaryNavy,
                            Color(0xFF2E2880),
                          ],
                          //colors: [Color(0xFF5B8DEF), Color(0xFF2563EB)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        icon: Icons.help_outline_rounded,
                        title: 'FAQs / Help Center',
                        subtitle:
                            'Find answers to common questions and get help',
                        badgeLabel: 'FAQs',
                        onTap: () => context.pushNamed(AppRoutes.faq),
                      ),
                      const SizedBox(height: 16),
                      KenwellActionCard(
                        gradient: const LinearGradient(
                          colors: [
                            KenwellColors.secondaryNavy,
                            Color(0xFF2E2880),
                          ],
                          //colors: [Color(0xFF059669), Color(0xFF065F46)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        icon: Icons.description_outlined,
                        title: 'Terms & Privacy Policy',
                        subtitle: 'Read our terms and privacy policy',
                        badgeLabel: 'Legal',
                        onTap: viewModel.openTermsAndPrivacy,
                      ),
                      const SizedBox(height: 16),
                      const _WelcomeBanner(),
                    ]),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

// ── Gradient header ──────────────────────────────────────────────────────────

class _HelpHeader extends StatelessWidget {
  const _HelpHeader();
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      padding: const EdgeInsets.all(10),
      //width: double.infinity,
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
            // const KenwellSectionLabel(label: 'SUPPORT'),
            // const SizedBox(height: 10),
            const Text(
              'Help &\nSupport',
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
              'Get assistance, read FAQs, or contact our team.',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WelcomeBanner extends StatelessWidget {
  const _WelcomeBanner();

  @override
  Widget build(BuildContext context) {
    return Consumer<HelpScreenViewModel>(
      builder: (context, viewModel, _) {
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
                        'About KenWell365:',
                        style: TextStyle(
                          color: KenwellColors.primaryGreenLight,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.0,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Corporate Wellness Management Platform',
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
                      const SizedBox(height: 20),
                      Text(
                        'Version: '
                        '${viewModel.appVersion.isNotEmpty ? viewModel.appVersion : 'Loading...'}'
                        ' · Developer: ${viewModel.developer}',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.65),
                          fontSize: 12,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
                /*   const SizedBox(width: 16),
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
                ), */
              ],
            ),
          ),
        );
      },
    );
  }
}
