import 'package:flutter/material.dart';
import 'package:kenwell_health_app/ui/shared/ui/app_bar/kenwell_app_bar.dart';
import 'package:kenwell_health_app/ui/shared/ui/colours/kenwell_colours.dart';

/// In-app FAQ & Help Center screen.
///
/// Organised into collapsible categories covering the key user flows:
/// Events, Wellness Flow, Screenings, Reports, Account & Settings.
class FaqScreen extends StatefulWidget {
  const FaqScreen({super.key});

  @override
  State<FaqScreen> createState() => _FaqScreenState();
}

class _FaqScreenState extends State<FaqScreen> {
  String? _openCategory;

  // ── FAQ data ───────────────────────────────────────────────────────────────

  static const _categories = [
    _FaqCategory(
      icon: Icons.event_rounded,
      color: KenwellColors.primaryGreen,
      title: 'Events',
      items: [
        _FaqItem(
          q: 'How do I create a new event?',
          a: 'Tap the "Add Event" quick-action on the Home screen, or use the '
              'floating "+" button on the Calendar or Events screens. '
              'Fill in all required fields (title, date, venue, services) and tap "Save".',
        ),
        _FaqItem(
          q: 'How do I start / go live with an event?',
          a: 'Open the event details page and tap "Start Event". '
              'The event status will change to In Progress and it will appear '
              'on the Live Statistics screen.',
        ),
        _FaqItem(
          q: 'How do I allocate staff or nurses to an event?',
          a: 'Go to All Events, tap on the event card, then select "Allocate". '
              'Choose the users you want to assign and confirm.',
        ),
        _FaqItem(
          q: 'How do I edit or delete an event?',
          a: 'Open the event details page. Use the edit (pencil) icon in the '
              'app bar to modify the event. To delete, swipe left on an event '
              'card in the Calendar Events List — a "Delete" action will appear.',
        ),
        _FaqItem(
          q: 'What does the event status mean?',
          a: '"Scheduled" = future event not yet started.\n'
              '"In Progress" = event is currently running (live).\n'
              '"Completed" = event has ended and been closed.',
        ),
      ],
    ),
    _FaqCategory(
      icon: Icons.health_and_safety_rounded,
      color: Color(0xFF3B82F6),
      title: 'Wellness Flow & Screenings',
      items: [
        _FaqItem(
          q: 'How do I register a member for a wellness event?',
          a: 'From the Calendar or Events screen, open a live event and tap '
              '"Start Wellness Flow". Search for the member by name or ID '
              'number. If they are not yet registered, tap "Add New Member" to '
              'create their profile.',
        ),
        _FaqItem(
          q: 'What is the correct order for the wellness flow?',
          a: 'The flow follows four sections:\n'
              'A – Member Registration\n'
              'B – Informed Consent\n'
              'C – Health Screenings (HRA, HCT, TB, Cancer — based on consent)\n'
              'D – Post-Screening Survey\n\n'
              'Each section must be completed before the next one unlocks.',
        ),
        _FaqItem(
          q: 'What if a member has already consented at a previous event?',
          a: 'Consent is per-event. Even if a member attended before, a new '
              'consent form must be completed for each event they attend.',
        ),
        _FaqItem(
          q: 'What screenings are included?',
          a: '• HRA – Health Risk Assessment (lifestyle & biometric data)\n'
              '• HCT – HIV Counselling & Testing\n'
              '• TB – Tuberculosis symptom screening\n'
              '• Cancer – Cervical (Pap Smear), Breast, and/or PSA depending '
              'on the services requested for the event.',
        ),
        _FaqItem(
          q: 'How does the HP signature work?',
          a: 'The Healthcare Practitioner captures their signature once on the '
              'consent form. This signature is automatically pre-filled on all '
              'subsequent health screening forms for that member. '
              'You can tap "Override Signature" on any form to draw a new one.',
        ),
        _FaqItem(
          q: 'What happens when I submit a health screening?',
          a: 'The screening data is saved to Firestore and synced to the local '
              'offline database. The member\'s screening status is updated and '
              'the event\'s screened count is automatically incremented when '
              'all consented screenings are complete.',
        ),
      ],
    ),
    _FaqCategory(
      icon: Icons.bar_chart_rounded,
      color: Color(0xFF8B5CF6),
      title: 'Statistics & Reports',
      items: [
        _FaqItem(
          q: 'What is the Live Statistics screen?',
          a: 'The Live Statistics screen shows real-time data for events that '
              'are currently in progress (today\'s date, status = In Progress). '
              'It updates automatically as screenings are completed.',
        ),
        _FaqItem(
          q: 'What does "Registered" mean on the stats screen?',
          a: '"Registered" shows the number of members who have been registered '
              '(checked in) for the current live events via the wellness flow.',
        ),
        _FaqItem(
          q: 'What does "Screened" mean?',
          a: '"Screened" counts members who have completed at least one health '
              'screening during the current event(s).',
        ),
        _FaqItem(
          q: 'How do I export statistics?',
          a: 'In the Statistics screen, open an event\'s detail view. '
              'Managers and Admins will see an "Export" button in the top-right '
              'corner to download a CSV report.',
        ),
      ],
    ),
    _FaqCategory(
      icon: Icons.people_rounded,
      color: Color(0xFFEF4444),
      title: 'Members',
      items: [
        _FaqItem(
          q: 'How do I add a new member?',
          a: 'Members can be added during the wellness flow ("Add New Member") '
              'or via the Users / Registration screen accessible from the '
              'navigation bar.',
        ),
        _FaqItem(
          q: 'Can I edit a member\'s details?',
          a: 'Yes. Open the member\'s profile from the Users screen and tap the '
              'edit icon. Name, ID number, date of birth, gender and contact '
              'details can all be updated.',
        ),
        _FaqItem(
          q: 'How do I view a member\'s screening history?',
          a: 'Tap on a member in the Users screen and navigate to the '
              '"Event History" section to see all previous screenings and events.',
        ),
      ],
    ),
    _FaqCategory(
      icon: Icons.lock_outline_rounded,
      color: Color(0xFFF59E0B),
      title: 'Account & Roles',
      items: [
        _FaqItem(
          q: 'What are the different user roles?',
          a: '• Admin – Full access to all features including user management.\n'
              '• Top Management / Project Manager – Access to stats, exports and event management.\n'
              '• Project Coordinator / Health Practitioner – Can run wellness flows and view events.\n'
              '• Client – Read-only access to statistics.\n'
              '• Restricted – Limited access for field staff.',
        ),
        _FaqItem(
          q: 'Why can\'t I see some features?',
          a: 'Features are gated by your assigned role. If you need additional '
              'access, contact your Administrator to update your role.',
        ),
        _FaqItem(
          q: 'How do I update my profile?',
          a: 'Your profile is accessible from "My Profile" in the help/support '
              'screen or via the home screen quick action. You can edit your '
              'name, contact details and profile photo.',
        ),
        _FaqItem(
          q: 'The app is showing cached data — what should I do?',
          a: 'This happens when you\'re offline. The app continues to work using '
              'locally cached data. When you reconnect, pull down to refresh '
              'and the latest data will sync automatically.',
        ),
      ],
    ),
    _FaqCategory(
      icon: Icons.bug_report_rounded,
      color: Color(0xFF6B7280),
      title: 'Troubleshooting',
      items: [
        _FaqItem(
          q: 'A screening form won\'t submit — what should I do?',
          a: 'Ensure all required fields are completed:\n'
              '• All screening questions answered\n'
              '• Nurse name, SANC number and rank filled in\n'
              '• A signature present (either drawn or auto-filled from consent)\n\n'
              'If the issue persists, contact support.',
        ),
        _FaqItem(
          q: 'An event isn\'t showing on the Live Stats screen.',
          a: 'Live Stats only shows events where:\n'
              '1. The event date is today\n'
              '2. The event status is "In Progress"\n\n'
              'Make sure the event has been started and that its date is set to today.',
        ),
        _FaqItem(
          q: 'I accidentally deleted an event — can I recover it?',
          a: 'A short UNDO option appears in the snack bar immediately after '
              'deletion. If you missed it, contact your Admin to restore '
              'the event from the audit log.',
        ),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KenwellColors.neutralBackground,
      appBar: const KenwellAppBar(
        title: 'FAQs & Help Center',
        automaticallyImplyLeading: true,
        titleStyle: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
      body: CustomScrollView(
        slivers: [
          // Header
          const SliverToBoxAdapter(child: _FaqHeader()),
          // Categories
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final cat = _categories[index];
                  final isOpen = _openCategory == cat.title;
                  return _CategoryCard(
                    category: cat,
                    isOpen: isOpen,
                    onTap: () => setState(() {
                      _openCategory = isOpen ? null : cat.title;
                    }),
                  );
                },
                childCount: _categories.length,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Header ────────────────────────────────────────────────────────────────────

class _FaqHeader extends StatelessWidget {
  const _FaqHeader();
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [KenwellColors.secondaryNavy, Color(0xFF2E2880)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'FAQs & Help Center',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Tap a category to expand answers to common questions.',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.help_outline_rounded,
                color: Colors.white, size: 28),
          ),
        ],
      ),
    );
  }
}

// ── Category card (expandable) ────────────────────────────────────────────────

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({
    required this.category,
    required this.isOpen,
    required this.onTap,
  });

