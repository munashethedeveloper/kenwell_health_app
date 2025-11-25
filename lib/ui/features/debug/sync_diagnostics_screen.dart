import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../background/sync_worker.dart';
import '../../../data/local/app_database.dart';
import '../../../data/repositories_dcl/event_repository.dart';
import '../../../data/services/event_sync_service.dart';
import '../../../domain/models/wellness_event.dart';
import '../../auth/view_models/auth_view_model.dart';

class SyncDiagnosticsScreen extends StatefulWidget {
  const SyncDiagnosticsScreen({super.key});

  @override
  State<SyncDiagnosticsScreen> createState() => _SyncDiagnosticsScreenState();
}

class _SyncDiagnosticsScreenState extends State<SyncDiagnosticsScreen> {
  Future<List<EventEntry>>? _pendingFuture;
  bool _backgroundEnabled = true;

  @override
  void initState() {
    super.initState();
    final syncService = context.read<EventSyncService>();
    syncService.refreshPendingCount();
    _backgroundEnabled = context.read<AuthViewModel>().isLoggedIn;
    _reloadPending();
  }

  void _reloadPending() {
    final repository = context.read<EventRepository>();
    setState(() {
      _pendingFuture = repository.listPendingEntries();
    });
  }

  Future<void> _triggerSync() async {
    final syncService = context.read<EventSyncService>();
    await syncService.syncNow();
    _reloadPending();
  }

  Future<void> _refreshPendingCount() async {
    final syncService = context.read<EventSyncService>();
    await syncService.refreshPendingCount();
    _reloadPending();
  }

  Future<void> _toggleBackgroundSync(bool value) async {
    setState(() => _backgroundEnabled = value);
    if (value) {
      await scheduleBackgroundSyncTask();
    } else {
      await cancelBackgroundSyncTask();
    }
  }

