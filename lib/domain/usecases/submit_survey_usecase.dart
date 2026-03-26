import '../../data/repositories_dcl/firestore_survey_repository.dart';

/// Encapsulates the "save a post-event survey result" business action.
///
/// ViewModels build the survey data map from form state, then call this use
/// case — keeping the ViewModel free of any direct repository dependency.
class SubmitSurveyUseCase {
  SubmitSurveyUseCase({FirestoreSurveyRepository? repository})
      : _repository = repository ?? const FirestoreSurveyRepository();

  final FirestoreSurveyRepository _repository;

  /// Persists the survey result identified by [id] with the given [data].
  Future<void> call({required String id, required Map<String, dynamic> data}) =>
      _repository.saveSurveyResult(id: id, data: data);
}
