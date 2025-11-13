// lib/app/core/routes/app_routes.dart
import 'package:get/get.dart';

// --- VERIFIKASI IMPORT ---
// Import SEMUA binding
import '../bindings/class_binding.dart';
import '../bindings/todo_binding.dart';

// Import SEMUA halaman
import '../../presentation/pages/course/class_page.dart';
import '../../presentation/pages/todo/todo_list_page.dart';
import '../../presentation/pages/todo/todo_detail_page.dart';
import '../../domain/entities/todo.dart'; // Dibutuhkan untuk GetPage /todo-detail

// Import halaman-halaman BARU
import '../../presentation/pages/login_page.dart';
import '../../presentation/pages/register_page.dart';
import '../../presentation/pages/home_page.dart';
// -------------------------

import '../bindings/auth_binding.dart'; // <-- 1. IMPORT
import '../../presentation/pages/splash_page.dart'; // <-- 2. IMPORT

class AppPages {
  //? --- PERBAIKAN 1: Ubah rute awal ke /login ---
  static const INITIAL = '/splash';

  static final pages = [
    //? --- Rute BARU untuk Autentikasi ---

    //? --- Rute BARU untuk Splash/Gatekeeper ---
    GetPage(
      name: '/splash',
      page: () => const SplashPage(),
      binding: AuthBinding(), // <-- 3. TAMBAHKAN BINDING
    ),

    GetPage(
      name: '/login',
      page: () => const LoginPage(),
      binding: AuthBinding(), // <-- 4. TAMBAHKAN BINDING
    ),
    GetPage(
      name: '/register',
      page: () => const RegisterPage(),
      binding: AuthBinding(), // <-- 5. TAMBAHKAN BINDING
    ),

    //? --- Rute BARU untuk Halaman Utama (Induk) ---
    GetPage(
      name: '/home',
      page: () => const HomePage(),
      bindings: [
        TodoBinding(),
        ClassBinding(),
        AuthBinding(), // <-- 6. TAMBAHKAN BINDING
      ],
    ),

    // --- Rute-rute LAMA kita ---
    // (Kita biarkan agar deep linking / tes tetap berfungsi)
    GetPage(
      name: '/todo-list',
      page: () => const TodoListPage(),
      binding: TodoBinding(),
    ),
    GetPage(
      name: '/class-list',
      page: () => const ClassPage(),
      binding: ClassBinding(),
    ),
    GetPage(
      name: '/todo-detail',
      page: () {
        final Todo todo = Get.arguments as Todo;
        return TodoDetailPage(todo: todo);
      },
      // Halaman detail tidak perlu binding,
      // karena controllernya sudah di-load oleh '/todo-list'
    ),
  ];
}
