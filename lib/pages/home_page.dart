// lib/pages/home_page.dart
import 'package:flutter/material.dart';

// Import halaman-halaman yang akan menjadi 'tab'
import 'main_content_page.dart';
import 'account_page.dart';
import 'class_page.dart';

// Import Halaman Todo List
import 'todo_list_page.dart';

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

  final List<Widget> _pages = <Widget>[
    const MainContentPage(), // 0
    const ClassPage(), // 1
    const Center(child: Text("Halaman Kelasku")), // 2
    const Center(child: Text("Halaman KoinLS")), // 3
    const TodoListPage(), //? 4 <-- Halaman Todo
    const AccountPage(), // 5
  ];

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
          children: _pages,
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
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt),
            label: "Todo", //? <-- Tab Baru
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Akun"),
        ],
      ),
    );
  }
}
