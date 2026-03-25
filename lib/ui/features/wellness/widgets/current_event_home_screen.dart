import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kenwell_health_app/domain/models/wellness_event.dart';
import 'package:kenwell_health_app/ui/shared/ui/buttons/custom_primary_button.dart';
import 'package:kenwell_health_app/ui/features/wellness/view_model/wellness_flow_view_model.dart';
import 'package:kenwell_health_app/ui/shared/ui/colours/kenwell_colours.dart';
import 'package:provider/provider.dart';

class CurrentEventHomeScreen extends StatelessWidget {
  final WellnessEvent event;
  final Function(String section) onSectionTap;
  final VoidCallback onBackToSearch;

  const CurrentEventHomeScreen({
    super.key,
    required this.event,
    required this.onSectionTap,
    required this.onBackToSearch,
  });

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<WellnessFlowViewModel>();

    final sections = _buildSections(viewModel);
    final completedCount = sections.where((s) => s.isCompleted).length;
    final totalCount = sections.length;
    final progressValue = totalCount > 0 ? completedCount / totalCount : 0.0;

    return Column(
      children: [
        // ── Modern event banner ─────────────────────────────────────
        _EventBanner(
          event: event,
          progressValue: progressValue,
          completedCount: completedCount,
          totalCount: totalCount,
        ),

        // ── Scrollable content ──────────────────────────────────────
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (viewModel.currentMember != null) ...[
                  _MemberCard(viewModel: viewModel),
                  const SizedBox(height: 16),
                ],

                _SectionsWithProgress(
                    sections: sections, onSectionTap: onSectionTap),

                const SizedBox(height: 24),
                CustomPrimaryButton(
                  label: 'Back to Search',
                  onPressed: onBackToSearch,
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ],
    );
  }

  List<_SectionData> _buildSections(WellnessFlowViewModel vm) => [
        _SectionData(
          icon: Icons.person_add_rounded,
          title: 'Member Registration',
          subtitle: 'Section A',
          isCompleted: vm.memberRegistrationCompleted,
          isInProgress: false,
          isLocked: vm.memberRegistrationCompleted,
          sectionKey: WellnessFlowViewModel.sectionMemberRegistration,
        ),
        _SectionData(
          icon: Icons.assignment_turned_in_rounded,
          title: 'Informed Consent',
          subtitle: 'Section B',
          isCompleted: vm.consentCompleted,
          isInProgress: false,
          isLocked: vm.consentCompleted,
          sectionKey: WellnessFlowViewModel.sectionConsent,
        ),
        _SectionData(
          icon: Icons.health_and_safety_rounded,
          title: 'Health Screenings',
          subtitle: 'Section C',
          isCompleted: vm.screeningsCompleted,
          isInProgress: vm.screeningsInProgress,
          isLocked: vm.screeningsCompleted,
          sectionKey: WellnessFlowViewModel.sectionHealthScreenings,
        ),
        _SectionData(
          icon: Icons.poll_rounded,
          title: 'Survey',
          subtitle: 'Section D',
          isCompleted: vm.surveyCompleted,
          isInProgress: false,
          isLocked: vm.surveyCompleted,
          sectionKey: WellnessFlowViewModel.sectionSurvey,
        ),
      ];
}

// ── Data class ────────────────────────────────────────────────────────────────