  Future<void> _copyPendingAsJson() async {
    final repository = context.read<EventRepository>();
    final entries = await repository.listPendingEntries();
    final payload = entries
        .map((entry) => jsonDecode(entry.payload) as Map<String, dynamic>)
        .toList();
    final prettyJson = const JsonEncoder.withIndent('  ').convert(payload);
    await Clipboard.setData(ClipboardData(text: prettyJson));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Copied ${entries.length} event(s) to clipboard.'),
        ),
      );
    }
  }

  void _showEventDetails(EventEntry entry) {
    final event = WellnessEvent.fromJson(
      jsonDecode(entry.payload) as Map<String, dynamic>,
    );
    showModalBottomSheet<void>(
      context: context,
      builder: (_) => Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                event.title,
                style: Theme.of(context).textTheme.headlineSmall,
              ],
              const SizedBox(height: 8),
              Text('Event ID: ${event.id}'),
              Text('Date: ${event.date.toLocal()}'),
              Text('Sync status: ${entry.syncStatus}'),
              Text('Last updated: ${entry.updatedAt.toLocal()}'),
              Text(
                'Remote updated: ${entry.remoteUpdatedAt?.toLocal().toString() ?? '—'}',
              ),
              const Divider(height: 24),
              Text(const JsonEncoder.withIndent('  ')
                  .convert(jsonDecode(entry.payload))),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _markAsSynced(EventEntry entry) async {
    final repository = context.read<EventRepository>();
    await repository.markEventSynced(entry.id, DateTime.now());
    await _refreshPendingCount();
    _showSnack('Marked ${entry.id} as synced');
  }

  Future<void> _markAsPending(EventEntry entry) async {
    final repository = context.read<EventRepository>();
    await repository.updateSyncStatus(entry.id, 'pending');
    await _refreshPendingCount();
    _showSnack('Re-queued ${entry.id}');
  }

  Future<void> _deleteEvent(EventEntry entry) async {
    final repository = context.read<EventRepository>();
    await repository.deleteEvent(entry.id);
    await _refreshPendingCount();
    _showSnack('Deleted ${entry.id}');
  }

  void _showSnack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final syncService = context.watch<EventSyncService>();
    final authViewModel = context.watch<AuthViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sync Diagnostics'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      authViewModel.isLoggedIn
                          ? 'User: ${FirebaseAuth.instance.currentUser?.email ?? 'Unknown'}'
                          : 'User: Not logged in',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    ValueListenableBuilder<DateTime?>(
                      valueListenable: syncService.lastSyncTimeListenable,
                      builder: (_, value, __) {
                        final formatted = value == null
                            ? 'Never'
                            : '${value.toLocal()}';
                        return Text('Last sync: $formatted');
                      },
                    ),
                    ValueListenableBuilder<int>(
                      valueListenable: syncService.pendingCountListenable,
                      builder: (_, value, __) =>
                          Text('Pending events: $value'),
                    ),
                    ValueListenableBuilder<bool>(
                      valueListenable: syncService.isSyncingListenable,
                      builder: (_, value, __) =>
                          Text('Syncing: ${value ? "Yes" : "No"}'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                ElevatedButton.icon(
                  onPressed: syncService.isSyncing ? null : _triggerSync,
                  icon: const Icon(Icons.sync),
                  label: const Text('Sync Now'),
                ),
                OutlinedButton.icon(
                  onPressed: _refreshPendingCount,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Refresh Pending'),
                ),
                OutlinedButton.icon(
                  onPressed: _copyPendingAsJson,
                  icon: const Icon(Icons.copy),
                  label: const Text('Copy pending JSON'),
                ),
              ],
            ),
            SwitchListTile(
              value: _backgroundEnabled,
              onChanged: _toggleBackgroundSync,
              title: const Text('Background sync enabled'),
              subtitle: const Text('Requires app to have run at least once'),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: FutureBuilder<List<EventEntry>>(
                future: _pendingFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final pending = snapshot.data ?? [];
                  if (pending.isEmpty) {
                    return const Center(child: Text('No pending events'));
                  }
                  return RefreshIndicator(
                    onRefresh: () async {
                      final repository = context.read<EventRepository>();
                      final data = await repository.listPendingEntries();
                      setState(() {
                        _pendingFuture = Future.value(data);
                      });
                    },
                    child: ListView.builder(
                      itemCount: pending.length,
                      itemBuilder: (context, index) {
                        final entry = pending[index];
                        final event = WellnessEvent.fromJson(
                          jsonDecode(entry.payload) as Map<String, dynamic>,
                        );
                        return ListTile(
                          leading: const Icon(Icons.event_note),
                          title: Text(event.title),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Date: ${event.date.toLocal()}',
                              ),
                              Text(
                                'Status: ${entry.syncStatus} | Updated ${entry.updatedAt.toLocal()}',
                              ),
                            ],
                          ),
                          trailing: PopupMenuButton<String>(
                            onSelected: (value) {
                              switch (value) {
                                case 'view':
                                  _showEventDetails(entry);
                                  break;
                                case 'forceSync':
                                  _markAsSynced(entry);
                                  break;
                                case 'pending':
                                  _markAsPending(entry);
                                  break;
                                case 'delete':
                                  _deleteEvent(entry);
                                  break;
                              }
                            },
                            itemBuilder: (_) => const [
                              PopupMenuItem(
                                value: 'view',
                                child: ListTile(
                                  leading: Icon(Icons.visibility),
                                  title: Text('View details'),
                                ),
                              ),
                              PopupMenuItem(
                                value: 'forceSync',
                                child: ListTile(
                                  leading: Icon(Icons.check_circle),
                                  title: Text('Mark as synced'),
                                ),
                              ),
                              PopupMenuItem(
                                value: 'pending',
                                child: ListTile(
                                  leading: Icon(Icons.replay),
                                  title: Text('Mark pending'),
                                ),
                              ),
                              PopupMenuItem(
                                value: 'delete',
                                child: ListTile(
                                  leading: Icon(Icons.delete),
                                  title: Text('Delete locally'),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
