// lib/app/presentation/pages/course/class_page.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';

// --- VERIFIKASI IMPORT ---
import '../../widgets/custom_cards.dart';
import '../../controllers/class_controller.dart';
import '../../../domain/entities/course.dart';
import './class_form_page.dart';
// -------------------------

const Color lsGreen = Color(0xFF0DA680);

class ClassPage extends StatelessWidget {
  const ClassPage({super.key});

  //? --- PERBAIKAN DI SINI ---
  //? Fungsi ini sekarang diperbaiki untuk menghapus '0x'
  //? dengan benar sebelum mem-parsing warnanya.
  Color _hexToColor(String hexCode) {
    // 1. Bersihkan string dari prefiks yang umum
    final String cleanHex = hexCode
        .replaceAll('0x', '')
        .replaceAll('0X', '')
        .replaceAll('#', '');

    String finalHex;
    // 2. Cek panjangnya
    if (cleanHex.length == 6) {
      // Jika RRGGBB, tambahkan FF (alpha) di depan
      finalHex = 'FF$cleanHex';
    } else if (cleanHex.length == 8) {
      // Jika AARRGGBB, sudah benar
      finalHex = cleanHex;
    } else {
      // Format tidak dikenal, kembalikan abu-abu
      return Colors.grey;
    }

    // 3. Parse string hex menjadi integer
    try {
      return Color(int.parse(finalHex, radix: 16));
    } catch (e) {
      // Jika parsing gagal, kembalikan abu-abu
      return Colors.grey;
    }
  }
  //? --------------------------

  @override
  Widget build(BuildContext context) {
    // 1. 'Get.find()' menemukan Controller yang sudah di-inject oleh Binding
    final ClassController controller = Get.find<ClassController>();

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: Colors.white, // <-- Background putih (sesuai request)
        appBar: AppBar(
          title: const Text(
            'Manajemen Kelas',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.white,
          elevation: 1.0,
          bottom: TabBar(
            onTap: controller.updateTab, // Hubungkan ke controller
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            labelColor: lsGreen,
            unselectedLabelColor: Colors.grey,
            indicatorColor: lsGreen,
            tabs: const [
              Tab(text: 'Kelas Terpopuler'),
              Tab(text: 'Kelas SPL'),
              Tab(text: 'Kelas Lainnya'),
            ],
          ),
        ),
        body: TabBarView(
          // Matikan swipe agar controller jadi sumber data utama
          physics: const NeverScrollableScrollPhysics(),
          children: [
            _buildClassList(context, controller),
            _buildClassList(context, controller),
            _buildClassList(context, controller),
          ],
        ),
      ),
    );
  }

  // Widget yang membangun isi dari setiap tab
  Widget _buildClassList(BuildContext context, ClassController controller) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        // ======================
        //* Tombol Tambah Kelas
        // ======================
        ElevatedButton.icon(
          onPressed: () async {
            final result = await showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (BuildContext sheetContext) {
                return Container(
                  height: MediaQuery.of(context).size.height * 0.85,
                  child: const ClipRRect(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20.0),
                      topRight: Radius.circular(20.0),
                    ),
                    // ClassFormPage tidak perlu diubah, sudah benar
                    child: ClassFormPage(), // (Mode 'Tambah')
                  ),
                );
              },
            );

            if (result != null && result is Map<String, dynamic>) {
              // Panggil fungsi controller (yang akan memanggil use case)
              await controller.addClass(result);

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Kelas baru berhasil ditambahkan!'),
                  backgroundColor: Colors.green,
                ),
              );
            }
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

        // ======================
        //* Search Bar
        // ======================
        Padding(
          padding: const EdgeInsets.only(bottom: 20.0),
          child: TextField(
            onChanged: controller.updateSearchQuery,
            decoration: InputDecoration(
              labelText: 'Cari nama kelas...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),

        // ======================
        //* WIDGET REAKTIF UTAMA
        // ======================
        Obx(() {
          // Tampilkan loading jika data masih diambil
          if (controller.isLoading.value && controller.allClasses.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(32.0),
                child: CircularProgressIndicator(),
              ),
            );
          }

          final List<Course> classes = controller.filteredClasses;

          // Tampilkan empty state jika hasil filter/pencarian kosong
          if (classes.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 50.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.search_off, size: 60, color: Colors.grey[400]),
                    const SizedBox(height: 16),
                    const Text(
                      'Tidak ada kelas ditemukan',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text(
                      'Coba ubah filter atau kata kunci pencarian Anda.',
                      style: TextStyle(color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }

          // Tampilkan list data
          return Column(
            children: [
              ...classes.map((course) {
                // Konversi String Hex (dari Domain) ke Color (untuk UI)
                // Sekarang ini akan berfungsi dengan benar
                final List<Color> tagColors = course.tagColorsHex
                    .map((hex) => _hexToColor(hex))
                    .toList();

                return AdminCourseCard(
                  title: course.nama,
                  image: course.thumbnail,
                  tags: course.tags,
                  tagColors: tagColors, // Kirim List<Color>
                  price: "Rp ${course.harga}",
                  onEdit: () async {
                    final result = await showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (BuildContext sheetContext) {
                        return Container(
                          height: MediaQuery.of(context).size.height * 0.85,
                          child: ClipRRect(
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(20.0),
                              topRight: Radius.circular(20.0),
                            ),
                            child: ClassFormPage(
                              initialData: course.toMap(),
                            ), // (Mode Edit)
                          ),
                        );
                      },
                    );

                    if (result != null && result is Map<String, dynamic>) {
                      await controller.updateClass(result);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Perubahan berhasil disimpan!'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  },
                  onDelete: () {
                    // Panggil fungsi di controller dan kirim 'context'
                    controller.showDeleteConfirmation(context, course);
                  },
                );
              }),
            ],
          );
        }),
      ],
    );
  }
}
