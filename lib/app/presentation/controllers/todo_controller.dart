// lib/app/presentation/controllers/todo_controller.dart
import 'package:get/get.dart';

import '../../domain/entities/todo.dart';
import '../../domain/usecases/todo/add_todo.dart';
import '../../domain/usecases/todo/delete_todo.dart';
import '../../domain/usecases/todo/get_all_todos.dart';
import '../../domain/usecases/todo/update_todo.dart';
import '../../core/services/notification_service.dart';

enum FilterStatus { all, completed, pending }

class TodoController extends GetxController {
  final GetAllTodosUseCase getAllTodosUseCase;
  final AddTodoUseCase addTodoUseCase;
  final UpdateTodoUseCase updateTodoUseCase;
  final DeleteTodoUseCase deleteTodoUseCase;

  TodoController({
    required this.getAllTodosUseCase,
    required this.addTodoUseCase,
    required this.updateTodoUseCase,
    required this.deleteTodoUseCase,
  });

  final allTodos = <Todo>[].obs;
  final isLoading = false.obs;
  final errorMessage = Rxn<String>();
  final filterStatus = FilterStatus.all.obs;
  final searchQuery = "".obs;

  List<Todo> get filteredTodos {
    List<Todo> todos = allTodos;

    if (filterStatus.value == FilterStatus.completed) {
      todos = todos.where((todo) => todo.completed).toList();
    } else if (filterStatus.value == FilterStatus.pending) {
      todos = todos.where((todo) => !todo.completed).toList();
    }

    if (searchQuery.value.isNotEmpty) {
      todos = todos
          .where(
            (todo) => todo.text.toLowerCase().contains(
              searchQuery.value.toLowerCase(),
            ),
          )
          .toList();
    }
    return todos;
  }

  @override
  void onInit() {
    fetchTodos();
    super.onInit();
  }

  Future<void> fetchTodos() async {
    isLoading(true);
    errorMessage(null);
    try {
      final todos = await getAllTodosUseCase();
      allTodos.assignAll(todos);
    } catch (e) {
      errorMessage(e.toString());
    }
    isLoading(false);
  }

  // --- 1. UPDATE: Notifikasi Tambah Todo Lebih Detail ---
  Future<void> addTodo(String text) async {
    try {
      await addTodoUseCase(text);
      await fetchTodos();

      // Menggunakan variabel 'text' agar notifikasi dinamis
      try {
        await NotificationService.to.showLocalNotification(
          title: "Catatan Baru Ditambahkan",
          body: "Tugas '$text' berhasil disimpan ke daftar! 📝",
        );
      } catch (_) {}
    } catch (e) {
      errorMessage("Gagal menambah: ${e.toString()}");
    }
  }

  // --- 2. UPDATE: Notifikasi Toggle Status ---
  Future<void> toggleTodoStatus(Todo todo) async {
    try {
      final bool isNowCompleted = !todo.completed;
      final updatedTodo = todo.copyWith(completed: isNowCompleted);

      await updateTodoUseCase(updatedTodo);
      await fetchTodos();

      // Logic pesan berbeda tergantung status baru
      String statusMessage = isNowCompleted
          ? "Selesai dikerjakan! Kerja bagus 🎉"
          : "Ditandai kembali sebagai belum selesai ⏳";

      try {
        await NotificationService.to.showLocalNotification(
          title: "Status Diperbarui",
          body: "Tugas '${todo.text}' kini $statusMessage",
        );
      } catch (_) {}
    } catch (e) {
      errorMessage("Gagal update: ${e.toString()}");
    }
  }

  // --- 3. UPDATE: Notifikasi Hapus dengan Nama Todo ---
  Future<void> removeTodo(String id) async {
    try {
      // TRIK: Cari dulu Todo-nya di list lokal sebelum dihapus dari server
      // agar kita bisa mengambil teks judulnya.
      final todoToDelete = allTodos.firstWhereOrNull((t) => t.id == id);
      final String todoTitle = todoToDelete?.text ?? "Item";

      await deleteTodoUseCase(id);
      await fetchTodos();

      try {
        await NotificationService.to.showLocalNotification(
          title: "Catatan Dihapus",
          body: "Tugas '$todoTitle' telah dihapus dari daftar 🗑️",
        );
      } catch (_) {}
    } catch (e) {
      errorMessage("Gagal menghapus: ${e.toString()}");
    }
  }

  Future<void> updateTodoText(Todo oldTodo, String newText) async {
    if (oldTodo.text == newText) return;
    try {
      final updatedTodo = oldTodo.copyWith(text: newText);
      await updateTodoUseCase(updatedTodo);
      await fetchTodos();
    } catch (e) {
      errorMessage("Gagal update teks: ${e.toString()}");
    }
  }

  void setFilter(FilterStatus status) {
    filterStatus(status);
  }

  void setSearchQuery(String query) {
    searchQuery(query);
  }
}
