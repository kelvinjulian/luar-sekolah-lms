import 'package:get/get.dart';

// --- VERIFIKASI IMPORT ---
// Import binding yang BUKAN Auth
import '../bindings/class_binding.dart';
import '../bindings/todo_binding.dart';

// Import SEMUA halaman
import '../../presentation/pages/course/class_page.dart';
import '../../presentation/pages/todo/todo_list_page.dart';
import '../../presentation/pages/todo/todo_detail_page.dart';
import '../../domain/entities/todo.dart';
import '../../presentation/pages/login_page.dart';
import '../../presentation/pages/register_page.dart';
import '../../presentation/pages/home_page.dart';
import '../../presentation/pages/splash_page.dart';

//? --- PERBAIKAN 1: Hapus import AuthBinding ---
// import '../bindings/auth_binding.dart';

class AppPages {
  static const INITIAL = '/splash';

  static final pages = [
    //? --- PERBAIKAN 2: Hapus 'binding: AuthBinding()' ---
    GetPage(
      name: '/splash',
      page: () => const SplashPage(),
      // binding: AuthBinding(), // <-- HAPUS
    ),

    //? --- PERBAIKAN 3: Hapus 'binding: AuthBinding()' ---
    GetPage(
      name: '/login',
      page: () => const LoginPage(),
      // binding: AuthBinding(), // <-- HAPUS
    ),

    //? --- PERBAIKAN 4: Hapus 'binding: AuthBinding()' ---
    GetPage(
      name: '/register',
      page: () => const RegisterPage(),
      // binding: AuthBinding(), // <-- HAPUS
    ),

    GetPage(
      name: '/home',
      page: () => const HomePage(),
      bindings: [
        //? --- PERBAIKAN 5: Hapus AuthBinding() dari list ---
        TodoBinding(),
        ClassBinding(),
        // AuthBinding(), // <-- HAPUS
      ],
    ),

    // --- Rute-rute ini sudah benar ---
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
    ),
  ];
}
