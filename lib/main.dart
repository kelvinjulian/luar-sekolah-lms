import 'package:flutter/material.dart';
// import 'pages/home_page.dart';
// import 'pages/login_page.dart';
import 'pages/register_page.dart';

// import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const LmsApp());
}

class LmsApp extends StatelessWidget {
  const LmsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        // textTheme: GoogleFonts.robotoTextTheme(), // pakai google fonts roboto
        // textTheme: GoogleFonts.inclusiveSansTextTheme(), // pakai google fonts inclusive sans
        textTheme:
            GoogleFonts.beVietnamProTextTheme(), // pakai google fonts be vietnam pro
        scaffoldBackgroundColor: const Color(
          0xFFFFFFFF,
        ), // background global putih
      ),
      home: const RegisterPage(),
      // home: const HomePage(),
    );
  }
}
