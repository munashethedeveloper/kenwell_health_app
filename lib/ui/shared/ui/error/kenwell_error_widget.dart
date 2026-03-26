import 'package:flutter/material.dart';
import 'package:kenwell_health_app/ui/shared/ui/colours/kenwell_colours.dart';

/// Branded error widget shown when a widget subtree throws an unhandled
/// exception during [build].  Replaces Flutter's default red error screen in
/// both debug and release builds so users see a friendly branded message
/// instead of a raw stack trace.
///
/// ### Registration
/// Call [KenwellErrorWidget.register] once in [main] — before [runApp] — to
/// override [ErrorWidget.builder] globally:
///
/// ```dart
/// KenwellErrorWidget.register();
/// runApp(const MyApp());
/// ```
class KenwellErrorWidget extends StatelessWidget {
  const KenwellErrorWidget({
    super.key,
    required this.details,
  });

  final FlutterErrorDetails details;

  /// Registers this widget as the global [ErrorWidget.builder].
  static void register() {
    ErrorWidget.builder = (FlutterErrorDetails details) {
      return KenwellErrorWidget(details: details);
    };
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: KenwellColors.primaryGreen.withAlpha(26),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.warning_amber_rounded,
                  color: KenwellColors.primaryGreen,
                  size: 40,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Something went wrong',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: KenwellColors.secondaryNavy,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'An unexpected error has occurred.\n'
                'Please restart the app. If the problem\n'
                'persists, contact your system administrator.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
