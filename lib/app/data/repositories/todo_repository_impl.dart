// lib/app/data/repositories/todo_repository_impl.dart
import '../../domain/entities/todo.dart';
import '../../domain/repositories/i_todo_repository.dart';
//? --- PERBAIKAN: Import class konkret ---
import '../datasources/todo_remote_data_source.dart';

class TodoRepositoryImpl implements ITodoRepository {
  //? --- PERBAIKAN: Dependensi ke class konkret ---
  final TodoRemoteDataSource dataSource;

  TodoRepositoryImpl(this.dataSource);

  @override
  Future<List<Todo>> getTodos() {
    // Langsung teruskan, remote source sudah mengembalikan List<Todo>
    return dataSource.fetchTodos();
  }

  @override
  Future<Todo> addTodo(String text) {
    return dataSource.createTodo(text);
  }

  @override
  Future<void> updateTodo(Todo todo) {
    // Pastikan ID tidak null
    if (todo.id == null) throw Exception("Cannot update todo with null ID");
    return dataSource.updateTodo(todo.id!, todo);
  }

  @override
  Future<void> deleteTodo(String id) {
    return dataSource.deleteTodo(id);
  }
}
