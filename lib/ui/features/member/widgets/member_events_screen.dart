import 'package:flutter/material.dart';
import '../../../../domain/models/member.dart';
import '../view_model/member_events_view_model.dart';
import '../../../shared/ui/app_bar/kenwell_app_bar.dart';
import '../../../shared/ui/headers/kenwell_gradient_header.dart';
import '../../../shared/ui/cards/kenwell_detail_row.dart';
import '../../../shared/ui/cards/kenwell_section_card.dart';
import '../../../shared/ui/colours/kenwell_colours.dart';

/// Displays a member's personal details and their event-attendance history.
///
/// All data loading is handled by [MemberEventsViewModel]; this widget is
/// pure UI.
class MemberEventsScreen extends StatefulWidget {
  final Member member;

  const MemberEventsScreen({
    super.key,
    required this.member,
  });

  @override
  State<MemberEventsScreen> createState() => _MemberEventsScreenState();
}

class _MemberEventsScreenState extends State<MemberEventsScreen> {
  late final MemberEventsViewModel _vm;

  @override
  void initState() {
    super.initState();
    _vm = MemberEventsViewModel(member: widget.member);
    _vm.addListener(_onVmChanged);
    _vm.loadMemberEvents();
  }

  @override
  void dispose() {
    _vm
      ..removeListener(_onVmChanged)
      ..dispose();
    super.dispose();
  }

  void _onVmChanged() {
    if (mounted) setState(() {});
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: const KenwellAppBar(
        title: 'KenWell365',
        automaticallyImplyLeading: true,
      ),
      body: RefreshIndicator(
        onRefresh: _vm.loadMemberEvents,
        child: CustomScrollView(
          slivers: [
            // ── Gradient section header ─────────────────────────
            const SliverToBoxAdapter(
              child: KenwellGradientHeader(
                label: 'MEMBER',
                title: 'Member\nDetails',
                subtitle:
                    'Detailed information about the member and their event history',
              ),
            ),
            // ── Content ─────────────────────────────────────────
            SliverList(
              delegate: SliverChildListDelegate([
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      KenwellSectionCard(
                        title: 'Personal Information',
                        icon: Icons.person,
                        children: [
                          KenwellDetailRow(
                              label: 'Name and Surname',
                              value:
                                  '${widget.member.name} ${widget.member.surname}'),
                          const Divider(height: 1),
                          KenwellDetailRow(
                              label: 'Gender',
                              value: widget.member.gender ?? ''),
                          const Divider(height: 1),
                          KenwellDetailRow(
                              label: 'Email', value: widget.member.email ?? ''),
                          const Divider(height: 1),
                          KenwellDetailRow(
                              label: 'Phone Number',
                              value: widget.member.cellNumber ?? ''),
                          const Divider(height: 1),
                          KenwellDetailRow(
                              label: 'Citizenship Status',
                              value: widget.member.citizenshipStatus ?? ''),
                          const Divider(height: 1),
                          KenwellDetailRow(
                              label: 'Nationality',
                              value: widget.member.nationality ?? ''),
                          const Divider(height: 1),
                          KenwellDetailRow(
                              label: 'ID Number',
                              value: widget.member.idNumber ?? ''),
                          const Divider(height: 1),
                          KenwellDetailRow(
                              label: 'Passport Number',
                              value: widget.member.passportNumber ?? ''),
                          const Divider(height: 1),
                          KenwellDetailRow(
                              label: 'Medical Aid',
                              value: widget.member.medicalAidName ?? ''),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Events History  (${_vm.events.length})',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF201C58),
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (_vm.isLoading)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.all(32.0),
                            child: CircularProgressIndicator(),
                          ),
                        )
                      else if (_vm.errorMessage != null)
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(32.0),
                            child: Column(
                              children: [
                                Icon(Icons.error_outline,
                                    size: 64, color: theme.colorScheme.error),
                                const SizedBox(height: 16),
                                Text(_vm.errorMessage!,
                                    textAlign: TextAlign.center,
                                    style: theme.textTheme.bodyMedium),
                                const SizedBox(height: 16),
                                ElevatedButton(
                                    onPressed: _vm.loadMemberEvents,
                                    child: const Text('Retry')),
                              ],
                            ),
                          ),
                        )
                      else if (_vm.events.isEmpty)
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(32.0),
                            child: Column(
                              children: [
                                Icon(Icons.event_busy,
                                    size: 64,
                                    color: theme.colorScheme.onSurfaceVariant),
                                const SizedBox(height: 16),
                                Text('No Events Found',
                                    style:
                                        theme.textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    )),
                                const SizedBox(height: 8),
                                Text(
                                  'This member has not attended any events yet.',
                                  textAlign: TextAlign.center,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      else
                        ..._vm.events
                            .map((event) => _EventCard(
                                  event: event,
                                  formatDate: _vm.formatDate,
                                  referral: _vm.referralFor(
                                      event['eventId'] as String? ?? ''),
                                ))
                            .toList(),
                    ],
                  ),
                ),
              ]),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Private section widgets
// ─────────────────────────────────────────────────────────────────────────────

class _EventCard extends StatelessWidget {
  const _EventCard({
    required this.event,
    required this.formatDate,
    this.referral,
  });

  final Map<String, dynamic> event;
  final String Function(dynamic) formatDate;
  final EventReferralSummary? referral;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final location = _resolveLocation();
    final isScreened = event['isScreened'] as bool? ?? false;
    final completedScreenings = _completedScreenings();

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.primaryColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.primaryColor.withValues(alpha: 0.15),
          width: 1.5,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: theme.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.event, color: theme.primaryColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        event['eventTitle'] ?? 'Unknown Event',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: theme.primaryColor,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    _ScreeningBadge(isScreened: isScreened),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.calendar_today,
                        size: 14, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      formatDate(event['eventDate']),
                      style: theme.textTheme.bodySmall
                          ?.copyWith(color: Colors.grey[600]),
                    ),
                  ],
                ),
                if (location != null) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.location_on,
                          size: 14, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          location,
                          style: theme.textTheme.bodySmall
                              ?.copyWith(color: Colors.grey[600]),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    ],
                  ),
                ],
                if (completedScreenings.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    children: completedScreenings
                        .map((s) => _ScreeningChip(label: s))
                        .toList(),
                  ),
                ],
                // ── Referral outcome ────────────────────────────────────
                if (referral != null && referral!.status != null) ...[
                  const SizedBox(height: 10),
                  const Divider(height: 1),
                  const SizedBox(height: 10),
                  _ReferralOutcomeSection(referral: referral!),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  String? _resolveLocation() {
    final loc = event['eventLocation'];
    if (loc != null && loc.toString().isNotEmpty) return loc as String;
    final venue = event['eventVenue'];
    if (venue != null && venue.toString().isNotEmpty) return venue as String;
    return null;
  }

  List<String> _completedScreenings() => [
        if (event['hraCompleted'] as bool? ?? false) 'HRA',
        if (event['hctCompleted'] as bool? ?? false) 'HCT',
        if (event['tbCompleted'] as bool? ?? false) 'TB',
        if (event['cancerCompleted'] as bool? ?? false) 'Cancer',
      ];
}

