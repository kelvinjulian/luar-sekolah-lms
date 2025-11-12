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

class AppPages {
  //? --- PERBAIKAN 1: Ubah rute awal ke /login ---
  static const INITIAL = '/home';

  static final pages = [
    //? --- Rute BARU untuk Autentikasi ---
    GetPage(
      name: '/login',
      page: () => const LoginPage(),
      // Tidak perlu binding, halaman ini simpel
    ),
    GetPage(
      name: '/register',
      page: () => const RegisterPage(),
      // Tidak perlu binding, halaman ini simpel
    ),

    //? --- Rute BARU untuk Halaman Utama (Induk) ---
    GetPage(
      name: '/home',
      page: () => const HomePage(),
      //? PENTING:
      //? Halaman Home memuat ClassPage dan TodoListPage,
      //? jadi kita harus memuat binding mereka di sini.
      bindings: [TodoBinding(), ClassBinding()],
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
