// lib/services/todo_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/todo.dart'; // Impor model baru

class TodoService {
  final String _baseUrl =
      'https://ls-lms.zoidify.my.id/api/todos'; // URL API lms luar sekolah (yang baru)

  //? 1. TOKEN AUTENTIKASI (KUNCI)
  final String _authToken = "default-token";

  //? 2. FUNGSI PRIBADI UNTUK MEMBUAT HEADERS
  Map<String, String> _getHeaders() {
    return {
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer $_authToken', // Selalu kirim token
    };
  }

  //? 3. READ (GET)
  Future<List<Todo>> fetchTodos() async {
    try {
      final response = await http.get(
        Uri.parse(_baseUrl),
        headers: _getHeaders(), // Selalu pakai headers
      );

      if (response.statusCode == 200) {
        // Kirim ke model untuk di-parsing
        return todoListFromJson(response.body);
      } else {
        throw Exception('Gagal memuat data. Status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Terjadi kesalahan: $e');
    }
  }

  //? 4. CREATE (POST)
  Future<Todo> createTodo(String text) async {
    try {
      //? Buat objek Todo baru
      final newTodo = Todo(text: text, completed: false);

      //? Kirim ke API
      final response = await http.post(
        Uri.parse(_baseUrl), //? URL API
        headers: _getHeaders(), //? Gunakan headers dengan token
        body: jsonEncode(newTodo.toJson()), //? Ubah ke JSON
      );

      //? STATUS CODE (201 ATAU 200)
      if (response.statusCode == 201 || response.statusCode == 200) {
        return Todo.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
      } else {
        throw Exception('Gagal membuat todo. Status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Terjadi kesalahan saat membuat: $e');
    }
  }

  //? 6. UPDATE (PUT)
  Future<void> updateTodo(String id, Todo todo) async {
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/$id'),
        headers: _getHeaders(),
        body: jsonEncode(todo.toJson()),
      );

      // (Edit/Update biasanya mengembalikan 200 OK)
      if (response.statusCode != 200) {
        throw Exception(
          'Gagal memperbarui todo. Status: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Terjadi kesalahan saat update: $e');
    }
  }

  //? 7. DELETE (DELETE)
  Future<void> deleteTodo(String id) async {
    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl/$id'),
        headers: _getHeaders(),
      );

      // (Delete bisa 200 OK atau 204 No Content)
      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Gagal menghapus todo. Status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Terjadi kesalahan saat menghapus: $e');
    }
  }
}
