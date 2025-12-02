//* 1. IMPORT
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:luar_sekolah_lms/app/data/repositories/auth_repository_impl.dart';
import 'package:luar_sekolah_lms/app/data/datasources/auth_firebase_data_source.dart';

//* 2. MOCK CLASS DEFINITIONS
// Memalsukan Data Source agar tidak menghubungi Firebase asli
class MockAuthFirebaseDataSource extends Mock
    implements AuthFirebaseDataSource {}

class MockUserCredential extends Mock implements UserCredential {}

void main() {
  late AuthRepositoryImpl repository;
  late MockAuthFirebaseDataSource mockDataSource;

  //* 3. SETUP
  setUp(() {
    mockDataSource = MockAuthFirebaseDataSource();
    // Inject Mock ke Repository
    repository = AuthRepositoryImpl(mockDataSource);
  });

  group('AuthRepositoryImpl', () {
    const email = 'test@example.com';
    const password = 'password123';

    //* SKENARIO 1: HAPPY PATH (SUKSES)
    // Simulasikan DataSource mengembalikan UserCredential sukses, return data user
    test(
      'loginWithEmail should call dataSource.loginWithEmail and return UserCredential',
      () async {
        //? ARRANGE
        final mockUserCred = MockUserCredential();

        // Stubbing: DataSource sukses
        when(
          () => mockDataSource.loginWithEmail(email, password),
        ).thenAnswer((_) async => mockUserCred);

        //? ACT
        final result = await repository.loginWithEmail(email, password);

        //? ASSERT
        expect(result, equals(mockUserCred)); // Data harus sama
        verify(
          () => mockDataSource.loginWithEmail(email, password),
        ).called(1); // Fungsi dipanggil
      },
    );

    //* SKENARIO 2: NEGATIVE PATH (LOGIN GAGAL - Firebase Error)
    // Penting untuk memastikan Controller bisa menampilkan pesan error yang spesifik.
    // User salah password, Firebase mengembalikan error wrong-password
    test('should rethrow FirebaseAuthException when login fails', () async {
      //? ARRANGE
      // Simulasi DataSource melempar error Firebase (misal password salah)
      when(
        () => mockDataSource.loginWithEmail(email, password),
      ).thenThrow(FirebaseAuthException(code: 'wrong-password'));

      //? ACT & ASSERT
      // Kita pastikan Repository meneruskan error tersebut (Rethrow)
      expect(
        () => repository.loginWithEmail(email, password),
        throwsA(isA<FirebaseAuthException>()),
      );
    });

    //* SKENARIO 3: NEGATIVE PATH (GENERAL ERROR)
    // server down / jaringan mati / bug internal.
    test('should throw Exception when unknown error occurs', () async {
      //? ARRANGE
      when(() => mockDataSource.loginWithEmail(email, password)).thenThrow(
        Exception('Server Down'),
      ); // Simulasi error umum yang tidak spesifik

      //? ACT & ASSERT
      expect(
        () => repository.loginWithEmail(email, password),
        throwsA(isA<Exception>()), // Repository tetap melempar error tersebut
      );
    });

    //* SKENARIO 4: LOGOUT
    // User menekan tombol logout, seharusnya repository meneruskan ke datasource
    test('logout should call dataSource.logout', () async {
      //? ARRANGE
      when(() => mockDataSource.logout()).thenAnswer((_) async {});

      //? ACT
      await repository.logout();

      //? ASSERT
      verify(() => mockDataSource.logout()).called(1);
    });
  });
}
