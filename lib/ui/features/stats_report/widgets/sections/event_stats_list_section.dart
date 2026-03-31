import 'package:flutter/material.dart';
import 'package:kenwell_health_app/ui/shared/ui/colours/kenwell_colours.dart';
import '../../../../../domain/models/wellness_event.dart';
import '../event_stats_detail_screen.dart';

/// Displays the "Event Breakdown" list card.
///
/// Each row shows an event title, date, status badge, and screened-count
/// badge.  Tapping navigates to [EventStatsDetailScreen].
///
/// Shown on both the Live Events and Past Events views; [isLiveTab] switches
/// between green and navy colour themes.
///
/// By default only the first [_kInitialCount] events are shown.  A
/// "Show more" button reveals all events.
class EventStatsListSection extends StatefulWidget {
  const EventStatsListSection({
    super.key,
    required this.events,
    required this.isLiveTab,
    required this.getStatusColor,
  });

  final List<WellnessEvent> events;
  final bool isLiveTab;

  /// Colour resolver for the status badge — injected so the parent can keep
  /// ownership of that utility without duplication.
  final Color Function(String status) getStatusColor;

  @override
  State<EventStatsListSection> createState() => _EventStatsListSectionState();
}

class _EventStatsListSectionState extends State<EventStatsListSection> {
  static const int _kInitialCount = 5;
  bool _showAll = false;

  @override
  Widget build(BuildContext context) {
    final List<Color> gradientColors = widget.isLiveTab
        ? [KenwellColors.primaryGreen, const Color(0xFF065F46)]
        : [KenwellColors.secondaryNavy, const Color(0xFF3B3F86)];

    final displayedEvents = _showAll
        ? widget.events
        : widget.events.take(_kInitialCount).toList();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header row ────────────────────────────────────────────────
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: gradientColors,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  widget.isLiveTab
                      ? Icons.play_circle_outline
                      : Icons.history,
                  color: Colors.white,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                widget.isLiveTab
                    ? 'Live Event Breakdown'
                    : 'Past Event Breakdown',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: KenwellColors.secondaryNavy,
                ),
              ),
              const Spacer(),
              Text(
                '${widget.events.length} event${widget.events.length != 1 ? "s" : ""}',
                style: const TextStyle(
                  fontSize: 12,
                  color: KenwellColors.neutralGrey,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(height: 1, color: KenwellColors.neutralDivider),
          const SizedBox(height: 12),

          // ── Empty state ───────────────────────────────────────────────
          if (widget.events.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(22),
                      decoration: const BoxDecoration(
                        color: KenwellColors.neutralBackground,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.event_busy,
                          size: 44, color: Colors.grey[400]),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      widget.isLiveTab ? 'No live events' : 'No past events',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: KenwellColors.secondaryNavy,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      widget.isLiveTab
                          ? 'Events currently in progress will appear here'
                          : 'Completed events will appear here',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF6B7280),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            )
          else ...[
            // ── Event rows ──────────────────────────────────────────────
            ...displayedEvents.map(
              (event) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => EventStatsDetailScreen(event: event),
                      ),
                    ),
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: KenwellColors.neutralBackground,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: KenwellColors.neutralDivider,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          // Gradient icon
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: gradientColors,
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.event,
                                color: Colors.white, size: 18),
                          ),
                          const SizedBox(width: 12),
                          // Title + date + status badge
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  event.title,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: KenwellColors.secondaryNavy,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(Icons.calendar_today,
                                        size: 12,
                                        color: Colors.grey[500]),
                                    const SizedBox(width: 3),
                                    Text(
                                      '${event.date.day}/${event.date.month}/${event.date.year}',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey[500],
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 7, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: widget
                                            .getStatusColor(event.status)
                                            .withValues(alpha: 0.12),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        event.status,
                                        style: TextStyle(
                                          fontSize: 9,
                                          color: widget
                                              .getStatusColor(event.status),
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          // Screened count badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: gradientColors,
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '${event.screenedCount}',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Icon(Icons.chevron_right,
                              color: Colors.grey.shade400),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // ── Show more / show less button ──────────────────────────
            if (widget.events.length > _kInitialCount)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () =>
                        setState(() => _showAll = !_showAll),
                    icon: Icon(
                      _showAll
                          ? Icons.keyboard_arrow_up_rounded
                          : Icons.keyboard_arrow_down_rounded,
                      size: 18,
                    ),
                    label: Text(
                      _showAll
                          ? 'Show less'
                          : 'Show ${widget.events.length - _kInitialCount} more event${widget.events.length - _kInitialCount != 1 ? "s" : ""}',
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: gradientColors.first,
                      side: BorderSide(
                          color: gradientColors.first.withValues(alpha: 0.5)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }
}
