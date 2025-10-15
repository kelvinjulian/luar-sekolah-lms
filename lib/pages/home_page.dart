import 'package:flutter/material.dart';

// Import halaman-halaman yang akan menjadi 'tab'
import 'main_content_page.dart';
import 'account_page.dart';
import 'class_page.dart';

// =========================
// DEFINISI WARNA
// =========================
const Color lsGreen = Color(0xFF0DA680);
const Color backgroundLight = Color(0xFFFAFAFA);

// =================================================================
//* WIDGET HOME PAGE (Navigator Utama dengan Animasi)
//* - Kerangka aplikasi yang mengatur perpindahan tab dengan PageView
// =================================================================
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  // TODO MODIFIKASI: Menambahkan PageController untuk mengontrol PageView
  late PageController _pageController;

  final List<Widget> _pages = <Widget>[
    const MainContentPage(),

    // TODO MODIFIKASI: Menambahkan halaman baru
    const ClassPage(),
    const Center(child: Text("Halaman Kelasku")),
    const Center(child: Text("Halaman KoinLS")),
    const AccountPage(),
  ];

  @override
  void initState() {
    super.initState();
    // Inisialisasi controller dengan halaman awal yang sesuai
    _pageController = PageController(initialPage: _selectedIndex);
  }

  @override
  void dispose() {
    // Controller harus di-dispose untuk mencegah memory leak
    _pageController.dispose();
    super.dispose();
  }

  // TODO MODIFIKASI: Fungsi ini sekarang juga mengontrol animasi PageController
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    // Memberitahu PageController untuk pindah ke halaman baru dengan animasi
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _selectedIndex == 0 ? lsGreen : backgroundLight,

      // TODO MODIFIKASI: Mengganti body dengan PageView untuk transisi yang mulus
      body: SafeArea(
        child: PageView(
          controller: _pageController,
          // onPageChanged akan terpanggil jika pengguna menggeser (swipe) halaman
          onPageChanged: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          // Menonaktifkan swipe jika Anda hanya ingin navigasi via tab
          // physics: const NeverScrollableScrollPhysics(),
          children: _pages,
        ),
      ),

      // BOTTOM NAVIGATION BAR (Tidak ada perubahan di sini)
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: lsGreen,
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Beranda"),
          BottomNavigationBarItem(icon: Icon(Icons.book), label: "Kelas"),
          BottomNavigationBarItem(icon: Icon(Icons.school), label: "Kelasku"),
          BottomNavigationBarItem(icon: Icon(Icons.payment), label: "KoinLS"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Akun"),
        ],
      ),
    );
  }
}
