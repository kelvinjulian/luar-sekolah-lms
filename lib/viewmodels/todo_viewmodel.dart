// lib/viewmodels/todo_viewmodel.dart
import 'package:flutter/foundation.dart';
import '../models/todo.dart';
import '../services/todo_service.dart';

enum FilterStatus { all, completed, pending }

class TodoViewModel extends ChangeNotifier {
  final TodoService _service = TodoService();

  //? 1. STATE PRIBADI (HANYA DIKENAL VIEWMODEL)
  List<Todo> _allTodos = []; // Data master dari server
  bool _isLoading = false;
  String? _errorMessage;
  FilterStatus _filterStatus = FilterStatus.all;
  String _searchQuery = "";

  //? 2. STATE PUBLIK (DIBACA OLEH UI)
  //* Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  FilterStatus get filterStatus => _filterStatus;

  //? 3. GETTER PINTAR (UI MENGAMBIL DATA DARI SINI)
  List<Todo> get filteredTodos {
    List<Todo> todos = _allTodos;
    // Terapkan filter status
    if (_filterStatus == FilterStatus.completed) {
      todos = todos.where((todo) => todo.completed).toList();
    } else if (_filterStatus == FilterStatus.pending) {
      todos = todos.where((todo) => !todo.completed).toList();
    } // ... (filter pending) ...

    // Terapkan filter search
    if (_searchQuery.isNotEmpty) {
      todos = todos
          .where(
            (todo) =>
                todo.text.toLowerCase().contains(_searchQuery.toLowerCase()),
          )
          .toList();
    }
    return todos;
  }

  //? 4. FUNGSI AKSI (DIPANGGIL OLEH UI)
  //? --- AKSI API (READ, CREATE, UPDATE, DELETE) ---
  //? Pola utamanya selalu: Panggil Service -> Panggil fetchTodos()
  //* aksi untuk mengambil todo dari server
  Future<void> fetchTodos() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners(); // Beri tahu UI: "Saya lagi loading"
    try {
      _allTodos = await _service.fetchTodos(); // Panggil service
    } catch (e) {
      _errorMessage = e.toString();
    }
    _isLoading = false;
    notifyListeners(); // Beri tahu UI: "Loading selesai, ini datanya"
  }

  //* aksi untuk menambah todo
  Future<void> addTodo(String text) async {
    try {
      await _service.createTodo(text); // 1. Panggil Service
      await fetchTodos(); // 2. Ambil data terbaru
    } catch (e) {
      /* ... handle error ... */
      _errorMessage = "Gagal menambah: ${e.toString()}";
      notifyListeners();
    }
  }

  //* aksi untuk mengubah status todo (selesai/belum)
  Future<void> toggleTodoStatus(Todo todo) async {
    try {
      final updatedTodo = todo.copyWith(completed: !todo.completed);
      await _service.updateTodo(todo.id!, updatedTodo); // 1. Panggil Service
      await fetchTodos(); // 2. Ambil data terbaru
    } catch (e) {
      /* ... handle error ... */
      _errorMessage = "Gagal update: ${e.toString()}";
      notifyListeners();
    }
  }

  //* aksi untuk menghapus todo
  Future<void> removeTodo(String id) async {
    try {
      await _service.deleteTodo(id);
      await fetchTodos();
    } catch (e) {
      _errorMessage = "Gagal menghapus: ${e.toString()}";
      notifyListeners();
    }
  }

  //* aksi untuk mengupdate teks todo
  Future<void> updateTodoText(Todo oldTodo, String newText) async {
    // Cek jika teksnya sama, tidak perlu panggil API
    if (oldTodo.text == newText) return;

    try {
      // Buat objek todo baru dengan teks yang sudah diupdate
      final updatedTodo = oldTodo.copyWith(text: newText);

      await _service.updateTodo(
        updatedTodo.id!,
        updatedTodo,
      ); // 1. Panggil Service

      await fetchTodos(); // 2. Ambil data terbaru
    } catch (e) {
      /* ... handle error ... */
      _errorMessage = "Gagal update teks: ${e.toString()}";
      notifyListeners();
    }
  }

  //? 5. FUNGSI FILTER (HANYA MENGUBAH STATE & NOTIFY)
  //* aksi untuk mengubah filter status
  void setFilter(FilterStatus status) {
    _filterStatus = status;
    notifyListeners(); // UI akan rebuild dengan 'filteredTodos' baru
  }

  //* aksi untuk mengubah query pencarian
  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners(); // UI akan rebuild dengan 'filteredTodos' baru
  }
}
