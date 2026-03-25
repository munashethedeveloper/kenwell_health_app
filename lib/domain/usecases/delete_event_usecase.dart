import '../../data/repositories_dcl/event_repository.dart';

/// Encapsulates the "delete an event" business action.
class DeleteEventUseCase {
  DeleteEventUseCase({EventRepository? repository})
      : _repository = repository ?? EventRepository();

  final EventRepository _repository;

  Future<void> call(String eventId) => _repository.deleteEvent(eventId);
}
