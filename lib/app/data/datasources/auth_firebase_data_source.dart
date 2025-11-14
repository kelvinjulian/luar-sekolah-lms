import 'package:firebase_auth/firebase_auth.dart';

class AuthFirebaseDataSource {
  final _auth = FirebaseAuth.instance;

  // Stream<User?> get authStateChanges => _auth.authStateChanges();
  Stream<User?> get authStateChanges {
    print("🔥 Auth stream initialized");
    return _auth.authStateChanges();
  }

  Future<UserCredential> registerWithEmail(String email, String password) {
    return _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<UserCredential> loginWithEmail(String email, String password) {
    return _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<void> logout() {
    return _auth.signOut();
  }
}
