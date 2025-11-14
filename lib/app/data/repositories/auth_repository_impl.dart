import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/repositories/i_auth_repository.dart';
import '../datasources/auth_firebase_data_source.dart';

class AuthRepositoryImpl implements IAuthRepository {
  final AuthFirebaseDataSource dataSource;
  AuthRepositoryImpl(this.dataSource);

  @override
  Stream<User?> get authStateChanges => dataSource.authStateChanges;

  @override
  Future<UserCredential> registerWithEmail(String email, String password) {
    return dataSource.registerWithEmail(email, password);
  }

  @override
  Future<UserCredential> loginWithEmail(String email, String password) {
    return dataSource.loginWithEmail(email, password);
  }

  @override
  Future<void> logout() {
    return dataSource.logout();
  }
}
