import 'package:flutter/material.dart';
import 'package:kenwell_health_app/ui/shared/ui/app_bar/kenwell_app_bar.dart';
import 'package:kenwell_health_app/ui/shared/ui/colours/kenwell_colours.dart';

/// Displays the KenWell365 Privacy Policy and Terms of Service in-app.
///
/// Restricted to authenticated users only; accessible from the Help screen's
/// "Terms & Privacy Policy" card.  Content is rendered as a scrollable
/// rich-text document so that no external browser session is required.
class LegalScreen extends StatelessWidget {
  const LegalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KenwellColors.neutralBackground,
      appBar: const KenwellAppBar(
        title: 'KenWell365',
        subtitle: 'Legal',
        titleStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        automaticallyImplyLeading: true,
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(20, 24, 20, 48),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _LegalSection(
              title: 'Terms of Service',
              lastUpdated: '29 March 2026',
              items: [
                _LegalItem(
                  heading: '1. Acceptance of Terms',
                  body:
                      'By accessing or using KenWell365 ("the App"), you agree '
                      'to be bound by these Terms of Service and all applicable '
                      'laws and regulations. If you do not agree, you may not '
                      'use the App.',
                ),
                _LegalItem(
                  heading: '2. Authorised Use',
                  body:
                      'KenWell365 is a corporate wellness management platform '
                      'licensed to organisations ("Clients") for the purpose of '
                      'planning and delivering employee wellness programmes. '
                      'Access is granted only to personnel authorised by the '
                      'Client (administrators, coordinators, nurses, and '
                      'practitioners). Unauthorised access is prohibited.',
                ),
                _LegalItem(
                  heading: '3. User Responsibilities',
                  body:
                      'You are responsible for maintaining the confidentiality '
                      'of your account credentials, for all activities that '
                      'occur under your account, and for ensuring that your '
                      'use of the App complies with all applicable laws '
                      'including the Protection of Personal Information Act '
                      '(POPIA) and the National Health Act.',
                ),
                _LegalItem(
                  heading: '4. Health Information Disclaimer',
                  body:
                      'The App facilitates the capture and reporting of health '
                      'screening data. Information captured through the App '
                      'does not constitute medical advice and must be '
                      'interpreted by qualified healthcare professionals. '
                      'KenWell Healthcare (Pty) Ltd is not liable for any '
                      'clinical decisions made on the basis of App data.',
                ),
                _LegalItem(
                  heading: '5. Intellectual Property',
                  body:
                      'All content, branding, and software forming part of '
                      'KenWell365 are the exclusive property of KenWell '
                      'Healthcare (Pty) Ltd. Reproduction, distribution, or '
                      'reverse-engineering without prior written consent is '
                      'strictly prohibited.',
                ),
                _LegalItem(
                  heading: '6. Limitation of Liability',
                  body:
                      'To the maximum extent permitted by law, KenWell '
                      'Healthcare (Pty) Ltd shall not be liable for any '
                      'indirect, incidental, or consequential damages arising '
                      'from your use of, or inability to use, the App.',
                ),
                _LegalItem(
                  heading: '7. Governing Law',
                  body:
                      'These Terms are governed by the laws of the Republic of '
                      'South Africa. Any disputes shall be subject to the '
                      'exclusive jurisdiction of the South African courts.',
                ),
              ],
            ),
            SizedBox(height: 32),
            _LegalSection(
              title: 'Privacy Policy',
              lastUpdated: '29 March 2026',
              items: [
                _LegalItem(
                  heading: '1. Information We Collect',
                  body:
                      'KenWell365 collects personal information necessary to '
                      'deliver corporate wellness services, including: '
                      'employee names, ID / passport numbers, dates of birth, '
                      'medical aid numbers, health screening results (HRA, '
                      'HCT, TB, cancer, resilience survey), and device '
                      'identifiers for push notifications.',
                ),
                _LegalItem(
                  heading: '2. How We Use Your Information',
                  body:
                      'Personal information is used exclusively to: '
                      '(a) register and identify wellness event participants; '
                      '(b) record and report health screening outcomes; '
                      '(c) communicate event reminders via push notification; '
                      'and (d) maintain an audit log of data operations as '
                      'required by POPIA and the National Health Act.',
                ),
                _LegalItem(
                  heading: '3. Data Security',
                  body:
                      'All personally identifiable information (PII) stored '
                      'in the App is encrypted at rest using AES-256-CBC '
                      'encryption before being written to our cloud database. '
                      'Data in transit is protected by TLS 1.2+. '
                      'Access is restricted to authorised personnel only.',
                ),
                _LegalItem(
                  heading: '4. Data Retention',
                  body:
                      'Health screening data is retained for the period '
                      'required by the National Health Act and your '
                      'organisation\'s data retention policy, after which it '
                      'is permanently deleted. You may request deletion of '
                      'your personal data by contacting your organisation\'s '
                      'wellness coordinator.',
                ),
                _LegalItem(
                  heading: '5. Sharing of Information',
                  body:
                      'We do not sell or rent personal information to third '
                      'parties. Data is shared only with: (a) your employer '
                      '(the licensed Client) in aggregated, de-identified '
                      'form; (b) healthcare professionals participating in '
                      'your wellness event; and (c) service providers '
                      '(e.g. Firebase / Google) bound by data processing '
                      'agreements consistent with POPIA.',
                ),
                _LegalItem(
                  heading: '6. Your Rights (POPIA)',
                  body:
                      'Under the Protection of Personal Information Act '
                      '(POPIA) you have the right to: access your personal '
                      'information, correct inaccurate data, object to '
                      'processing, and lodge a complaint with the Information '
                      'Regulator. Contact us at '
                      'mapiyem@kenwellhealthcare.co.za to exercise these '
                      'rights.',
                ),
                _LegalItem(
                  heading: '7. Cookies & Analytics',
                  body:
                      'The web version of KenWell365 uses Firebase '
                      'Performance Monitoring and Crashlytics to improve '
                      'reliability. No advertising or cross-site tracking '
                      'cookies are used.',
                ),
                _LegalItem(
                  heading: '8. Changes to This Policy',
                  body:
                      'We may update this Privacy Policy periodically. The '
                      '"Last Updated" date at the top of each section will '
                      'reflect any changes. Continued use of the App after '
                      'an update constitutes acceptance of the revised policy.',
                ),
                _LegalItem(
                  heading: '9. Contact',
                  body:
                      'KenWell Healthcare (Pty) Ltd\n'
                      'Email: mapiyem@kenwellhealthcare.co.za\n'
                      'Website: kenwellhealth.co.za',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Section ──────────────────────────────────────────────────────────────────

class _LegalSection extends StatelessWidget {
  const _LegalSection({
    required this.title,
    required this.lastUpdated,
    required this.items,
  });

  final String title;
  final String lastUpdated;
  final List<_LegalItem> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [KenwellColors.secondaryNavy, Color(0xFF2E2880)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Last updated: $lastUpdated',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.65),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        ...items.map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: item,
          ),
        ),
      ],
    );
  }
}

// ── Item ─────────────────────────────────────────────────────────────────────

class _LegalItem extends StatelessWidget {
  const _LegalItem({required this.heading, required this.body});

  final String heading;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            heading,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: KenwellColors.secondaryNavy,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            body,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF374151),
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
