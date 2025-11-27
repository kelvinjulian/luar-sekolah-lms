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

  // --- REACTIVE STATE ---
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs; // Variable penampung error
  final RxString successMessage = ''.obs; // Variable penampung sukses

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

  // DI SINI KUNCINYA: Memasang "pendengar" (Listener)
  @override
  void onReady() {
    super.onReady();
    _handleAuthChanged(_user.value);
    ever(_user, _handleAuthChanged);

    // 1. DENGARKAN ERROR MESSAGE
    // Setiap kali 'errorMessage' berubah isinya, fungsi ini jalan
    ever(errorMessage, (String msg) {
      if (msg.isNotEmpty && !Get.testMode) {
        Get.snackbar(
          "Terjadi Kesalahan",
          msg,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFFE53935),
          colorText: Colors.white,
          margin: const EdgeInsets.all(10),
        );
      }
    });

    // 2. DENGARKAN SUCCESS MESSAGE
    // Setiap kali 'successMessage' berubah isinya, fungsi ini jalan
    ever(successMessage, (String msg) {
      if (msg.isNotEmpty && !Get.testMode) {
        Get.snackbar(
          "Berhasil",
          msg,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFF4CAF50),
          colorText: Colors.white,
          margin: const EdgeInsets.all(10),
        );
      }
    });
  }

  void _handleAuthChanged(User? user) {
    if (user != null) {
      if (Get.currentRoute != '/home') Get.offAllNamed('/home');
    } else {
      if (Get.currentRoute != '/login') Get.offAllNamed('/login');
    }
  }

  // Fungsi reset agar pesan lama tidak muncul lagi saat retry
  void _resetMessages() {
    errorMessage.value = '';
    successMessage.value = '';
  }

  //? --- LOGIN ---
  Future<void> login(String email, String password) async {
    isLoading(true);
    _resetMessages(); // Reset dulu sebelum mulai

    try {
      await loginUseCase(email, password);
    } on FirebaseAuthException catch (e) {
      // Update state, nanti 'ever' di onReady yang akan menampilkan snackbar
      errorMessage.value = e.message ?? "Gagal Login";
    } catch (e) {
      errorMessage.value = "Terjadi kesalahan tidak terduga";
    } finally {
      isLoading(false);
    }
  }

  //? --- REGISTER ---
  Future<void> register(String email, String password) async {
    isLoading(true);
    _resetMessages();

    try {
      await registerUseCase(email, password);
      successMessage.value = "Registrasi Berhasil! Silakan Login.";
    } on FirebaseAuthException catch (e) {
      errorMessage.value = e.message ?? "Gagal Registrasi";
      if (e.code == 'email-already-in-use') {
        Get.toNamed('/login');
      }
    } catch (e) {
      errorMessage.value = "Terjadi kesalahan tidak terduga";
    } finally {
      isLoading(false);
    }
  }

  // --- LOGOUT ---
  Future<void> logout() async {
    isLoading(true);
    _resetMessages();
    try {
      await logoutUseCase();
    } on FirebaseAuthException catch (e) {
      errorMessage.value = e.message ?? "Gagal Logout";
    } finally {
      isLoading(false);
    }
  }
}
