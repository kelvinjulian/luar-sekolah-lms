import 'package:firebase_auth/firebase_auth.dart';

class AuthFirebaseDataSource {
  final _auth = FirebaseAuth.instance;

  // Stream<User?> get authStateChanges => _auth.authStateChanges();
  // untuk mendeteksi perubahan status autentikasi user secara real-time.
  Stream<User?> get authStateChanges {
    // print("" Auth stream initialized");
    return _auth.authStateChanges();
  }

  // Fungsi untuk registrasi user baru dengan email dan password
  Future<UserCredential> registerWithEmail(String email, String password) {
    return _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  // Fungsi untuk login user dengan email dan password
  Future<UserCredential> loginWithEmail(String email, String password) {
    return _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  // Fungsi untuk logout user
  Future<void> logout() {
    return _auth.signOut();
  }
}
