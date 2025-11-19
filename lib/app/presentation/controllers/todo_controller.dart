// lib/app/presentation/controllers/todo_controller.dart
import 'package:get/get.dart';

// --- VERIFIKASI IMPORT ---
import '../../domain/entities/todo.dart';
import '../../domain/usecases/todo/add_todo.dart';
import '../../domain/usecases/todo/delete_todo.dart';
import '../../domain/usecases/todo/get_all_todos.dart';
import '../../domain/usecases/todo/update_todo.dart';
// -------------------------

enum FilterStatus { all, completed, pending }

class TodoController extends GetxController {
  // --- INJEKSI USE CASES ---
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

  // --- STATE REAKTIF (.obs) ---
  final allTodos = <Todo>[].obs;
  final isLoading = false.obs;
  final errorMessage = Rxn<String>();
  final filterStatus = FilterStatus.all.obs;
  final searchQuery = "".obs;

  // --- GETTER PINTAR (UI MENGAMBIL DATA DARI SINI) ---
  List<Todo> get filteredTodos {
    //? --- PERBAIKAN DI SINI ---
    //? 'allTodos' adalah RxList, jadi tidak perlu '.value'
    List<Todo> todos = allTodos;
    //? --------------------------

    //? '.value' diperlukan di sini karena 'filterStatus' adalah Rx<FilterStatus>
    if (filterStatus.value == FilterStatus.completed) {
      todos = todos.where((todo) => todo.completed).toList();
    } else if (filterStatus.value == FilterStatus.pending) {
      todos = todos.where((todo) => !todo.completed).toList();
    }

    //? '.value' diperlukan di sini karena 'searchQuery' adalah RxString
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
    //?todo --- PERBAIKAN: Kembalikan pemanggilan data otomatis ---
    fetchTodos();
    super.onInit();
  }

  // --- FUNGSI AKSI (DIPANGGIL OLEH UI) ---

  Future<void> fetchTodos() async {
    isLoading(true);
    errorMessage(null);
    try {
      final todos = await getAllTodosUseCase();
      allTodos.assignAll(todos); // 'assignAll' adalah cara update RxList
    } catch (e) {
      errorMessage(e.toString());
    }
    isLoading(false);
  }

  Future<void> addTodo(String text) async {
    try {
      // Manajer mengambil "Kartu Resep" (UseCase)
      await addTodoUseCase(text);

      // PENTING: Panggil 'fetchTodos' lagi untuk refresh
      await fetchTodos();
    } catch (e) {
      errorMessage("Gagal menambah: ${e.toString()}");
    }
  }

  Future<void> toggleTodoStatus(Todo todo) async {
    try {
      final updatedTodo = todo.copyWith(completed: !todo.completed);
      await updateTodoUseCase(updatedTodo);
      await fetchTodos();
    } catch (e) {
      errorMessage("Gagal update: ${e.toString()}");
    }
  }

  Future<void> removeTodo(String id) async {
    try {
      await deleteTodoUseCase(id);
      await fetchTodos();
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

  // --- FUNGSI FILTER (HANYA MENGUBAH STATE) ---
  void setFilter(FilterStatus status) {
    filterStatus(status);
  }

  void setSearchQuery(String query) {
    searchQuery(query);
  }
}
