import 'dart:io'; // WAJIB ADA untuk File
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../widgets/custom_cards.dart';
import '../controllers/auth_controller.dart';

// WARNA & DATA STATIS
const Color lsGreen = Color(0xFF0DA680);
const Color backgroundLight = Color(0xFFFAFAFA);
const Color tagBlue = Color.fromARGB(255, 37, 146, 247);
const Color tagGreen = Color(0xFF0DA680);

const List<String> promoBanners = [
  "assets/images/banner1.png",
  "assets/images/banner1.png",
  "assets/images/banner1.png",
];

class MainContentPage extends StatefulWidget {
  const MainContentPage({super.key});

  @override
  State<MainContentPage> createState() => _MainContentPageState();
}

class _MainContentPageState extends State<MainContentPage> {
  int _currentPage = 0;
  final PageController _pageController = PageController(initialPage: 0);
  final AuthController authC = Get.find<AuthController>();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // HEADER
        Padding(
          padding: const EdgeInsets.only(
            top: 60,
            left: 24,
            right: 24,
            bottom: 24,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  // AVATAR SINKRON
                  Obx(() {
                    final user = authC.user;
                    final localPath = authC.localPhotoPath.value;

                    ImageProvider bgImage;
                    // Cek apakah ada foto lokal yang tersimpan
                    if (localPath != null && File(localPath).existsSync()) {
                      bgImage = FileImage(File(localPath));
                    } else if (user?.photoURL != null) {
                      bgImage = NetworkImage(user!.photoURL!);
                    } else {
                      bgImage = const AssetImage("assets/images/avatar.jpg");
                    }

                    return CircleAvatar(
                      radius: 24,
                      backgroundColor: Colors.white.withOpacity(0.2),
                      backgroundImage: bgImage,
                    );
                  }),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Halo,",
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                      const SizedBox(height: 2),
                      Obx(
                        () => Text(
                          "${authC.user?.displayName ?? "Pengguna"} 👋",
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                          overflow: TextOverflow.ellipsis,
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

        // KONTEN UTAMA
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
