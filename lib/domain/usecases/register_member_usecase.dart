import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:kenwell_health_app/data/local/app_database.dart';
import 'package:kenwell_health_app/data/repositories_dcl/firestore_member_event_repository.dart';
import 'package:kenwell_health_app/data/repositories_dcl/firestore_member_repository.dart';
import 'package:kenwell_health_app/data/repositories_dcl/member_repository.dart';
import 'package:kenwell_health_app/data/services/app_performance.dart';
import 'package:kenwell_health_app/data/services/pending_write_service.dart';
import 'package:kenwell_health_app/domain/models/member.dart';
import 'package:kenwell_health_app/domain/models/member_event.dart';

/// Use case that persists a new [Member] across all three storage layers:
///
///  1. **Local SQLite** (via [MemberRepository]) — always attempted; failure
///     is fatal so the wellness flow cannot proceed without a local record.
///  2. **Firestore members** (via [FirestoreMemberRepository]) — non-fatal;
///     if the device is offline the local record keeps the flow alive and
///     Firestore sync is retried later.  Permanent failures are queued via
///     [PendingWriteService] for automatic retry on reconnection.
///  3. **Firestore member_events** (via [FirestoreMemberEventRepository]) —
///     non-fatal; links the member to the current wellness event.  Same
///     retry strategy as above.
///
/// Separating this orchestration from the ViewModel keeps [MemberDetailsViewModel]
/// responsible only for form state, while this class owns the persistence strategy.
class RegisterMemberUseCase {
  RegisterMemberUseCase({
    MemberRepository? memberRepository,
    FirestoreMemberRepository? firestoreMemberRepository,
    FirestoreMemberEventRepository? memberEventRepository,
    PendingWriteService? pendingWriteService,
  })  : _memberRepository =
            memberRepository ?? MemberRepository(AppDatabase.instance),
        _firestoreRepo =
            firestoreMemberRepository ?? FirestoreMemberRepository(),
        _memberEventRepo =
            memberEventRepository ?? FirestoreMemberEventRepository(),
        _pendingWrites = pendingWriteService ?? PendingWriteService.instance;

  final MemberRepository _memberRepository;
  final FirestoreMemberRepository _firestoreRepo;
  final FirestoreMemberEventRepository _memberEventRepo;
  final PendingWriteService _pendingWrites;

  /// Registers [member] and returns the saved instance (with its generated
  /// local `id` populated).
  ///
  /// Optional event parameters are used to create the linking
  /// [MemberEvent] record.  Pass them whenever the registration occurs inside
  /// a wellness flow session.
  Future<Member> call(
    Member member, {
    String? eventId,
    String? eventTitle,
    DateTime? eventDate,
    String? eventVenue,
    String? eventLocation,
  }) async {
    return AppPerformance.traceAsync(
      AppPerformance.kRegisterMember,
      () => _execute(
        member,
        eventId: eventId,
        eventTitle: eventTitle,
        eventDate: eventDate,
        eventVenue: eventVenue,
        eventLocation: eventLocation,
      ),
    );
  }

  Future<Member> _execute(
    Member member, {
    String? eventId,
    String? eventTitle,
    DateTime? eventDate,
    String? eventVenue,
    String? eventLocation,
  }) async {
    // 1. Persist to local SQLite — fatal if this fails.
    final savedMember = await _memberRepository.createMember(member);
    debugPrint(
        'RegisterMemberUseCase: saved to local DB (id=${savedMember.id})');

    // 2. Sync to Firestore members — non-fatal.
    // Use the original `member` (not `savedMember`) so that `eventId` is
    // preserved — the local DB schema has no eventId column, meaning
    // savedMember.eventId is always null after the local round-trip.
    try {
      await _firestoreRepo.addMember(member);
    } catch (e) {
      debugPrint(
          'RegisterMemberUseCase: Firestore member sync failed (non-fatal): $e');
      // Queue for retry when connectivity is restored.
      await _pendingWrites.enqueue(
        collection: FirestoreMemberRepository.membersCollection,
        docId: member.id,
        data: member.toMap(),
      );
    }

    // 3. Create member_events link record — non-fatal.
    if (eventId != null && eventId.isNotEmpty) {
      try {
        final memberEvent = MemberEvent(
          memberId: savedMember.id,
          eventId: eventId,
          eventTitle: eventTitle ?? 'Unknown Event',
          eventDate: eventDate != null ? Timestamp.fromDate(eventDate) : null,
          eventVenue: eventVenue,
          eventLocation: eventLocation,
        );
        await _memberEventRepo.addMemberEvent(memberEvent);
        debugPrint(
            'RegisterMemberUseCase: member_events record created for ${savedMember.id} / $eventId');
      } catch (e) {
        debugPrint(
            'RegisterMemberUseCase: member_events record failed (non-fatal): $e');
        // Queue the link record for retry.
        await _pendingWrites.enqueue(
          collection: FirestoreMemberEventRepository.memberEventsCollection,
          docId: '${savedMember.id}_$eventId',
          data: MemberEvent(
            memberId: savedMember.id,
            eventId: eventId,
            eventTitle: eventTitle ?? 'Unknown Event',
            eventDate: eventDate != null ? Timestamp.fromDate(eventDate) : null,
            eventVenue: eventVenue,
            eventLocation: eventLocation,
          ).toMap(),
        );
      }
    }

    return savedMember;
  }
}
