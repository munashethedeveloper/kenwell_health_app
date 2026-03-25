import '../models/wellness_event.dart';
import '../../data/repositories_dcl/event_repository.dart';

/// Encapsulates the "create a new event" business action.
class AddEventUseCase {
  AddEventUseCase({EventRepository? repository})
      : _repository = repository ?? EventRepository();

  final EventRepository _repository;

  Future<void> call(WellnessEvent event) => _repository.addEvent(event);
}
