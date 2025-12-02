import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/entities/todo.dart';

class TodoFirestoreDataSource {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>> _getTodoCollection() {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      throw Exception("User tidak login, tidak bisa mengakses todo.");
    }
    return _db.collection('users').doc(userId).collection('todos');
  }

  Future<List<Todo>> fetchTodos({int limit = 20, Todo? startAfter}) async {
    try {
      // PERBAIKAN: Gunakan FieldPath.documentId untuk sorting yang stabil
      // Jangan sort by 'scheduledTime' di sini karena data lama akan hilang/null.
      var query = _getTodoCollection()
          .orderBy(FieldPath.documentId)
          .limit(limit);

      if (startAfter != null && startAfter.id != null) {
        final lastDocSnapshot = await _getTodoCollection()
            .doc(startAfter.id)
            .get();
        if (lastDocSnapshot.exists) {
          query = query.startAfterDocument(lastDocSnapshot);
        }
      }

      final snapshot = await query.get();
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return Todo.fromJson(data);
      }).toList();
    } catch (e) {
      throw Exception('Gagal memuat data: $e');
    }
  }

  // --- FUNGSI BARU: SEARCH ALL ---
  // Mengambil semua data user untuk difilter secara lokal
  Future<List<Todo>> searchTodos(String query) async {
    try {
      // Kita ambil semua data (tanpa limit)
      // Urutkan berdasarkan waktu agar hasil search rapi
      // Catatan: Jika data user > 1000, ini mungkin agak berat, tapi untuk Todo App ini aman.
      final snapshot = await _getTodoCollection()
          .orderBy(FieldPath.documentId)
          .get();

      final allData = snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return Todo.fromJson(data);
      }).toList();

      // Filter di sisi Dart (Case Insensitive & Partial Match)
      // Ini jauh lebih powerful daripada query Firestore
      return allData.where((todo) {
        return todo.text.toLowerCase().contains(query.toLowerCase());
      }).toList();
    } catch (e) {
      throw Exception('Gagal mencari data: $e');
    }
  }

  // Pastikan fungsi add/update/delete tidak dihapus
  Future<void> addTodo(Todo todo) async {
    try {
      await _getTodoCollection().add(todo.toJson());
    } catch (e) {
      throw Exception('Gagal membuat todo: $e');
    }
  }

  Future<void> updateTodo(String id, Todo todo) async {
    try {
      await _getTodoCollection().doc(id).update(todo.toJson());
    } catch (e) {
      throw Exception('Gagal update todo: $e');
    }
  }

  Future<void> deleteTodo(String id) async {
    try {
      await _getTodoCollection().doc(id).delete();
    } catch (e) {
      throw Exception('Gagal menghapus todo: $e');
    }
  }
}
