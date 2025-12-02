//* 1. IMPORT
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:luar_sekolah_lms/app/domain/usecases/auth/login_use_case.dart';
import 'package:luar_sekolah_lms/app/domain/repositories/i_auth_repository.dart';

//* 2. MOCK CLASS DEFINITIONS
class MockIAuthRepository extends Mock implements IAuthRepository {}

class MockUserCredential extends Mock implements UserCredential {}

void main() {
  late LoginUseCase useCase;
  late MockIAuthRepository mockRepository;

  //* 3. SETUP
  setUp(() {
    mockRepository = MockIAuthRepository();
    useCase = LoginUseCase(mockRepository);
  });

  group('LoginUseCase Tests', () {
    //* SKENARIO 1: SUKSES (Happy Path)
    // Password dummy harus memenuhi SEMUA syarat: 8 char, 1 Kapital, 1 Simbol
    test('should trim inputs and call repository successfully', () async {
      //? ARRANGE
      const rawEmail = '  test@example.com  ';
      const cleanEmail = 'test@example.com';
      const password =
          'Password@123'; // <-- Valid (Ada P besar, ada @, panjang > 8)

      // Stub: Repository sukses
      when(
        () => mockRepository.loginWithEmail(cleanEmail, password),
      ).thenAnswer((_) async => MockUserCredential());

      //? ACT
      await useCase(rawEmail, password);

      // ASSERT
      verify(
        () => mockRepository.loginWithEmail(cleanEmail, password),
      ).called(1); // perbaiki
    });

    // --- SKENARIO VALIDASI EXISTING ---

    test('should throw Exception when email is empty', () async {
      expect(
        () => useCase('', 'Password@123'),
        throwsA(isA<AuthValidationException>()),
      );
    });

    test('should throw Exception when email format is invalid', () async {
      expect(
        () => useCase('bukan-email', 'Password@123'),
        throwsA(isA<AuthValidationException>()),
      );
    });

    // --- SKENARIO VALIDASI PASSWORD ---
    test('should throw Exception when password is empty', () async {
      expect(
        () => useCase('test@example.com', ''),
        throwsA(isA<AuthValidationException>()),
      );
    });

    // Validasi Panjang (< 8)
    test('should throw Exception when password is too short (<8)', () async {
      expect(
        // 'Pass@12' cuma 7 karakter
        () => useCase('test@example.com', 'Pass@12'),
        throwsA(isA<AuthValidationException>()),
      );
    });

    // Validasi Kapital (Tidak ada huruf besar)
    test('should throw Exception when password has no uppercase', () async {
      expect(
        // 'password@123' valid panjang & simbol, tapi huruf kecil semua
        () => useCase('test@example.com', 'password@123'),
        throwsA(isA<AuthValidationException>()),
      );
    });

    // Validasi Simbol (Tidak ada karakter spesial)
    test('should throw Exception when password has no symbol', () async {
      expect(
        // 'Password123' valid panjang & kapital, tapi tidak ada simbol
        () => useCase('test@example.com', 'Password123'),
        throwsA(isA<AuthValidationException>()),
      );
    });

    // --- SKENARIO REPOSITORY ERROR ---
    test('should rethrow FirebaseAuthException when repository fails', () async {
      // ARRANGE
      const email = 'test@example.com';
      const password =
          'Password@123'; // Password valid secara format, tapi salah di server

      when(
        () => mockRepository.loginWithEmail(email, password),
      ).thenThrow(FirebaseAuthException(code: 'wrong-password'));

      // ACT & ASSERT
      expect(
        () => useCase(email, password),
        throwsA(isA<FirebaseAuthException>()),
      );
    });
  });
}
