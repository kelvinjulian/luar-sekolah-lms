// lib/main.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

// --- VERIFIKASI IMPORT ---
import 'app/core/routes/app_routes.dart';
// -------------------------

void main() {
  runApp(const LmsApp());
}

class LmsApp extends StatelessWidget {
  const LmsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'LMS App (Clean Architecture)',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        appBarTheme: const AppBarTheme(
          elevation: 1.0,
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
        ),
      ),
      // Rute awal sekarang adalah '/login' (diambil dari AppPages.INITIAL)
      initialRoute: AppPages.INITIAL,
      // Ambil semua halaman dari AppPages
      getPages: AppPages.pages,
    );
  }
}
