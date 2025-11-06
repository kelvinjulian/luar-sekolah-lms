// lib/app/domain/entities/todo.dart
import 'dart:convert'; // <-- PENTING: Tambahkan import ini

//? --- FUNGSI YANG HILANG ADA DI SINI ---
//? Ini diambil dari file lib/models/todo.dart asli Anda
List<Todo> todoListFromJson(String str) {
  final dynamic decodedJson = json.decode(str);

  List<dynamic> todoList;

  //? 2. CEK APAKAH HASILNYA MAP ATAU LIST
  if (decodedJson is Map<String, dynamic>) {
    // Jika Map, cari list di dalam key 'data' atau 'todos'
    if (decodedJson.containsKey('data')) {
      todoList = decodedJson['data'] as List<dynamic>;
    } else if (decodedJson.containsKey('todos')) {
      todoList = decodedJson['todos'] as List<dynamic>;
    } else {
      // Coba asumsikan root-nya adalah Map tapi tidak ada key pembungkus
      // Jika tidak ada key yang cocok, lempar error
      throw Exception(
        "Format JSON tidak dikenal: Kunci 'data' atau 'todos' tidak ditemukan dalam Map.",
      );
    }
  } else if (decodedJson is List<dynamic>) {
    // Jika sudah List, langsung pakai
    todoList = decodedJson;
  } else {
    throw Exception("Format JSON tidak dikenal: Bukan Map atau List.");
  }

  //? 3. Ubah tiap item di list menjadi objek Todo
  return todoList
      .map((dynamic item) => Todo.fromJson(item as Map<String, dynamic>))
      .toList();
}
//? --- END FUNGSI YANG HILANG ---

class Todo {
  final String? id;
  final String text;
  final bool completed;

  Todo({this.id, required this.text, required this.completed});

  // 'fromJson' (Server -> Aplikasi)
  // (Diambil dari file todo.dart asli Anda)
  factory Todo.fromJson(Map<String, dynamic> json) {
    return Todo(
      // API mungkin mengembalikan 'id' atau '_id'
      // Kita tambahkan '_id' untuk jaga-jaga, tapi utamakan 'id'
      id: json['id'] as String? ?? json['_id'] as String?,
      text: json['text'] as String,
      completed: json['completed'] as bool,
    );
  }

  // 'toJson' (Aplikasi -> Server)
  // (Diambil dari file todo.dart asli Anda)
  Map<String, dynamic> toJson() {
    return {'text': text, 'completed': completed};
  }

  // 'copyWith' (Helper untuk update)
  Todo copyWith({String? id, String? text, bool? completed}) => Todo(
    id: id ?? this.id,
    text: text ?? this.text,
    completed: completed ?? this.completed,
  );
}
