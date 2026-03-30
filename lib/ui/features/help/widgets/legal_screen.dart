import 'package:flutter/material.dart';
import 'package:kenwell_health_app/ui/shared/ui/app_bar/kenwell_app_bar.dart';
import 'package:kenwell_health_app/ui/shared/ui/colours/kenwell_colours.dart';

/// In-app Legal / Terms & Privacy Policy screen.
///
/// Presents the app's Terms of Use and Privacy Policy in a scrollable,
/// readable format so users do not need to leave the app.
class LegalScreen extends StatelessWidget {
  const LegalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KenwellColors.neutralBackground,
      appBar: const KenwellAppBar(
        title: 'KenWell365',
        titleStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        automaticallyImplyLeading: true,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
        children: const [
          _LegalHeader(),
          SizedBox(height: 24),
          _LegalSection(
            title: 'Terms of Use',
            icon: Icons.gavel_rounded,
            content: [
              _LegalParagraph(
                'By using the KenWell365 application, you agree to abide by '
                'these Terms of Use. The application is intended for authorised '
                'KenWell Healthcare personnel and registered members only.',
              ),
              _LegalParagraph(
                'You agree not to misuse the application, share your credentials '
                'with unauthorised persons, or attempt to access data beyond your '
                'assigned role permissions.',
              ),
              _LegalParagraph(
                'KenWell Healthcare reserves the right to suspend or terminate '
                'access for any user found to be in violation of these terms.',
              ),
              _LegalParagraph(
                'The application and all its content are the intellectual property '
                'of KenWell Healthcare (Pty) Ltd. Unauthorised reproduction or '
                'distribution is strictly prohibited.',
              ),
            ],
          ),
          SizedBox(height: 20),
          _LegalSection(
            title: 'Privacy Policy',
            icon: Icons.privacy_tip_rounded,
            content: [
              _LegalParagraph(
                'KenWell Healthcare is committed to protecting the privacy and '
                'confidentiality of all personal and health information collected '
                'through this application.',
              ),
              _LegalParagraph(
                'Personal and health data collected (including member details, '
                'screening results, and consent records) is used solely to '
                'deliver and improve KenWell Healthcare\'s wellness services.',
              ),
              _LegalParagraph(
                'We implement industry-standard security measures, including '
                'encryption of sensitive fields, to protect your data against '
                'unauthorised access, disclosure, or loss.',
              ),
              _LegalParagraph(
                'Data is retained in accordance with applicable South African '
                'legislation, including the Protection of Personal Information '
                'Act (POPIA). You have the right to request access to, correction '
                'of, or deletion of your personal information.',
              ),
              _LegalParagraph(
                'We do not sell or share personal information with third parties '
                'for marketing purposes. Data may be shared with authorised '
                'healthcare partners solely for service delivery.',
              ),
            ],
          ),
          SizedBox(height: 20),
          _LegalSection(
            title: 'Data Collection',
            icon: Icons.storage_rounded,
            content: [
              _LegalParagraph(
                'The application collects member demographic information, health '
                'screening data, event participation records, and user account '
                'details as necessary to deliver wellness services.',
              ),
              _LegalParagraph(
                'Usage data (such as app interactions and session information) '
                'may be collected to improve application performance and user '
                'experience.',
              ),
            ],
          ),
          SizedBox(height: 20),
          _LegalSection(
            title: 'Contact Us',
            icon: Icons.contact_support_rounded,
            content: [
              _LegalParagraph(
                'If you have any questions or concerns regarding these terms or '
                'our privacy practices, please contact us at:',
              ),
              _LegalContact(
                label: 'Email',
                value: 'mapiyem@kenwellhealthcare.co.za',
              ),
              _LegalContact(
                label: 'Website',
                value: 'www.kenwellhealth.co.za',
              ),
            ],
          ),
          SizedBox(height: 20),
          _LegalFooter(),
        ],
      ),
    );
  }
}

// ── Header ────────────────────────────────────────────────────────────────────

class _LegalHeader extends StatelessWidget {
  const _LegalHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            KenwellColors.secondaryNavy,
            Color(0xFF2E2880),
            KenwellColors.primaryGreenDark,
          ],
          stops: [0.0, 0.55, 1.0],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: KenwellColors.secondaryNavy.withValues(alpha: 0.35),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.shield_outlined,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'Terms & Privacy Policy',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Last updated: January 2025',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Section ───────────────────────────────────────────────────────────────────

class _LegalSection extends StatelessWidget {
  const _LegalSection({
    required this.title,
    required this.icon,
    required this.content,
  });

  final String title;
  final IconData icon;
  final List<Widget> content;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: theme.primaryColor, size: 20),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: KenwellColors.secondaryNavy,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(height: 1, color: KenwellColors.neutralDivider),
          const SizedBox(height: 14),
          ...content,
        ],
      ),
    );
  }
}

// ── Paragraph ─────────────────────────────────────────────────────────────────

class _LegalParagraph extends StatelessWidget {
  const _LegalParagraph(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 13.5,
          color: KenwellColors.neutralDarkGrey,
          height: 1.55,
        ),
      ),
    );
  }
}

// ── Contact row ───────────────────────────────────────────────────────────────

class _LegalContact extends StatelessWidget {
  const _LegalContact({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 60,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: KenwellColors.neutralGrey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                color: KenwellColors.secondaryNavy,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Footer ────────────────────────────────────────────────────────────────────

class _LegalFooter extends StatelessWidget {
  const _LegalFooter();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        '© 2025 KenWell Healthcare (Pty) Ltd.\nAll rights reserved.',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 12,
          color: KenwellColors.neutralGrey.withValues(alpha: 0.7),
          height: 1.5,
        ),
      ),
    );
  }
}
