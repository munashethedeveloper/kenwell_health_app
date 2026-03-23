import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';

import 'app_database.dart';

/// A write-through local cache for all screening records and related data.
///
/// Uses the existing [AppDatabase] (Drift / SQLite) via raw `customStatement`
/// and `customSelect` queries so that **no code-generation step is required**.
///
/// Seven tables are created by [AppDatabase.migration] (schema version 15):
///   - `cached_consents`
///   - `cached_member_events`
///   - `cached_hiv_screenings`
///   - `cached_hiv_results`
///   - `cached_hra_screenings`
///   - `cached_tb_screenings`
///   - `cached_cancer_screenings`
///
/// Each table stores a serialised JSON blob alongside indexed `member_id` and
/// `event_id` columns so that the most common look-ups (by member, by event)
/// can be answered without deserialising every row.
class ScreeningLocalStore {
  ScreeningLocalStore._internal();
  static final ScreeningLocalStore instance = ScreeningLocalStore._internal();

  final AppDatabase _db = AppDatabase.instance;

  // ── JSON sanitisation ──────────────────────────────────────────────────────

  /// Recursively converts non-JSON-serialisable values (e.g. Firestore
  /// [Timestamp]) to JSON-safe equivalents so that [jsonEncode] never throws.
  ///
  /// - [Timestamp] → `{'_t':'ts','ms':<epochMs>}`
  /// - [DateTime]  → `{'_t':'dt','ms':<epochMs>}`
  /// - Nested [Map] → recursively sanitised
  /// - [List]      → each element sanitised
  static dynamic _sanitize(dynamic value) {
    if (value is Timestamp) {
      return {'_t': 'ts', 'ms': value.millisecondsSinceEpoch};
    }
    if (value is DateTime) {
      return {'_t': 'dt', 'ms': value.millisecondsSinceEpoch};
    }
    if (value is Map) {
      return value
          .map((k, v) => MapEntry(k as String, _sanitize(v)));
    }
    if (value is List) {
      return value.map(_sanitize).toList();
    }
    return value;
  }

  // ── Generic helpers ────────────────────────────────────────────────────────

  Future<void> _upsert(
    String table,
    String id,
    String memberId,
    String eventId,
    Map<String, dynamic> data,
  ) async {
    try {
      final json = jsonEncode(_sanitize(data));
      final now = DateTime.now().millisecondsSinceEpoch;
      await _db.customStatement(
        'INSERT OR REPLACE INTO $table (id, member_id, event_id, data, cached_at)'
        ' VALUES (?, ?, ?, ?, ?)',
        [id, memberId, eventId, json, now],
      );
    } catch (e) {
      debugPrint('ScreeningLocalStore._upsert[$table]: $e');
    }
  }

