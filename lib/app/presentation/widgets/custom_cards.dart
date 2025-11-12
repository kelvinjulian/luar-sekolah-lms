// lib/widgets/custom_cards.dart

// Import library bawaan Flutter untuk membangun UI
import 'package:flutter/material.dart';

// =================================================================
// 0. DEFINISI WARNA GLOBAL
// =================================================================
// Di sini kita bikin warna konstan (static) biar gampang dipakai ulang
const Color lsGreen = Color(0xFF0DA680); // warna hijau utama aplikasi
const Color cardWhite = Colors.white; // warna putih untuk background kartu

// =================================================================
// 1. WIDGET CAROUSEL BANNER & INDICATOR
// =================================================================
// Widget ini menampilkan banner gambar yang bisa digeser (slide)
// plus indikator titik di bawahnya untuk menunjukkan posisi halaman.
class CarouselBanner extends StatelessWidget {
  // Controller untuk mengatur halaman PageView
  final PageController pageController;

  // Daftar gambar yang mau ditampilkan (alamat asset)
  final List<String> banners;

  // Halaman saat ini (untuk indikator aktif)
  final int currentPage;

  // Callback ketika halaman berubah
  final ValueChanged<int> onPageChanged;

  // Constructor untuk menerima data dari luar
  const CarouselBanner({
    super.key,
    required this.pageController,
    required this.banners,
    required this.currentPage,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Bagian banner (gambar geser)
        Container(
          height: 140,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6), // sudut melengkung
            color: cardWhite, // background putih
          ),
          child: PageView.builder(
            controller: pageController, // controller yang dipakai
            itemCount: banners.length, // jumlah gambar
            onPageChanged: onPageChanged, // ketika digeser, jalankan fungsi ini
            itemBuilder: (context, index) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(6), // melengkungkan gambar
                child: Image.asset(
                  banners[index], // ambil gambar sesuai index
                  fit: BoxFit.cover, // biar penuh sesuai container
                  width: double.infinity,
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 15), // jarak antar elemen
        // Bagian indikator titik-titik di bawah banner
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: banners.asMap().entries.map((entry) {
            return BannerIndicator(
              isActive: entry.key == currentPage, // aktif jika sesuai halaman
              activeColor: lsGreen, // warna aktif hijau
            );
          }).toList(),
        ),
      ],
    );
  }
}

// Widget kecil untuk indikator titik di bawah carousel
class BannerIndicator extends StatelessWidget {
  final bool isActive; // apakah titik ini aktif?
  final Color activeColor; // warna aktif

  const BannerIndicator({
    super.key,
    required this.isActive,
    required this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150), // animasi perubahan
      margin: const EdgeInsets.symmetric(horizontal: 4.0),
      height: 8.0,
      width: isActive ? 16.0 : 8.0, // jika aktif, titik melebar
      decoration: BoxDecoration(
        color: isActive ? activeColor : Colors.grey.shade300, // warna aktif/abu
        borderRadius: BorderRadius.circular(4), // sudut melengkung
      ),
    );
  }
}

// =================================================================
// 2. WIDGET REDEEM VOUCHER CARD
// =================================================================
// Kartu yang berisi logo, teks, dan tombol untuk redeem voucher Prakerja.
class RedeemVoucherCard extends StatelessWidget {
  final Widget? logo; // logo di sebelah kiri (opsional)

  const RedeemVoucherCard({super.key, this.logo});

