import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kenwell_health_app/ui/shared/ui/app_bar/kenwell_app_bar.dart';
import 'package:provider/provider.dart';

import '../../../../domain/models/wellness_event.dart';
import '../../../shared/ui/buttons/custom_primary_button.dart';
import '../../../shared/ui/form/kenwell_form_card.dart';
import '../view_model/event_view_model.dart';
import '../../wellness/widgets/wellness_flow_page.dart';

class ConductEventScreen extends StatefulWidget {
  const ConductEventScreen({super.key});

  @override
  State<ConductEventScreen> createState() => _ConductEventScreenState();
}

class _ConductEventScreenState extends State<ConductEventScreen> {
  String? _startingEventId;

  @override
  Widget build(BuildContext context) {
    final eventVM = context.watch<EventViewModel>();
    final upcoming = eventVM.getUpcomingEvents();

    if (upcoming.isEmpty) {
      return const Scaffold(
          appBar: KenwellAppBar(
            title: 'Upcoming Events',
            backgroundColor: Color(0xFF201C58),
            titleColor: Colors.white,
            automaticallyImplyLeading: true,
          ),
          body: Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.event_available,
                      size: 64, color: Color(0xFF90C048)),
                  SizedBox(height: 16),
                  Text(
                    'No upcoming events ready to conduct.\nCreate an event or check back when it\'s time to start.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
          ));
    }

    return Scaffold(
        appBar: const KenwellAppBar(
          title: 'Conduct Events',
          backgroundColor: Color(0xFF201C58),
          titleColor: Colors.white,
          automaticallyImplyLeading: true,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: ListView.separated(
            itemCount: upcoming.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final event = upcoming[index];
              final isStarting = _startingEventId == event.id;
              return KenwellFormCard(
                title: 'Upcoming Event: ${event.title}',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      DateFormat.yMMMMd().add_jm().format(
                            event.startDateTime ?? event.date,
                          ),
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      event.venue.isNotEmpty ? event.venue : event.address,
                      style: const TextStyle(color: Colors.black54),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _infoChip(
                            Icons.access_time,
                            event.startTime.isEmpty
                                ? 'Pending time'
                                : event.startTime),
                        if (event.servicesRequested.isNotEmpty)
                          _infoChip(
                              Icons.medical_services, event.servicesRequested),
                        if (event.expectedParticipation > 0)
                          _infoChip(Icons.people,
                              '${event.expectedParticipation} expected'),
                        if (event.status == WellnessEventStatus.inProgress)
                          _infoChip(Icons.check_circle,
                              '${event.screenedCount} participant${event.screenedCount == 1 ? '' : 's'} screened'),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (event.status == WellnessEventStatus.inProgress) ...[
                      Row(
                        children: [
                          Expanded(
                            child: CustomPrimaryButton(
                              label: 'Resume Event',
                              onPressed:
                                  isStarting ? null : () => _startEvent(context, event),
                              isBusy: isStarting,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: CustomPrimaryButton(
                              label: 'Finish Event',
                              onPressed: isStarting
                                  ? null
                                  : () => _finishEvent(context, event),
                            ),
                          ),
                        ],
                      ),
                    ] else
                      CustomPrimaryButton(
                        label: 'Start Event',
                        onPressed:
                            isStarting ? null : () => _startEvent(context, event),
                        isBusy: isStarting,
                      ),
                  ],
                ),
              );
            },
          ),
        ));
  }

  Future<void> _startEvent(BuildContext context, WellnessEvent event) async {
    setState(() => _startingEventId = event.id);
    try {
      final eventVM = context.read<EventViewModel>();
      final updated = await eventVM.markEventInProgress(event.id) ?? event;
      if (!mounted) return;
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => WellnessFlowPage(
            event: updated,
            onExitEarly: () async {
              await eventVM.updateEvent(
                updated.copyWith(
                  status: WellnessEventStatus.scheduled,
                  actualStartTime: null,
                  actualEndTime: null,
                ),
              );
            },
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _startingEventId = null);
      }
    }
  }

  Future<void> _finishEvent(BuildContext context, WellnessEvent event) async {
    final eventVM = context.read<EventViewModel>();
    await eventVM.markEventCompleted(event.id);
  }

  Widget _infoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6EE),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: const Color(0xFF201C58)),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF201C58),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
