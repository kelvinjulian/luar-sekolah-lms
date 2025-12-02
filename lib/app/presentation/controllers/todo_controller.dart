// lib/app/presentation/controllers/todo_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart'; // Opsional jika butuh formatting di controller

import '../../domain/entities/todo.dart';
import '../../domain/usecases/todo/search_todos.dart'; // Import UseCase Baru
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
  final SearchTodosUseCase searchTodosUseCase; // Inject UseCase Baru
  final NotificationService notificationService;

  TodoController({
    required this.getAllTodosUseCase,
    required this.addTodoUseCase,
    required this.updateTodoUseCase,
    required this.deleteTodoUseCase,
    required this.searchTodosUseCase, // Tambahkan di constructor
    required this.notificationService,
  });

  // --- STATE ---
  final allTodos = <Todo>[].obs;
  final isLoading = false.obs;
  final filterStatus = FilterStatus.all.obs;
  final searchQuery = "".obs;

  final errorMessage = Rxn<String>();
  final successMessage = Rxn<String>();

  // Pagination
  final ScrollController scrollController = ScrollController();
  final isMoreLoading = false.obs;
  final isSearchMode = false.obs;
  Todo? lastTodo;
  bool hasMore = true;
  final int pageSize = 20;

  // --- GETTER (FILTER & SORTING OTOMATIS) ---
  List<Todo> get filteredTodos {
    // 1. Copy list agar aman
    List<Todo> todos = List.from(allTodos);

    // 2. Filter Status
    if (filterStatus.value == FilterStatus.completed) {
      todos = todos.where((todo) => todo.completed).toList();
    } else if (filterStatus.value == FilterStatus.pending) {
      todos = todos.where((todo) => !todo.completed).toList();
    }

    // 3. Filter Search
    if (searchQuery.value.isNotEmpty) {
      todos = todos
          .where(
            (todo) => todo.text.toLowerCase().contains(
              searchQuery.value.toLowerCase(),
            ),
          )
          .toList();
    }

    // 4. SORTING: Deadline Terdekat di Atas
    // Logic: Pending > Completed. Jika Pending, Waktu Terdekat > Waktu Jauh > Tanpa Waktu.
    todos.sort((a, b) {
      // Prioritas 1: Status (Pending di atas)
      if (a.completed != b.completed) {
        return a.completed ? 1 : -1;
      }
      // Prioritas 2: Waktu (Terdekat di atas)
      if (a.scheduledTime == null && b.scheduledTime == null) return 0;
      if (a.scheduledTime == null) return 1; // Yg ga punya tanggal taruh bawah
      if (b.scheduledTime == null) return -1;

      return a.scheduledTime!.compareTo(b.scheduledTime!);
    });

    return todos;
  }

  @override
  void onInit() {
    super.onInit();
    fetchTodos(isRefresh: true);

    // Listener Lazy Load
    scrollController.addListener(() {
      if (!isSearchMode.value && // <-- Cek Mode
          scrollController.position.pixels >=
              scrollController.position.maxScrollExtent &&
          !isMoreLoading.value &&
          hasMore) {
        fetchTodos();
      }
    });

    // LISTENER SEARCH (DEBOUNCE)
    // Fungsi ini akan dijalankan 500ms setelah user berhenti mengetik
    debounce(searchQuery, (String query) {
      if (query.isEmpty) {
        // Jika kosong, kembali ke mode Pagination normal
        isSearchMode.value = false;
        fetchTodos(isRefresh: true);
      } else {
        // Jika ada text, masuk mode Search
        isSearchMode.value = true;
        performSearch(query);
      }
    }, time: const Duration(milliseconds: 500));
  }

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }

  @override
  void onReady() {
    super.onReady();
    // Listener Snackbar Global
    ever(errorMessage, (String? msg) {
      if (msg != null && msg.isNotEmpty && !Get.testMode) {
        Get.snackbar(
          "Error",
          msg,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(16),
        );
      }
    });
    ever(successMessage, (String? msg) {
      if (msg != null && msg.isNotEmpty && !Get.testMode) {
        Get.snackbar(
          "Info",
          msg,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(16),
        );
      }
    });
  }

  // --- FETCH DATA ---
  Future<void> fetchTodos({bool isRefresh = false}) async {
    if (!hasMore && !isRefresh) return;
    if (isLoading.value || isMoreLoading.value) return;

    if (isRefresh) {
      isLoading(true);
      lastTodo = null;
      hasMore = true;
      allTodos.clear();
      errorMessage.value = null;
    } else {
      isMoreLoading(true);
    }

    try {
      await Future.delayed(const Duration(seconds: 1)); // Efek loading halus
      final newTodos = await getAllTodosUseCase(
        limit: pageSize,
        startAfter: lastTodo,
      );

      if (newTodos.length < pageSize) hasMore = false;
      if (newTodos.isNotEmpty) lastTodo = newTodos.last;

      allTodos.addAll(newTodos);
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading(false);
      isMoreLoading(false);
    }
  }

  // --- FUNGSI PENCARIAN BARU ---
  Future<void> performSearch(String query) async {
    isLoading(true);
    try {
      // Panggil UseCase Search (Ambil semua data yang cocok dari server)
      final results = await searchTodosUseCase(query);

      // Timpa list lokal dengan hasil pencarian
      allTodos.assignAll(results);

      // Saat mode search, kita tidak butuh pagination
      hasMore = false;
    } catch (e) {
      errorMessage.value = "Gagal mencari: $e";
    } finally {
      isLoading(false);
    }
  }

  // Update setSearchQuery untuk trigger debounce
  void setSearchQuery(String query) {
    searchQuery.value = query; // Ini akan memicu debounce di onInit
  }

  // --- ACTIONS UTAMA ---

  // 1. ADD TODO (Terima Text & Tanggal)
  Future<void> addTodo(String text, DateTime? scheduledTime) async {
    try {
      // Buat Object Todo lengkap
      final newTodo = Todo(
        text: text,
        completed: false,
        scheduledTime: scheduledTime,
      );

      // Panggil UseCase (Pastikan usecase sudah terima parameter Todo)
      await addTodoUseCase(newTodo);

      await fetchTodos(isRefresh: true);

      try {
        await notificationService.showLocalNotification(
          title: "Tugas Baru",
          body: "Berhasil menambahkan: $text",
        );
      } catch (_) {}
    } catch (e) {
      errorMessage.value = "Gagal menambah: $e";
    }
  }

  // 2. TOGGLE STATUS
  Future<void> toggleTodoStatus(Todo todo) async {
    try {
      final updatedTodo = todo.copyWith(completed: !todo.completed);
      await updateTodoUseCase(updatedTodo);

      // Update lokal biar UI langsung berubah (Optimistic UI)
      final index = allTodos.indexWhere((t) => t.id == todo.id);
      if (index != -1) allTodos[index] = updatedTodo;
    } catch (e) {
      errorMessage.value = "Gagal update: $e";
    }
  }

  // 3. REMOVE
  Future<void> removeTodo(String id) async {
    try {
      await deleteTodoUseCase(id);
      allTodos.removeWhere((t) => t.id == id);
      successMessage.value = "Tugas berhasil dihapus";
    } catch (e) {
      errorMessage.value = "Gagal hapus: $e";
    }
  }

  // 4. UPDATE TEXT
  Future<void> updateTodoText(Todo oldTodo, String newText) async {
    if (oldTodo.text == newText) return;
    try {
      final updatedTodo = oldTodo.copyWith(text: newText);
      await updateTodoUseCase(updatedTodo);
      await fetchTodos(isRefresh: true);
    } catch (e) {
      errorMessage.value = "Gagal update teks: $e";
    }
  }

  // --- TAMBAHKAN FUNGSI INI DI DALAM CLASS TodoController ---

  // Update Todo Lengkap (Teks, Status, Waktu)
  Future<void> updateTodo(Todo todo) async {
    try {
      // 1. Panggil UseCase (yang kamu kirim di chat)
      await updateTodoUseCase(todo);

      // 2. Refresh list agar data terbaru muncul
      await fetchTodos(isRefresh: true);

      // 3. Update Notifikasi jika ada waktu baru
      if (todo.scheduledTime != null) {
        // Pastikan waktu di masa depan sebelum pasang alarm
        if (todo.scheduledTime!.isAfter(DateTime.now())) {
          scheduleReminder(todo, todo.scheduledTime!);
        }
      }

      successMessage.value = "Tugas berhasil diperbarui";
    } catch (e) {
      errorMessage.value = "Gagal update: $e";
    }
  }

  // 5. SCHEDULE REMINDER (Alarm)
  Future<void> scheduleReminder(Todo todo, DateTime scheduledTime) async {
    try {
      if (scheduledTime.isBefore(DateTime.now())) {
        errorMessage.value = "Waktu pengingat harus di masa depan!";
        return;
      }

      int notificationId = todo.text.hashCode; // Generate ID unik dari text

      await notificationService.scheduleNotification(
        id: notificationId,
        title: "🔔 Pengingat Tugas",
        body: "Waktunya mengerjakan: '${todo.text}'",
        scheduledDate: scheduledTime,
      );

      // Feedback Text
      final diff = scheduledTime.difference(DateTime.now());
      String msg = "";
      if (diff.inMinutes < 60) {
        msg = "Pengingat diset ${diff.inMinutes} menit lagi";
      } else {
        msg =
            "Pengingat diset jam ${DateFormat('HH:mm').format(scheduledTime)}";
      }
      successMessage.value = msg;
    } catch (e) {
      errorMessage.value = "Gagal pasang alarm: $e";
    }
  }

  // Helpers
  void setFilter(FilterStatus status) => filterStatus(status);
  Future<void> deleteAllTodos() async {} // Implementasi jika perlu
  Future<void> injectDummyData() async {} // Implementasi jika perlu
}
