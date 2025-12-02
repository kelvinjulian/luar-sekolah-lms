//* 1. IMPORT
// Mengimpor library testing, GetX, Mocktail, dan file-file asli project (Page, Controller, dll).
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

//* 2. MOCK CLASS DEFINITIONS
// Kita membuat kelas tiruan untuk semua dependensi agar tidak butuh Firebase/Internet asli.
class MockIAuthRepository extends Mock implements IAuthRepository {}

class MockLoginUseCase extends Mock implements LoginUseCase {}

class MockRegisterUseCase extends Mock implements RegisterUseCase {}

class MockLogoutUseCase extends Mock implements LogoutUseCase {}

class MockUserCredential extends Mock implements UserCredential {}

void main() {
  late MockIAuthRepository mockRepo;
  late MockLoginUseCase mockLoginUseCase;

  //* 3. SETUP (Jalan sebelum setiap test)
  setUp(() {
    mockRepo = MockIAuthRepository();
    mockLoginUseCase = MockLoginUseCase();
    //? Stubbing: Mencegah error 'Null Check' saat Controller.onInit memanggil stream auth
    when(() => mockRepo.authStateChanges).thenAnswer((_) => Stream.value(null));
    Get.reset(); // Membersihkan memory GetX agar test satu tidak mengganggu test lain
  });

  //* 4. HELPER FUNCTION: LOAD UI
  // Fungsi pembantu untuk merender halaman login ke layar virtual
  Future<void> loadLoginUI(WidgetTester tester) async {
    // Trik: Mengatur ukuran layar virtual menjadi besar (HP Modern)
    // agar tidak terjadi error "RenderFlex Overflow" atau widget terpotong.
    tester.view.physicalSize = const Size(2400, 3000);
    tester.view.devicePixelRatio = 3.0;

    // Membersihkan settingan layar setelah test selesai
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    // Inisialisasi Controller Asli dengan UseCase Palsu (Mock)
    final controller = AuthController(
      loginUseCase: mockLoginUseCase,
      registerUseCase: MockRegisterUseCase(),
      logoutUseCase: MockLogoutUseCase(),
      authRepository: mockRepo,
    );

    // Inisialisasi Controller Asli dengan UseCase Palsu (Mock)
    Get.put(controller);

    // Render Widget Utama
    await tester.pumpWidget(
      GetMaterialApp(
        home: const LoginPage(),
        getPages: [
          // Definisi rute agar navigasi Get.toNamed tidak error
          GetPage(name: '/login', page: () => const LoginPage()),
          GetPage(
            name: '/home',
            page: () => const Scaffold(body: Text("Home")),
          ),
        ],
      ),
    );
  }

  //* 5. TEST UTAMA: HAPPY PATH
  testWidgets('LoginPage flow: Render -> Input -> Click -> Call Logic', (
    WidgetTester tester,
  ) async {
    await loadLoginUI(tester);
    await tester.pumpAndSettle(); // Tunggu semua animasi/render selesai

    // Verifikasi Elemen Awal
    expect(find.text('Email Aktif'), findsOneWidget); //? Pastikan label ada

    final btnFinder = find.widgetWithText(ElevatedButton, 'Masuk');

    // Scroll otomatis sampai tombol terlihat (Penting!)
    // Gunakan ensureVisible agar aman
    await tester.ensureVisible(btnFinder);
    await tester.pumpAndSettle();

    //? Pastikan tombol Mati (Disabled) karena form masih kosong
    final btnBefore = tester.widget<ElevatedButton>(btnFinder);
    expect(btnBefore.onPressed, isNull);

    //? Isi Form
    // Cari field pertama (Email) dan isi
    final emailFinder = find.byType(TextFormField).at(0);
    await tester.ensureVisible(emailFinder);
    await tester.enterText(emailFinder, 'user@test.com');

    // Cari field kedua (Password) dan isi
    final passFinder = find.byType(TextFormField).at(1);
    await tester.ensureVisible(passFinder);
    await tester.enterText(passFinder, 'password123');

    await tester.pump(); // Rebuild UI agar state tombol berubah

    //? Pastikan tombol Hidup (Enabled)
    await tester.ensureVisible(btnFinder);
    final btnAfter = tester.widget<ElevatedButton>(btnFinder);
    expect(btnAfter.onPressed, isNotNull);

    // SIMULASI KLIK
    // Latih Mock agar mengembalikan UserCredential saat dipanggil
    when(
      () => mockLoginUseCase.call(any(), any()),
    ).thenAnswer((_) async => MockUserCredential());
    await tester.tap(btnFinder); // Klik tombol
    await tester.pump(); // Proses event klik

    //? VERIFIKASI (ASSERT)
    // Buktikan bahwa UI benar-benar memanggil fungsi use case logic 'login'
    verify(
      () => mockLoginUseCase.call('user@test.com', 'password123'),
    ).called(1);
  });

  //* 6. TEST KEDUA: VALIDASI UI & ERROR MESSAGE
  testWidgets('LoginPage shows error validation UI', (
    WidgetTester tester,
  ) async {
    await loadLoginUI(tester);
    await tester.pumpAndSettle();

    // Isi form dengan Email SALAH
    final emailFinder = find.byType(TextFormField).at(0);
    final passFinder = find.byType(TextFormField).at(1);

    await tester.ensureVisible(emailFinder);
    await tester.enterText(emailFinder, 'bukan-email'); // Input salah

    await tester.ensureVisible(passFinder);
    await tester.enterText(passFinder, '123');
    await tester.pump();

    // Klik tombol untuk memicu validasi form
    final btnFinder = find.widgetWithText(ElevatedButton, 'Masuk');
    await tester.ensureVisible(btnFinder);
    await tester.pumpAndSettle();
    await tester.tap(btnFinder);
    await tester.pump();

    // Cari Scrollable widget (ListView/SingleChildScrollView)
    // agar bisa men-scroll layar untuk mencari pesan error
    final scrollableFinder = find.byType(Scrollable);

    // Jika ketemu scrollable, coba scroll ke atas untuk melihat error message
    if (scrollableFinder.evaluate().isNotEmpty) {
      // Drag ke bawah (offset positif Y) untuk scroll ke atas
      await tester.drag(scrollableFinder.first, const Offset(0, 300));
      await tester.pumpAndSettle();
    }

    // Assert error message
    // Cari teks error apapun yang mungkin muncul
    //? Bisa jadi errornya 'Format email tidak valid' atau 'Email tidak valid'
    expect(find.textContaining('email', findRichText: true), findsWidgets);
    // Jika ingin spesifik:
    expect(find.text('Format email tidak valid'), findsOneWidget);
  });
}
