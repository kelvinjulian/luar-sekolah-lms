// lib/app/presentation/controllers/todo_controller.dart
import 'package:get/get.dart';

// Import Entities & Use Cases (Layer Domain)
import '../../domain/entities/todo.dart';
import '../../domain/usecases/todo/add_todo.dart';
import '../../domain/usecases/todo/delete_todo.dart';
import '../../domain/usecases/todo/get_all_todos.dart';
import '../../domain/usecases/todo/update_todo.dart';

// Import Service Notifikasi (Layer Core)
// Controller butuh akses ke service ini untuk memicu notifikasi lokal
import '../../core/services/notification_service.dart';

enum FilterStatus { all, completed, pending }

class TodoController extends GetxController {
  // --- DEPENDENCY INJECTION ---
  // Controller tidak tahu menahu soal Firestore/API.
  // Dia hanya tahu cara memanggil "Use Case" (Resep) yang sudah disiapkan.
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

  // --- STATE MANAGEMENT (REAKTIF) ---
  // .obs membuat variabel ini bisa didengarkan perubahannya oleh UI (Obx)
  final allTodos = <Todo>[].obs;
  final isLoading = false.obs;
  final errorMessage = Rxn<String>();
  final filterStatus = FilterStatus.all.obs;
  final searchQuery = "".obs;

  // --- GETTER PINTAR (COMPUTED PROPERTY) ---
  // UI tidak mengambil 'allTodos' secara langsung, tapi mengambil 'filteredTodos'.
  // Logika filter ditaruh di sini agar UI tetap bersih.
  List<Todo> get filteredTodos {
    List<Todo> todos = allTodos;

    // 1. Filter berdasarkan Status (Selesai/Belum)
    if (filterStatus.value == FilterStatus.completed) {
      todos = todos.where((todo) => todo.completed).toList();
    } else if (filterStatus.value == FilterStatus.pending) {
      todos = todos.where((todo) => !todo.completed).toList();
    }

    // 2. Filter berdasarkan Pencarian Teks
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
    // Saat controller dibuat, langsung ambil data dari Firestore
    fetchTodos();
    super.onInit();
  }

  // --- FUNGSI FETCH DATA ---
  Future<void> fetchTodos() async {
    isLoading(true); // Mulai loading
    errorMessage(null); // Reset error
    try {
      // Panggil UseCase untuk ambil data
      final todos = await getAllTodosUseCase();
      // Masukkan data ke state reaktif (.assignAll)
      allTodos.assignAll(todos);
    } catch (e) {
      errorMessage(e.toString());
    }
    isLoading(false); // Selesai loading
  }

  // ==================================================================
  // BAGIAN LOGIKA NOTIFIKASI (ACTION-BASED TRIGGER)
  // ==================================================================

  // --- 1. ADD TODO ---
  Future<void> addTodo(String text) async {
    try {
      //? Langkah 1: Simpan ke Server (Firestore) dulu.
      // Kita pakai 'await' agar notifikasi TIDAK muncul kalau simpan ke DB gagal.
      await addTodoUseCase(text);

      //? Langkah 2: Refresh data di UI agar item baru muncul.
      await fetchTodos();

      //? Langkah 3: Trigger Notifikasi Lokal
      // Kita menggunakan Try-Catch terpisah di sini (Nested Try-Catch).
      // KENAPA? Agar jika sistem notifikasi error (misal izin ditolak),
      // aplikasi TIDAK crash dan proses tambah todo tetap dianggap sukses.
      try {
        // Memanggil service singleton (.to)
        await NotificationService.to.showLocalNotification(
          title: "Catatan Baru Ditambahkan",
          // String Interpolation: Menyisipkan isi 'text' ke dalam pesan notif
          body: "Tugas '$text' berhasil disimpan ke daftar! 📝",
        );
      } catch (_) {
        // Silent catch: Abaikan error notifikasi, yang penting data tersimpan.
      }
    } catch (e) {
      // Ini catch untuk error Firestore (Gagal Simpan)
      errorMessage("Gagal menambah: ${e.toString()}");
    }
  }

