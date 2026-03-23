import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kenwell_health_app/data/local/screening_local_store.dart';
import 'package:kenwell_health_app/domain/models/hiv_result.dart';
import 'package:kenwell_health_app/data/services/firestore_service.dart';
import 'package:kenwell_health_app/utils/logger.dart';

class FirestoreHivResultRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ScreeningLocalStore _local = ScreeningLocalStore.instance;
  static const String _collectionName = FirestoreService.hivResultsCollection;

  Future<void> addHivResult(HivResult result) async {
    try {
      await _firestore
          .collection(_collectionName)
          .doc(result.id)
          .set(result.toMap());
      // Write-through: persist to local SQLite store so data is available offline.
      unawaited(_local.upsertHivResult(result.toMap()));
      AppLogger.info('HIV result added successfully: ${result.id}');
    } catch (e) {
      AppLogger.error('Failed to add HIV result', e);
      rethrow;
    }
  }

  Future<HivResult?> getHivResult(String id) async {
    try {
      final doc = await _firestore.collection(_collectionName).doc(id).get();
      if (!doc.exists) return null;
      final result = HivResult.fromMap(doc.data()!);
      unawaited(_local.upsertHivResult(doc.data()!));
      return result;
    } catch (e) {
      // Offline fallback 1: Firestore on-device cache.
      try {
        final cached = await _firestore
            .collection(_collectionName)
            .doc(id)
            .get(const GetOptions(source: Source.cache));
        if (cached.exists) return HivResult.fromMap(cached.data()!);
      } catch (_) {}
      // Offline fallback 2: local SQLite store.
      try {
        final row = await _local.getHivResultById(id);
        if (row != null) return HivResult.fromMap(row);
      } catch (_) {}
      AppLogger.error('Failed to get HIV result', e);
      rethrow;
    }
  }

  Future<List<HivResult>> getHivResultsByMember(String memberId) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collectionName)
          .where('memberId', isEqualTo: memberId)
          .orderBy('createdAt', descending: true)
          .get();

      final results = querySnapshot.docs
          .map((doc) => HivResult.fromMap(doc.data()))
          .toList();
      for (final doc in querySnapshot.docs) {
        unawaited(_local.upsertHivResult(doc.data()));
      }
      return results;
    } catch (e) {
      // Offline fallback 1: Firestore on-device cache.
      try {
        final cached = await _firestore
            .collection(_collectionName)
            .where('memberId', isEqualTo: memberId)
            .get(const GetOptions(source: Source.cache));
        if (cached.docs.isNotEmpty) {
          return cached.docs
              .map((doc) => HivResult.fromMap(doc.data()))
              .toList();
        }
      } catch (_) {}
      // Offline fallback 2: local SQLite store.
      try {
        final rows = await _local.getHivResultsByMember(memberId);
        if (rows.isNotEmpty) {
          return rows.map((r) => HivResult.fromMap(r)).toList();
        }
      } catch (_) {}
      AppLogger.error('Failed to get HIV results by member', e);
      rethrow;
    }
  }

  Future<List<HivResult>> getHivResultsByEvent(String eventId) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collectionName)
          .where('eventId', isEqualTo: eventId)
          .orderBy('createdAt', descending: true)
          .get();

      final results = querySnapshot.docs
          .map((doc) => HivResult.fromMap(doc.data()))
          .toList();
      for (final doc in querySnapshot.docs) {
        unawaited(_local.upsertHivResult(doc.data()));
      }
      return results;
    } catch (e) {
      // Offline fallback 1: Firestore on-device cache.
      try {
        final cached = await _firestore
            .collection(_collectionName)
            .where('eventId', isEqualTo: eventId)
            .get(const GetOptions(source: Source.cache));
        if (cached.docs.isNotEmpty) {
          return cached.docs
              .map((doc) => HivResult.fromMap(doc.data()))
              .toList();
        }
      } catch (_) {}
      // Offline fallback 2: local SQLite store.
      try {
        final rows = await _local.getHivResultsByEvent(eventId);
        if (rows.isNotEmpty) {
          return rows.map((r) => HivResult.fromMap(r)).toList();
        }
      } catch (_) {}
      AppLogger.error('Failed to get HIV results by event', e);
      rethrow;
    }
  }
}