class _ReferralOutcomeSection extends StatelessWidget {
  const _ReferralOutcomeSection({required this.referral});
  final EventReferralSummary referral;

  @override
  Widget build(BuildContext context) {
    final isHighRisk = referral.isHighRisk;
    final color = isHighRisk ? Colors.red.shade700 : Colors.green.shade700;
    final bgColor = isHighRisk
        ? Colors.red.withValues(alpha: 0.08)
        : Colors.green.withValues(alpha: 0.08);
    final icon =
        isHighRisk ? Icons.dangerous_outlined : Icons.check_circle_outline;
    final label = isHighRisk ? 'High Risk' : 'Healthy';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.medical_services_outlined,
                size: 13, color: KenwellColors.neutralGrey),
            const SizedBox(width: 4),
            Text(
              'Referral Outcome',
              style: TextStyle(
                fontSize: 11,
                color: KenwellColors.neutralGrey,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
            ],
          ),
        ),
        // Show flagged metrics only for high-risk outcomes.
        if (isHighRisk && referral.riskFlags.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            'Flagged metrics:',
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[600],
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Wrap(
            spacing: 4,
            runSpacing: 4,
            children: referral.riskFlags
                .map((flag) => _RiskFlagChip(label: flag))
                .toList(),
          ),
        ],
      ],
    );
  }
}

class _RiskFlagChip extends StatelessWidget {
  const _RiskFlagChip({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.red.withValues(alpha: 0.25)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          color: Colors.red.shade700,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _ScreeningBadge extends StatelessWidget {
  const _ScreeningBadge({required this.isScreened});
  final bool isScreened;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = isScreened ? Colors.green : Colors.orange;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isScreened ? Icons.check_circle_outline : Icons.app_registration,
            size: 12,
            color: isScreened ? Colors.green.shade700 : Colors.orange.shade700,
          ),
          const SizedBox(width: 3),
          Text(
            isScreened ? 'Screened' : 'Registered',
            style: theme.textTheme.labelSmall?.copyWith(
              color:
                  isScreened ? Colors.green.shade700 : Colors.orange.shade700,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _ScreeningChip extends StatelessWidget {
  const _ScreeningChip({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: theme.primaryColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.primaryColor.withValues(alpha: 0.2)),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelSmall?.copyWith(
          color: theme.primaryColor,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
