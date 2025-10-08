import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

// Kita import widget CustomCards yang isinya widget-widget lain seperti
// CarouselBanner, ProgramCard, RedeemVoucherCard, CourseCard, SubscriptionCard.
// Tujuannya supaya file ini (HomePage) tetap rapi dan tidak kepanjangan.
import '../widgets/custom_cards.dart';

// Definisi warna global supaya bisa dipakai berulang tanpa harus tulis kode warna panjang.
const Color lsGreen = Color(0xFF0DA680); // hijau utama app
const Color backgroundLight = Color(0xFFFAFAFA); // background putih abu
const Color tagBlue = Color.fromARGB(255, 37, 146, 247); // biru untuk label/tag
const Color tagGreen = Color(0xFF0DA680); // hijau untuk label/tag

// Data list untuk carousel (banner iklan). Bentuknya list gambar.
const List<String> promoBanners = [
  "assets/images/banner1.png",
  "assets/images/banner1.png",
  "assets/images/banner1.png",
];

// HomePage adalah halaman utama, Stateful karena ada perubahan state (misalnya slider geser).
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // State untuk melacak halaman banner yang sedang aktif
  int _currentPage = 0;

  // Controller untuk mengontrol PageView (carousel)
  final PageController _pageController = PageController(initialPage: 0);

  // Jangan lupa dispose controller biar tidak terjadi memory leak
  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // =============================
  // BAGIAN BUILD (UI utama layar)
  // =============================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lsGreen, // Scaffold warna hijau
      body: SafeArea(
        child: Column(
          children: [
            // ----------------------------
            // HEADER: Avatar + Greeting + Bell Icon
            // ----------------------------
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Kiri: avatar + teks sapaan
                  Row(
                    children: [
                      const CircleAvatar(
                        backgroundImage: AssetImage("assets/images/avatar.jpg"),
                        radius: 24,
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            "Halo,",
                            style: TextStyle(fontSize: 16, color: Colors.white),
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
            // KONTEN UTAMA (dengan background putih #FAFAFA)
            // ----------------------------
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: backgroundLight,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(18),
                    topRight: Radius.circular(18),
                  ),
                ),
                child: ListView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 24,
                  ),
                  children: [
                    // ========================
                    // CAROUSEL BANNER
                    // ========================
                    // Di sini kita panggil widget "CarouselBanner"
                    // Widget ini menerima pageController, daftar gambar, dan currentPage
                    // Di dalam widget CarouselBanner, logikanya adalah menampilkan PageView
                    // dengan gambar yang bisa discroll kiri kanan.
                    CarouselBanner(
                      pageController: _pageController,
                      banners: promoBanners,
                      currentPage: _currentPage,
                      onPageChanged: (index) {
                        setState(() {
                          _currentPage = index; // update state saat user geser
                        });
                      },
                    ),
                    const SizedBox(height: 34),

                    // ========================
                    // PROGRAM DARI LUARSEKOLAH
                    // ========================
                    const Text(
                      "Program dari Luarsekolah",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Di sini kita panggil widget "ProgramCard"
                    // ProgramCard adalah widget kecil untuk menampilkan logo + nama program.
                    // Kita kirim parameter "label" dan "icon".
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ProgramCard(
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
                            child: SvgPicture.asset(
                              'assets/icons/magang-icon.svg',
                            ),
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
                    // REDEEM VOUCHER
                    // ========================
                    // Di sini kita panggil widget "RedeemVoucherCard"
                    // Widget ini menerima parameter logo dan teks yang sudah diatur di dalam widget.
                    RedeemVoucherCard(
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
                    // KELAS TERPOPULER
                    // ========================
                    const Text(
                      "Kelas Terpopuler di Prakerja",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Di sini kita panggil widget "CourseCard"
                    // Widget ini menampilkan 1 card kursus: gambar, judul, harga, rating, dan tag.
                    SizedBox(
                      height: 250,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          CourseCard(
                            title: "Teknik Pemilahan dan Pengolahan Sampah",
                            price: "Rp 1.500.000",
                            rating: 4.5,
                            tags: const ["Prakerja", "SPL"],
                            tagColors: const [tagBlue, tagGreen],
                            image: "assets/images/course1.png",
                          ),
                          const SizedBox(width: 12),
                          CourseCard(
                            title:
                                "Meningkatkan Pertumbuhan Tanaman untuk Petani",
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
                    // SUBSCRIPTION CARD
                    // ========================
                    const Text(
                      "Akses Semua Kelas dengan Berlangganan",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Di sini kita panggil widget "SubscriptionCard"
                    // SubscriptionCard menampilkan paket berlangganan (gambar + judul + jumlah kelas).
                    SizedBox(
                      height: 220,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: const [
                          SubscriptionCard(
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
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      // ========================
      // BOTTOM NAVIGATION BAR
      // ========================
      // Ini widget bawaan Flutter untuk navigasi tab bawah
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: lsGreen,
        unselectedItemColor: Colors.grey,
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
