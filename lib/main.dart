// lib/main.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

// --- VERIFIKASI IMPORT ---
import 'app/core/routes/app_routes.dart';

import 'package:firebase_core/firebase_core.dart'; // <-- 1. IMPORT
import 'firebase_options.dart'; // <-- 2. IMPORT
// -------------------------

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Tambahkan try-catch agar error Firebase bisa terlihat
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print("✅ Firebase initialized successfully");
  } catch (e) {
    print("❌ Firebase init error: $e");
  }

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
