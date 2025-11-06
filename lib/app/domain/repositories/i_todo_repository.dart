// lib/app/domain/repositories/i_todo_repository.dart
import '../entities/todo.dart';

// Ini adalah "Kontrak" yang harus dipenuhi oleh Data Layer
abstract class ITodoRepository {
  Future<List<Todo>> getTodos();
  Future<Todo> addTodo(String text);
  Future<void> updateTodo(Todo todo);
  Future<void> deleteTodo(String id);
}
