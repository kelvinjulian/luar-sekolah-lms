// lib/pages/home_page.dart
import 'package:flutter/material.dart';

// Import halaman-halaman yang akan menjadi 'tab'
import 'main_content_page.dart';
import 'account_page.dart';
import 'class_page.dart'; // Halaman "Kelas" (GetX) kita yang baru
import 'todo_list_page.dart'; // Halaman "Todo" (Provider) kita yang lama

// Definisi Warna
const Color lsGreen = Color(0xFF0DA680);
const Color backgroundLight = Color(0xFFFAFAFA);

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  late PageController _pageController;

  //? --- PERUBAHAN PENTING ADA DI SINI ---
  final List<Widget> _pages = <Widget>[
    const MainContentPage(), // 0. Halaman statis, boleh pakai 'const'
    // 1. PENTING: Kita HAPUS 'const' dari ClassPage()
    // Kenapa? Halaman 'ClassPage' sekarang menggunakan GetX dan bersifat REAKTIF.
    // Widget yang reaktif tidak boleh 'const' (konstan/tetap).
    ClassPage(),

    const Center(child: Text("Halaman Kelasku")), // 2
    const Center(child: Text("Halaman KoinLS")), // 3
    // 4. Halaman Todo kita BIARKAN 'const'.
    // Kenapa? Karena dia pakai Provider yang state-nya diangkat ke main.dart.
    const TodoListPage(),

    const AccountPage(), // 5
  ];
  //? -----------------------------------

  // Sisa file ini adalah logika standar untuk BottomNavigationBar
  // dan PageView, tidak ada yang diubah.

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _selectedIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
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
      body: SafeArea(
        child: PageView(
          controller: _pageController,
          onPageChanged: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          children: _pages, // Menggunakan daftar halaman di atas
        ),
      ),
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
          BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: "Todo"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Akun"),
        ],
      ),
    );
  }
}
