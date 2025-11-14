import 'package:firebase_auth/firebase_auth.dart';
import '../../repositories/i_auth_repository.dart';

class LoginUseCase {
  final IAuthRepository repository;
  LoginUseCase(this.repository);

  Future<UserCredential> call(String email, String password) {
    return repository.loginWithEmail(email, password);
  }
}
