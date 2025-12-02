import '../../repositories/i_todo_repository.dart';
import '../../entities/todo.dart';

class ValidationException implements Exception {
  final String message;
  ValidationException(this.message);
}

class AddTodoUseCase {
  final ITodoRepository repository;

  AddTodoUseCase(this.repository);

  // PERBAIKAN: Parameter ganti jadi Todo
  Future<void> call(Todo todo) async {
    // 1. Validasi Teks di dalam object Todo
    final cleanText = todo.text.trim();

    if (cleanText.isEmpty) {
      throw ValidationException("Teks Todo tidak boleh kosong");
    }

    if (cleanText.length > 100) {
      throw ValidationException("Teks Todo terlalu panjang (max 100 karakter)");
    }

    // 2. Buat object bersih (trim text)
    final cleanTodo = todo.copyWith(text: cleanText);

    // 3. Kirim ke Repo
    return await repository.addTodo(cleanTodo);
  }
}
