import '../../data/repositories_dcl/firestore_hct_result_repository.dart';
import '../models/hct_result.dart';

/// Encapsulates the "submit an HCT test result" business action.
///
/// ViewModels build the [HctResult] value object from form state, then call
/// this use case — keeping the ViewModel free of any direct repository
/// dependency.
class SubmitHCTTestResultUseCase {
  SubmitHCTTestResultUseCase({FirestoreHctResultRepository? repository})
      : _repository = repository ?? FirestoreHctResultRepository();

  final FirestoreHctResultRepository _repository;

  Future<void> call(HctResult result) => _repository.addHctResult(result);
}