  Future<Map<String, dynamic>?> _getById(
      String table, String id) async {
    try {
      final rows = await _db
          .customSelect(
            'SELECT data FROM $table WHERE id = ? LIMIT 1',
            variables: [Variable.withString(id)],
          )
          .get();
      if (rows.isEmpty) return null;
      return jsonDecode(rows.first.read<String>('data'))
          as Map<String, dynamic>;
    } catch (e) {
      debugPrint('ScreeningLocalStore._getById[$table]: $e');
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> _getByMember(
      String table, String memberId) async {
    try {
      final rows = await _db
          .customSelect(
            'SELECT data FROM $table WHERE member_id = ?',
            variables: [Variable.withString(memberId)],
          )
          .get();
      return rows
          .map((r) =>
              jsonDecode(r.read<String>('data')) as Map<String, dynamic>)
          .toList();
    } catch (e) {
      debugPrint('ScreeningLocalStore._getByMember[$table]: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> _getByEvent(
      String table, String eventId) async {
    try {
      final rows = await _db
          .customSelect(
            'SELECT data FROM $table WHERE event_id = ?',
            variables: [Variable.withString(eventId)],
          )
          .get();
      return rows
          .map((r) =>
              jsonDecode(r.read<String>('data')) as Map<String, dynamic>)
          .toList();
    } catch (e) {
      debugPrint('ScreeningLocalStore._getByEvent[$table]: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> _getByEvents(
      String table, List<String> eventIds) async {
    if (eventIds.isEmpty) return [];
    try {
      // SQLite supports up to 999 host parameters. The Firestore chunk size is
      // 30 so in practice this will always be well under the limit.
      final placeholders = eventIds.map((_) => '?').join(', ');
      final rows = await _db
          .customSelect(
            'SELECT data FROM $table WHERE event_id IN ($placeholders)',
            variables:
                eventIds.map((id) => Variable.withString(id)).toList(),
          )
          .get();
      return rows
          .map((r) =>
              jsonDecode(r.read<String>('data')) as Map<String, dynamic>)
          .toList();
    } catch (e) {
      debugPrint('ScreeningLocalStore._getByEvents[$table]: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> _getAll(String table) async {
    try {
      final rows = await _db
          .customSelect('SELECT data FROM $table')
          .get();
      return rows
          .map((r) =>
              jsonDecode(r.read<String>('data')) as Map<String, dynamic>)
          .toList();
    } catch (e) {
      debugPrint('ScreeningLocalStore._getAll[$table]: $e');
      return [];
    }
  }

  // ── Consents ───────────────────────────────────────────────────────────────

  Future<void> upsertConsent(Map<String, dynamic> data) =>
      _upsert('cached_consents', data['id'] as String,
          data['memberId'] as String? ?? '', data['eventId'] as String? ?? '', data);

  Future<Map<String, dynamic>?> getConsentById(String id) =>
      _getById('cached_consents', id);

  Future<List<Map<String, dynamic>>> getConsentsByMember(String memberId) =>
      _getByMember('cached_consents', memberId);

  Future<List<Map<String, dynamic>>> getConsentsByEvent(String eventId) =>
      _getByEvent('cached_consents', eventId);

  // ── Member Events ──────────────────────────────────────────────────────────

  Future<void> upsertMemberEvent(Map<String, dynamic> data) =>
      _upsert('cached_member_events', data['id'] as String? ?? '',
          data['memberId'] as String? ?? '', data['eventId'] as String? ?? '', data);

  Future<Map<String, dynamic>?> getMemberEventById(String id) =>
      _getById('cached_member_events', id);

  Future<List<Map<String, dynamic>>> getMemberEventsByMember(
          String memberId) =>
      _getByMember('cached_member_events', memberId);

  Future<List<Map<String, dynamic>>> getMemberEventsByEvent(String eventId) =>
      _getByEvent('cached_member_events', eventId);

  // ── HIV Screenings ─────────────────────────────────────────────────────────

  Future<void> upsertHivScreening(Map<String, dynamic> data) =>
      _upsert('cached_hiv_screenings', data['id'] as String,
          data['memberId'] as String? ?? '', data['eventId'] as String? ?? '', data);

  Future<Map<String, dynamic>?> getHivScreeningById(String id) =>
      _getById('cached_hiv_screenings', id);

  Future<List<Map<String, dynamic>>> getHivScreeningsByMember(
          String memberId) =>
      _getByMember('cached_hiv_screenings', memberId);

  Future<List<Map<String, dynamic>>> getHivScreeningsByEvent(String eventId) =>
      _getByEvent('cached_hiv_screenings', eventId);

  Future<List<Map<String, dynamic>>> getHivScreeningsByEvents(
          List<String> eventIds) =>
      _getByEvents('cached_hiv_screenings', eventIds);

  Future<List<Map<String, dynamic>>> getAllHivScreenings() =>
      _getAll('cached_hiv_screenings');

  // ── HIV Results ────────────────────────────────────────────────────────────

  Future<void> upsertHivResult(Map<String, dynamic> data) =>
      _upsert('cached_hiv_results', data['id'] as String,
          data['memberId'] as String? ?? '', data['eventId'] as String? ?? '', data);

  Future<Map<String, dynamic>?> getHivResultById(String id) =>
      _getById('cached_hiv_results', id);

  Future<List<Map<String, dynamic>>> getHivResultsByMember(String memberId) =>
      _getByMember('cached_hiv_results', memberId);

  Future<List<Map<String, dynamic>>> getHivResultsByEvent(String eventId) =>
      _getByEvent('cached_hiv_results', eventId);

  // ── HRA Screenings ─────────────────────────────────────────────────────────

  Future<void> upsertHraScreening(Map<String, dynamic> data) =>
      _upsert('cached_hra_screenings', data['id'] as String,
          data['memberId'] as String? ?? '', data['eventId'] as String? ?? '', data);

  Future<Map<String, dynamic>?> getHraScreeningById(String id) =>
      _getById('cached_hra_screenings', id);

  Future<List<Map<String, dynamic>>> getHraScreeningsByMember(
          String memberId) =>
      _getByMember('cached_hra_screenings', memberId);

  Future<List<Map<String, dynamic>>> getHraScreeningsByEvent(String eventId) =>
      _getByEvent('cached_hra_screenings', eventId);

  Future<List<Map<String, dynamic>>> getHraScreeningsByEvents(
          List<String> eventIds) =>
      _getByEvents('cached_hra_screenings', eventIds);

  Future<List<Map<String, dynamic>>> getAllHraScreenings() =>
      _getAll('cached_hra_screenings');

  // ── TB Screenings ──────────────────────────────────────────────────────────

  Future<void> upsertTbScreening(Map<String, dynamic> data) =>
      _upsert('cached_tb_screenings', data['id'] as String,
          data['memberId'] as String? ?? '', data['eventId'] as String? ?? '', data);

  Future<Map<String, dynamic>?> getTbScreeningById(String id) =>
      _getById('cached_tb_screenings', id);

  Future<List<Map<String, dynamic>>> getTbScreeningsByMember(
          String memberId) =>
      _getByMember('cached_tb_screenings', memberId);

  Future<List<Map<String, dynamic>>> getTbScreeningsByEvent(String eventId) =>
      _getByEvent('cached_tb_screenings', eventId);

  Future<List<Map<String, dynamic>>> getTbScreeningsByEvents(
          List<String> eventIds) =>
      _getByEvents('cached_tb_screenings', eventIds);

  Future<List<Map<String, dynamic>>> getAllTbScreenings() =>
      _getAll('cached_tb_screenings');

  // ── Cancer Screenings ──────────────────────────────────────────────────────

  Future<void> upsertCancerScreening(Map<String, dynamic> data) =>
      _upsert('cached_cancer_screenings', data['id'] as String,
          data['memberId'] as String? ?? '', data['eventId'] as String? ?? '', data);

  Future<Map<String, dynamic>?> getCancerScreeningById(String id) =>
      _getById('cached_cancer_screenings', id);

  Future<List<Map<String, dynamic>>> getCancerScreeningsByMember(
          String memberId) =>
      _getByMember('cached_cancer_screenings', memberId);

  Future<List<Map<String, dynamic>>> getCancerScreeningsByEvent(
          String eventId) =>
      _getByEvent('cached_cancer_screenings', eventId);

  Future<List<Map<String, dynamic>>> getCancerScreeningsByEvents(
          List<String> eventIds) =>
      _getByEvents('cached_cancer_screenings', eventIds);

  Future<List<Map<String, dynamic>>> getAllCancerScreenings() =>
      _getAll('cached_cancer_screenings');
}