  @override
  Widget build(BuildContext context) {
    const Color cardWhite = Colors.white;

    return Container(
      padding: const EdgeInsets.all(16), // jarak dalam
      decoration: BoxDecoration(
        color: cardWhite, // putih
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.grey.shade300), // border abu
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start, // sejajar ke atas
        children: [
          // Bagian logo di kiri
          if (logo != null) ...[
            logo!,
            const SizedBox(width: 12), // jarak logo ke teks
          ],

          // Bagian teks + tombol di kanan
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Redeem Voucher Prakerjamu",
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Kamu pengguna Prakerja? Segera redeem vouchermu sekarang juga",
                  style: TextStyle(fontSize: 13),
                ),
                const SizedBox(height: 12),

                // Tombol redeem
                SizedBox(
                  width: double.infinity, // tombol selebar container
                  child: OutlinedButton(
                    onPressed: () {}, // fungsi tombol
                    style: OutlinedButton.styleFrom(
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                      side: const BorderSide(color: Colors.black45, width: 1),
                    ),
                    child: const Text(
                      "Masukkan Voucher Prakerja",
                      style: TextStyle(
                        color: Colors.black87,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// =================================================================
// 3. WIDGET PROGRAM CARD (ikon + label)
// =================================================================
// Kartu kecil yang menampilkan 1 ikon + label di bawahnya
class ProgramCard extends StatelessWidget {
  final Widget icon; // ikon bisa SVG, Icon bawaan, atau gambar
  final String label; // teks di bawah ikon

  const ProgramCard({super.key, required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 75,
          height: 60,
          decoration: BoxDecoration(
            color: cardWhite,
            borderRadius: BorderRadius.circular(6),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.shade300,
                blurRadius: 6, // efek blur
                offset: const Offset(0, 2), // posisi bayangan
              ),
            ],
          ),
          child: Center(
            child: icon, // tampilkan ikon di tengah
          ),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontSize: 12)), // teks label
      ],
    );
  }
}

// =================================================================
// 4. WIDGET COURSE CARD (kursus dalam scroll horizontal)
// =================================================================
class CourseCard extends StatelessWidget {
  final String title; // judul kursus
  final String price; // harga kursus
  final double rating; // rating (contoh: 4.8)
  final List<String> tags; // daftar tag (misalnya: "UI", "Flutter")
  final List<Color> tagColors; // warna untuk setiap tag
  final String image; // gambar thumbnail kursus

  const CourseCard({
    super.key,
    required this.title,
    required this.price,
    required this.rating,
    required this.tags,
    required this.tagColors,
    required this.image,
  });

  @override
  Widget build(BuildContext context) {
    const Color cardWhite = Colors.white;

    return Container(
      width: 200, // lebar tetap
      decoration: BoxDecoration(
        color: cardWhite,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Gambar kursus
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
            child: Image.asset(
              image,
              height: 100,
              width: 200,
              fit: BoxFit.cover,
            ),
          ),
          // Bagian teks
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Tag kursus
                Wrap(
                  spacing: 4,
                  children: tags.asMap().entries.map((entry) {
                    final index = entry.key;
                    final tag = entry.value;
                    final tagColor = index < tagColors.length
                        ? tagColors[index]
                        : Colors.grey; // default abu

                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: tagColor, // warna tag
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        tag,
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.white, // teks putih
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.star, size: 14, color: Colors.orange),
                    const SizedBox(width: 4),
                    Text("$rating", style: const TextStyle(fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  price,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// =================================================================
// 5. WIDGET SUBSCRIPTION CARD
// =================================================================
// Kartu untuk langganan, menampilkan gambar + jumlah kelas + judul
class SubscriptionCard extends StatelessWidget {
  final String title; // judul langganan
  final String image; // gambar banner
  final int courses; // jumlah kelas

  const SubscriptionCard({
    super.key,
    required this.title,
    required this.image,
    required this.courses,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Bagian gambar
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
            child: Image.asset(
              image,
              height: 120,
              width: 220,
              fit: BoxFit.cover,
            ),
          ),
          // Jumlah kelas
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              "$courses Kelas Pembelajaran",
              style: const TextStyle(fontSize: 12),
            ),
          ),
          // Judul langganan
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

// TODO
// =================================================================
// 6. WIDGET ADMIN COURSE CARD (UNTUK HALAMAN KELAS ADMIN)
// =================================================================
// Kartu ini mirip dengan CourseCard, tapi dengan tambahan tombol aksi
// seperti Edit dan Delete untuk keperluan admin.
class AdminCourseCard extends StatelessWidget {
  final String title;
  final String image;
  final List<String> tags;
  final List<Color> tagColors;
  final String price;
  final VoidCallback onEdit; // Fungsi yang dipanggil saat 'Edit' diklik
  final VoidCallback onDelete; // Fungsi yang dipanggil saat 'Delete' diklik

  const AdminCourseCard({
    super.key,
    required this.title,
    required this.image,
    required this.tags,
    required this.tagColors,
    required this.price,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12.0),
      margin: const EdgeInsets.only(bottom: 16.0), // Jarak antar kartu
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Gambar Thumbnail di kiri
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Image.asset(image, width: 80, height: 80, fit: BoxFit.cover),
          ),
          const SizedBox(width: 12),

          // Informasi kelas di tengah (Expanded agar memenuhi sisa ruang)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: tags.asMap().entries.map((entry) {
                    final index = entry.key;
                    final tag = entry.value;
                    final color = tagColors.length > index
                        ? tagColors[index]
                        : Colors.grey;
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        tag,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 8),
                Text(
                  price,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: lsGreen,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),

          // Menu Aksi (tiga titik) di kanan
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'edit') {
                onEdit();
              } else if (value == 'delete') {
                onDelete();
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'edit',
                child: ListTile(
                  leading: Icon(Icons.edit_outlined, size: 20),
                  title: Text('Edit'),
                ),
              ),
              const PopupMenuItem<String>(
                value: 'delete',
                child: ListTile(
                  leading: Icon(
                    Icons.delete_outline,
                    size: 20,
                    color: Colors.red,
                  ),
                  title: Text('Delete', style: TextStyle(color: Colors.red)),
                ),
              ),
            ],
            icon: const Icon(Icons.more_vert, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
