// lib/app/domain/usecases/todo/add_todo.dart
import '../../entities/todo.dart';
import '../../repositories/i_todo_repository.dart';

class AddTodoUseCase {
  // Resep ini tahu dia harus menghubungi 'repository' (Buku Menu)
  final ITodoRepository repository;

  AddTodoUseCase(this.repository);

  // Saat 'addTodoUseCase(text)' dipanggil, fungsi 'call' inilah yang dieksekusi
  Future<Todo> call(String text) {
    // Resep memberi instruksi ke "Buku Menu"
    return repository.addTodo(text);
  }
}
