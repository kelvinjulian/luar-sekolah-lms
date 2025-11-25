import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/usecases/auth/login_use_case.dart';
import '../../domain/usecases/auth/register_use_case.dart';
import '../../domain/usecases/auth/logout_use_case.dart';
import '../../domain/repositories/i_auth_repository.dart';

//? Controller untuk mengelola autentikasi user
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

  //? bagian ini, jika user berhasil login atau logout, maka firebase akan mendeteksi status tersebut dan mengupdate stream authStateChanges.
  //? sehingga akan menavigasi user ke halaman yang sesuai secara otomatis.
  @override
  void onInit() {
    super.onInit();
    // Ikat stream ke variabel _user agar selalu update saat auth berubah
    _user.bindStream(
      authRepository.authStateChanges,
    ); // kapanpun status login berubah di firebase (user login/logout), variable _user akan otomatis terupdate
  }

  //? OnReady adalah fungsi GetX yang berjalan satu kali setelah widget SplashPage dibangun
  @override
  void onReady() {
    super.onReady();

    // (1) Jalankan handler navigasi dengan status user saat ini
    _handleAuthChanged(_user.value);

    // (1) Jalankan handler navigasi dengan status user saat ini
    ever(_user, _handleAuthChanged);
  }

  //? Fungsi untuk menangani navigasi berdasarkan status login
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

  //? --- LOGIN ---
  Future<void> login(String email, String password) async {
    try {
      isLoading(true); // <-- Spinner aktif di UI
      await loginUseCase(email, password);
      // Login sukses. Stream _user akan otomatis terupdate.
    } on FirebaseAuthException catch (e) {
      isLoading(false); // <-- Spinner mati jika gagal
      Get.snackbar(
        "Login Gagal",
        e.message ?? "Terjadi kesalahan",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFE53935),
        colorText: const Color(0xFFFFFFFF),
      );
    }
  }

  //? --- REGISTER ---
  Future<void> register(String email, String password) async {
    try {
      isLoading(true); // <-- (1) UI menampilkan spinner

      // (2) Panggil UseCase -> Repository -> DataSource
      await registerUseCase(email, password);

      // (3) Tampilkan pesan sukses
      Get.snackbar(
        "Registrasi Berhasil",
        "Selamat datang di aplikasi!",
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
        backgroundColor: const Color(0xFF4CAF50),
        colorText: const Color(0xFFFFFFFF),
      );
    } on FirebaseAuthException catch (e) {
      isLoading(false);
      Get.snackbar(
        "Register Gagal",
        e.message ?? "Terjadi kesalahan",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFE53935),
        colorText: const Color(0xFFFFFFFF),
      );

      // jika email sudah terdaftar, arahkan ke halaman login
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
