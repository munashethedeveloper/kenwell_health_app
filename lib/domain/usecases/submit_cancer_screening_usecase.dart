import '../../data/repositories_dcl/firestore_cancer_screening_repository.dart';
import '../models/cander_screening.dart';

/// Encapsulates the "submit a cancer screening" business action.
///
/// ViewModels build the [CancerScreening] value object from form state, then
/// call this use case — keeping the ViewModel free of any direct repository
/// dependency.
class SubmitCancerScreeningUseCase {
  SubmitCancerScreeningUseCase({
    FirestoreCancerScreeningRepository? repository,
  }) : _repository =
            repository ?? FirestoreCancerScreeningRepository();

  final FirestoreCancerScreeningRepository _repository;

  Future<void> call(CancerScreening screening) =>
      _repository.addCancerScreening(screening);
}
