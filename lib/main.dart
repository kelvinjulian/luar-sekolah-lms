// lib/main.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:io';

// 1. Kita impor kedua state management
import 'package:provider/provider.dart';
import 'package:get/get.dart';

// 2. Impor 'otak' (ViewModel) dari Todo dan file router kita
import 'viewmodels/todo_viewmodel.dart';
import 'config/router.dart'; // Impor go_router

// Class MyHttpOverrides (Ini tetap sama, untuk atasi error SSL)
class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

void main() {
  HttpOverrides.global = MyHttpOverrides();

  // 3. Daftarkan Provider untuk 'Todo' di level tertinggi
  // Ini adalah kode asli Anda, dan kita biarkan seperti ini
  // agar TodoViewModel tetap berfungsi di seluruh aplikasi.
  runApp(
    ChangeNotifierProvider(
      create: (context) => TodoViewModel()..fetchTodos(),
      child: const LmsApp(), // Jalankan aplikasi utama kita
    ),
  );
}

class LmsApp extends StatelessWidget {
  const LmsApp({super.key});

  @override
  Widget build(BuildContext context) {
    // 4. Gunakan GetMaterialApp.router
    // Kita ganti MaterialApp.router menjadi GetMaterialApp.router
    // agar semua fitur GetX bisa aktif dan berfungsi.
    // GetMaterialApp ini menjadi 'child' dari ChangeNotifierProvider di atas.
    return GetMaterialApp.router(
      // 5. PERBAIKAN PENTING (Build Error Fix)
      // Awalnya kita pakai `routerConfig: router`, tapi itu bikin error.
      // Solusinya adalah memberikan 3 properti ini secara manual
      // agar GetX dan GoRouter bisa "berdamai".
      routeInformationProvider: router.routeInformationProvider,
      routeInformationParser: router.routeInformationParser,
      routerDelegate: router.routerDelegate,

      // Konfigurasi standar, tidak ada yang berubah
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        textTheme: GoogleFonts.beVietnamProTextTheme(),
        scaffoldBackgroundColor: const Color(0xFFFFFFFF),
      ),
    );
  }
}
