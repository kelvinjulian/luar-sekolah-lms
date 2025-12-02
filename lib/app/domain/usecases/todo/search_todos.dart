import '../../entities/todo.dart';
import '../../repositories/i_todo_repository.dart';

class SearchTodosUseCase {
  final ITodoRepository repository;

  SearchTodosUseCase(this.repository);

  Future<List<Todo>> call(String query) {
    return repository.searchTodos(query);
  }
}
