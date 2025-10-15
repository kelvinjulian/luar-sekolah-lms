import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Import file konfigurasi router Anda
import 'config/router.dart';

// Hapus import halaman individual dari main.dart
// karena sekarang diatur oleh router
// import 'pages/register_page.dart';

void main() {
  runApp(const LmsApp());
}

class LmsApp extends StatelessWidget {
  const LmsApp({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. Ubah MaterialApp menjadi MaterialApp.router
    return MaterialApp.router(
      // 2. Gunakan properti routerConfig untuk menghubungkan router Anda
      routerConfig: router,

      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        textTheme: GoogleFonts.beVietnamProTextTheme(),
        scaffoldBackgroundColor: const Color(0xFFFFFFFF),
      ),
      // 3. Properti 'home' dihapus karena halaman awal
      //    sekarang ditentukan oleh 'initialLocation' di dalam file router.
    );
  }
}
