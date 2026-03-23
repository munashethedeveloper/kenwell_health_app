import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kenwell_health_app/data/local/screening_local_store.dart';
import 'package:kenwell_health_app/domain/models/consent.dart';
import 'package:kenwell_health_app/data/services/firestore_service.dart';
import 'package:kenwell_health_app/utils/logger.dart';

class FirestoreConsentRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ScreeningLocalStore _local = ScreeningLocalStore.instance;
  static const String _collectionName = FirestoreService.consentsCollection;

  /// Add a new consent
  Future<void> addConsent(Consent consent) async {
    try {
      await _firestore
          .collection(_collectionName)
          .doc(consent.id)
          .set(consent.toMap());
      // Write-through: persist to local SQLite store so data is available offline.
      unawaited(_local.upsertConsent(consent.toMap()));
      AppLogger.info('Consent added successfully: ${consent.id}');
    } catch (e) {
      AppLogger.error('Failed to add consent', e);
      rethrow;
    }
  }

  /// Get consent by ID
  Future<Consent?> getConsent(String id) async {
    try {
      final doc = await _firestore.collection(_collectionName).doc(id).get();
      if (!doc.exists) {
        return null;
      }
      final consent = Consent.fromMap(doc.data()!);
      unawaited(_local.upsertConsent(doc.data()!));
      return consent;
    } catch (e) {
      // Offline fallback 1: Firestore on-device cache.
      try {
        final cached = await _firestore
            .collection(_collectionName)
            .doc(id)
            .get(const GetOptions(source: Source.cache));
        if (cached.exists) return Consent.fromMap(cached.data()!);
      } catch (_) {}
      // Offline fallback 2: local SQLite store.
      try {
        final row = await _local.getConsentById(id);
        if (row != null) return Consent.fromMap(row);
      } catch (_) {}
      AppLogger.error('Failed to get consent', e);
      rethrow;
    }
  }

  /// Update consent
  Future<void> updateConsent(Consent consent) async {
    try {
      final updatedConsent = consent.copyWith(updatedAt: DateTime.now());
      await _firestore
          .collection(_collectionName)
          .doc(consent.id)
          .update(updatedConsent.toMap());
      AppLogger.info('Consent updated successfully: ${consent.id}');
    } catch (e) {
      AppLogger.error('Failed to update consent', e);
      rethrow;
    }
  }

  /// Delete consent
  Future<void> deleteConsent(String id) async {
    try {
      await _firestore.collection(_collectionName).doc(id).delete();
      AppLogger.info('Consent deleted successfully: $id');
    } catch (e) {
      AppLogger.error('Failed to delete consent', e);
      rethrow;
    }
  }

  /// Get all consents for a specific member
  Future<List<Consent>> getConsentsByMember(String memberId) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collectionName)
          .where('memberId', isEqualTo: memberId)
          .get();

      final consents = querySnapshot.docs
          .map((doc) => Consent.fromMap(doc.data()))
          .toList();
      // Write-through cache.
      for (final doc in querySnapshot.docs) {
        unawaited(_local.upsertConsent(doc.data()));
      }
      return consents;
    } catch (e) {
      // Offline fallback 1: Firestore on-device cache.
      try {
        final cached = await _firestore
            .collection(_collectionName)
            .where('memberId', isEqualTo: memberId)
            .get(const GetOptions(source: Source.cache));
        if (cached.docs.isNotEmpty) {
          return cached.docs
              .map((doc) => Consent.fromMap(doc.data()))
              .toList();
        }
      } catch (_) {}
      // Offline fallback 2: local SQLite store.
      try {
        final rows = await _local.getConsentsByMember(memberId);
        if (rows.isNotEmpty) {
          return rows.map((r) => Consent.fromMap(r)).toList();
        }
      } catch (_) {}
      AppLogger.error('Failed to get consents by member', e);
      rethrow;
    }
  }

  /// Get all consents for a specific event
  Future<List<Consent>> getConsentsByEvent(String eventId) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collectionName)
          .where('eventId', isEqualTo: eventId)
          .orderBy('createdAt', descending: true)
          .get();

      final consents = querySnapshot.docs
          .map((doc) => Consent.fromMap(doc.data()))
          .toList();
      // Write-through cache.
      for (final doc in querySnapshot.docs) {
        unawaited(_local.upsertConsent(doc.data()));
      }
      return consents;
    } catch (e) {
      // Offline fallback 1: Firestore on-device cache.
      try {
        final cached = await _firestore
            .collection(_collectionName)
            .where('eventId', isEqualTo: eventId)
            .get(const GetOptions(source: Source.cache));
        if (cached.docs.isNotEmpty) {
          return cached.docs
              .map((doc) => Consent.fromMap(doc.data()))
              .toList();
        }
      } catch (_) {}
      // Offline fallback 2: local SQLite store.
      try {
        final rows = await _local.getConsentsByEvent(eventId);
        if (rows.isNotEmpty) {
          return rows.map((r) => Consent.fromMap(r)).toList();
        }
      } catch (_) {}
      AppLogger.error('Failed to get consents by event', e);
      rethrow;
    }
  }

  /// Watch all consents (real-time stream)
  Stream<List<Consent>> watchAllConsents() {
    return _firestore
        .collection(_collectionName)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Consent.fromMap(doc.data())).toList());
  }

  /// Watch consents for a specific member (real-time stream)
  Stream<List<Consent>> watchConsentsByMember(String memberId) {
    return _firestore
        .collection(_collectionName)
        .where('memberId', isEqualTo: memberId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Consent.fromMap(doc.data())).toList());
  }

  /// Watch consents for a specific event (real-time stream)
  Stream<List<Consent>> watchConsentsByEvent(String eventId) {
    return _firestore
        .collection(_collectionName)
        .where('eventId', isEqualTo: eventId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Consent.fromMap(doc.data())).toList());
  }
}
