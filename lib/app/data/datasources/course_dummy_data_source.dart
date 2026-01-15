import 'dart:io';
import 'package:flutter/foundation.dart';
import '../../domain/entities/course.dart';

class CourseDummyDataSource {
  // 1. DATA MASTER AWAL
  static final List<Course> _masterData = [
    Course(
      id: "dummy-1",
      nama: "Belajar Flutter Dasar (Dummy)",
      harga: 0,
      thumbnail: "https://via.placeholder.com/150/0DA680/FFFFFF?text=Populer",
      tags: ["Populer"],
      tagColorsHex: ["#0DA680"],
    ),
    Course(
      id: "dummy-2",
      nama: "Mastering Clean Architecture (Dummy)",
      harga: 250000,
      thumbnail: "https://via.placeholder.com/150/2196F3/FFFFFF?text=SPL",
      tags: ["SPL"],
      tagColorsHex: ["#2196F3"],
    ),
  ];

  // --- HELPER WARNA (Tetap sama) ---
  List<String> _generateTagColors(List<String> tags) {
    return tags.map((tag) {
      final cleanTag = tag.trim().toLowerCase();
      if (cleanTag.contains('populer')) return "#0DA680";
      if (cleanTag.contains('spl')) return "#2196F3";
      if (cleanTag.contains('prakerja')) return "#9C27B0";
      return "#808080";
    }).toList();
  }

  // --- READ ---
  Future<List<Course>> getCourses({
    int limit = 20,
    int offset = 0,
    String? tag,
  }) async {
    await Future.delayed(const Duration(seconds: 1));
    List<Course> filteredData = _masterData;
    if (tag != null) {
      filteredData = _masterData
          .where(
            (c) =>
                c.tags.any((t) => t.toLowerCase().contains(tag.toLowerCase())),
          )
          .toList();
    }
    if (offset >= filteredData.length) return [];
    int end = offset + limit;
    if (end > filteredData.length) end = filteredData.length;
    return filteredData.sublist(offset, end);
  }

  // --- CREATE DENGAN UPLOAD GAMBAR ---
  Future<void> addCourse(Course course, File? imageFile) async {
    await Future.delayed(const Duration(seconds: 2));

    final String newId = "dummy-${DateTime.now().millisecondsSinceEpoch}";

    // Jika ada file gambar, gunakan path lokalnya sebagai thumbnail
    // Jika tidak ada, gunakan placeholder
    String thumbPath = imageFile != null
        ? imageFile.path
        : "https://via.placeholder.com/150/808080/FFFFFF?text=No+Image";

    final newCourse = Course(
      id: newId,
      nama: course.nama,
      harga: course.harga,
      thumbnail: thumbPath, // Menyimpan path file lokal
      tags: course.tags,
      tagColorsHex: _generateTagColors(course.tags),
    );

    _masterData.insert(0, newCourse);
    debugPrint("Dummy Upload: Berhasil menyimpan path gambar: $thumbPath");
  }

  // --- UPDATE DENGAN UPLOAD GAMBAR ---
  Future<void> updateCourse(Course course, File? imageFile) async {
    await Future.delayed(const Duration(seconds: 2));

    final index = _masterData.indexWhere((item) => item.id == course.id);
    if (index != -1) {
      // Jika user memilih gambar baru, gunakan path barunya.
      // Jika tidak, tetap gunakan thumbnail lama.
      String thumbPath = imageFile != null ? imageFile.path : course.thumbnail;

      final updatedCourse = Course(
        id: course.id,
        nama: course.nama,
        harga: course.harga,
        thumbnail: thumbPath,
        tags: course.tags,
        tagColorsHex: _generateTagColors(course.tags),
      );
      _masterData[index] = updatedCourse;
    }
  }

  Future<void> deleteCourse(String id) async {
    await Future.delayed(const Duration(milliseconds: 800));
    _masterData.removeWhere((item) => item.id == id);
  }
}
