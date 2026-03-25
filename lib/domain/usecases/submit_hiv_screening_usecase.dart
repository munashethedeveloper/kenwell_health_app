import '../../data/repositories_dcl/firestore_hiv_screening_repository.dart';
import '../models/hiv_screening.dart';

/// Encapsulates the "submit an HIV screening" business action.
///
/// ViewModels build the [HivScreening] value object from form state, then
/// call this use case — keeping the ViewModel free of any direct repository
/// dependency.
class SubmitHIVScreeningUseCase {
  SubmitHIVScreeningUseCase({
    FirestoreHivScreeningRepository? repository,
  }) : _repository = repository ?? FirestoreHivScreeningRepository();

  final FirestoreHivScreeningRepository _repository;

  Future<void> call(HivScreening screening) =>
      _repository.addHivScreening(screening);
}
