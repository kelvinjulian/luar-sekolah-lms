// lib/app/domain/usecases/todo/add_todo.dart
import '../../entities/todo.dart';
import '../../repositories/i_todo_repository.dart';

class AddTodoUseCase {
  final ITodoRepository repository;

  AddTodoUseCase(this.repository);

  // Menerima parameter yang dibutuhkan
  Future<Todo> call(String text) {
    return repository.addTodo(text);
  }
}
