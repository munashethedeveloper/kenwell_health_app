import 'package:flutter/foundation.dart';
import "../../../../data/repositories_dcl/auth_repository_dcl.dart";
import '../../../../domain/models/user_model.dart';

class LoginViewModel extends ChangeNotifier {
  final AuthRepository _repository;
  bool isLoading = false;

  LoginViewModel(this._repository);

  Future<UserModel?> login(String email, String password) async {
    isLoading = true;
    notifyListeners();
    final user = await _repository.login(email, password);
    isLoading = false;
    notifyListeners();
    return user; // returns UserModel? instead of bool
  }
}
