import '../../data/repositories_dcl/event_repository.dart';
import '../../data/repositories_dcl/user_event_repository.dart';
import '../models/wellness_event.dart';

/// Encapsulates the "load wellness events for a specific user" business action.
///
/// The resolution strategy is:
///  1. Fetch the raw `user_events` records for [userId] from [UserEventRepository].
///  2. Extract the list of event IDs from those records.
///  3. Resolve each event ID to a [WellnessEvent] via [EventRepository], dropping
///     any IDs that no longer exist (null-safe).
///
/// Moving this multi-repository resolution out of the ViewModel ensures the UI
/// layer only deals with typed domain objects.
class LoadUserEventsUseCase {
  LoadUserEventsUseCase({
    UserEventRepository? userEventRepository,
    EventRepository? eventRepository,
  })  : _userEventRepository = userEventRepository ?? UserEventRepository(),
        _eventRepository = eventRepository ?? EventRepository();

  final UserEventRepository _userEventRepository;
  final EventRepository _eventRepository;

  /// Returns the resolved list of [WellnessEvent]s for [userId].
  Future<List<WellnessEvent>> call(String userId) async {
    final userEventMaps = await _userEventRepository.fetchUserEvents(userId);

    final eventIds = userEventMaps
        .map((m) => m['eventId'] as String?)
        .whereType<String>()
        .toList();

    final results = await Future.wait(
      eventIds.map((id) async {
        try {
          return await _eventRepository.fetchEventById(id);
        } catch (_) {
          return null;
        }
      }),
    );

    return results.whereType<WellnessEvent>().toList();
  }

  /// Returns a live stream of [WellnessEvent] lists for [userId].
  ///
  /// Each time the underlying `user_events` stream emits, the event IDs are
  /// resolved to full [WellnessEvent] objects via [EventRepository].
  Stream<List<WellnessEvent>> watch(String userId) {
    return _userEventRepository.watchUserEvents(userId).asyncMap(
      (maps) async {
        final eventIds = maps
            .map((m) => m['eventId'] as String?)
            .whereType<String>()
            .toList();

        final results = await Future.wait(
          eventIds.map((id) async {
            try {
              return await _eventRepository.fetchEventById(id);
            } catch (_) {
              return null;
            }
          }),
        );
        return results.whereType<WellnessEvent>().toList();
      },
    );
  }
}
