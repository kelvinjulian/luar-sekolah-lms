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

  // PERBAIKAN DI SINI:
  // Ubah parameter 'startAfter' agar menerima objek 'Todo', bukan DocumentSnapshot
  Future<List<Todo>> fetchTodos({int limit = 20, Todo? startAfter}) async {
    try {
      // 1. Query Dasar: Urutkan berdasarkan documentId (default sort yang stabil)
      //    Atau gunakan 'createdAt' jika Anda menyimpan field tersebut.
      var query = _getTodoCollection()
          .orderBy(FieldPath.documentId)
          .limit(limit);

      // 2. Logika Pagination (Object-Based Cursor)
      if (startAfter != null && startAfter.id != null) {
        // Trik: Kita ambil DocumentSnapshot dari ID Todo tersebut
        final lastDocSnapshot = await _getTodoCollection()
            .doc(startAfter.id)
            .get();

        // Jika dokumen ditemukan, gunakan sebagai titik mulai (Cursor)
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

  // ... (Fungsi create, update, delete tetap sama) ...
  Future<Todo> createTodo(String text) async {
    try {
      final newTodo = Todo(text: text, completed: false);
      final docRef = await _getTodoCollection().add(newTodo.toJson());
      return newTodo.copyWith(id: docRef.id);
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
