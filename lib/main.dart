// lib/main.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:io';

// 1. Import Provider dan GetX
import 'package:provider/provider.dart';
import 'package:get/get.dart';

// 2. Import ViewModel (Provider) dan Router
// Pastikan path ini benar sesuai struktur folder Anda
import 'viewmodels/todo_viewmodel.dart';
import 'config/router.dart';

// Class MyHttpOverrides (Tetap sama)
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

  // 3. Daftarkan Provider untuk 'Todo' (seperti kode asli Anda)
  // Ini tidak akan kita ubah.
  runApp(
    ChangeNotifierProvider(
      create: (context) => TodoViewModel()..fetchTodos(),
      child: const LmsApp(), // Aplikasi utama
    ),
  );
}

class LmsApp extends StatelessWidget {
  const LmsApp({super.key});

  @override
  Widget build(BuildContext context) {
    // 4. Gunakan GetMaterialApp.router agar GetX bisa dipakai
    //    GetMaterialApp akan menjadi 'child' dari ChangeNotifierProvider
    return GetMaterialApp.router(
      // 5. PERBAIKAN untuk 'routerConfig' build error
      //    Gunakan 3 properti ini, BUKAN 'routerConfig'
      routeInformationProvider: router.routeInformationProvider,
      routeInformationParser: router.routeInformationParser,
      routerDelegate: router.routerDelegate,

      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        textTheme: GoogleFonts.beVietnamProTextTheme(),
        scaffoldBackgroundColor: const Color(0xFFFFFFFF),
      ),
    );
  }
}
