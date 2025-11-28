// lib/app/domain/usecases/todo/get_all_todos.dart
import '../../entities/todo.dart';
import '../../repositories/i_todo_repository.dart';

class GetAllTodosUseCase {
  final ITodoRepository repository;

  GetAllTodosUseCase(this.repository);

  //? UPDATE: Method call sekarang menerima parameter opsional
  Future<List<Todo>> call({int limit = 20, Todo? startAfter}) {
    return repository.getTodos(limit: limit, startAfter: startAfter);
  }
}
