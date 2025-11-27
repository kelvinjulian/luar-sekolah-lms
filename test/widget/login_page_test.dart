import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mocktail/mocktail.dart';

import 'package:luar_sekolah_lms/app/presentation/pages/login_page.dart';
import 'package:luar_sekolah_lms/app/presentation/widgets/input_field.dart';
import 'package:luar_sekolah_lms/app/presentation/controllers/auth_controller.dart';
import 'package:luar_sekolah_lms/app/domain/repositories/i_auth_repository.dart';
import 'package:luar_sekolah_lms/app/domain/usecases/auth/login_use_case.dart';
import 'package:luar_sekolah_lms/app/domain/usecases/auth/register_use_case.dart';
import 'package:luar_sekolah_lms/app/domain/usecases/auth/logout_use_case.dart';
// import 'package:firebase_auth/firebase_auth.dart'; // Dibutuhkan untuk UserCredential

// --- MOCK DUMMY CLASSES ---
class MockIAuthRepositoryDummy extends Mock implements IAuthRepository {}

class MockLoginUseCase extends Mock implements LoginUseCase {}

class MockRegisterUseCase extends Mock implements RegisterUseCase {}

class MockLogoutUseCase extends Mock implements LogoutUseCase {}

void main() {
  testWidgets('LoginPage must render components and check button state', (
    WidgetTester tester,
  ) async {
    // 1. ARRANGE: Setup Mock Dependencies
    final mockRepo = MockIAuthRepositoryDummy();

    // Mock stream authStateChanges agar tidak crash saat onInit
    when(() => mockRepo.authStateChanges).thenAnswer((_) => Stream.value(null));

    // Inject AuthController dengan mock minimal
    Get.put(
      AuthController(
        loginUseCase: MockLoginUseCase(),
        registerUseCase: MockRegisterUseCase(),
        logoutUseCase: MockLogoutUseCase(),
        authRepository: mockRepo,
      ),
    );

    // 2. ACT: Render UI dengan Route Definition (agar navigasi tidak crash)
    await tester.pumpWidget(
      GetMaterialApp(
        home: const LoginPage(),
        getPages: [
          GetPage(name: '/login', page: () => const LoginPage()),
          GetPage(
            name: '/register',
            page: () => const Center(child: Text("Register Page")),
          ),
          GetPage(
            name: '/home',
            page: () => const Center(child: Text("Home Page")),
          ),
        ],
      ),
    );

    await tester.pumpAndSettle();

    // Cari tombol Masuk
    final loginButtonFinder = find.widgetWithText(ElevatedButton, 'Masuk');

    // ASSERT A: Status Awal Tombol (Disabled)
    final buttonBefore = tester.widget<ElevatedButton>(loginButtonFinder);
    expect(
      buttonBefore.onPressed,
      isNull,
      reason: "Tombol harus mati saat form kosong",
    );

    // --- 3. INTERAKSI: ISI FORM ---

    // Strategi: Cari InputField berdasarkan label
    final emailInputFinder = find.descendant(
      of: find.widgetWithText(InputField, 'Email Aktif'),
      matching: find.byType(TextFormField),
    );

    final passwordInputFinder = find.descendant(
      of: find.widgetWithText(InputField, 'Password'),
      matching: find.byType(TextFormField),
    );

    // ACT A: Isi Email
    await tester.enterText(emailInputFinder, 'test@a.com');
    await tester.pump();

    // ACT B: Isi Password
    await tester.enterText(passwordInputFinder, '123456');
    await tester.pump();

    // ASSERT B: Status Akhir Tombol (Enabled)
    final buttonAfter = tester.widget<ElevatedButton>(loginButtonFinder);
    expect(
      buttonAfter.onPressed,
      isNotNull,
      reason: "Tombol harus aktif setelah form terisi",
    );
  });

  tearDown(() => Get.reset());
}
