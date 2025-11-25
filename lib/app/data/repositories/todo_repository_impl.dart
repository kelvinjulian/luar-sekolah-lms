import '../../domain/entities/todo.dart';
import '../../domain/repositories/i_todo_repository.dart';
//?todo --- PERBAIKAN: Ganti import remote ke firestore ---
import '../datasources/todo_firestore_data_source.dart';

class TodoRepositoryImpl implements ITodoRepository {
  //?todo --- PERBAIKAN: Ganti tipe data source ---
  // Koki tahu nomor Supplier-nya (di-inject oleh Binding)
  final TodoFirestoreDataSource dataSource;

  TodoRepositoryImpl(this.dataSource);

  @override
  Future<List<Todo>> getTodos() {
    return dataSource.fetchTodos();
  }

  @override
  Future<Todo> addTodo(String text) {
    // Koki meneruskan perintah ke Supplier
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
