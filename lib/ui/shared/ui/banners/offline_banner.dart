import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../data/services/connectivity_service.dart';

/// An animated banner that slides in from the top whenever the device loses
/// network connectivity, and slides back out when connectivity is restored.
///
/// Usage — place **above the content** inside any scrollable body `Column`:
///
/// ```dart
/// Column(
///   children: [
///     const OfflineBanner(),
///     Expanded(child: ...),
///   ],
/// )
/// ```
///
/// Requires a [ConnectivityService] to be available in the widget tree.
class OfflineBanner extends StatelessWidget {
  const OfflineBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final isOnline = context.watch<ConnectivityService>().isOnline;

    return AnimatedCrossFade(
      duration: const Duration(milliseconds: 350),
      crossFadeState:
          isOnline ? CrossFadeState.showSecond : CrossFadeState.showFirst,
      firstChild: _OfflineTile(),
      secondChild: const SizedBox.shrink(),
    );
  }
}

class _OfflineTile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Colors.orange.shade800,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          const Icon(Icons.cloud_off_rounded, color: Colors.white, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'You are offline',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
                Text(
                  'Showing cached data. Changes will sync when reconnected.',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: Colors.orangeAccent,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 4),
                const Text(
                  'OFFLINE',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
