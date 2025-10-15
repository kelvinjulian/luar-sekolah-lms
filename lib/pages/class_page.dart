// lib/pages/kelas_page.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart'; // Jangan lupa import go_router
import '../widgets/custom_cards.dart'; // Import file kartu kustom Anda

// Definisi warna yang konsisten
const Color lsGreen = Color(0xFF0DA680);
const Color tagBlue = Color.fromARGB(255, 37, 146, 247);
const Color tagGreen = Color(0xFF0DA680);

class ClassPage extends StatelessWidget {
  const ClassPage({super.key});

  @override
  Widget build(BuildContext context) {
    // DefaultTabController mengatur state untuk TabBar dan TabBarView
    return DefaultTabController(
      length: 3, // Jumlah tab yang Anda inginkan
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Manajemen Kelas',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.white,
          elevation: 1.0,
          bottom: const TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            labelColor: lsGreen,
            unselectedLabelColor: Colors.grey,
            indicatorColor: lsGreen,
            tabs: [
              Tab(text: 'Kelas Terpopuler'),
              Tab(text: 'Kelas SPL'),
              Tab(text: 'Kelas Lainnya'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildClassList(context), // Konten Tab 1
            _buildClassList(context), // Konten Tab 2 (contoh)
            const Center(
              child: Text('Belum ada kelas lainnya'),
            ), // Konten Tab 3
          ],
        ),
      ),
    );
  }

  // Widget helper untuk membangun daftar kelas
  Widget _buildClassList(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        // Tombol Tambah Kelas
        ElevatedButton.icon(
          onPressed: () {
            // TODO MODIFIKASI: Navigasi untuk "Tambah Kelas"
            // Kita panggil rute '/class/form' tanpa mengirim data 'extra'.
            // Ini akan membuat ClassFormPage berjalan dalam mode "Tambah".
            context.push('/class/form');
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: lsGreen,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
          icon: const Icon(Icons.add),
          label: const Text('Tambah Kelas'),
        ),
        const SizedBox(height: 20),

        // Daftar kelas menggunakan widget AdminCourseCard
        AdminCourseCard(
          title: "Teknik Pemilahan dan Pengolahan Sampah",
          image: "assets/images/course1.png",
          tags: const ["Prakerja", "SPL"],
          tagColors: const [tagBlue, tagGreen],
          price: "Rp 1.500.000",
          onEdit: () {
            // TODO MODIFIKASI: Navigasi untuk "Edit Kelas"
            // 1. Siapkan data dari kelas ini dalam bentuk Map
            final classData = {
              'nama': "Teknik Pemilahan dan Pengolahan Sampah",
              'harga': "1500000", // Kirim sebagai string angka jika perlu
              'kategori': "SPL",
              'thumbnail': "assets/images/course1.png",
            };

            // 2. Panggil rute '/class/form' dan kirim 'classData'
            //    melalui parameter 'extra'.
            context.push('/class/form', extra: classData);
          },
          onDelete: () {
            // TODO Tampilkan dialog konfirmasi sebelum menghapus
            print("Delete Tapped");
          },
        ),
        AdminCourseCard(
          title: "Meningkatkan Pertumbuhan Tanaman untuk Petani Terampil",
          image: "assets/images/course2.png",
          tags: const ["Prakerja"],
          tagColors: const [tagBlue],
          price: "Rp 1.500.000",
          onEdit: () {
            // TODO MODIFIKASI: Lakukan hal yang sama untuk item lainnya
            final classData = {
              'nama': "Meningkatkan Pertumbuhan Tanaman untuk Petani Terampil",
              'harga': "1500000",
              'kategori': "Prakerja",
              'thumbnail': "assets/images/course2.png",
            };
            context.push('/class/form', extra: classData);
          },
          onDelete: () {},
        ),
      ],
    );
  }
}
