import '../models/wellness_event.dart';
import '../../data/repositories_dcl/event_repository.dart';

/// Encapsulates the "update an existing event" business action.
class UpdateEventUseCase {
  UpdateEventUseCase({EventRepository? repository})
      : _repository = repository ?? EventRepository();

  final EventRepository _repository;

  Future<void> call(WellnessEvent event) => _repository.updateEvent(event);
}
