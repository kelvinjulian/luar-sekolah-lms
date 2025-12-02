//* 1. IMPORT
// Mengimpor library testing, GetX, Mocktail, dan file-file asli project.
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mocktail/mocktail.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:luar_sekolah_lms/app/presentation/controllers/auth_controller.dart';
import 'package:luar_sekolah_lms/app/domain/repositories/i_auth_repository.dart';
import 'package:luar_sekolah_lms/app/domain/usecases/auth/login_use_case.dart';
import 'package:luar_sekolah_lms/app/domain/usecases/auth/register_use_case.dart';
import 'package:luar_sekolah_lms/app/domain/usecases/auth/logout_use_case.dart';

//* 2. MOCK CLASS DEFINITIONS
class MockIAuthRepository extends Mock implements IAuthRepository {}

class MockLoginUseCase extends Mock implements LoginUseCase {}

class MockRegisterUseCase extends Mock implements RegisterUseCase {}

class MockLogoutUseCase extends Mock implements LogoutUseCase {}

class MockUserCredential extends Mock implements UserCredential {}

void main() {
  late AuthController controller;
  late MockLoginUseCase mockLoginUseCase;
  late MockRegisterUseCase mockRegisterUseCase;
  late MockLogoutUseCase mockLogoutUseCase;
  late MockIAuthRepository mockAuthRepository;

  //* 3. SETUP
  setUp(() {
    // Inisialisasi Mock
    mockLoginUseCase = MockLoginUseCase();
    mockRegisterUseCase = MockRegisterUseCase();
    mockLogoutUseCase = MockLogoutUseCase();
    mockAuthRepository = MockIAuthRepository();

    //? Stubbing: Mengatur agar stream authStateChanges mengembalikan null (User Logged Out)
    when(
      () => mockAuthRepository.authStateChanges,
    ).thenAnswer((_) => Stream.value(null));

    //? Reset: Membersihkan state GetX sebelum setiap test
    Get.reset();

    // Inisialisasi Controller dengan Dependency Palsu (Mock)
    controller = AuthController(
      loginUseCase: mockLoginUseCase,
      registerUseCase: mockRegisterUseCase,
      logoutUseCase: mockLogoutUseCase,
      authRepository: mockAuthRepository,
    );
    controller.onInit(); // Jalankan onInit manual
  });

  group('AuthController Logic (Reactive State Pattern)', () {
    const email = 'test@example.com';
    const password = 'password123';

    //* SKENARIO: LOGIN SUKSES
    test(
      'login success: isLoading updates, errorMessage remains empty',
      () async {
        //? ARRANGE: Latih Mock agar mengembalikan sukses
        when(
          () => mockLoginUseCase(email, password),
        ).thenAnswer((_) async => MockUserCredential());

        //? ACT: Panggil fungsi login
        final future = controller.login(email, password);

        // Cek state loading AWAL (harus true saat proses berjalan)
        expect(controller.isLoading.value, isTrue); // Cek loading awal
        await future; // Tunggu proses selesai

        //? ASSERT: Cek state AKHIR
        expect(controller.isLoading.value, isFalse); // Loading harus mati
        expect(controller.errorMessage.value, isEmpty); // Tidak boleh ada error
      },
    );

    //* SKENARIO: LOGIN GAGAL
    test('login failure: updates errorMessage correctly', () async {
      //? ARRANGE: Latih Mock agar melempar error Firebase
      const errorMsg = 'User not found in database';
      when(() => mockLoginUseCase(email, password)).thenThrow(
        FirebaseAuthException(code: 'user-not-found', message: errorMsg),
      );

      //? ACT: Panggil fungsi login
      await controller.login(email, password);

      //? ASSERT: Verifikasi State
      expect(controller.isLoading.value, isFalse);

      // KUNCI TESTING: Kita mengecek variabel errorMessage, BUKAN Snackbar UI.
      // Ini membuktikan logika controller menangkap error dengan benar.
      expect(controller.errorMessage.value, errorMsg);
    });
  });
}
