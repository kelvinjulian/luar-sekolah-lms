import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/usecases/auth/login_use_case.dart';
import '../../domain/usecases/auth/register_use_case.dart';
import '../../domain/usecases/auth/logout_use_case.dart';
import '../../domain/repositories/i_auth_repository.dart';

class AuthController extends GetxController {
  final LoginUseCase loginUseCase;
  final RegisterUseCase registerUseCase;
  final LogoutUseCase logoutUseCase;
  final IAuthRepository authRepository;

  final isLoading = false.obs;
  final Rxn<User> _user = Rxn<User>();
  User? get user => _user.value;
  Stream<User?> get authStateChanges => authRepository.authStateChanges;

  AuthController({
    required this.loginUseCase,
    required this.registerUseCase,
    required this.logoutUseCase,
    required this.authRepository,
  });

  @override
  void onInit() {
    super.onInit();
    _user.bindStream(authRepository.authStateChanges);
  }

  @override
  void onReady() {
    super.onReady();
    _handleAuthChanged(_user.value);
    ever(_user, _handleAuthChanged);
  }

  void _handleAuthChanged(User? user) {
    if (user != null) {
      if (Get.currentRoute != '/home') Get.offAllNamed('/home');
    } else {
      if (Get.currentRoute != '/login') Get.offAllNamed('/login');
    }
  }

  //? --- LOGIN ---
  Future<void> login(String email, String password) async {
    isLoading(true);
    try {
      await loginUseCase(email, password);
    } on FirebaseAuthException catch (e) {
      // PENTING: Pengecekan ini MENCEGAH crash 'Null check operator' saat testing
      if (!Get.testMode) {
        Get.snackbar(
          "Login Gagal",
          e.message ?? "Terjadi kesalahan",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFFE53935),
          colorText: const Color(0xFFFFFFFF),
        );
      }
    } finally {
      isLoading(false); // Pastikan loading mati
    }
  }

  //? --- REGISTER ---
  Future<void> register(String email, String password) async {
    isLoading(true);
    try {
      await registerUseCase(email, password);

      if (!Get.testMode) {
        Get.snackbar(
          "Registrasi Berhasil",
          "Selamat datang di aplikasi!",
          backgroundColor: const Color(0xFF4CAF50),
          colorText: const Color(0xFFFFFFFF),
        );
      }
    } on FirebaseAuthException catch (e) {
      if (!Get.testMode) {
        Get.snackbar(
          "Register Gagal",
          e.message ?? "Terjadi kesalahan",
          backgroundColor: const Color(0xFFE53935),
          colorText: const Color(0xFFFFFFFF),
        );
      }
      if (e.code == 'email-already-in-use') {
        Get.toNamed('/login');
      }
    } finally {
      isLoading(false);
    }
  }

  // --- LOGOUT ---
  Future<void> logout() async {
    isLoading(true);
    try {
      await logoutUseCase();
    } on FirebaseAuthException catch (e) {
      if (!Get.testMode) {
        Get.snackbar(
          "Logout Gagal",
          e.message ?? "Terjadi kesalahan",
          backgroundColor: const Color(0xFFE53935),
          colorText: const Color(0xFFFFFFFF),
        );
      }
    } finally {
      isLoading(false);
    }
  }
}
