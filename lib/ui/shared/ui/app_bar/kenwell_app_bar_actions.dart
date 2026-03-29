import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../snackbars/app_snackbar.dart';
import 'package:kenwell_health_app/routing/app_routes.dart';

/// Standard app bar actions widget used across all main screens.
///
/// Renders a [Refresh] `IconButton` and a [Help] `TextButton.icon` in a
/// consistent order.  Pass [onRefresh] to handle the refresh tap; if null,
/// no refresh button is shown.
///
/// Usage:
/// ```dart
/// KenwellAppBar(
///   title: 'KenWell365',
///   actions: KenwellAppBarActions(
///     onRefresh: () => vm.loadEvents(),
///     refreshSuccessMessage: 'Events refreshed',
///   ).build(context),
/// )
/// ```
class KenwellAppBarActions {
  const KenwellAppBarActions({
    this.onRefresh,
    this.refreshSuccessMessage = 'Refreshed',
  });

  /// Called when the user taps the refresh button.  If null, no refresh
  /// button is rendered.
  final Future<void> Function()? onRefresh;

  /// Snackbar message shown after a successful refresh.
  final String refreshSuccessMessage;

  /// Returns the [List<Widget>] suitable for [AppBar.actions].
  List<Widget> build(BuildContext context) {
    return [
      if (onRefresh != null)
        IconButton(
          tooltip: 'Refresh',
          icon: const Icon(Icons.refresh, color: Colors.white),
          onPressed: () async {
            await onRefresh!();
            if (context.mounted) {
              AppSnackbar.showSuccess(
                context,
                refreshSuccessMessage,
                duration: const Duration(seconds: 1),
              );
            }
          },
        ),
      TextButton.icon(
        onPressed: () => context.pushNamed(AppRoutes.help),
        icon: const Icon(Icons.help_outline, color: Colors.white),
        label: const Text('Help', style: TextStyle(color: Colors.white)),
      ),
    ];
  }
}
