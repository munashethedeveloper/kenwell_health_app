import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../domain/models/wellness_event.dart';
import '../../../shared/ui/app_bar/kenwell_app_bar.dart';
import '../view_model/wellness_flow_view_model.dart';
import 'wellness_flow_screen.dart';

class WellnessFlowPage extends StatelessWidget {
  final WellnessEvent event;
  final Future<void> Function()? onFlowCompleted;
  final Future<void> Function()? onExitEarly;

  const WellnessFlowPage({
    super.key,
    required this.event,
    this.onFlowCompleted,
    this.onExitEarly,
  });

  Future<void> _handleExit(BuildContext context) async {
    if (onExitEarly != null) {
      await onExitEarly!();
    }
    if (context.mounted) {
      Navigator.of(context).pop();
    }
  }

  Future<void> _handleCompletion(BuildContext context) async {
    if (onFlowCompleted != null) {
      await onFlowCompleted!();
    }
    if (context.mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: KenwellAppBar(
        title: 'Conduct ${event.title}',
        backgroundColor: const Color(0xFF201C58),
        titleColor: Colors.white,
        automaticallyImplyLeading: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () => _handleExit(context),
          ),
        ],
      ),
      body: ChangeNotifierProvider<WellnessFlowViewModel>(
        create: (_) => WellnessFlowViewModel(activeEvent: event),
        child: WellnessFlowScreen(
          event: event,
          onExitFlow: () => _handleExit(context),
          onFlowCompleted: () => _handleCompletion(context),
        ),
      ),
    );
  }
}
