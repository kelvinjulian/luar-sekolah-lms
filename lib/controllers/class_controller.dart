// lib/controllers/class_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/course_model.dart'; // Impor model

class ClassController extends GetxController {
  // --- STATE DATA ASLI (DATABASE LOKAL) ---
  final RxList<CourseModel> allClasses = <CourseModel>[
    CourseModel(
      id: '1',
      nama: "Teknik Pemilahan dan Pengolahan Sampah",
      harga: "1500000",
      thumbnail: "assets/images/course1.png",
      tags: ["Prakerja", "SPL"],
      tagColors: [tagBlue, tagGreen],
    ),
    CourseModel(
      id: '2',
      nama: "Meningkatkan Pertumbuhan Tanaman untuk Petani Terampil",
      harga: "1500000",
      thumbnail: "assets/images/course2.png",
      tags: ["Prakerja"],
      tagColors: [tagBlue],
    ),
    CourseModel(
      id: '3',
      nama: "Kursus Public Speaking",
      harga: "1000000",
      thumbnail: "assets/images/course1.png", // Ganti gambar jika ada
      tags: ["Lainnya"], // Kategori lain untuk tes filter
      tagColors: [Colors.purple],
    ),
  ].obs;

  // --- STATE BARU UNTUK FILTER DAN SEARCH ---
  final RxInt currentTabIndex = 0.obs;
  final RxString searchQuery = "".obs;

  // --- GETTER REAKTIF (COMPUTED PROPERTY) ---
  // Ini adalah inti fungsionalitas. UI akan otomatis update
  // setiap kali 'allClasses', 'currentTabIndex', atau 'searchQuery' berubah.
  List<CourseModel> get filteredClasses {
    List<CourseModel> list = allClasses;

    // 1. Filter berdasarkan Tab
    if (currentTabIndex.value == 1) {
      // Tab "Kelas SPL"
      list = list.where((course) => course.tags.contains("SPL")).toList();
    } else if (currentTabIndex.value == 2) {
      // Tab "Kelas Lainnya"
      list = list
          .where(
            (course) =>
                !course.tags.contains("SPL") &&
                !course.tags.contains("Prakerja"),
          )
          .toList();
    }
    // (Tab 0 'Populer' kita anggap menampilkan semua untuk saat ini)

    // 2. Filter berdasarkan Search Query
    if (searchQuery.value.isNotEmpty) {
      list = list
          .where(
            (course) => course.nama.toLowerCase().contains(
              searchQuery.value.toLowerCase(),
            ),
          )
          .toList();
    }

    return list;
  }

  // --- FUNGSI AKSI BARU ---
  void updateTab(int index) {
    currentTabIndex(index);
  }

  void updateSearchQuery(String query) {
    searchQuery(query);
  }

  // --- FUNGSI CRUD (TETAP SAMA) ---
  void addClass(Map<String, dynamic> newClassData) {
    final newCourse = CourseModel.fromMap(newClassData);
    allClasses.add(newCourse);
  }

  void updateClass(Map<String, dynamic> updatedClassData) {
    final updatedCourse = CourseModel.fromMap(updatedClassData);
    final index = allClasses.indexWhere((item) => item.id == updatedCourse.id);
    if (index != -1) {
      allClasses[index] = updatedCourse; // Ganti item di list
    }
  }

  void deleteClass(String id) {
    allClasses.removeWhere((item) => item.id == id);
  }

  void showDeleteConfirmation(CourseModel course) {
    Get.dialog(
      AlertDialog(
        title: const Text('Konfirmasi Hapus'),
        content: Text(
          'Apakah Anda yakin ingin menghapus kelas "${course.nama}"?',
        ),
        actions: <Widget>[
          TextButton(child: const Text('Batal'), onPressed: () => Get.back()),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Ya, Hapus'),
            onPressed: () {
              deleteClass(course.id);
              Get.back();
            },
          ),
        ],
      ),
    );
  }
}
