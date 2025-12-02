/*
import 'dart:io'; // Untuk File
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../../domain/entities/course.dart';

class CourseFirestoreDataSource {
  final _db = FirebaseFirestore.instance;
  final _storage = FirebaseStorage.instance;
  final String _collectionName = 'courses'; // Koleksi di root (bukan per user)

  // --- GET DATA (REALTIME) ---
  Stream<List<Course>> getCourses() {
    return _db.collection(_collectionName).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        // Menggunakan fromMap yang sudah kita update sebelumnya (butuh ID)
        return Course.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }

  // --- ADD DATA + UPLOAD IMAGE ---
  Future<void> addCourse(Course course, File? imageFile) async {
    try {
      // 1. Buat referensi dokumen baru untuk dapat ID-nya (Auto ID)
      final docRef = _db.collection(_collectionName).doc();

      String imageUrl =
          "assets/images/course1.png"; // Default jika tidak upload

      // 2. Jika ada file gambar, Upload ke Firebase Storage
      if (imageFile != null) {
        // Nama file di storage: courses/{docId}.jpg
        final storageRef = _storage.ref().child(
          'course_images/${docRef.id}.jpg',
        );
        await storageRef.putFile(imageFile);
        imageUrl = await storageRef.getDownloadURL();
      }

      // 3. Simpan data ke Firestore
      // Kita override 'thumbnail' dengan URL dari internet (atau default)
      final data = course.toMap();
      data['thumbnail'] = imageUrl;

      // Simpan menggunakan ID yang sudah digenerate di awal
      await docRef.set(data);
    } catch (e) {
      throw Exception("Gagal menambah kelas: $e");
    }
  }

  // --- UPDATE DATA + UPLOAD IMAGE ---
  Future<void> updateCourse(Course course, File? imageFile) async {
    try {
      String imageUrl = course.thumbnail; // Pakai URL lama dulu

      // 1. Jika User ganti gambar, upload ulang & update URL
      if (imageFile != null) {
        final storageRef = _storage.ref().child(
          'course_images/${course.id}.jpg',
        );
        await storageRef.putFile(imageFile);
        imageUrl = await storageRef.getDownloadURL();
      }

      // 2. Update Firestore
      final data = course.toMap();
      data['thumbnail'] = imageUrl; // Update field thumbnail

      await _db.collection(_collectionName).doc(course.id).update(data);
    } catch (e) {
      throw Exception("Gagal update kelas: $e");
    }
  }

  // --- DELETE DATA ---
  Future<void> deleteCourse(String id) async {
    try {
      // 1. Hapus Dokumen
      await _db.collection(_collectionName).doc(id).delete();

      // 2. (Opsional) Hapus Gambarnya juga di Storage untuk hemat memori
      // await _storage.ref().child('course_images/$id.jpg').delete();
    } catch (e) {
      throw Exception("Gagal menghapus kelas: $e");
    }
  }
}

 */
