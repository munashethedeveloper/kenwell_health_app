import 'package:firebase_performance/firebase_performance.dart';
import 'package:flutter/foundation.dart';

/// Thin wrapper around Firebase Performance Monitoring.
///
/// Provides a single `traceAsync` helper that:
///  1. Starts a named [Trace].
///  2. Awaits the supplied [action].
///  3. Stops the trace (even on failure) so the duration is always recorded.
///
/// In debug builds the helper still runs [action] but skips Firebase entirely
/// so that local development is never slowed by instrumentation.
///
/// ### Pre-defined trace names
/// Use the string constants below to keep names consistent across call sites.
///
/// ### Usage
/// ```dart
/// final member = await AppPerformance.traceAsync(
///   AppPerformance.kRegisterMember,
///   () => _registerUseCase(member, eventId: event.id),
/// );
/// ```
abstract final class AppPerformance {
  AppPerformance._();

  // ── Trace name constants ──────────────────────────────────────────────────

  /// Member registration (SQLite + Firestore member + Firestore member_events).
  static const String kRegisterMember = 'register_member';

  /// Consent form submission (Firestore consents + survey_results).
  static const String kSubmitConsent = 'submit_consent';

  /// Event creation via [AddEventUseCase] (SQLite + Firestore).
  static const String kAddEvent = 'add_event';

  /// Event update via [UpdateEventUseCase] (SQLite + Firestore).
  static const String kUpdateEvent = 'update_event';

  /// Event deletion via [DeleteEventUseCase] (SQLite + Firestore).
  static const String kDeleteEvent = 'delete_event';

  /// [PendingWriteService.flushPending] — offline write-queue replay.
  static const String kFlushPendingWrites = 'flush_pending_writes';

  /// Wellness completion-status load ([LoadWellnessCompletionStatusUseCase]).
  static const String kLoadWellnessStatus = 'load_wellness_status';

  // ── Core helper ───────────────────────────────────────────────────────────

  /// Runs [action] inside a Firebase Performance [Trace] named [traceName].
  ///
  /// Returns the result of [action].  The trace is always stopped, even if
  /// [action] throws, so the duration is always recorded.
  ///
  /// Optional [attributes] are key/value pairs added to the trace (max 5
  /// per trace, 40 chars each per Firebase limits).
  static Future<T> traceAsync<T>(
    String traceName,
    Future<T> Function() action, {
    Map<String, String>? attributes,
  }) async {
    // Skip Firebase instrumentation in debug builds to keep local development
    // snappy.  The action is always executed regardless.
    if (kDebugMode) {
      return action();
    }

    final trace = FirebasePerformance.instance.newTrace(traceName);

    if (attributes != null) {
      for (final entry in attributes.entries) {
        trace.putAttribute(entry.key, entry.value);
      }
    }

    await trace.start();
    try {
      return await action();
    } finally {
      await trace.stop();
    }
  }

  // ── Convenience: HTTP metric ───────────────────────────────────────────────

  /// Wraps an HTTP-style operation with a [HttpMetric].
  ///
  /// Use this for any direct REST/HTTP calls made outside the Firebase SDK
  /// (e.g., geocoding API).  Firebase's own Firestore/Auth SDK calls are
  /// auto-instrumented by the Performance Monitoring plugin.
  static Future<T> httpMetric<T>({
    required String url,
    required HttpMethod method,
    required Future<T> Function(HttpMetric metric) action,
  }) async {
    if (kDebugMode) {
      // Create a no-op metric so action() can call metric.responseCode etc.
      final metric = FirebasePerformance.instance.newHttpMetric(url, method);
      return action(metric);
    }

    final metric = FirebasePerformance.instance.newHttpMetric(url, method);
    await metric.start();
    try {
      return await action(metric);
    } finally {
      await metric.stop();
    }
  }
}
