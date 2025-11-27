import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mocktail/mocktail.dart';
import 'package:firebase_auth/firebase_auth.dart';
// Pastikan path import ini sesuai struktur folder Anda
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

    // Reset GetX sebelum setiap test
    Get.reset();
    // Set testMode ke true agar controller men-skip snackbar
    Get.testMode = true;

    controller = AuthController(
      loginUseCase: mockLoginUseCase,
      registerUseCase: mockRegisterUseCase,
      logoutUseCase: mockLogoutUseCase,
      authRepository: mockAuthRepository,
    );
    controller.onInit();
  });

  tearDown(() {
    controller.dispose();
    Get.reset();
  });

  group('AuthController Login Logic', () {
    const email = 'test@example.com';
    const password = 'password123';

    test('login should set loading state correctly on success', () async {
      // ARRANGE
      // Gunakan delay kecil agar simulasi lebih nyata
      when(() => mockLoginUseCase(email, password)).thenAnswer((_) async {
        await Future.delayed(const Duration(milliseconds: 10));
        return MockUserCredential();
      });

      // ACT
      final future = controller.login(email, password);

      // ASSERT 1: Loading harus true (karena ada delay di mock)
      expect(controller.isLoading.value, isTrue);

      await future;

      // ASSERT 2: Loading harus false setelah selesai
      expect(controller.isLoading.value, isFalse);
    });

    test('login should set loading state correctly on error', () async {
      // ARRANGE
      // PENTING: Gunakan thenAnswer + async throw agar tidak terjadi secara instan (synchronous)
      // Ini mencegah isLoading berubah false sebelum kita sempat mengeceknya.
      when(() => mockLoginUseCase(email, password)).thenAnswer((_) async {
        await Future.delayed(const Duration(milliseconds: 10));
        throw FirebaseAuthException(
          code: 'user-not-found',
          message: 'User not found',
        );
      });

      // ACT
      final future = controller.login(email, password);

      // ASSERT 1: Sekarang ini akan sukses karena error tidak langsung dilempar
      expect(controller.isLoading.value, isTrue);

      try {
        await future;
      } catch (e) {
        // Error ditangkap, snackbar dilewati karena Get.testMode = true
      }

      // ASSERT 2: Loading harus kembali false
      expect(controller.isLoading.value, isFalse);
    });
  });
}
