import 'package:firebase_auth/firebase_auth.dart'; // Kita boleh pakai ini di domain

//? GetX tahu bahwa IAuthRepository diimplementasikan oleh AuthRepositoryImpl (karena di-binding).
abstract class IAuthRepository {
  Stream<User?> get authStateChanges;
  Future<UserCredential> registerWithEmail(String email, String password);
  Future<UserCredential> loginWithEmail(String email, String password);
  Future<void> logout();
}
