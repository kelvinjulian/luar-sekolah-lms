// test/unit/controllers/auth_controller_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mocktail/mocktail.dart';
import 'package:firebase_auth/firebase_auth.dart';
// Sesuaikan import path
import 'package:luar_sekolah_lms/app/presentation/controllers/auth_controller.dart';
import 'package:luar_sekolah_lms/app/domain/repositories/i_auth_repository.dart';
import 'package:luar_sekolah_lms/app/domain/usecases/auth/login_use_case.dart';
import 'package:luar_sekolah_lms/app/domain/usecases/auth/register_use_case.dart';
import 'package:luar_sekolah_lms/app/domain/usecases/auth/logout_use_case.dart';

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

  setUp(() {
    mockLoginUseCase = MockLoginUseCase();
    mockRegisterUseCase = MockRegisterUseCase();
    mockLogoutUseCase = MockLogoutUseCase();
    mockAuthRepository = MockIAuthRepository();

    when(
      () => mockAuthRepository.authStateChanges,
    ).thenAnswer((_) => Stream.value(null));

    // Kita tidak perlu Get.testMode = true lagi untuk mencegah crash,
    // tapi tetap berguna untuk binding GetX standar.
    Get.reset();

    controller = AuthController(
      loginUseCase: mockLoginUseCase,
      registerUseCase: mockRegisterUseCase,
      logoutUseCase: mockLogoutUseCase,
      authRepository: mockAuthRepository,
    );
    controller.onInit();
  });

  group('AuthController Logic (Reactive State Pattern)', () {
    const email = 'test@example.com';
    const password = 'password123';

    test(
      'login success: isLoading updates, errorMessage remains empty',
      () async {
        // ARRANGE
        when(
          () => mockLoginUseCase(email, password),
        ).thenAnswer((_) async => MockUserCredential());

        // ACT
        final future = controller.login(email, password);

        expect(controller.isLoading.value, isTrue); // Cek loading awal
        await future;

        // ASSERT
        expect(controller.isLoading.value, isFalse); // Cek loading akhir
        expect(
          controller.errorMessage.value,
          isEmpty,
        ); // Pastikan TIDAK ada error
      },
    );

    test('login failure: updates errorMessage correctly', () async {
      // ARRANGE
      const errorMsg = 'User not found in database';
      when(() => mockLoginUseCase(email, password)).thenThrow(
        FirebaseAuthException(code: 'user-not-found', message: errorMsg),
      );

      // ACT
      await controller.login(email, password);

      // ASSERT
      expect(controller.isLoading.value, isFalse);

      // DI SINI KUNCI TESTINGNYA:
      // Kita cek apakah variabel errorMessage terisi dengan pesan yang benar
      expect(controller.errorMessage.value, errorMsg);
    });
  });
}
