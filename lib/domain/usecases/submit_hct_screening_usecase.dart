import '../../data/repositories_dcl/firestore_hct_screening_repository.dart';
import '../models/hct_screening.dart';

/// Encapsulates the "submit an HCT screening" business action.
///
/// ViewModels build the [HctScreening] value object from form state, then
/// call this use case — keeping the ViewModel free of any direct repository
/// dependency.
class SubmitHCTScreeningUseCase {
  SubmitHCTScreeningUseCase({
    FirestoreHctScreeningRepository? repository,
  }) : _repository = repository ?? FirestoreHctScreeningRepository();

  final FirestoreHctScreeningRepository _repository;

  Future<void> call(HctScreening screening) =>
      _repository.addHctScreening(screening);
}