  // --- 2. TOGGLE STATUS ---
  Future<void> toggleTodoStatus(Todo todo) async {
    try {
      // Hitung status baru (kebalikan dari status lama)
      final bool isNowCompleted = !todo.completed;
      final updatedTodo = todo.copyWith(completed: isNowCompleted);

      // Update ke Firestore
      await updateTodoUseCase(updatedTodo);
      await fetchTodos();

      // Logic Dinamis: Pesan notifikasi berbeda tergantung status barunya
      String statusMessage = isNowCompleted
          ? "Selesai dikerjakan! Kerja bagus 🎉" // jika TRUE, pakai kalimat ini
          : "Ditandai kembali sebagai belum selesai ⏳"; // jika FALSE, pakai kalimat ini

      try {
        await NotificationService.to.showLocalNotification(
          title: "Status Diperbarui",
          // Menggunakan nama todo dan pesan status dinamis
          body: "Tugas '${todo.text}' kini $statusMessage",
        );
      } catch (_) {}
    } catch (e) {
      errorMessage("Gagal update: ${e.toString()}");
    }
  }

  // --- 3. REMOVE TODO (LOGIKA SPESIAL) ---
  Future<void> removeTodo(String id) async {
    try {
      // TRIK PENTING:
      // Masalah: Jika kita hapus data ke Firestore dulu, datanya hilang.
      // Kita tidak bisa tahu apa judul Todo yang dihapus untuk ditaruh di notifikasi.

      // Solusi: Cari dulu Todo-nya di memory lokal (allTodos) berdasarkan ID.
      final todoToDelete = allTodos.firstWhereOrNull((t) => t.id == id);
      // Simpan judulnya ke variabel sementara. Jika null, pakai default "Item".
      final String todoTitle = todoToDelete?.text ?? "Item";

      // Baru lakukan penghapusan ke Firestore
      await deleteTodoUseCase(id);
      await fetchTodos();

      // Tampilkan notifikasi menggunakan judul yang sudah kita simpan tadi
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
      // Catatan: Di sini kita tidak memasang notifikasi,
      // tapi jika mau, polanya sama seperti di atas.
    } catch (e) {
      errorMessage("Gagal update teks: ${e.toString()}");
    }
  }

  // --- FITUR BONUS: SCHEDULE REMINDER ---
  Future<void> scheduleTodoReminder(Todo todo) async {
    try {
      print("🕒 Memulai timer manual 5 detik...");

      // // CARA 1: TEST MANUAL (Bukan ZonedSchedule)
      // // Ini akan menguji apakah masalahnya di 'Permission Alarm' atau 'Tampilan Notifikasi'.
      // Future.delayed(const Duration(seconds: 10), () async {
      //   print(
      //     "⏰ Timer 10 detik habis! Mencoba memunculkan notifikasi SEKARANG...",
      //   );
      //   await NotificationService.to.showLocalNotification(
      //     title: "TEST MANUAL",
      //     body:
      //         "Jika ini muncul, berarti Izin Notifikasi AMAN. Masalahnya ada di fitur Schedule/Alarm.",
      //   );
      // });

      // --- CARA 2: SCHEDULE ASLI (Komentari dulu yang ini) ---
      final scheduledTime = DateTime.now().add(const Duration(seconds: 5));
      await NotificationService.to.scheduleNotification(
        id: DateTime.now().millisecond,
        title: "⏰ Pengingat Tugas",
        body: "Jangan lupa kerjakan: '${todo.text}'!",
        scheduledDate: scheduledTime,
      );

      Get.snackbar("Test", "Tunggu 5 detik...");
    } catch (e) {
      errorMessage("Gagal jadwal: $e");
    }
  }

  // --- FUNGSI FILTER UI ---
  void setFilter(FilterStatus status) {
    filterStatus(status);
  }

  void setSearchQuery(String query) {
    searchQuery(query);
  }
}
