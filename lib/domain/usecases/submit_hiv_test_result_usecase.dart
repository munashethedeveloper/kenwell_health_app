import '../../data/repositories_dcl/firestore_hiv_result_repository.dart';
import '../models/hiv_result.dart';

/// Encapsulates the "submit an HIV test result" business action.
///
/// ViewModels build the [HivResult] value object from form state, then call
/// this use case — keeping the ViewModel free of any direct repository
/// dependency.
class SubmitHIVTestResultUseCase {
  SubmitHIVTestResultUseCase({FirestoreHivResultRepository? repository})
      : _repository = repository ?? FirestoreHivResultRepository();

  final FirestoreHivResultRepository _repository;

  Future<void> call(HivResult result) => _repository.addHivResult(result);
}
