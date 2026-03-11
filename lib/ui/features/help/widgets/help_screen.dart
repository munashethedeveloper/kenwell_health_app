import 'package:flutter/material.dart';
import 'package:kenwell_health_app/ui/shared/ui/cards/kenwell_action_card.dart';
import 'package:kenwell_health_app/ui/shared/ui/colours/kenwell_colours.dart';
import 'package:kenwell_health_app/ui/shared/ui/labels/kenwell_section_label.dart';
import 'package:kenwell_health_app/ui/shared/ui/app_bar/kenwell_app_bar.dart';
import 'package:provider/provider.dart';
import '../view_model/help_screen_view_model.dart';

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
          automaticallyImplyLeading: true,
        ),
        // Body of the screen
        body: Consumer<HelpScreenViewModel>(
          builder: (context, viewModel, _) {
            return CustomScrollView(
              slivers: [
                // ── Gradient section header ───────────────────────────────
                SliverToBoxAdapter(child: const _HelpHeader()),
                // ── Help action cards ─────────────────────────────────────
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      KenwellActionCard(
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
                      const SizedBox(height: 16),
                      KenwellActionCard(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF90C048), Color(0xFF5E8C1F)],
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
                          colors: [Color(0xFF5B8DEF), Color(0xFF2563EB)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        icon: Icons.help_outline_rounded,
                        title: 'FAQs / Help Center',
                        subtitle:
                            'Find answers to common questions and get help',
                        badgeLabel: 'FAQs',
                        onTap: viewModel.openFAQs,
                      ),
                      const SizedBox(height: 16),
                      KenwellActionCard(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF059669), Color(0xFF065F46)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        icon: Icons.description_outlined,
                        title: 'Terms & Privacy Policy',
                        subtitle: 'Read our terms and privacy policy',
                        badgeLabel: 'Legal',
                        onTap: viewModel.openTermsAndPrivacy,
                      ),
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
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section label
            const KenwellSectionLabel(label: 'SUPPORT'),
            const SizedBox(height: 10),
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

