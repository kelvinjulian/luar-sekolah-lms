import '../entities/todo.dart';

abstract class ITodoRepository {
  //? UPDATE: Tambahkan parameter limit dan startAfter
  //? startAfter adalah objek Todo terakhir yang user lihat di layar
  Future<List<Todo>> getTodos({int limit = 20, Todo? startAfter});

  Future<Todo> addTodo(String text);
  Future<void> updateTodo(Todo todo);
  Future<void> deleteTodo(String id);
}
