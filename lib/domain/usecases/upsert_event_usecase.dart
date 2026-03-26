import '../models/wellness_event.dart';
import '../../data/repositories_dcl/event_repository.dart';

/// Encapsulates the "upsert (restore) an event" business action.
class UpsertEventUseCase {
  UpsertEventUseCase({EventRepository? repository})
      : _repository = repository ?? EventRepository();

  final EventRepository _repository;

  Future<void> call(WellnessEvent event) => _repository.upsertEvent(event);
}
