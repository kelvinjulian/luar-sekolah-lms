// lib/app/domain/usecases/todo/add_todo.dart
import '../../repositories/i_todo_repository.dart';
import '../../entities/todo.dart';

// Buat Exception custom jika belum ada
class ValidationException implements Exception {
  final String message;
  ValidationException(this.message);
}

class AddTodoUseCase {
  final ITodoRepository repository;

  AddTodoUseCase(this.repository);

  Future<Todo> call(String text) async {
    // 1. TRIM: Hapus spasi depan/belakang
    final cleanText = text.trim();

    // // KODE SABOTASE (SALAH)
    // final cleanText = text; // <-- Lupa di-trim!

    // 2. VALIDASI: Cek kosong
    if (cleanText.isEmpty) {
      throw ValidationException("Teks Todo tidak boleh kosong");
    }

    // 3. VALIDASI: Cek panjang karakter (misal max 100)
    if (cleanText.length > 100) {
      throw ValidationException("Teks Todo terlalu panjang (max 100 karakter)");
    }

    // 4. Panggil Repository dengan data bersih
    return await repository.addTodo(cleanText);
  }
}
