// lib/app/domain/usecases/todo/delete_todo.dart
import '../../repositories/i_todo_repository.dart';

class DeleteTodoUseCase {
  final ITodoRepository repository;

  DeleteTodoUseCase(this.repository);

  Future<void> call(String id) {
    return repository.deleteTodo(id);
  }
}
