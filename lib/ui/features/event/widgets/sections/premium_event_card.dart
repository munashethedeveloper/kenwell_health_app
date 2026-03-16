import 'package:flutter/material.dart';
import 'package:kenwell_health_app/ui/shared/ui/colours/kenwell_colours.dart';
import 'package:kenwell_health_app/ui/shared/ui/buttons/custom_primary_button.dart';
import '../../../../../domain/models/wellness_event.dart';
import '../../../../../utils/event_status_colors.dart';

/// Premium event card with a gradient top accent bar and modern card layout.
///
/// Displays event title, address, date/time/participant metadata, and action
/// buttons ("Start Event" / "Resume Event" and "Finish Event").
///
/// The [canStart] flag controls whether the Start/Resume button is enabled.
/// When [startTooltip] is non-null it is shown as a [Tooltip] around the
/// disabled button to explain the restriction to the user.
class PremiumEventCard extends StatelessWidget {
  const PremiumEventCard({
    super.key,
    required this.event,
    required this.isStarting,
    required this.canStart,
    required this.startTooltip,
    required this.onStart,
    required this.onFinish,
  });

  /// The wellness event to display.
  final WellnessEvent event;

  /// True while the start/resume navigation is in progress (shows a spinner).
  final bool isStarting;

  /// Whether the "Start Event" button should be enabled.
  final bool canStart;

  /// Optional tooltip message explaining why the start button is locked.
  final String? startTooltip;

  /// Called when the user taps "Start Event" / "Resume Event".
  final VoidCallback onStart;

  /// Called when the user taps "Finish Event".
  final VoidCallback onFinish;

  @override
  Widget build(BuildContext context) {
    final statusColor = EventStatusColors.getStatusColor(event.status);

    // Concatenate non-empty address parts into a single line.
    final fullAddress = [event.address, event.townCity, event.province]
        .where((s) => s.isNotEmpty)
        .join(', ');

    return Container(
      margin: const EdgeInsets.only(top: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.07),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          children: [
            // ── Gradient top accent bar ────────────────────────────────
            Container(
              height: 4,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [KenwellColors.primaryGreen, Color(0xFF3B3F86)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
              ),
            ),

            // ── Card body ──────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header: icon + title + status badge
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Event icon badge
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              KenwellColors.secondaryNavy,
                              Color(0xFF3B3F86),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(
                          Icons.event_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Title + micro label
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'CLIENT ORGANIZATION',
                              style: TextStyle(
                                color: KenwellColors.primaryGreen,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.8,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              event.title,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: KenwellColors.secondaryNavy,
                                height: 1.25,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Status badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 9, vertical: 5),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: statusColor.withValues(alpha: 0.3),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          event.status,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: statusColor,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Address row (hidden when empty)
                  if (fullAddress.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(top: 1.5),
                          child: Icon(
                            Icons.location_on_outlined,
                            size: 13,
                            color: KenwellColors.neutralGrey,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            fullAddress,
                            style: const TextStyle(
                              fontSize: 12,
                              color: KenwellColors.neutralGrey,
                              height: 1.4,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],

                  const SizedBox(height: 14),
                  const Divider(
                    height: 1,
                    thickness: 1,
                    color: KenwellColors.neutralDivider,
                  ),
                  const SizedBox(height: 12),

                  // Meta pills: date, time range, participant count
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: [
                      EventMetaPill(
                        icon: Icons.calendar_today_outlined,
                        label:
                            '${event.date.day}/${event.date.month}/${event.date.year}',
                      ),
                      if (event.startTime.isNotEmpty)
                        EventMetaPill(
                          icon: Icons.access_time_rounded,
                          label: event.endTime.isNotEmpty
                              ? '${event.startTime} – ${event.endTime}'
                              : event.startTime,
                        ),
                      if (event.expectedParticipation > 0)
                        EventMetaPill(
                          icon: Icons.people_outline_rounded,
                          label:
                              '${event.expectedParticipation} participant${event.expectedParticipation == 1 ? '' : 's'}',
                        ),
                    ],
                  ),

                  // Services requested row
                  if (event.servicesRequested.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(top: 1.5),
                          child: Icon(
                            Icons.medical_services_outlined,
                            size: 13,
                            color: KenwellColors.neutralGrey,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Expanded(
                          child: Text(
                            'Services: ${event.servicesRequested}',
                            style: const TextStyle(
                              fontSize: 11,
                              color: KenwellColors.neutralGrey,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],

                  const SizedBox(height: 14),
                  const Divider(
                    height: 1,
                    thickness: 1,
                    color: KenwellColors.neutralDivider,
                  ),
                  const SizedBox(height: 12),

                  // Action buttons
                  Row(
                    children: [
                      Expanded(
                        child: Builder(
                          builder: (context) {
                            final btn = CustomPrimaryButton(
                              label:
                                  event.status == WellnessEventStatus.inProgress
                                      ? 'Resume Event'
                                      : 'Start Event',
                              // Disable while starting or when time-locked.
                              onPressed:
                                  isStarting || !canStart ? null : onStart,
                              isBusy: isStarting,
                              fullWidth: true,
                            );
                            // Wrap in Tooltip when start is restricted so the
                            // nurse knows when the button will become available.
                            return startTooltip != null
                                ? Tooltip(message: startTooltip!, child: btn)
                                : btn;
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: CustomPrimaryButton(
                          label: 'Finish Event',
                          fullWidth: true,
                          // Only allow finishing an in-progress event that has
                          // at least one screened participant.
                          onPressed:
                              event.status == WellnessEventStatus.inProgress &&
                                      event.screenedCount > 0
                                  ? onFinish
                                  : null,
                          backgroundColor: Colors.red.shade700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Small pill chip displaying an icon + label for event metadata.
///
/// Used in [PremiumEventCard] for date, time-range and participant count.
class EventMetaPill extends StatelessWidget {
  const EventMetaPill({super.key, required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: KenwellColors.neutralBackground,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: KenwellColors.neutralDivider, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: KenwellColors.secondaryNavy),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: KenwellColors.secondaryNavy,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
