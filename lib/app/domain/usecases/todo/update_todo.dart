// lib/app/domain/usecases/todo/update_todo.dart
import '../../entities/todo.dart';
import '../../repositories/i_todo_repository.dart';

class UpdateTodoUseCase {
  final ITodoRepository repository;

  UpdateTodoUseCase(this.repository);

  Future<void> call(Todo todo) {
    return repository.updateTodo(todo);
  }
}
