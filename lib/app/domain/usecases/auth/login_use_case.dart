import 'package:firebase_auth/firebase_auth.dart';
import '../../repositories/i_auth_repository.dart';

class AuthValidationException implements Exception {
  final String message;
  AuthValidationException(this.message);
}

class LoginUseCase {
  final IAuthRepository repository;

  LoginUseCase(this.repository);

  Future<UserCredential> call(String email, String password) {
    final cleanEmail = email.trim();
    final cleanPassword = password.trim();

    // Validasi Email
    if (cleanEmail.isEmpty)
      throw AuthValidationException("Email tidak boleh kosong");
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(cleanEmail)) {
      throw AuthValidationException("Format email tidak valid");
    }

    // --- VALIDASI PASSWORD BARU ---

    // 1. Cek Kosong
    if (cleanPassword.isEmpty) {
      throw AuthValidationException("Password tidak boleh kosong");
    }

    // 2. Cek Minimal 8 Karakter
    if (cleanPassword.length < 8) {
      throw AuthValidationException("Password minimal 8 karakter");
    }

    // 3. Cek Minimal 1 Huruf Kapital (A-Z)
    if (!cleanPassword.contains(RegExp(r'[A-Z]'))) {
      throw AuthValidationException("Password harus mengandung huruf kapital");
    }

    // 4. Cek Minimal 1 Simbol (Karakter Spesial)
    if (!cleanPassword.contains(RegExp(r'[!@#\$%^&*(),.?":{}|<>]'))) {
      throw AuthValidationException("Password harus mengandung simbol");
    }

    return repository.loginWithEmail(cleanEmail, cleanPassword);
  }
}
