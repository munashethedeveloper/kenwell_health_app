import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../../domain/models/wellness_event.dart';
import '../repositories_dcl/event_repository.dart';

class EventSyncService {
  EventSyncService({
    required EventRepository eventRepository,
    required FirebaseFirestore firestore,
    required FirebaseAuth auth,
  })  : _eventRepository = eventRepository,
        _firestore = firestore,
        _auth = auth;

  final EventRepository _eventRepository;
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  Timer? _timer;
  bool _isSyncing = false;
  final ValueNotifier<DateTime?> _lastSyncTime = ValueNotifier<DateTime?>(null);
  final ValueNotifier<int> _pendingCount = ValueNotifier<int>(0);
  final ValueNotifier<bool> _syncing = ValueNotifier<bool>(false);

  ValueListenable<DateTime?> get lastSyncTimeListenable => _lastSyncTime;
  ValueListenable<int> get pendingCountListenable => _pendingCount;
  ValueListenable<bool> get isSyncingListenable => _syncing;
  bool get isSyncing => _isSyncing;

  void start({Duration interval = const Duration(minutes: 5)}) {
    _timer ??= Timer.periodic(interval, (_) => syncNow());
    unawaited(refreshPendingCount());
    unawaited(syncNow());
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
  }

  Future<void> syncNow() async {
    if (_isSyncing) return;
    final user = _auth.currentUser;
    if (user == null) return;

    _isSyncing = true;
    _syncing.value = true;
    try {
      final eventsCollection = _userEventsCollection(user.uid);
      await _pushPending(eventsCollection);
      await _pullRemote(eventsCollection);
      _lastSyncTime.value = DateTime.now();
      await refreshPendingCount();
    } catch (error, stackTrace) {
      debugPrint('EventSyncService error: $error');
      debugPrintStack(stackTrace: stackTrace);
    } finally {
      _isSyncing = false;
      _syncing.value = false;
    }
  }

  Future<void> refreshPendingCount() async {
    final pendingEntries = await _eventRepository.listPendingEntries();
    _pendingCount.value = pendingEntries.length;
  }

  CollectionReference<Map<String, dynamic>> _userEventsCollection(
      String uid) {
    return _firestore.collection('users').doc(uid).collection('events');
  }

  Future<void> _pushPending(
    CollectionReference<Map<String, dynamic>> collection,
  ) async {
    final pendingEntries = await _eventRepository.listPendingEntries();

    for (final entry in pendingEntries) {
      final event =
          WellnessEvent.fromJson(jsonDecode(entry.payload) as Map<String, dynamic>);
      final docRef = collection.doc(event.id);
      await docRef.set({
        ...event.toJson(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      final snapshot = await docRef.get();
      final remoteUpdatedAt = _remoteTimestamp(snapshot);
      if (remoteUpdatedAt != null) {
        await _eventRepository.markEventSynced(event.id, remoteUpdatedAt);
      }
    }

    await refreshPendingCount();
  }

  Future<void> _pullRemote(
    CollectionReference<Map<String, dynamic>> collection,
  ) async {
    final snapshot = await collection.get();
    for (final doc in snapshot.docs) {
      final data = doc.data();
      final remoteUpdatedAt = _remoteTimestamp(doc);
      final localEntry = await _eventRepository.getEventEntry(doc.id);
      final localRemote = localEntry?.remoteUpdatedAt;

      if (remoteUpdatedAt == null) {
        continue;
      }

      final shouldUpdate = localEntry == null ||
          localRemote == null ||
          remoteUpdatedAt.isAfter(localRemote);

      if (shouldUpdate) {
        final remoteEvent = WellnessEvent.fromJson(data);
        await _eventRepository.upsertRemoteEvent(remoteEvent, remoteUpdatedAt);
      }
    }
  }

  DateTime? _remoteTimestamp(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    final raw = snapshot.data()?['updatedAt'];
    if (raw is Timestamp) {
      return raw.toDate();
    }
    if (raw is DateTime) {
      return raw;
    }
    if (raw is String) {
      return DateTime.tryParse(raw);
    }
    return snapshot.updateTime?.toDate();
  }
}
