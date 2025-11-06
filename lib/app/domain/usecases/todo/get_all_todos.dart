// lib/app/domain/usecases/todo/get_all_todos.dart
import '../../entities/todo.dart';
import '../../repositories/i_todo_repository.dart';

class GetAllTodosUseCase {
  final ITodoRepository repository;

  GetAllTodosUseCase(this.repository);

  // Fungsi 'call' agar class ini bisa dipanggil seperti fungsi
  Future<List<Todo>> call() {
    return repository.getTodos();
  }
}
