// lib/main.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'app/core/routes/app_routes.dart';
// Import NotificationService yang baru dibuat
import 'app/core/services/notification_service.dart';
import 'app/presentation/controllers/auth_controller.dart';
import 'app/data/repositories/auth_repository_impl.dart';
import 'app/data/datasources/auth_firebase_data_source.dart';
import 'app/domain/usecases/auth/login_use_case.dart';
import 'app/domain/usecases/auth/register_use_case.dart';
import 'app/domain/usecases/auth/logout_use_case.dart';

// Fungsi 'main' harus async karena inisialisasi Firebase butuh waktu (await)
void main() async {
  // 1. Flutter Binding
  // Wajib dipanggil pertama kali jika fungsi main bersifat async.
  // Ini memastikan engine Flutter siap berkomunikasi dengan native code (Android/iOS).
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Inisialisasi Firebase
  // Menghubungkan aplikasi ke proyek Firebase menggunakan config yang ada di firebase_options.dart
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  //? --- INISIALISASI SERVICES (FITUR BARU MINGGU 10) ---
  // Langkah A: Dependency Injection Service
  // Kita menggunakan Get.put untuk memasukkan NotificationService ke memori.
  // 'permanent: true' artinya service ini TIDAK AKAN PERNAH DIHAPUS dari memori
  // selama aplikasi berjalan. Ini penting karena notifikasi bisa datang kapan saja.
  final notificationService = Get.put(NotificationService(), permanent: true);

  //? Langkah B: Inisialisasi Logic Service
  // Memanggil fungsi .init() yang berisi: Request Permission, Setup Channel, Setup Listener.
  // Kita 'await' di sini agar listener siap SEBELUM aplikasi menampilkan UI.
  await notificationService.init();

  // --- SETUP AUTHENTICATION (MINGGU 9) ---

  // Setup Layer Data (DataSource & Repository)
  final dataSource = AuthFirebaseDataSource();
  final repo = AuthRepositoryImpl(dataSource);

  // Setup Global Auth Controller
  // Controller ini juga permanent karena dia menjaga status login user (Logged In / Logged Out).
  // Dia yang mengatur navigasi otomatis (Splash -> Home atau Splash -> Login).
  Get.put(
    AuthController(
      loginUseCase: LoginUseCase(repo),
      registerUseCase: RegisterUseCase(repo),
      logoutUseCase: LogoutUseCase(repo),
      authRepository: repo,
    ),
    permanent: true,
  );

  // 3. Jalankan Aplikasi
  runApp(const LmsApp());
}

class LmsApp extends StatelessWidget {
  const LmsApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Menggunakan GetMaterialApp untuk integrasi Routing & State Management GetX
    return GetMaterialApp(
      title: 'LMS App (Clean Architecture)',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        appBarTheme: const AppBarTheme(
          elevation: 1.0,
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
        ),
      ),
      // Rute awal diarahkan ke AppPages.INITIAL (biasanya Splash Screen)
      initialRoute: AppPages.INITIAL,
      getPages: AppPages.pages,
    );
  }
}