class _SectionData {
  const _SectionData({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isCompleted,
    required this.isInProgress,
    required this.isLocked,
    required this.sectionKey,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool isCompleted;
  final bool isInProgress;
  final bool isLocked;
  final String sectionKey;
}

// ── Event banner ──────────────────────────────────────────────────────────────

class _EventBanner extends StatelessWidget {
  const _EventBanner({
    required this.event,
    required this.progressValue,
    required this.completedCount,
    required this.totalCount,
  });

  final WellnessEvent event;
  final double progressValue;
  final int completedCount;
  final int totalCount;

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('EEE, d MMM yyyy').format(event.date);

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [KenwellColors.secondaryNavy, Color(0xFF2E2880)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label chip
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: KenwellColors.primaryGreen.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              'CURRENT EVENT',
              style: TextStyle(
                color: KenwellColors.primaryGreen,
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Event title
          Text(
            event.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w800,
              height: 1.2,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 6),

          // Meta row
          Row(
            children: [
              const Icon(Icons.calendar_today_rounded,
                  size: 13, color: Colors.white70),
              const SizedBox(width: 4),
              Text(dateStr,
                  style: const TextStyle(color: Colors.white70, fontSize: 12)),
              if (event.venue.isNotEmpty) ...[
                const SizedBox(width: 12),
                const Icon(Icons.location_on_outlined,
                    size: 13, color: Colors.white70),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    event.venue,
                    style:
                        const TextStyle(color: Colors.white70, fontSize: 12),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ],
          ),

          const SizedBox(height: 14),

          // Progress bar
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Flow progress',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    '$completedCount / $totalCount sections',
                    style: const TextStyle(
                      color: KenwellColors.primaryGreen,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progressValue,
                  backgroundColor: Colors.white.withValues(alpha: 0.2),
                  valueColor: const AlwaysStoppedAnimation<Color>(
                      KenwellColors.primaryGreen),
                  minHeight: 6,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Member card ───────────────────────────────────────────────────────────────

class _MemberCard extends StatelessWidget {
  const _MemberCard({required this.viewModel});

  final WellnessFlowViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final member = viewModel.currentMember!;
    final fullName = '${member.name} ${member.surname}'.trim();
    final initials = _initials(member.name, member.surname);
    final idLabel =
        member.idDocumentType == 'ID' ? 'ID Number' : 'Passport';
    final idValue = member.idDocumentType == 'ID'
        ? (member.idNumber ?? 'N/A')
        : (member.passportNumber ?? 'N/A');

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: KenwellColors.primaryGreen.withValues(alpha: 0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: KenwellColors.primaryGreen.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [KenwellColors.primaryGreen, Color(0xFF6DB33F)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: Text(
                initials,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        fullName,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: KenwellColors.secondaryNavy,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: KenwellColors.primaryGreen
                            .withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'Active',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: KenwellColors.primaryGreen,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.badge_rounded,
                        size: 12, color: KenwellColors.neutralGrey),
                    const SizedBox(width: 4),
                    Text(
                      '$idLabel: $idValue',
                      style: const TextStyle(
                          fontSize: 12, color: KenwellColors.neutralGrey),
                    ),
                  ],
                ),
                if (member.gender != null &&
                    member.gender!.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(
                        member.gender?.toLowerCase() == 'female'
                            ? Icons.female_rounded
                            : Icons.male_rounded,
                        size: 12,
                        color: KenwellColors.neutralGrey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        member.gender!,
                        style: const TextStyle(
                            fontSize: 12,
                            color: KenwellColors.neutralGrey),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _initials(String first, String last) {
    final f = first.isNotEmpty ? first[0].toUpperCase() : '';
    final l = last.isNotEmpty ? last[0].toUpperCase() : '';
    final combined = '$f$l';
    return combined.isNotEmpty ? combined : '?';
  }
}

// ── Sections with vertical progress line ─────────────────────────────────────

class _SectionsWithProgress extends StatelessWidget {
  const _SectionsWithProgress({
    required this.sections,
    required this.onSectionTap,
  });

  final List<_SectionData> sections;
  final Function(String) onSectionTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: 12),
          child: Text(
            'Wellness Flow',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: KenwellColors.secondaryNavy,
              letterSpacing: 0.2,
            ),
          ),
        ),
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Vertical progress timeline
              _VerticalTimeline(sections: sections),
              const SizedBox(width: 12),
              // Section cards
              Expanded(
                child: Column(
                  children: [
                    for (int i = 0; i < sections.length; i++) ...[
                      _SectionCard(
                        section: sections[i],
                        onTap: sections[i].isLocked
                            ? null
                            : () => onSectionTap(sections[i].sectionKey),
                      ),
                      if (i < sections.length - 1) const SizedBox(height: 8),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Vertical timeline ─────────────────────────────────────────────────────────

class _VerticalTimeline extends StatelessWidget {
  const _VerticalTimeline({required this.sections});

  final List<_SectionData> sections;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 24,
      child: Column(
        children: [
          for (int i = 0; i < sections.length; i++) ...[
            _TimelineDot(section: sections[i]),
            if (i < sections.length - 1)
              Expanded(
                child: Container(
                  width: 2,
                  margin: const EdgeInsets.symmetric(horizontal: 11),
                  color: sections[i].isCompleted
                      ? KenwellColors.primaryGreen
                      : Colors.grey.shade200,
                ),
              ),
          ],
        ],
      ),
    );
  }
}

class _TimelineDot extends StatelessWidget {
  const _TimelineDot({required this.section});

  final _SectionData section;

  @override
  Widget build(BuildContext context) {
    if (section.isCompleted) {
      return Container(
        width: 24,
        height: 24,
        decoration: const BoxDecoration(
          color: KenwellColors.primaryGreen,
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.check_rounded, size: 14, color: Colors.white),
      );
    }
    if (section.isInProgress) {
      return Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: Colors.orange.withValues(alpha: 0.15),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.orange, width: 2),
        ),
        child: Center(
          child: Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: Colors.orange,
              shape: BoxShape.circle,
            ),
          ),
        ),
      );
    }
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.grey.shade300, width: 2),
        color: Colors.grey.shade50,
      ),
    );
  }
}

// ── Section card ──────────────────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.section, this.onTap});

  final _SectionData section;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final Color iconBg;
    final Color iconColor;
    final Color statusColor;
    final String statusText;
    final Color borderColor;

    if (section.isCompleted) {
      iconBg = const Color(0xFF90C048).withValues(alpha: 0.15);
      iconColor = const Color(0xFF90C048);
      statusColor = const Color(0xFF90C048);
      statusText = 'Completed';
      borderColor = const Color(0xFF90C048).withValues(alpha: 0.3);
    } else if (section.isInProgress) {
      iconBg = Colors.orange.withValues(alpha: 0.12);
      iconColor = Colors.orange[700]!;
      statusColor = Colors.orange[700]!;
      statusText = 'In Progress';
      borderColor = Colors.orange.withValues(alpha: 0.3);
    } else {
      iconBg = Colors.grey.shade100;
      iconColor = Colors.grey[500]!;
      statusColor = Colors.grey.shade500;
      statusText = 'Not Started';
      borderColor = Colors.grey.shade200;
    }

    return Tooltip(
      message: section.isLocked ? 'Already completed' : '',
      child: Material(
        color: section.isCompleted ? Colors.grey.shade50 : Colors.white,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: borderColor, width: 1.2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: iconBg,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(section.icon, color: iconColor, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        section.subtitle,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: statusColor,
                          letterSpacing: 0.5,
                        ),
                      ),
                      Text(
                        section.title,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: section.isCompleted
                              ? KenwellColors.secondaryNavy
                                  .withValues(alpha: 0.6)
                              : KenwellColors.secondaryNavy,
                        ),
                      ),
                    ],
                  ),
                ),
                if (section.isLocked)
                  Icon(Icons.lock_outline_rounded,
                      size: 18,
                      color: const Color(0xFF90C048).withValues(alpha: 0.7))
                else if (onTap != null)
                  Icon(Icons.chevron_right_rounded,
                      size: 20, color: Colors.grey.shade400),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
