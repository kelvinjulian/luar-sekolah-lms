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
    // Ikat stream ke variabel _user agar selalu update saat auth berubah
    _user.bindStream(authRepository.authStateChanges);
  }

  @override
  void onReady() {
    super.onReady();

    // Jalankan handler navigasi dengan status user saat ini
    _handleAuthChanged(_user.value);

    // Dengarkan perubahan auth di masa depan
    ever(_user, _handleAuthChanged);
  }

  // Fungsi untuk menangani navigasi berdasarkan status login
  void _handleAuthChanged(User? user) {
    isLoading(false);

    if (user != null) {
      // Jika user login, arahkan ke home (jika belum di sana)
      if (Get.currentRoute != '/home') {
        Get.offAllNamed('/home');
      }
    } else {
      // Jika user logout, arahkan ke login (jika belum di sana)
      if (Get.currentRoute != '/login') {
        Get.offAllNamed('/login');
      }
    }
  }

  // --- LOGIN ---
  Future<void> login(String email, String password) async {
    try {
      isLoading(true);
      await loginUseCase(email, password);
      // Navigasi otomatis oleh _handleAuthChanged
    } on FirebaseAuthException catch (e) {
      isLoading(false);
      Get.snackbar(
        "Login Gagal",
        e.message ?? "Terjadi kesalahan",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFE53935),
        colorText: const Color(0xFFFFFFFF),
      );
    }
  }

  // --- REGISTER ---
  Future<void> register(String email, String password) async {
    try {
      isLoading(true);
      await registerUseCase(email, password);

      //  Tampilkan pesan sukses (tidak logout)
      Get.snackbar(
        "Registrasi Berhasil",
        "Selamat datang di aplikasi!",
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
        backgroundColor: const Color(0xFF4CAF50),
        colorText: const Color(0xFFFFFFFF),
      );

      // Tidak perlu logout — user akan otomatis diarahkan ke Home
    } on FirebaseAuthException catch (e) {
      isLoading(false);
      Get.snackbar(
        "Register Gagal",
        e.message ?? "Terjadi kesalahan",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFE53935),
        colorText: const Color(0xFFFFFFFF),
      );

      if (e.code == 'email-already-in-use') {
        Get.toNamed('/login');
      }
    }
  }

  // --- LOGOUT ---
  Future<void> logout() async {
    try {
      isLoading(true);
      await logoutUseCase();
      // Navigasi otomatis oleh _handleAuthChanged
    } on FirebaseAuthException catch (e) {
      isLoading(false);
      Get.snackbar(
        "Logout Gagal",
        e.message ?? "Terjadi kesalahan",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFE53935),
        colorText: const Color(0xFFFFFFFF),
      );
    }
  }
}
