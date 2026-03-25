import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

import 'pending_write_service.dart';

/// Service that continuously monitors device network connectivity.
///
/// Consumers can read [isOnline] for an instant snapshot, or `await`
/// [onConnectivityChanged] for a live stream of connectivity results.
///
/// When the device regains connectivity, any writes that were queued via
/// [PendingWriteService] while offline are automatically flushed.
///
/// ```dart
/// // In a widget tree:
/// if (context.watch<ConnectivityService>().isOnline) { ... }
///
/// // As a stream:
/// connectivityService.onConnectivityChanged.listen((online) { ... });
/// ```
class ConnectivityService extends ChangeNotifier {
  ConnectivityService({PendingWriteService? pendingWriteService})
      : _pendingWrites = pendingWriteService ?? PendingWriteService.instance {
    _init();
  }

  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _subscription;
  final PendingWriteService _pendingWrites;

  bool _isOnline = true; // Optimistic default until first check.

  /// Whether the device currently has network access.
  bool get isOnline => _isOnline;

  /// Stream that emits `true` when a network connection is gained and `false`
  /// when it is lost.
  final StreamController<bool> _statusController =
      StreamController<bool>.broadcast();

  Stream<bool> get onConnectivityChanged => _statusController.stream;

  Future<void> _init() async {
    // Check the initial state.
    try {
      final results = await _connectivity.checkConnectivity();
      _updateStatus(results);
    } catch (e) {
      debugPrint('ConnectivityService: initial check failed – $e');
    }

    // Subscribe to changes.
    _subscription = _connectivity.onConnectivityChanged.listen(_updateStatus);
  }

  void _updateStatus(List<ConnectivityResult> results) {
    final online = results.any((r) => r != ConnectivityResult.none);
    if (online == _isOnline) return; // No change.
    _isOnline = online;
    _statusController.add(_isOnline);
    notifyListeners();
    debugPrint(
        'ConnectivityService: network is ${_isOnline ? "ONLINE" : "OFFLINE"}');

    // When connectivity is restored, retry any writes that failed while offline.
    if (_isOnline) {
      _pendingWrites.flushPending().catchError(
            (e) => debugPrint('ConnectivityService: flush failed – $e'),
          );
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _statusController.close();
    super.dispose();
  }
}
