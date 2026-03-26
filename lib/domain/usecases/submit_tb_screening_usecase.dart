import '../../data/repositories_dcl/firestore_tb_screening_repository.dart';
import '../models/tb_screening.dart';

/// Encapsulates the "submit a TB screening" business action.
///
/// ViewModels build the [TbScreening] value object from form state, then
/// call this use case — keeping the ViewModel free of any direct repository
/// dependency.
class SubmitTBScreeningUseCase {
  SubmitTBScreeningUseCase({
    FirestoreTbScreeningRepository? repository,
  }) : _repository = repository ?? FirestoreTbScreeningRepository();

  final FirestoreTbScreeningRepository _repository;

  Future<void> call(TbScreening screening) =>
      _repository.addTbScreening(screening);
}
