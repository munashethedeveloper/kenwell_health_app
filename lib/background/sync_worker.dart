import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:workmanager/workmanager.dart';

import '../data/local/app_database.dart';
import '../data/repositories_dcl/event_repository.dart';
import '../data/services/event_sync_service.dart';
import '../firebase_options.dart';

const String backgroundSyncTaskName = 'kenwell_event_sync_task';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    final db = AppDatabase();
    final repository = EventRepository(db);
    final syncService = EventSyncService(
      eventRepository: repository,
      firestore: FirebaseFirestore.instance,
      auth: FirebaseAuth.instance,
    );
    await syncService.syncNow();
    await db.close();
    return true;
  });
}

Future<void> scheduleBackgroundSyncTask() {
  if (!_backgroundSyncSupported()) {
    return Future.value();
  }
  return Workmanager().registerPeriodicTask(
    backgroundSyncTaskName,
    backgroundSyncTaskName,
    frequency: const Duration(minutes: 15),
    existingWorkPolicy: ExistingWorkPolicy.keep,
    constraints: const Constraints(
      networkType: NetworkType.connected,
    ),
    initialDelay: const Duration(minutes: 1),
    backoffPolicy: BackoffPolicy.linear,
    backoffPolicyDelay: const Duration(minutes: 5),
  );
}

Future<void> cancelBackgroundSyncTask() =>
    _backgroundSyncSupported()
        ? Workmanager().cancelByUniqueName(backgroundSyncTaskName)
        : Future.value();

bool _backgroundSyncSupported() {
  if (kIsWeb) return false;
  return defaultTargetPlatform == TargetPlatform.android;
}
