import 'package:firebase_auth/firebase_auth.dart';
import '../../repositories/i_auth_repository.dart';

// UseCase untuk registrasi user baru
class RegisterUseCase {
  final IAuthRepository repository;

  RegisterUseCase(this.repository);

  // Fungsi panggilan utama untuk registrasi
  Future<UserCredential> call(String email, String password) {
    return repository.registerWithEmail(email, password);
  }
}
