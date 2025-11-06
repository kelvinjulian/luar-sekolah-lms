// lib/app/presentation/controllers/class_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

// --- VERIFIKASI IMPORT ---
import '../../domain/entities/course.dart';
import '../../domain/usecases/course/add_course.dart';
import '../../domain/usecases/course/delete_course.dart';
import '../../domain/usecases/course/get_all_courses.dart';
import '../../domain/usecases/course/update_course.dart';
// -------------------------

class ClassController extends GetxController {
  // --- INJEKSI USE CASES ---
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

  // --- STATE REAKTIF (.obs) ---
  final isLoading = false.obs;
  final errorMessage = Rxn<String>();
  final allClasses = <Course>[].obs; // Ini adalah RxList

  // State UI (Filter)
  final currentTabIndex = 0.obs; // Ini adalah RxInt
  final searchQuery = "".obs; // Ini adalah RxString

  @override
  void onInit() {
    fetchCourses();
    super.onInit();
  }

  // --- GETTER PINTAR ---
  List<Course> get filteredClasses {
    //? --- PERBAIKAN DI SINI ---
    //? 'allClasses' adalah RxList, jadi tidak perlu '.value'
    List<Course> list = allClasses;
    //? --------------------------

    //? '.value' diperlukan di sini
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

    //? '.value' diperlukan di sini
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

  // --- FUNGSI AKSI ---

  Future<void> fetchCourses() async {
    try {
      isLoading(true);
      errorMessage(null);
      final courses = await getAllCoursesUseCase();
      allClasses.assignAll(courses); // 'assignAll' untuk update RxList
    } catch (e) {
      errorMessage(e.toString());
    } finally {
      isLoading(false);
    }
  }

  void updateTab(int index) {
    currentTabIndex(index);
  }

  void updateSearchQuery(String query) {
    searchQuery(query);
  }

  Future<void> addClass(Map<String, dynamic> newClassData) async {
    try {
      await addCourseUseCase(newClassData);
      await fetchCourses(); // Refresh
    } catch (e) {
      Get.snackbar("Error", "Gagal menambah kelas: $e");
    }
  }

  Future<void> updateClass(Map<String, dynamic> updatedClassData) async {
    try {
      await updateCourseUseCase(updatedClassData);
      await fetchCourses(); // Refresh
    } catch (e) {
      Get.snackbar("Error", "Gagal update kelas: $e");
    }
  }

  Future<void> deleteClass(String id) async {
    try {
      await deleteCourseUseCase(id);
      await fetchCourses(); // Refresh
    } catch (e) {
      Get.snackbar("Error", "Gagal menghapus kelas: $e");
    }
  }

  // --- FUNGSI DIALOG (Tidak berubah) ---
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
                deleteClass(course.id); // Panggil fungsi controller
                Navigator.of(dialogContext).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
