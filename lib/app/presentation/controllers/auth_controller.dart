// lib/app/presentation/controllers/auth_controller.dart
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
    // Ikat stream ke variabel _user. Ini akan terus update
    _user.bindStream(authRepository.authStateChanges);
  }

  //? --- PERBAIKAN UTAMA ADA DI SINI ---
  // onReady() dijalankan SATU KALI setelah widget pertama di-render.
  // Ini adalah tempat teraman untuk navigasi awal.
  @override
  void onReady() {
    super.onReady();

    // 1. Jalankan handler navigasi dengan status user saat ini
    _handleAuthChanged(_user.value);

    // 2. Siapkan listener 'ever' HANYA untuk perubahan di MASA DEPAN
    //    (yaitu, saat user menekan tombol login atau logout manual)
    ever(_user, _handleAuthChanged);
  }

  // Fungsi yang menangani navigasi berdasarkan status login
  void _handleAuthChanged(User? user) {
    isLoading(false); // Selalu set loading false saat auth berubah

    if (user != null) {
      // Jika user login, dan kita TIDAK sedang di /home, pergi ke /home
      if (Get.currentRoute != '/home') {
        Get.offAllNamed('/home');
      }
    } else {
      // Jika user logout, dan kita TIDAK sedang di /login, pergi ke /login
      if (Get.currentRoute != '/login') {
        Get.offAllNamed('/login');
      }
    }
  }

  // --- FUNGSI AKSI (LOGIN/REGISTER/LOGOUT) ---

  Future<void> login(String email, String password) async {
    try {
      isLoading(true);
      await loginUseCase(email, password);
      // Navigasi akan di-handle oleh 'ever' + '_handleAuthChanged'
    } on FirebaseAuthException catch (e) {
      isLoading(false);
      Get.snackbar("Login Gagal", e.message ?? "Terjadi kesalahan");
    }
  }

  Future<void> register(String email, String password) async {
    try {
      isLoading(true);
      await registerUseCase(email, password);
      // Navigasi akan di-handle oleh 'ever' + '_handleAuthChanged'
    } on FirebaseAuthException catch (e) {
      isLoading(false);
      Get.snackbar("Register Gagal", e.message ?? "Terjadi kesalahan");

      if (e.code == 'email-already-in-use') {
        Get.toNamed('/login');
      }
    }
  }

  Future<void> logout() async {
    try {
      isLoading(true);
      await logoutUseCase();
      // Navigasi akan di-handle oleh 'ever' + '_handleAuthChanged'
    } on FirebaseAuthException catch (e) {
      isLoading(false);
      Get.snackbar("Logout Gagal", e.message ?? "Terjadi kesalahan");
    }
  }
}
