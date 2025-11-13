import 'package:firebase_auth/firebase_auth.dart'; // Kita boleh pakai ini di domain

abstract class IAuthRepository {
  Stream<User?> get authStateChanges;
  Future<UserCredential> registerWithEmail(String email, String password);
  Future<UserCredential> loginWithEmail(String email, String password);
  Future<void> logout();
}
