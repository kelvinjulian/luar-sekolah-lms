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

  //TODO bagian yang diminta ka zahid untuk diperbaiki, karena sebelumnya belum cek rawEmail apakah benar benar menjadi cleanEmail, bukan hanya verify panggilan saja
  group('LoginUseCase Tests', () {
    //* SKENARIO 1: SUKSES (Happy Path)
    // Password dummy harus memenuhi SEMUA syarat: 8 char, 1 Kapital, 1 Simbol
    // Skenario ini memastikan input di-trim dan diteruskan ke repository dengan benar
    test('should trim the rawEmail into cleanEmail correctly', () async {
      // ARRANGE — menyiapkan dependency & input
      final repo = MockIAuthRepository();
      // Membuat mock repository yang akan menangkap parameter yang dikirim usecase

      final usecase = LoginUseCase(repo);
      // Inject mock ke dalam usecase agar pemanggilan login diarahkan ke mock, bukan server

      final rawEmail = "   test@gmail.com   ";
      // Email mengandung spasi di depan dan belakang untuk menguji proses trimming

      final rawPassword = "   Abcd1234!   ";
      // Password valid + diberi spasi supaya trimming password juga ikut teruji
      // (meski test ini fokus di email, trimming password tetap terjadi dalam usecase)

      // Stub/mock behavior:
      // Ketika loginWithEmail dipanggil dengan nilai apa pun, balikan nilai dummy.
      when(
        () => repo.loginWithEmail(any(), any()),
      ).thenAnswer((_) async => MockUserCredential());
      // Tujuan: bukan mengetes repository, hanya memvalidasi parameter yang dikirim ke repo.

      // ACT — eksekusi usecase dengan email & password yang masih kotor (belum trimmed)
      await usecase(rawEmail, rawPassword);

      // ASSERT — memeriksa apakah email yang dikirim ke repository sudah di-trim
      final captured =
          verify(() => repo.loginWithEmail(captureAny(), any())).captured.first
              as String;
      // captureAny() menangkap argument pertama (email)
      // .captured.first memberikan nilai email yang dikirimkan oleh usecase

      expect(captured, equals("test@gmail.com"));
      // Memastikan hasil email yang dikirim repository sudah bersih tanpa spasi
    });

    // --- SKENARIO VALIDASI TRIMMED KOSONG ---
    test('should throw error when trimmed email is empty', () async {
      // ARRANGE
      const rawEmail = '   '; // hanya spasi → setelah trim() = ''

      // ACT + ASSERT
      expect(
        () => useCase(rawEmail, 'Password@123'),
        throwsA(isA<Exception>()), // atau sesuai error yang kamu lempar
      );

      // Repository tidak boleh dipanggil
      verifyNever(() => mockRepository.loginWithEmail(any(), any()));
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
