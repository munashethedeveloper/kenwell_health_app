import '../../data/repositories_dcl/firestore_hra_repository.dart';
import '../models/hra_screening.dart';

/// Encapsulates the "submit a Health Risk Assessment (HRA) screening" business
/// action.
///
/// ViewModels build the [HraScreening] value object from form state, then
/// call this use case — keeping the ViewModel free of any direct repository
/// dependency.
class SubmitHRAUseCase {
  SubmitHRAUseCase({FirestoreHraRepository? repository})
      : _repository = repository ?? FirestoreHraRepository();

  final FirestoreHraRepository _repository;

  Future<void> call(HraScreening screening) =>
      _repository.addHraScreening(screening);
}
