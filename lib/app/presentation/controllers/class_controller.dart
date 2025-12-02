import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../domain/entities/course.dart';
import '../../domain/usecases/course/add_course.dart';
import '../../domain/usecases/course/delete_course.dart';
import '../../domain/usecases/course/get_all_courses.dart';
import '../../domain/usecases/course/update_course.dart';

class ClassController extends GetxController {
  final GetAllCoursesUseCase getAllCoursesUseCase;
  final AddCourseUseCase addCourseUseCase;
  final UpdateCourseUseCase updateCourseUseCase;
  final DeleteCourseUseCase deleteCourseUseCase;

  ClassController({
    required this.getAllCoursesUseCase,
    required this.addCourseUseCase,
    required this.updateCourseUseCase,
    required this.deleteCourseUseCase,
  });

  // State
  final isLoading = false.obs;
  final isMoreLoading = false.obs;
  final courseList = <Course>[].obs;
  final currentTabIndex = 0.obs;
  final searchQuery = "".obs;

  // Pagination Config
  final int _limit = 20;
  int _offset = 0;
  bool _hasMore = true;

  final ScrollController scrollController = ScrollController();

  @override
  void onInit() {
    super.onInit();
    fetchCourses(isRefresh: true);
  }

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }

  // --- LOGIKA FETCH DATA UTAMA ---
  Future<void> fetchCourses({bool isRefresh = false}) async {
    if (isRefresh) {
      isLoading(true);
      _offset = 0;
      _hasMore = true;
      courseList.clear();
      // Reset status load more juga biar aman
      isMoreLoading(false);
    }
    // CATATAN: Logika isMoreLoading(true) dipindah ke loadMoreCourses
    // agar bisa di-lock SEBELUM delay.

    try {
      String? tagFilter;
      switch (currentTabIndex.value) {
        case 0:
          tagFilter = 'populer';
          break;
        case 1:
          tagFilter = 'spl';
          break;
        case 2:
          tagFilter = 'prakerja';
          break;
        case 3:
          tagFilter = null;
          break;
      }

      final newCourses = await getAllCoursesUseCase(
        limit: _limit,
        offset: _offset,
        tag: tagFilter,
      );

      if (newCourses.length < _limit) {
        _hasMore = false;
      }

      if (isRefresh) {
        courseList.assignAll(newCourses);
      } else {
        courseList.addAll(newCourses);
      }

      _offset += newCourses.length;
    } catch (e) {
      print("Error Fetch: $e");
      if (isRefresh) Get.snackbar("Error", "Gagal memuat data: $e");
    } finally {
      isLoading(false);
      isMoreLoading(false); // Buka kunci loading
    }
  }

  // --- PERBAIKAN BUG DATA RATUSAN (RACE CONDITION) ---
  Future<void> loadMoreCourses() async {
    // 1. CEK DULU: Jika sedang loading atau data habis, STOP.
    if (isLoading.value || isMoreLoading.value || !_hasMore) return;

    // 2. KUNCI SEGERA! (PENTING)
    // Ubah jadi true SEBELUM delay, supaya listener scroll tidak memanggil ulang.
    isMoreLoading(true);

    // 3. BARU DELAY (Efek visual)
    await Future.delayed(const Duration(seconds: 2));

    // 4. Panggil API (tanpa parameter isRefresh)
    // Kita panggil fungsi internal yang tidak mereset offset
    await fetchCourses(isRefresh: false);
  }

  void updateSearchQuery(String query) {
    searchQuery(query);
  }

  List<Course> get filteredClasses {
    if (searchQuery.value.isEmpty) {
      return courseList;
    } else {
      return courseList.where((course) {
        return course.nama.toLowerCase().contains(
          searchQuery.value.toLowerCase(),
        );
      }).toList();
    }
  }

  void updateTab(int index) {
    if (currentTabIndex.value != index) {
      currentTabIndex(index);
      searchQuery('');
      fetchCourses(isRefresh: true);
    }
  }

  // --- CRUD Functions (Dengan Snackbar Fix) ---

  Future<void> addClass(Map<String, dynamic> data) async {
    try {
      isLoading(true);
      File? imageFile;
      if (data['imageFile'] != null) imageFile = data['imageFile'] as File;
      int hargaInt = int.tryParse(data['harga'].toString()) ?? 0;

      final newCourse = Course(
        id: '',
        nama: data['nama'],
        harga: hargaInt,
        thumbnail: '',
        tags: List<String>.from(data['tags']),
        tagColorsHex: [],
      );

      await addCourseUseCase(newCourse, imageFile);
      await fetchCourses(isRefresh: true);

      Get.back(); // Tutup BottomSheet (jika belum tertutup)

      // Tampilkan Snackbar Sukses
      Get.snackbar(
        "Berhasil",
        "Kelas baru berhasil ditambahkan",
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM, // Coba di bawah biar jelas
        margin: const EdgeInsets.all(16),
      );
    } catch (e) {
      _showErrorSnackbar(e);
    } finally {
      isLoading(false);
    }
  }

  Future<void> updateClass(Map<String, dynamic> data) async {
    try {
      isLoading(true);
      File? imageFile;
      if (data['imageFile'] != null) imageFile = data['imageFile'] as File;
      int hargaInt = int.tryParse(data['harga'].toString()) ?? 0;

      final updatedCourse = Course(
        id: data['id'],
        nama: data['nama'],
        harga: hargaInt,
        thumbnail: data['thumbnail'] ?? '',
        tags: List<String>.from(data['tags']),
        tagColorsHex: [],
      );

      await updateCourseUseCase(updatedCourse, imageFile);
      await fetchCourses(isRefresh: true);

      // FIX SNACKBAR TIDAK MUNCUL
      Get.snackbar(
        "Berhasil",
        "Data kelas berhasil diperbarui",
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      );
    } catch (e) {
      _showErrorSnackbar(e);
    } finally {
      isLoading(false);
    }
  }

  Future<void> deleteClass(String id) async {
    try {
      await deleteCourseUseCase(id);

      // Hapus lokal dulu biar cepat responsnya di UI
      courseList.removeWhere((item) => item.id == id);

      Get.snackbar(
        "Terhapus",
        "Kelas berhasil dihapus",
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );

      // Opsional: fetch ulang untuk sinkronisasi total data
      // fetchCourses(isRefresh: true);
    } catch (e) {
      _showErrorSnackbar(e);
    }
  }

  void _showErrorSnackbar(Object e) {
    String errorMsg = e.toString().replaceAll('Exception:', '').trim();
    Get.snackbar(
      "Gagal",
      errorMsg,
      backgroundColor: Colors.red[100],
      colorText: Colors.red[900],
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
    );
  }

  void showDeleteConfirmation(BuildContext context, Course course) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Konfirmasi Hapus'),
          content: Text(
            'Apakah Anda yakin ingin menghapus kelas "${course.nama}"?',
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Batal'),
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Ya, Hapus'),
              onPressed: () {
                Navigator.of(dialogContext).pop(); // Tutup dialog dulu
                deleteClass(course.id); // Baru eksekusi hapus
              },
            ),
          ],
        );
      },
    );
  }
}
