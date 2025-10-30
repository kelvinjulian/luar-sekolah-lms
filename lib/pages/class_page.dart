// lib/pages/class_page.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart'; // Tetap perlukan GetX untuk Obx dan Controller
import '../widgets/custom_cards.dart';
import '../controllers/class_controller.dart';
import '../models/course_model.dart';
import 'class_form_page.dart';

const Color lsGreen = Color(0xFF0DA680);

class ClassPage extends StatelessWidget {
  const ClassPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ClassController controller = Get.put(ClassController());

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          // ... (AppBar Anda tetap sama) ...
          title: const Text(
            'Manajemen Kelas',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.white,
          elevation: 1.0,
          bottom: TabBar(
            onTap: controller.updateTab,
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
                    child: ClassFormPage(),
                  ),
                );
              },
            );

            //? PERBAIKAN: Tampilkan SnackBar DI SINI
            if (result != null && result is Map<String, dynamic>) {
              controller.addClass(result);
              // Tampilkan notifikasi setelah sheet tertutup
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Kelas baru berhasil ditambahkan!'),
                  backgroundColor: Colors.green,
                ),
              );
            }
          },
          // ... (Style tombol tetap sama)
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

        // ... (Search Bar tetap sama) ...
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

        // ... (Obx, Empty State tetap sama) ...
        Obx(() {
          final List<CourseModel> classes = controller.filteredClasses;

          if (classes.isEmpty) {
            return Center(
              // ... (Kode Empty State tetap sama)
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

          // Daftar Kelas
          return Column(
            children: [
              ...classes.map((course) {
                return AdminCourseCard(
                  title: course.nama,
                  image: course.thumbnail,
                  tags: course.tags,
                  tagColors: course.tagColors,
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
                            child: ClassFormPage(initialData: course.toMap()),
                          ),
                        );
                      },
                    );

                    //? PERBAIKAN: Tampilkan SnackBar DI SINI
                    if (result != null && result is Map<String, dynamic>) {
                      controller.updateClass(result);
                      // Tampilkan notifikasi setelah sheet tertutup
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Perubahan berhasil disimpan!'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  },
                  onDelete: () {
                    controller.showDeleteConfirmation(course);
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
