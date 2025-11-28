import '../../domain/entities/todo.dart';
import '../../domain/repositories/i_todo_repository.dart';
import '../datasources/todo_firestore_data_source.dart';

class TodoRepositoryImpl implements ITodoRepository {
  final TodoFirestoreDataSource dataSource;

  TodoRepositoryImpl(this.dataSource);

  @override
  //? UPDATE: Teruskan parameter pagination ke DataSource
  Future<List<Todo>> getTodos({int limit = 20, Todo? startAfter}) {
    return dataSource.fetchTodos(limit: limit, startAfter: startAfter);
  }

  @override
  Future<Todo> addTodo(String text) {
    return dataSource.createTodo(text);
  }

  @override
  Future<void> updateTodo(Todo todo) {
    if (todo.id == null) throw Exception("Cannot update todo with null ID");
    return dataSource.updateTodo(todo.id!, todo);
  }

  @override
  Future<void> deleteTodo(String id) {
    return dataSource.deleteTodo(id);
  }
}
