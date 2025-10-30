// lib/models/course_model.dart
import 'package:flutter/material.dart';

// Definisi warna bisa diletakkan di sini
const Color tagBlue = Color.fromARGB(255, 37, 146, 247);
const Color tagGreen = Color(0xFF0DA680);

class CourseModel {
  final String id;
  final String nama;
  final String harga;
  final String thumbnail;
  final List<String> tags;
  final List<Color> tagColors;

  CourseModel({
    required this.id,
    required this.nama,
    required this.harga,
    required this.thumbnail,
    required this.tags,
    required this.tagColors,
  });

  // Helper untuk konversi dari Map (yang dikembalikan form)
  factory CourseModel.fromMap(Map<String, dynamic> map) {
    return CourseModel(
      id: map['id'] as String,
      nama: map['nama'] as String,
      harga: map['harga'] as String,
      thumbnail: map['thumbnail'] as String,
      tags: (map['tags'] as List<dynamic>).cast<String>(),
      tagColors: (map['tagColors'] as List<dynamic>).cast<Color>(),
    );
  }

  // Helper untuk konversi ke Map (untuk dikirim ke form)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nama': nama,
      'harga': harga,
      'thumbnail': thumbnail,
      'tags': tags,
      'tagColors': tagColors,
    };
  }
}
