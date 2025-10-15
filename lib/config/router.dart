import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../pages/login_page.dart';
import '../pages/register_page.dart';
import '../pages/home_page.dart';
import '../pages/class_form_page.dart';

final GoRouter router = GoRouter(
  initialLocation: '/register',
  routes: [
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterPage(),
    ),
    GoRoute(
      path: '/login',
      // Gunakan pageBuilder, bukan builder biasa
      pageBuilder: (context, state) {
        return CustomTransitionPage(
          key: state.pageKey,
          child: const LoginPage(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            // Gunakan FadeTransition untuk efek memudar
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
        // Ambil data 'extra' jika ada (untuk mode edit)
        final data = state.extra as Map<String, dynamic>?;
        return ClassFormPage(initialData: data);
      },
    ),
  ],
);
