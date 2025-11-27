import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Sesuaikan path import
import 'package:luar_sekolah_lms/app/domain/usecases/auth/login_use_case.dart';
import 'package:luar_sekolah_lms/app/domain/repositories/i_auth_repository.dart';

// --- MOCK CLASSES ---
class MockIAuthRepository extends Mock implements IAuthRepository {}

class MockUserCredential extends Mock implements UserCredential {}

void main() {
  late LoginUseCase useCase;
  late MockIAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockIAuthRepository();
    useCase = LoginUseCase(mockRepository);
  });

  group('LoginUseCase Tests', () {
    // --- SKENARIO 1: SUKSES (Happy Path) ---
    test('should trim inputs and call repository successfully', () async {
      // ARRANGE
      const rawEmail = '  test@example.com  ';
      const cleanEmail = 'test@example.com';
      const password = 'password123';

      // Stub: Sukses
      when(
        () => mockRepository.loginWithEmail(cleanEmail, password),
      ).thenAnswer((_) async => MockUserCredential());

      // ACT
      await useCase(rawEmail, password);

      // ASSERT
      // Pastikan repo dipanggil dengan email yang sudah di-TRIM
      verify(
        () => mockRepository.loginWithEmail(cleanEmail, password),
      ).called(1);
    });

    // --- SKENARIO 2: VALIDASI EMAIL KOSONG ---
    test('should throw Exception when email is empty', () async {
      expect(
        () => useCase('', 'password123'),
        throwsA(isA<AuthValidationException>()),
      );
      verifyZeroInteractions(mockRepository);
    });

    // --- SKENARIO 3: VALIDASI EMAIL TIDAK VALID (FORMAT) ---
    test('should throw Exception when email format is invalid', () async {
      expect(
        () => useCase('bukan-email', 'password123'),
        throwsA(isA<AuthValidationException>()),
      );
      verifyZeroInteractions(mockRepository);
    });

    // --- SKENARIO 4: VALIDASI PASSWORD KOSONG ---
    test('should throw Exception when password is empty', () async {
      expect(
        () => useCase('test@example.com', ''),
        throwsA(isA<AuthValidationException>()),
      );
      verifyZeroInteractions(mockRepository);
    });

    // --- SKENARIO 5: VALIDASI PASSWORD PENDEK ---
    test('should throw Exception when password is too short (<6)', () async {
      expect(
        () => useCase('test@example.com', '12345'),
        throwsA(isA<AuthValidationException>()),
      );
      verifyZeroInteractions(mockRepository);
    });

    // --- SKENARIO 6: REPOSITORY ERROR (Salah Password/User Not Found) ---
    test(
      'should rethrow FirebaseAuthException when repository fails',
      () async {
        // ARRANGE
        const email = 'test@example.com';
        const password = 'wrongpassword';

        when(
          () => mockRepository.loginWithEmail(email, password),
        ).thenThrow(FirebaseAuthException(code: 'wrong-password'));

        // ACT & ASSERT
        expect(
          () => useCase(email, password),
          throwsA(isA<FirebaseAuthException>()),
        );
      },
    );
  });
}
