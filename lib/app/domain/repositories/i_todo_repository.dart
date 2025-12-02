import '../entities/todo.dart';

abstract class ITodoRepository {
  Future<List<Todo>> getTodos({int limit = 20, Todo? startAfter});

  Future<List<Todo>> searchTodos(String query);

  // PERBAIKAN: Terima parameter Todo (bukan String lagi)
  Future<void> addTodo(Todo todo);

  Future<void> updateTodo(Todo todo);
  Future<void> deleteTodo(String id);
}
