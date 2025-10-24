// lib/models/todo.dart
import 'dart:convert';

//? 1. Fungsi helper untuk mengubah List JSON String menjadi List<Todo>
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
      // (terkadang API mengembalikan { "items": [...] } atau sejenisnya)
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
  // Sekarang parse list yang sudah ditemukan
  return todoList
      .map((dynamic item) => Todo.fromJson(item as Map<String, dynamic>))
      .toList();
}

//? 4. CLASS TODO (SESUAI API)
class Todo {
  final String? id;
  final String text;
  final bool completed;

  Todo({this.id, required this.text, required this.completed});

  //? 5. 'fromJson' (Server -> Aplikasi)
  // mengubah data JSON mentah (map) dari server menajdi objek Todo yang bisa digunakan aplikasi
  factory Todo.fromJson(Map<String, dynamic> json) {
    return Todo(
      id: json['id'] as String?,
      text: json['text'] as String,
      completed: json['completed'] as bool,
    );
  }

  //? 6. 'toJson' (Aplikasi -> Server)
  Map<String, dynamic> toJson() {
    return {'text': text, 'completed': completed};
  }

  //? 7. 'copyWith' (Helper untuk update)
  Todo copyWith({String? id, String? text, bool? completed}) => Todo(
    id: id ?? this.id,
    text: text ?? this.text,
    completed: completed ?? this.completed,
  );
}
