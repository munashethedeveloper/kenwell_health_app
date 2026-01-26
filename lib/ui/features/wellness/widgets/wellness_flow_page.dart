import 'package:flutter/material.dart';
import '../../../../domain/models/wellness_event.dart';
import '../navigation/wellness_navigator.dart';

/// Entry point for the wellness event flow
/// Now uses proper screen-to-screen navigation instead of IndexedStack
class WellnessFlowPage extends StatefulWidget {
  final WellnessEvent event;
  final Future<void> Function()? onFlowCompleted;
  final Future<void> Function()? onExitEarly;

  const WellnessFlowPage({
    super.key,
    required this.event,
    this.onFlowCompleted,
    this.onExitEarly,
  });

  @override
  State<WellnessFlowPage> createState() => _WellnessFlowPageState();
}

class _WellnessFlowPageState extends State<WellnessFlowPage> {
  @override
  void initState() {
    super.initState();
    // Start the wellness flow after the widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) => _startFlow());
  }

  Future<void> _startFlow() async {
    if (!mounted) return;

    final navigator = WellnessNavigator(
      context: context,
      event: widget.event,
    );

    await navigator.startFlow();

    // Flow completed or exited
    if (mounted) {
      if (widget.onFlowCompleted != null) {
        await widget.onFlowCompleted!();
      }
      if (mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show a simple loading screen while navigation initializes
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(
              color: Color(0xFF90C048),
            ),
            const SizedBox(height: 24),
            Text(
              'Starting ${widget.event.title}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF201C58),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
