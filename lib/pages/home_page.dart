import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
// import 'package:shared_preferences/shared_preferences.dart'; // Sudah tidak dipakai di sini
import 'account_page.dart'; // Import halaman Akun, buat kalau user klik tab Akun
// Asumsi path ini benar, ini buat kartu-kartu custom di halaman Home
import '../widgets/custom_cards.dart';

// =========================
// DEFINISI WARNA & DATA STATIS
// =========================
const Color lsGreen = Color(0xFF0DA680); // Warna hijau utama app
const Color backgroundLight = Color(0xFFFAFAFA); // Warna background putih muda
const Color tagBlue = Color.fromARGB(255, 37, 146, 247); // Warna biru untuk tag
const Color tagGreen = Color(0xFF0DA680); // Warna hijau lagi untuk tag

const List<String> promoBanners = [
  "assets/images/banner1.png",
  "assets/images/banner1.png",
  "assets/images/banner1.png",
];

// =================================================================
// 1. WIDGET BARU: MainContentWidget (Konten Halaman Beranda)
//    - Ini adalah konten yang akan ditampilkan saat index 0 dipilih.
// =================================================================
class MainContentWidget extends StatefulWidget {
  const MainContentWidget({super.key});

  @override
  State<MainContentWidget> createState() => _MainContentWidgetState();
}

class _MainContentWidgetState extends State<MainContentWidget> {
  // State untuk melacak banner carousel yang sedang aktif
  int _currentPage = 0;
  final PageController _pageController = PageController(initialPage: 0);

