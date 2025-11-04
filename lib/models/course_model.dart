// lib/models/course_model.dart
import 'package:flutter/material.dart';

// Definisikan warna-warna khusus di sini
const Color tagBlue = Color.fromARGB(255, 37, 146, 247);
const Color tagGreen = Color(0xFF0DA680);

// Ini adalah 'Model' atau 'cetakan' untuk data kelas kita.
class CourseModel {
  // Properti data yang akan dimiliki oleh setiap kelas
  final String id;
  final String nama;
  final String harga;
  final String thumbnail;
  final List<String> tags;
  final List<Color> tagColors;

  // 'Constructor' untuk membuat objek CourseModel baru
  CourseModel({
    required this.id,
    required this.nama,
    required this.harga,
    required this.thumbnail,
    required this.tags,
    required this.tagColors,
  });

  // Fungsi "pabrik" untuk mengubah data mentah berbentuk Map (dari form)
  // menjadi sebuah objek CourseModel yang rapi.
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

  // Mengubah objek CourseModel ini kembali menjadi Map.
  // Kita pakai ini saat mau mengirim data ke 'ClassFormPage' (mode Edit).
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
