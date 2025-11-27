import 'package:firebase_auth/firebase_auth.dart';
import '../../repositories/i_auth_repository.dart';

// Gunakan Exception yang sama dengan Todo jika sudah dibuat di folder core/exceptions
// bisa kita buat di sini atau import dari file lain
class AuthValidationException implements Exception {
  final String message;
  AuthValidationException(this.message);
}

class LoginUseCase {
  final IAuthRepository repository;

  LoginUseCase(this.repository);

  Future<UserCredential> call(String email, String password) {
    // 1. Bersihkan Input
    final cleanEmail = email.trim();
    final cleanPassword = password.trim();

    // 2. Validasi Kosong
    if (cleanEmail.isEmpty) {
      throw AuthValidationException("Email tidak boleh kosong");
    }
    if (cleanPassword.isEmpty) {
      throw AuthValidationException("Password tidak boleh kosong");
    }

    // 3. Validasi Format Email (Regex Sederhana)
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(cleanEmail)) {
      throw AuthValidationException("Format email tidak valid");
    }

    // 4. Validasi Password Pendek (Firebase minimal 6 char)
    if (cleanPassword.length < 6) {
      throw AuthValidationException("Password minimal 6 karakter");
    }

    // 5. Panggil Repo
    return repository.loginWithEmail(cleanEmail, cleanPassword);
  }
}