  @override
  void dispose() {
    // Penting! Harus dibersihkan biar nggak error saat widget hilang
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //! Ingat! Widget ini hanya isinya Body, dia tidak pakai Scaffold lagi
    return Column(
      children: [
        // ----------------------------
        // HEADER: Avatar + Greeting + Bell Icon
        // ----------------------------
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceBetween, // Rata kiri dan kanan
            children: [
              //? Kiri: avatar + teks sapaan
              Row(
                children: [
                  const CircleAvatar(
                    backgroundImage: AssetImage(
                      "assets/images/avatar.jpg",
                    ), // Foto profil
                    radius: 24,
                  ),
                  const SizedBox(width: 12), // Jarak horizontal
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        "Halo,",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                        ), // Teks putih karena background-nya hijau
                      ),
                      SizedBox(height: 2),
                      Text(
                        "Ahmad Sahroni 👋",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              // Kanan: ikon notifikasi
              IconButton(
                onPressed: () {},
                icon: const Icon(
                  Icons.notifications_outlined,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),

        // ----------------------------
        //* KONTEN UTAMA (Body dengan background putih)
        // ----------------------------
        Expanded(
          child: Container(
            decoration: const BoxDecoration(
              color: backgroundLight,
              // Kasih sudut melengkung di bagian atas
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(18),
                topRight: Radius.circular(18),
              ),
            ),
            // ListView agar konten di bawah bisa di-scroll
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              children: [
                // ========================
                //* CAROUSEL BANNER (Iklan/Promo)
                // ========================
                CarouselBanner(
                  // Asumsi Widget ini sudah ada
                  pageController: _pageController,
                  banners: promoBanners,
                  currentPage: _currentPage,
                  onPageChanged: (index) {
                    setState(() {
                      // Update state agar indikator banner ikut berubah
                      _currentPage = index;
                    });
                  },
                ),
                const SizedBox(height: 34),

                // ========================
                //* PROGRAM DARI LUARSEKOLAH (Tombol-tombol navigasi program)
                // ========================
                const Text(
                  "Program dari Luarsekolah",
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceBetween, // Jarak antar tombol sama
                  children: [
                    ProgramCard(
                      // Asumsi Widget ini sudah ada
                      label: "Prakerja",
                      icon: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: SvgPicture.asset(
                          'assets/icons/prakerja-icon.svg',
                        ),
                      ),
                    ),
                    ProgramCard(
                      label: "magang+",
                      icon: Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: SvgPicture.asset('assets/icons/magang-icon.svg'),
                      ),
                    ),
                    ProgramCard(
                      label: "Subs",
                      icon: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: SvgPicture.asset(
                          'assets/icons/luarsekolah-icon.svg',
                        ),
                      ),
                    ),
                    ProgramCard(
                      label: "Lainnya",
                      icon: Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: SvgPicture.asset(
                          'assets/icons/lainnya-icon.svg',
                          width: 20,
                          height: 20,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // ========================
                //* REDEEM VOUCHER (Kartu promosi)
                // ========================
                RedeemVoucherCard(
                  // Asumsi Widget ini sudah ada
                  logo: Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: SvgPicture.asset(
                      'assets/icons/handphone-icon.svg',
                      width: 48,
                      height: 48,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // ========================
                //* KELAS TERPOPULER (Horizontal Scroll)
                // ========================
                const Text(
                  "Kelas Terpopuler di Prakerja",
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 250,
                  child: ListView(
                    scrollDirection:
                        Axis.horizontal, // Bikin bisa digeser ke samping
                    children: [
                      CourseCard(
                        // Asumsi Widget ini sudah ada
                        title: "Teknik Pemilahan dan Pengolahan Sampah",
                        price: "Rp 1.500.000",
                        rating: 4.5,
                        tags: const ["Prakerja", "SPL"],
                        tagColors: const [tagBlue, tagGreen],
                        image: "assets/images/course1.png",
                      ),
                      const SizedBox(width: 12),
                      CourseCard(
                        title: "Meningkatkan Pertumbuhan Tanaman untuk Petani",
                        price: "Rp 1.500.000",
                        rating: 4.5,
                        tags: const ["Prakerja"],
                        tagColors: const [tagBlue],
                        image: "assets/images/course2.png",
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton(
                    onPressed: () {},
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      foregroundColor: tagBlue,
                    ),
                    child: const Text("Lihat Semua Kelas"),
                  ),
                ),

                const SizedBox(height: 24),

                // ========================
                //* SUBSCRIPTION CARD (Horizontal Scroll)
                // ========================
                const Text(
                  "Akses Semua Kelas dengan Berlangganan",
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 220,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: const [
                      SubscriptionCard(
                        // Asumsi Widget ini sudah ada
                        title: "Belajar SwiftUI Untuk Pembuatan Interface",
                        image: "assets/images/subscription1.png",
                        courses: 5,
                      ),
                      SizedBox(width: 12),
                      SubscriptionCard(
                        title: "Belajar Dart Untuk Pembuatan Aplikasi",
                        image: "assets/images/subscription2.png",
                        courses: 5,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton(
                    onPressed: () {},
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      foregroundColor: tagBlue,
                    ),
                    child: const Text("Lihat Semua"),
                  ),
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// =================================================================
//* 2. WIDGET HOME PAGE (Navigator Utama)
//*    - Ini adalah kerangka aplikasi yang mengatur perpindahan tab
// =================================================================
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

//! jadi alur perpindahan halamannya:
// 1. awalnya index 0 (Beranda) aktif, tampilkan MainContentWidget
// 2. kalau user klik tab Akun (index 4), ganti _selected
// index jadi 4, otomatis body ganti ke AccountPage
class _HomePageState extends State<HomePage> {
  // State untuk melacak halaman yang sedang aktif di BottomNavBar
  int _selectedIndex = 0; // Index 0 = Beranda (default)

  // Daftar semua widget/halaman yang akan ditampilkan di BottomNavBar
  final List<Widget> _pages = <Widget>[
    // Index 0: Beranda
    const MainContentWidget(),
    // Index 1-3: Placeholder
    const Center(child: Text("Halaman Kelas")),
    const Center(child: Text("Halaman Kelasku")),
    const Center(child: Text("Halaman KoinLS")),
    // Index 4: Akun (Tujuan kita!)
    const AccountPage(),
  ];

  //! Fungsi yang dipanggil saat item di BottomNavBar diklik
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index; // Update index, dan Flutter otomatis ganti body
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Background Scaffold: hijau kalau di Beranda (index 0), putih kalau di tab lain
      backgroundColor: _selectedIndex == 0 ? lsGreen : backgroundLight,

      //! Tampilkan widget di body sesuai index yang dipilih
      body: SafeArea(
        // SafeArea biar konten nggak ketutup notch atau status bar HP
        child: _pages.elementAt(_selectedIndex),
      ),

      // BOTTOM NAVIGATION BAR (Ini yang selalu muncul)
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed, // Biar semua ikon tetap kelihatan
        currentIndex:
            _selectedIndex, // Kasih tahu nav bar, index mana yang aktif
        onTap: _onItemTapped, // Panggil fungsi saat tab diklik
        selectedItemColor: lsGreen, // Warna hijau saat tab aktif
        unselectedItemColor: Colors.grey, // Warna abu-abu saat tab tidak aktif

        backgroundColor:
            Colors.white, // Warna latar belakang navbar harus putih
        items: const [
          // Item 0
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Beranda"),
          // Item 1
          BottomNavigationBarItem(icon: Icon(Icons.book), label: "Kelas"),
          // Item 2
          BottomNavigationBarItem(icon: Icon(Icons.school), label: "Kelasku"),
          // Item 3
          BottomNavigationBarItem(icon: Icon(Icons.payment), label: "KoinLS"),
          // Item 4: Akun
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Akun"),
        ],
      ),
    );
  }
}
