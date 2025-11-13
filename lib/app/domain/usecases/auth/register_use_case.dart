import 'package:firebase_auth/firebase_auth.dart';
import '../../repositories/i_auth_repository.dart';

class RegisterUseCase {
  final IAuthRepository repository;
  RegisterUseCase(this.repository);

  Future<UserCredential> call(String email, String password) {
    return repository.registerWithEmail(email, password);
  }
}
