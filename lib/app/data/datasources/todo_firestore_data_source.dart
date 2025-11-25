import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // <-- Import Auth
import '../../domain/entities/todo.dart';

class TodoFirestoreDataSource {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  // Helper untuk mendapatkan collection 'todos' milik user yang sedang login
  //? (A) Helper Isolasi Data
  CollectionReference<Map<String, dynamic>> _getTodoCollection() {
    final userId = _auth.currentUser?.uid; // Cek siapa yang login
    if (userId == null) {
      throw Exception("User tidak login, tidak bisa mengakses todo.");
    }
    // Dapatkan brankas spesifik milik user itu
    return _db.collection('users').doc(userId).collection('todos');
  }

  // READ
  Future<List<Todo>> fetchTodos() async {
    try {
      final snapshot = await _getTodoCollection().get();

      return snapshot.docs.map((doc) {
        // Ubah data Map dari Firestore menjadi objek Todo
        final data = doc.data();
        // Tambahkan ID dokumen ke dalam data
        data['id'] = doc.id;
        return Todo.fromJson(data);
      }).toList();
    } catch (e) {
      throw Exception('Gagal memuat data dari Firestore: $e');
    }
  }

  // CREATE
  //? (B) Fungsi Aksi
  Future<Todo> createTodo(String text) async {
    try {
      final newTodo = Todo(text: text, completed: false);

      // 'add' akan membuat ID dokumen unik secara otomatis
      // Tambahkan dokumen ke brankas user
      final docRef = await _getTodoCollection().add(newTodo.toJson());

      // Kembalikan objek Todo lengkap dengan ID barunya
      return newTodo.copyWith(id: docRef.id);
    } catch (e) {
      throw Exception('Gagal membuat todo di Firestore: $e');
    }
  }

  // UPDATE
  Future<void> updateTodo(String id, Todo todo) async {
    try {
      await _getTodoCollection().doc(id).update(todo.toJson());
    } catch (e) {
      throw Exception('Gagal update todo di Firestore: $e');
    }
  }

  // DELETE
  Future<void> deleteTodo(String id) async {
    try {
      await _getTodoCollection().doc(id).delete();
    } catch (e) {
      throw Exception('Gagal menghapus todo di Firestore: $e');
    }
  }
}
