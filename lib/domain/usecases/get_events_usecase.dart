import '../models/wellness_event.dart';
import '../../data/repositories_dcl/event_repository.dart';

/// Encapsulates the "fetch all events" business action.
///
/// ViewModels call this use case instead of the repository directly,
/// preserving a clean separation between the domain and data layers.
class GetEventsUseCase {
  GetEventsUseCase({EventRepository? repository})
      : _repository = repository ?? EventRepository();

  final EventRepository _repository;

  Future<List<WellnessEvent>> call() => _repository.fetchAllEvents();

  Stream<List<WellnessEvent>> watch() => _repository.watchAllEvents();
}
