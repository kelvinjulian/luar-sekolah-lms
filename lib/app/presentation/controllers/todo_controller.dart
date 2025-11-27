import 'package:flutter/material.dart';
import 'package:get/get.dart';

// Import Entities & Use Cases
import '../../domain/entities/todo.dart';
import '../../domain/usecases/todo/add_todo.dart';
import '../../domain/usecases/todo/delete_todo.dart';
import '../../domain/usecases/todo/get_all_todos.dart';
import '../../domain/usecases/todo/update_todo.dart';

// Import Service
import '../../core/services/notification_service.dart';

enum FilterStatus { all, completed, pending }

class TodoController extends GetxController {
  // --- DEPENDENCIES ---
  final GetAllTodosUseCase getAllTodosUseCase;
  final AddTodoUseCase addTodoUseCase;
  final UpdateTodoUseCase updateTodoUseCase;
  final DeleteTodoUseCase deleteTodoUseCase;

  // REFACTOR: Service di-inject via constructor agar testable
  final NotificationService notificationService;

  TodoController({
    required this.getAllTodosUseCase,
    required this.addTodoUseCase,
    required this.updateTodoUseCase,
    required this.deleteTodoUseCase,
    required this.notificationService, // Wajib diisi (bisa via Get.find di Binding)
  });

  // --- STATE ---
  final allTodos = <Todo>[].obs;
  final isLoading = false.obs;
  final filterStatus = FilterStatus.all.obs;
  final searchQuery = "".obs;

  // State untuk feedback UI (Snackbar)
  final errorMessage = Rxn<String>();
  final successMessage = Rxn<String>();

  // --- GETTER (Computed) ---
  List<Todo> get filteredTodos {
    List<Todo> todos = allTodos;

    // 1. Filter Status
    if (filterStatus.value == FilterStatus.completed) {
      todos = todos.where((todo) => todo.completed).toList();
    } else if (filterStatus.value == FilterStatus.pending) {
      todos = todos.where((todo) => !todo.completed).toList();
    }

    // 2. Filter Search
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
    super.onInit();
    fetchTodos();
  }

  // --- LISTENER UI (Pengganti Get.snackbar langsung) ---
  @override
  void onReady() {
    super.onReady();

    // Dengarkan Error
    ever(errorMessage, (String? msg) {
      if (msg != null && msg.isNotEmpty && !Get.testMode) {
        Get.snackbar(
          "Error",
          msg,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    });

    // Dengarkan Sukses (Khusus untuk scheduleTodoReminder yang pakai snackbar sebelumnya)
    ever(successMessage, (String? msg) {
      if (msg != null && msg.isNotEmpty && !Get.testMode) {
        Get.snackbar(
          "Info",
          msg,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      }
    });
  }

  // --- FETCH DATA ---
  Future<void> fetchTodos() async {
    isLoading(true);
    errorMessage.value = null; // Reset
    try {
      final todos = await getAllTodosUseCase();
      allTodos.assignAll(todos);
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading(false);
    }
  }

  // --- ACTIONS ---

  // 1. ADD TODO
  Future<void> addTodo(String text) async {
    try {
      await addTodoUseCase(text); // Simpan DB
      await fetchTodos(); // Refresh UI

      // Trigger Local Notification (Business Logic Side Effect)
      try {
        await notificationService.showLocalNotification(
          title: "Catatan Baru Ditambahkan",
          body: "Tugas '$text' berhasil disimpan ke daftar! 📝",
        );
      } catch (_) {}
    } catch (e) {
      errorMessage.value = "Gagal menambah: ${e.toString()}";
    }
  }

  // 2. TOGGLE STATUS
  Future<void> toggleTodoStatus(Todo todo) async {
    try {
      final bool isNowCompleted = !todo.completed;
      final updatedTodo = todo.copyWith(completed: isNowCompleted);

      await updateTodoUseCase(updatedTodo);
      await fetchTodos();

      String statusMessage = isNowCompleted
          ? "Selesai dikerjakan! Kerja bagus 🎉"
          : "Ditandai kembali sebagai belum selesai ⏳";

      try {
        await notificationService.showLocalNotification(
          title: "Status Diperbarui",
          body: "Tugas '${todo.text}' kini $statusMessage",
        );
      } catch (_) {}
    } catch (e) {
      errorMessage.value = "Gagal update: ${e.toString()}";
    }
  }

  // 3. REMOVE TODO
  Future<void> removeTodo(String id) async {
    try {
      // Logic: Cari judul sebelum dihapus untuk notifikasi
      final todoToDelete = allTodos.firstWhereOrNull((t) => t.id == id);
      final String todoTitle = todoToDelete?.text ?? "Item";

      await deleteTodoUseCase(id);
      await fetchTodos();

      try {
        await notificationService.showLocalNotification(
          title: "Catatan Dihapus",
          body: "Tugas '$todoTitle' telah dihapus dari daftar 🗑️",
        );
      } catch (_) {}
    } catch (e) {
      errorMessage.value = "Gagal menghapus: ${e.toString()}";
    }
  }

  Future<void> updateTodoText(Todo oldTodo, String newText) async {
    if (oldTodo.text == newText) return;
    try {
      final updatedTodo = oldTodo.copyWith(text: newText);
      await updateTodoUseCase(updatedTodo);
      await fetchTodos();
    } catch (e) {
      errorMessage.value = "Gagal update teks: ${e.toString()}";
    }
  }

  // --- SCHEDULE REMINDER ---
  Future<void> scheduleTodoReminder(Todo todo) async {
    try {
      print("🕒 Memulai timer manual 5 detik...");

      final scheduledTime = DateTime.now().add(const Duration(seconds: 5));
      await notificationService.scheduleNotification(
        id: DateTime.now().millisecond,
        title: "⏰ Pengingat Tugas",
        body: "Jangan lupa kerjakan: '${todo.text}'!",
        scheduledDate: scheduledTime,
      );

      // REFACTOR: Menggunakan state message alih-alih Get.snackbar langsung
      successMessage.value = "Tunggu 5 detik...";
    } catch (e) {
      errorMessage.value = "Gagal jadwal: $e";
    }
  }

  // --- FILTERS ---
  void setFilter(FilterStatus status) => filterStatus(status);
  void setSearchQuery(String query) => searchQuery(query);
}
