// lib/app/presentation/controllers/todo_controller.dart
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
  final NotificationService notificationService;

  TodoController({
    required this.getAllTodosUseCase,
    required this.addTodoUseCase,
    required this.updateTodoUseCase,
    required this.deleteTodoUseCase,
    required this.notificationService,
  });

  // --- STATE UTAMA ---
  final allTodos = <Todo>[].obs;
  final isLoading = false.obs;
  final filterStatus = FilterStatus.all.obs;
  final searchQuery = "".obs;

  // --- STATE FEEDBACK UI ---
  final errorMessage = Rxn<String>();
  final successMessage = Rxn<String>();

  // --- PAGINATION STATE ---
  final ScrollController scrollController = ScrollController();
  final isMoreLoading = false.obs; // Loading kecil di bawah list

  // PERBAIKAN: Gunakan Todo? sebagai penanda halaman terakhir (bukan DocumentSnapshot)
  // Ini agar controller tidak perlu tahu tentang objek Firebase
  Todo? lastTodo;

  bool hasMore = true;
  final int pageSize = 20;

  // --- GETTER (COMPUTED) ---
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

  // --- LIFECYCLE ---
  @override
  void onInit() {
    super.onInit();
    // Load data awal
    fetchTodos(isRefresh: true);

    // Listener Scroll (Infinite Scroll)
    scrollController.addListener(() {
      if (scrollController.position.pixels >=
              scrollController.position.maxScrollExtent &&
          !isMoreLoading.value &&
          hasMore) {
        // Jika mentok bawah, load halaman berikutnya
        fetchTodos();
      }
    });
  }

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }

  @override
  void onReady() {
    super.onReady();
    // Listener untuk memunculkan Snackbar (UI Side Effect)

    // 1. Error Listener
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

    // 2. Success Listener
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

  // --- FETCH DATA (PAGINATION) ---
  Future<void> fetchTodos({bool isRefresh = false}) async {
    // Validasi kondisi
    if (!hasMore && !isRefresh) return;
    if (isLoading.value || isMoreLoading.value) return;

    // Reset State jika Refresh
    if (isRefresh) {
      isLoading(true);
      lastTodo = null; // Reset kursor
      hasMore = true;
      allTodos.clear();
      errorMessage.value = null;
    } else {
      isMoreLoading(true);
    }

    try {
      // Ini akan membuat spinner berputar selama 2 detik sebelum data diambil
      await Future.delayed(const Duration(seconds: 2));

      // Panggil UseCase dengan parameter Pagination
      final newTodos = await getAllTodosUseCase(
        limit: pageSize,
        startAfter: lastTodo, // Kirim objek Todo terakhir sebagai kursor
      );

      // Cek apakah data habis
      if (newTodos.length < pageSize) {
        hasMore = false;
      }

      // Update kursor untuk halaman berikutnya
      if (newTodos.isNotEmpty) {
        lastTodo = newTodos.last;
      }

      // Masukkan data ke list
      allTodos.addAll(newTodos);
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading(false);
      isMoreLoading(false);
    }
  }

  // --- ACTIONS ---

  // 1. ADD TODO
  Future<void> addTodo(String text) async {
    try {
      await addTodoUseCase(text);
      // Refresh list agar data baru muncul di atas dan pagination ter-reset
      await fetchTodos(isRefresh: true);

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

      // Update Lokal (Optimistic UI)
      final index = allTodos.indexWhere((t) => t.id == todo.id);
      if (index != -1) {
        allTodos[index] = updatedTodo;
      }

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
      final todoToDelete = allTodos.firstWhereOrNull((t) => t.id == id);
      final String todoTitle = todoToDelete?.text ?? "Item";

      await deleteTodoUseCase(id);

      // Hapus lokal
      allTodos.removeWhere((t) => t.id == id);

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

  // 4. UPDATE TODO TEXT
  Future<void> updateTodoText(Todo oldTodo, String newText) async {
    if (oldTodo.text == newText) return;
    try {
      final updatedTodo = oldTodo.copyWith(text: newText);
      await updateTodoUseCase(updatedTodo);

      // Refresh list untuk memastikan konsistensi data
      await fetchTodos(isRefresh: true);

      // Opsional: Notifikasi
      try {
        await notificationService.showLocalNotification(
          title: "Catatan Diubah",
          body: "Tugas berhasil diubah menjadi '$newText'",
        );
      } catch (_) {}
    } catch (e) {
      errorMessage.value = "Gagal update teks: ${e.toString()}";
    }
  }

  // 5. SCHEDULE REMINDER
  Future<void> scheduleTodoReminder(Todo todo) async {
    try {
      final scheduledTime = DateTime.now().add(const Duration(seconds: 5));

      await notificationService.scheduleNotification(
        id: DateTime.now().millisecond,
        title: "⏰ Pengingat Tugas",
        body: "Jangan lupa kerjakan: '${todo.text}'!",
        scheduledDate: scheduledTime,
      );

      // Trigger Snackbar Sukses lewat variabel state
      successMessage.value = "Tunggu 5 detik...";
    } catch (e) {
      errorMessage.value = "Gagal jadwal: $e";
    }
  }

  //! --- DEBUGGING / TESTING ONLY ---
  // Inject 50 Dummy Data
  Future<void> injectDummyData() async {
    // Pastikan tidak double request
    if (isLoading.value) return;

    isLoading(true);
    successMessage.value = "Sedang generate 50 data...";

    try {
      // Loop 50 kali
      for (int i = 1; i <= 50; i++) {
        await addTodoUseCase("Dummy Task #$i - Generated");
        // Opsional: Kasih delay dikit biar tidak kena rate limit Firestore (kalau koneksi lambat)
        // await Future.delayed(const Duration(milliseconds: 50));
        //  TAMBAHKAN DELAY DI SINI (Misal 100ms per item)
        // Ini biar tidak terlalu ngebut, jadi terasa prosesnya
        await Future.delayed(const Duration(milliseconds: 50));
      }

      // Refresh list setelah semua selesai
      await fetchTodos(isRefresh: true);

      successMessage.value = "Berhasil inject 50 data!";
    } catch (e) {
      errorMessage.value = "Gagal inject: $e";
    } finally {
      isLoading(false);
    }
  }

  //! --- DEBUG: HAPUS SEMUA DATA ---
  Future<void> deleteAllTodos() async {
    if (isLoading.value) return;

    // Cek jika list kosong
    if (allTodos.isEmpty) {
      errorMessage.value = "List sudah kosong!";
      return;
    }

    isLoading(true);
    successMessage.value = "Sedang menghapus semua data...";

    try {
      // 1. Ambil semua ID dari data yang sedang dimuat
      // Kita butuh copy list ID karena allTodos akan berubah
      final idsToDelete = allTodos
          .map((todo) => todo.id)
          .whereType<String>()
          .toList();

      // 2. Loop dan hapus satu per satu
      for (final id in idsToDelete) {
        await deleteTodoUseCase(id);
      }

      // 3. Bersihkan state lokal & reset pagination
      allTodos.clear();
      lastTodo = null;
      hasMore = true; // Reset agar fetch selanjutnya mulai dari awal

      successMessage.value = "Semua data berhasil dihapus!";
    } catch (e) {
      errorMessage.value = "Gagal menghapus sebagian data: $e";
    } finally {
      isLoading(false);
    }
  }

  // --- UI FILTERS ---
  void setFilter(FilterStatus status) => filterStatus(status);
  void setSearchQuery(String query) => searchQuery(query);
}
