// lib/app/presentation/pages/splash_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    //? --- PERBAIKAN: Gunakan Get.find() ---
    //? Ini "membangunkan" AuthController yang sudah di-lazyPut oleh AuthBinding.
    //? Ini HANYA perlu dipanggil untuk memastikan onInit/onReady-nya berjalan.
    Get.find<AuthController>();

    //? --- PERBAIKAN: Hapus StreamBuilder ---
    //? Kita tidak perlu StreamBuilder lagi karena AuthController
    //? sekarang menangani navigasi secara global.
    return const Scaffold(
      backgroundColor: Colors.white,
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
