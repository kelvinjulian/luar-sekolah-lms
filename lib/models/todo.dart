// lib/models/todo.dart

//? Model kelas Todo untuk merepresentasikan item todo
//? yang diambil dari API
//? Setiap todo memiliki id, userId, title, dan status completed
class Todo {
  final int id;
  final int userId;
  final String title;
  final bool completed;

  Todo({
    required this.id,
    required this.userId,
    required this.title,
    required this.completed,
  });

  // Factory constructor untuk parsing JSON
  //? untuk mengubah data mentah JSON dari API menjadi objek Todo
  factory Todo.fromJson(Map<String, dynamic> json) {
    return Todo(
      id: json['id'],
      userId: json['userId'],
      title: json['title'],
      completed: json['completed'],
    );
  }
}
