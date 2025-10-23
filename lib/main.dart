// lib/main.dart

// 1. Import SSL & PROVIDER
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:io'; // Import untuk HttpOverrides
import 'package:provider/provider.dart'; // <-- IMPORT PROVIDER
import 'viewmodels/todo_viewmodel.dart'; // <-- IMPORT VIEWMODEL

// Import file konfigurasi router
import 'config/router.dart';

//? 2. CLASS UNTUK MEMPERBAIKI ERROR SSL
// ==========================================================
//* CLASS UNTUK MENGATASI ERROR SSL CERTIFICATE
// ==========================================================
class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}
// ==========================================================

void main() {
  //? 3. AKTIFKAN PERBAIKAN SSL
  HttpOverrides.global = MyHttpOverrides();

  //* ==========================================================
  //* --- BUNGKUS runApp DENGAN PROVIDER ---
  //* ==========================================================
  runApp(
    //? 4. BUAT VIEWMODEL SECARA GLOBAL
    ChangeNotifierProvider(
      // Kita buat ViewModel di sini agar global
      // dan langsung panggil fetchTodos() saat app pertama kali dibuka
      create: (context) => TodoViewModel()..fetchTodos(),
      child: const LmsApp(), // Aplikasi utama
    ),
  );
  // ==========================================================
}

class LmsApp extends StatelessWidget {
  const LmsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      //? Hubungkan ke router
      routerConfig: router,

      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        textTheme: GoogleFonts.beVietnamProTextTheme(),
        scaffoldBackgroundColor: const Color(0xFFFFFFFF),
      ),
    );
  }
}
