// lib/services/todo_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/todo.dart';

//? class TodoService untuk mengambil data todo dengan satu fungsi fetchTodos
//? fungsi ini memanggil API JSONPlaceholder(http.get), mengecek statusCode = 200
//? lalu mengubah list data JSON menjadi List<Todo> menggunakan model yang sudah dibuat

//? fungsi fetchTodos:
//? menggunakan http.get untuk mengambil data dari API
//? mengambil data mentah JSON dan mengubahnya menjadi List<Todo>
class TodoService {
  final String _baseUrl = 'https://jsonplaceholder.typicode.com';

  Future<List<Todo>> fetchTodos() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/todos'));

      if (response.statusCode == 200) {
        // Jika request sukses
        List<dynamic> body = jsonDecode(response.body);
        List<Todo> todos = body
            .map((dynamic item) => Todo.fromJson(item))
            .toList();
        return todos;
      } else {
        // Jika server error
        throw Exception(
          'Gagal memuat data. Status code: ${response.statusCode}',
        );
      }
    } catch (e) {
      // Jika koneksi error
      throw Exception('Terjadi kesalahan: $e');
    }
  }
}
