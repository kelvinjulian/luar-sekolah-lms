import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Import ini

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
  final RxString errorMessage = ''.obs;
  final RxString successMessage = ''.obs;

  final Rxn<User> _user = Rxn<User>();
  User? get user => _user.value;
  Stream<User?> get authStateChanges => authRepository.authStateChanges;

  // VARIABLE BARU UNTUK FOTO LOKAL
  final RxnString localPhotoPath = RxnString();

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

    // --- TAMBAHAN PENTING: LISTEN PERUBAHAN USER ---
    // Saat aplikasi nyala dan user terdeteksi login, langsung load foto
    ever(_user, (User? u) {
      if (u != null) {
        loadLocalPhoto(u.uid); // <--- INI KUNCINYA
      } else {
        localPhotoPath.value = null;
      }
    });

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

  // --- FUNGSI LOAD FOTO ---
  Future<void> loadLocalPhoto(String uid) async {
    final prefs = await SharedPreferences.getInstance();
    // Ambil path dari memori
    String? path = prefs.getString('profile_photo_path_$uid');
    if (path != null && path.isNotEmpty) {
      localPhotoPath.value = path; // Update Variable Global
    }
  }

  //? --- FUNGSI UPDATE FOTO ---
  Future<void> updateLocalPhoto(String path) async {
    final user = _user.value;
    if (user != null) {
      final prefs = await SharedPreferences.getInstance();
      // Simpan path ke memori HP
      await prefs.setString('profile_photo_path_${user.uid}', path);
      localPhotoPath.value = path;
    }
  }

  void _handleAuthChanged(User? user) {
    if (user != null) {
      if (Get.currentRoute != '/home') Get.offAllNamed('/home');
    } else {
      if (Get.currentRoute != '/login') Get.offAllNamed('/login');
    }
  }

  void _resetMessages() {
    errorMessage.value = '';
    successMessage.value = '';
  }

  // --- LOGIN (Update Navigasi Manual) ---
  Future<void> login(String email, String password) async {
    isLoading(true);
    _resetMessages(); // Reset pesan error/sukses

    try {
      await loginUseCase(email, password);

      // PAKSA PINDAH KE HOME SETELAH SUKSES
      Get.offAllNamed('/home');
    } on FirebaseAuthException catch (e) {
      errorMessage.value = e.message ?? "Gagal Login";
    } catch (e) {
      errorMessage.value = "Password atau email salah";
    } finally {
      isLoading(false);
    }
  }

  //? --- REGISTER (Update Navigasi Manual) ---
  Future<void> register(String name, String email, String password) async {
    isLoading(true);
    _resetMessages();

    try {
      await registerUseCase(email, password);

      //? Langsung update display name setelah registrasi
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await user.updateDisplayName(name);
        await user.reload(); // Refresh data user lokal
        _user.value = FirebaseAuth.instance.currentUser; // Trigger UI update
      }

      successMessage.value = "Registrasi Berhasil!";

      // PAKSA PINDAH KE HOME (Karena register Firebase otomatis login)
      Get.offAllNamed('/home');
    } on FirebaseAuthException catch (e) {
      errorMessage.value = e.message ?? "Gagal Registrasi";
      if (e.code == 'email-already-in-use') {
        // Jika email sudah ada, arahkan ke login
        Get.toNamed('/login');
      }
    } catch (e) {
      errorMessage.value = "Terjadi kesalahan tidak terduga";
    } finally {
      isLoading(false);
    }
  }

  // --- LOGOUT (Update Navigasi Manual & Reset Data) ---
  Future<void> logout() async {
    isLoading(true);
    _resetMessages();
    try {
      await logoutUseCase();

      // 1. RESET MANUAL DATA USER (Biar UI langsung berubah kosong)
      _user.value = null;
      localPhotoPath.value = null;

      // 2. PAKSA PINDAH KE LOGIN
      Get.offAllNamed('/login');
    } on FirebaseAuthException catch (e) {
      errorMessage.value = e.message ?? "Gagal Logout";
    } finally {
      isLoading(false);
    }
  }

  Future<void> updateDisplayName(String newName) async {
    try {
      isLoading(true);
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await user.updateDisplayName(newName);
        await user.reload();
        _user.value = FirebaseAuth.instance.currentUser;
        successMessage.value = "Profil berhasil diperbarui!";
      }
    } on FirebaseAuthException catch (e) {
      errorMessage.value = e.message ?? "Gagal update profil";
    } catch (e) {
      errorMessage.value = "Terjadi kesalahan saat update profil";
    } finally {
      isLoading(false);
    }
  }
}
