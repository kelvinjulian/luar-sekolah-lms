import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mocktail/mocktail.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:luar_sekolah_lms/app/presentation/pages/login_page.dart';
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
  late MockIAuthRepository mockRepo;
  late MockLoginUseCase mockLoginUseCase;

  setUp(() {
    mockRepo = MockIAuthRepository();
    mockLoginUseCase = MockLoginUseCase();
    when(() => mockRepo.authStateChanges).thenAnswer((_) => Stream.value(null));
    Get.reset();
  });

  Future<void> loadLoginUI(WidgetTester tester) async {
    // --- SOLUSI LAYAR ---
    // Kita set lebar fisik 2400 dan pixel ratio 3.0 -> Lebar Logis 800px
    // Ini menjamin tidak ada overflow horizontal (Row muat)
    tester.view.physicalSize = const Size(2400, 3000);
    tester.view.devicePixelRatio = 3.0;

    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final controller = AuthController(
      loginUseCase: mockLoginUseCase,
      registerUseCase: MockRegisterUseCase(),
      logoutUseCase: MockLogoutUseCase(),
      authRepository: mockRepo,
    );

    Get.put(controller);

    await tester.pumpWidget(
      GetMaterialApp(
        home: const LoginPage(),
        getPages: [
          GetPage(name: '/login', page: () => const LoginPage()),
          GetPage(
            name: '/home',
            page: () => const Scaffold(body: Text("Home")),
          ),
        ],
      ),
    );
  }

  testWidgets('LoginPage flow: Render -> Input -> Click -> Call Logic', (
    WidgetTester tester,
  ) async {
    await loadLoginUI(tester);
    await tester.pumpAndSettle();

    // Cek komponen
    expect(find.text('Email Aktif'), findsOneWidget);

    final btnFinder = find.widgetWithText(ElevatedButton, 'Masuk');

    // Gunakan ensureVisible agar aman
    await tester.ensureVisible(btnFinder);
    await tester.pumpAndSettle();

    final btnBefore = tester.widget<ElevatedButton>(btnFinder);
    expect(btnBefore.onPressed, isNull);

    // Isi Form
    // Cari field pertama (Email)
    final emailFinder = find.byType(TextFormField).at(0);
    await tester.ensureVisible(emailFinder);
    await tester.enterText(emailFinder, 'user@test.com');

    // Cari field kedua (Password)
    final passFinder = find.byType(TextFormField).at(1);
    await tester.ensureVisible(passFinder);
    await tester.enterText(passFinder, 'password123');

    await tester.pump();

    // Cek Tombol Hidup
    await tester.ensureVisible(btnFinder);
    final btnAfter = tester.widget<ElevatedButton>(btnFinder);
    expect(btnAfter.onPressed, isNotNull);

    // Klik
    when(
      () => mockLoginUseCase.call(any(), any()),
    ).thenAnswer((_) async => MockUserCredential());

    await tester.tap(btnFinder);
    await tester.pump();

    verify(
      () => mockLoginUseCase.call('user@test.com', 'password123'),
    ).called(1);
  });

  testWidgets('LoginPage shows error validation UI', (
    WidgetTester tester,
  ) async {
    await loadLoginUI(tester);
    await tester.pumpAndSettle();

    // Isi form salah
    final emailFinder = find.byType(TextFormField).at(0);
    final passFinder = find.byType(TextFormField).at(1);

    await tester.ensureVisible(emailFinder);
    await tester.enterText(emailFinder, 'bukan-email');

    await tester.ensureVisible(passFinder);
    await tester.enterText(passFinder, '123');
    await tester.pump();

    // Klik tombol untuk trigger validasi
    final btnFinder = find.widgetWithText(ElevatedButton, 'Masuk');
    await tester.ensureVisible(btnFinder);
    await tester.pumpAndSettle();

    await tester.tap(btnFinder);
    await tester.pump();

    // --- SOLUSI FINDER SCROLL ---
    // Cari widget scrollable apapun (bisa ListView, SingleChildScrollView, dll)
    final scrollableFinder = find.byType(Scrollable);

    // Jika ketemu scrollable, coba scroll ke atas untuk melihat error message
    if (scrollableFinder.evaluate().isNotEmpty) {
      // Drag ke bawah (offset positif Y) untuk scroll ke atas
      await tester.drag(scrollableFinder.first, const Offset(0, 300));
      await tester.pumpAndSettle();
    }

    // Assert error message
    // Cari teks error apapun yang mungkin muncul
    // Bisa jadi errornya 'Format email tidak valid' atau 'Email tidak valid' (sesuaikan dengan kode Anda)
    expect(find.textContaining('email', findRichText: true), findsWidgets);
    // Jika ingin spesifik:
    expect(find.text('Format email tidak valid'), findsOneWidget);
  });
}
