//* 1. IMPORT
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

class MockUser extends Mock implements User {}

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

    // Stubbing: stream authStateChanges aman untuk test
    when(
      () => mockAuthRepository.authStateChanges,
    ).thenAnswer((_) => Stream<User?>.empty());

    // Reset GetX sebelum setiap test
    Get.reset();
    Get.testMode = true; // Disable snackbar di test

    // Inisialisasi Controller dengan Mock
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

    //* LOGIN SUCCESS
    test(
      'login success: isLoading updates, errorMessage remains empty',
      () async {
        // ARRANGE: Stub loginUseCase sesuai signature .call()
        when(
          () => mockLoginUseCase.call(email, password),
        ).thenAnswer((_) async => MockUserCredential());

        // ACT
        final future = controller.login(email, password);

        // LOADING harus true saat proses berjalan
        expect(controller.isLoading.value, isTrue);

        await future;

        // ASSERT
        expect(controller.isLoading.value, isFalse);
        expect(controller.errorMessage.value, isEmpty);
      },
    );

    //* LOGIN FAILURE
    test('login failure: updates errorMessage correctly', () async {
      // ARRANGE: Stub loginUseCase untuk lempar FirebaseAuthException
      const errorMsg = 'User not found in database';
      when(() => mockLoginUseCase.call(email, password)).thenThrow(
        FirebaseAuthException(code: 'user-not-found', message: errorMsg),
      );

      // ACT
      await controller.login(email, password);

      // ASSERT
      expect(controller.isLoading.value, isFalse);
      expect(controller.errorMessage.value, errorMsg);
    });

    //* LOGIN FAILURE GENERIC ERROR
    test('login failure: updates errorMessage on unexpected error', () async {
      when(
        () => mockLoginUseCase.call(email, password),
      ).thenThrow(Exception('oops'));

      await controller.login(email, password);

      expect(controller.isLoading.value, isFalse);
      expect(controller.errorMessage.value, 'Terjadi kesalahan tidak terduga');
    });
  });
}
