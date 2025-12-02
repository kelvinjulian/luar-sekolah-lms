import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../widgets/custom_cards.dart';
import '../../controllers/class_controller.dart';
import '../../../domain/entities/course.dart';
import './class_form_page.dart';

const Color lsGreen = Color(0xFF0DA680);

class ClassPage extends StatelessWidget {
  const ClassPage({super.key});

  Color _hexToColor(String hexCode) {
    // ... logic hex tetap sama ...
    final String cleanHex = hexCode.replaceAll(RegExp(r'[^0-9a-fA-F]'), '');
    String finalHex = cleanHex;
    if (cleanHex.length == 6) finalHex = 'FF$cleanHex';
    try {
      return Color(int.parse(finalHex, radix: 16));
    } catch (e) {
      return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final ClassController controller = Get.find<ClassController>();

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text(
            'Manajemen Kelas',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.white,
          elevation: 1.0,
          // 1. TAMBAH TOMBOL REFRESH DI KANAN ATAS
          actions: [
            IconButton(
              onPressed: () => controller.fetchCourses(isRefresh: true),
              icon: const Icon(Icons.refresh, color: lsGreen),
              tooltip: 'Refresh Data',
            ),
            const SizedBox(width: 8), // Jarak dikit dari pinggir
          ],
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
              Tab(text: 'Kelas Prakerja'),
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
            _buildClassList(context, controller),
          ],
        ),
      ),
    );
  }

  Widget _buildClassList(BuildContext context, ClassController controller) {
    return Column(
      children: [
        // ============================================================
        // BAGIAN 1: FIXED HEADER (Tidak ikut scroll)
        // ============================================================
        Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                offset: const Offset(0, 4),
                blurRadius: 4,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Tombol Tambah
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final result = await showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (ctx) => SizedBox(
                        height: MediaQuery.of(context).size.height * 0.85,
                        child: const ClipRRect(
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(20),
                          ),
                          child: ClassFormPage(),
                        ),
                      ),
                    );
                    if (result != null && result is Map<String, dynamic>) {
                      await controller.addClass(result);
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
              ),
              const SizedBox(height: 12),

              // 2. Search Bar
              TextField(
                onChanged: controller.updateSearchQuery,
                decoration: InputDecoration(
                  labelText: 'Cari nama kelas...',
                  prefixIcon: const Icon(Icons.search),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),

              // 3. Total Data
              const SizedBox(height: 8),
              Obx(
                () => Text(
                  "Total Data Terload: ${controller.filteredClasses.length}",
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ],
          ),
        ),

        // ============================================================
        // BAGIAN 2: SCROLLABLE LIST (Hanya kartu yang discroll)
        // ============================================================
        Expanded(
          child: NotificationListener<ScrollNotification>(
            onNotification: (ScrollNotification scrollInfo) {
              if (!controller.isMoreLoading.value &&
                  scrollInfo.metrics.pixels >=
                      scrollInfo.metrics.maxScrollExtent - 50) {
                controller.loadMoreCourses();
              }
              return true;
            },
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              final List<Course> classes = controller.filteredClasses;

              if (classes.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.search_off, size: 60, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      const Text('Tidak ada kelas ditemukan'),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount:
                    classes.length + (controller.isMoreLoading.value ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == classes.length) {
                    return const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }

                  final course = classes[index];
                  final List<Color> tagColors = course.tagColorsHex
                      .map((hex) => _hexToColor(hex))
                      .toList();

                  return AdminCourseCard(
                    title: course.nama,
                    image: course.thumbnail,
                    tags: course.tags,
                    tagColors: tagColors,
                    price: "Rp ${course.harga}",
                    onEdit: () async {
                      final result = await showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (ctx) => SizedBox(
                          height: MediaQuery.of(context).size.height * 0.85,
                          child: ClipRRect(
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(20),
                            ),
                            child: ClassFormPage(initialData: course.toMap()),
                          ),
                        ),
                      );
                      if (result != null && result is Map<String, dynamic>) {
                        await controller.updateClass(result);
                      }
                    },
                    onDelete: () =>
                        controller.showDeleteConfirmation(context, course),
                  );
                },
              );
            }),
          ),
        ),
      ],
    );
  }
}