  final _FaqCategory category;
  final bool isOpen;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isOpen
              ? category.color.withValues(alpha: 0.4)
              : Colors.grey.shade200,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // ── Header row ──────────────────────────────────────────────
          InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: category.color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(category.icon,
                        color: category.color, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      category.title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: KenwellColors.secondaryNavy,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: category.color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${category.items.length}',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: category.color,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    isOpen
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    color: Colors.grey.shade400,
                    size: 22,
                  ),
                ],
              ),
            ),
          ),

          // ── FAQ items (expanded) ─────────────────────────────────────
          if (isOpen) ...[
            Divider(
                height: 1,
                color: category.color.withValues(alpha: 0.15),
                indent: 16,
                endIndent: 16),
            ...category.items.map(
              (item) => _FaqItemTile(item: item, accentColor: category.color),
            ),
            const SizedBox(height: 4),
          ],
        ],
      ),
    );
  }
}

// ── Individual FAQ item ────────────────────────────────────────────────────────

class _FaqItemTile extends StatefulWidget {
  const _FaqItemTile({required this.item, required this.accentColor});

  final _FaqItem item;
  final Color accentColor;

  @override
  State<_FaqItemTile> createState() => _FaqItemTileState();
}

class _FaqItemTileState extends State<_FaqItemTile> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () => setState(() => _expanded = !_expanded),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.help_outline_rounded,
                    size: 16,
                    color: widget.accentColor.withValues(alpha: 0.7)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    widget.item.q,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: KenwellColors.secondaryNavy,
                      height: 1.4,
                    ),
                  ),
                ),
                Icon(
                  _expanded
                      ? Icons.remove_rounded
                      : Icons.add_rounded,
                  size: 18,
                  color: Colors.grey.shade400,
                ),
              ],
            ),
          ),
        ),
        if (_expanded)
          Container(
            margin: const EdgeInsets.fromLTRB(42, 0, 16, 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: widget.accentColor.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: widget.accentColor.withValues(alpha: 0.15),
              ),
            ),
            child: Text(
              widget.item.a,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF374151),
                height: 1.6,
              ),
            ),
          ),
        Divider(
            height: 1,
            color: Colors.grey.shade100,
            indent: 16,
            endIndent: 16),
      ],
    );
  }
}

// ── Data classes ──────────────────────────────────────────────────────────────

class _FaqCategory {
  const _FaqCategory({
    required this.icon,
    required this.color,
    required this.title,
    required this.items,
  });

  final IconData icon;
  final Color color;
  final String title;
  final List<_FaqItem> items;
}

class _FaqItem {
  const _FaqItem({required this.q, required this.a});

  final String q;
  final String a;
}
