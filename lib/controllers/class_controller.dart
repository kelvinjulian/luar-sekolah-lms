// lib/controllers/class_controller.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/course_model.dart';

class ClassController extends GetxController {
  // ... (Semua state dan fungsi lain seperti allClasses, filteredClasses, addClass, dll, tetap sama) ...
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
      thumbnail: "assets/images/course1.png",
      tags: ["Lainnya"],
      tagColors: [Colors.purple],
    ),
  ].obs;
  final RxInt currentTabIndex = 0.obs;
  final RxString searchQuery = "".obs;

  List<CourseModel> get filteredClasses {
    List<CourseModel> list = allClasses;
    if (currentTabIndex.value == 1) {
      list = list.where((course) => course.tags.contains("SPL")).toList();
    } else if (currentTabIndex.value == 2) {
      list = list
          .where(
            (course) =>
                !course.tags.contains("SPL") &&
                !course.tags.contains("Prakerja"),
          )
          .toList();
    }
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

  void updateTab(int index) {
    currentTabIndex(index);
  }

  void updateSearchQuery(String query) {
    searchQuery(query);
  }

  void addClass(Map<String, dynamic> newClassData) {
    final newCourse = CourseModel.fromMap(newClassData);
    allClasses.add(newCourse);
  }

  void updateClass(Map<String, dynamic> updatedClassData) {
    final updatedCourse = CourseModel.fromMap(updatedClassData);
    final index = allClasses.indexWhere((item) => item.id == updatedCourse.id);
    if (index != -1) {
      allClasses[index] = updatedCourse;
    }
  }

  void deleteClass(String id) {
    allClasses.removeWhere((item) => item.id == id);
  }

  //? --- PERBAIKAN DI SINI ---
  //? 1. Ubah fungsi agar menerima BuildContext
  void showDeleteConfirmation(BuildContext context, CourseModel course) {
    //? 2. Ganti 'Get.dialog' dengan 'showDialog' asli
    showDialog(
      context: context, // Gunakan context yang dikirim
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Konfirmasi Hapus'),
          content: Text(
            'Apakah Anda yakin ingin menghapus kelas "${course.nama}"?',
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Batal'),
              //? 3. Ganti 'Get.back()' dengan 'Navigator.pop'
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Ya, Hapus'),
              onPressed: () {
                deleteClass(course.id); // Panggil fungsi hapus
                //? 4. Ganti 'Get.back()' dengan 'Navigator.pop'
                Navigator.of(dialogContext).pop();
              },
            ),
          ],
        );
      },
    );
  }

  //? --------------------------
}
