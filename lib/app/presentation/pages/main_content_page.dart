import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

// Asumsi path ini benar, ini untuk widget-widget kartu custom
import '../widgets/custom_cards.dart';

// =========================
// DEFINISI WARNA & DATA STATIS (dipindahkan ke sini karena hanya dipakai di halaman ini)
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
// WIDGET KONTEN UTAMA HALAMAN BERANDA
// - Widget ini hanya berisi konten 'Beranda', tanpa Scaffold atau BottomNavBar.
// =================================================================
class MainContentPage extends StatefulWidget {
  const MainContentPage({super.key});

  @override
  State<MainContentPage> createState() => _MainContentPageState();
}

class _MainContentPageState extends State<MainContentPage> {
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
    return Column(
      children: [
        // ----------------------------
        // HEADER: Avatar + Greeting + Bell Icon
        // ----------------------------
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
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
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(18),
                topRight: Radius.circular(18),
              ),
            ),
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              children: [
                // ========================
                //* CAROUSEL BANNER
                // ========================
                CarouselBanner(
                  pageController: _pageController,
                  banners: promoBanners,
                  currentPage: _currentPage,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                  },
                ),
                const SizedBox(height: 34),

                // ========================
                //* PROGRAM DARI LUARSEKOLAH
                // ========================
                const Text(
                  "Program dari Luarsekolah",
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                ),
                const SizedBox(height: 12),
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
                //* REDEEM VOUCHER
                // ========================
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
                //* KELAS TERPOPULER
                // ========================
                const Text(
                  "Kelas Terpopuler di Prakerja",
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                ),
                const SizedBox(height: 12),
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
                //* SUBSCRIPTION CARD
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
