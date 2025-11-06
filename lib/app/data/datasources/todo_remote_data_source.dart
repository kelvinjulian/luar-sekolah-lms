// lib/app/data/datasources/todo_remote_data_source.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../domain/entities/todo.dart'; // <-- Import entity (yang punya helper 'todoListFromJson')

// Ini BUKAN implementasi interface, ini adalah class konkret
class TodoRemoteDataSource {
  final String _baseUrl = 'https://ls-lms.zoidify.my.id/api/todos';
  final String _authToken = "default-token"; // Ganti dengan token asli jika ada

  Map<String, String> _getHeaders() {
    return {
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer $_authToken',
    };
  }

  // Perhatikan: tidak ada lagi '@override'
  Future<List<Todo>> fetchTodos() async {
    try {
      final response = await http.get(
        Uri.parse(_baseUrl),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        // Panggil helper 'todoListFromJson' dari todo.dart
        return todoListFromJson(response.body);
      } else {
        throw Exception('Gagal memuat data. Status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Terjadi kesalahan: $e');
    }
  }

  Future<Todo> createTodo(String text) async {
    try {
      final newTodo = Todo(text: text, completed: false);
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: _getHeaders(),
        body: jsonEncode(newTodo.toJson()),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return Todo.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
      } else {
        throw Exception('Gagal membuat todo. Status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Terjadi kesalahan saat membuat: $e');
    }
  }

  Future<void> updateTodo(String id, Todo todo) async {
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/$id'),
        headers: _getHeaders(),
        body: jsonEncode(todo.toJson()),
      );

      if (response.statusCode != 200) {
        throw Exception(
          'Gagal memperbarui todo. Status: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Terjadi kesalahan saat update: $e');
    }
  }

  Future<void> deleteTodo(String id) async {
    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl/$id'),
        headers: _getHeaders(),
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Gagal menghapus todo. Status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Terjadi kesalahan saat menghapus: $e');
    }
  }
}
