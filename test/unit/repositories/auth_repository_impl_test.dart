import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:luar_sekolah_lms/app/data/repositories/auth_repository_impl.dart';
import 'package:luar_sekolah_lms/app/data/datasources/auth_firebase_data_source.dart';

// Asumsi Anda punya file exception custom (jika belum, pakai Exception biasa dulu)
// import 'package:luar_sekolah_lms/app/core/error/exceptions.dart';

class MockAuthFirebaseDataSource extends Mock
    implements AuthFirebaseDataSource {}

class MockUserCredential extends Mock implements UserCredential {}

void main() {
  late AuthRepositoryImpl repository;
  late MockAuthFirebaseDataSource mockDataSource;

  setUp(() {
    mockDataSource = MockAuthFirebaseDataSource();
    repository = AuthRepositoryImpl(mockDataSource);
  });

  group('AuthRepositoryImpl', () {
    const email = 'test@example.com';
    const password = 'password123';

    // --- 1. HAPPY PATH (SUKSES) ---
    test(
      'loginWithEmail should call dataSource.loginWithEmail and return UserCredential',
      () async {
        // ARRANGE
        final mockUserCred = MockUserCredential();
        when(
          () => mockDataSource.loginWithEmail(email, password),
        ).thenAnswer((_) async => mockUserCred);

        // ACT
        final result = await repository.loginWithEmail(email, password);

        // ASSERT
        expect(result, equals(mockUserCred));
        verify(() => mockDataSource.loginWithEmail(email, password)).called(1);
      },
    );

    // --- 2. NEGATIVE PATH (LOGIN GAGAL - Firebase Error) ---
    test('should rethrow FirebaseAuthException when login fails', () async {
      // ARRANGE
      // Simulasi DataSource melempar error Firebase (misal password salah)
      when(
        () => mockDataSource.loginWithEmail(email, password),
      ).thenThrow(FirebaseAuthException(code: 'wrong-password'));

      // ACT & ASSERT
      // Kita pastikan Repository meneruskan error tersebut
      expect(
        () => repository.loginWithEmail(email, password),
        throwsA(isA<FirebaseAuthException>()),
      );
    });

    // --- 3. NEGATIVE PATH (GENERAL ERROR) ---
    test('should throw Exception when unknown error occurs', () async {
      // ARRANGE
      when(
        () => mockDataSource.loginWithEmail(email, password),
      ).thenThrow(Exception('Server Down'));

      // ACT & ASSERT
      expect(
        () => repository.loginWithEmail(email, password),
        throwsA(isA<Exception>()),
      );
    });

    // --- 4. LOGOUT ---
    test('logout should call dataSource.logout', () async {
      when(() => mockDataSource.logout()).thenAnswer((_) async {});

      await repository.logout();

      verify(() => mockDataSource.logout()).called(1);
    });
  });
}
