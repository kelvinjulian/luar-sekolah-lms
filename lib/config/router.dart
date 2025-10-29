// lib/config/router.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// Import Halaman
import '../pages/login_page.dart';
import '../pages/register_page.dart';
import '../pages/home_page.dart';
import '../pages/class_form_page.dart';

//? --- IMPORT BARU ---
import '../pages/todo_detail_page.dart';
import '../models/todo.dart';

final GoRouter router = GoRouter(
  // initial location adalah halaman awal saat aplikasi dijalankan
  initialLocation: '/home', // akan membuka halaman home
  routes: [
    // ? --- RUTE UNTUK REGISTER, LOGIN, HOME, DLL. ---
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterPage(),
    ),
    GoRoute(
      path: '/login',
      pageBuilder: (context, state) {
        return CustomTransitionPage(
          key: state.pageKey,
          child: const LoginPage(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 350),
        );
      },
    ),
    GoRoute(
      path: '/home',
      pageBuilder: (context, state) {
        return CustomTransitionPage(
          key: state.pageKey,
          child: const HomePage(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        );
      },
    ),
    GoRoute(
      path: '/class/form',
      builder: (context, state) {
        final data = state.extra as Map<String, dynamic>?;
        return ClassFormPage(initialData: data);
      },
    ),

    //? --- RUTE BARU UNTUK DETAIL TODO ---
    GoRoute(
      path: '/todo-detail',
      name: 'todoDetail',
      pageBuilder: (context, state) {
        final todo = state.extra as Todo;

        return CustomTransitionPage(
          key: state.pageKey,
          child: TodoDetailPage(todo: todo),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        );
      },
    ),
  ],
);
