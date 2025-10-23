// lib/viewmodels/todo_viewmodel.dart
import 'package:flutter/foundation.dart';

// import model dan service
import '../models/todo.dart';
import '../services/todo_service.dart';

// Enum untuk status filter
enum FilterStatus { all, completed, pending }

class TodoViewModel extends ChangeNotifier {
  final TodoService _service = TodoService();

  // State untuk data utama
  List<Todo> _allTodos = []; // Daftar master semua todo dari server

  // State untuk UI
  bool _isLoading = false; // Status apakah sedang loading
  String? _errorMessage; // Pesan error jika terjadi kegagalan
  FilterStatus _filterStatus =
      FilterStatus.all; // Filter yang sedang aktif (all/completed/pending)
  String _searchQuery = ""; // Teks yang sedang diketik di TextField pencarian

  // Getter untuk UI
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Kita tambahkan getter publik agar UI bisa membaca
  // status filter yang sedang aktif.
  FilterStatus get filterStatus => _filterStatus;
  // =======================================================

  //? Getter yang sudah di-filter untuk ditampilkan di UI
  // Getter ini mengambil _allTodos, lalu menyaringnya berdasarkan _filterStatus dan _searchQuery sebelum dikirim ke UI
  List<Todo> get filteredTodos {
    List<Todo> todos = _allTodos;

    //? 1. Filter berdasarkan Status
    if (_filterStatus == FilterStatus.completed) {
      todos = todos.where((todo) => todo.completed).toList();
    } else if (_filterStatus == FilterStatus.pending) {
      todos = todos.where((todo) => !todo.completed).toList();
    }

    //? 2. Filter berdasarkan Pencarian
    if (_searchQuery.isNotEmpty) {
      todos = todos
          .where(
            (todo) =>
                todo.title.toLowerCase().contains(_searchQuery.toLowerCase()),
          )
          .toList();
    }

    return todos;
  }

  //? Aksi untuk mengambil data
  // fetchTodos memanggil TodoService, mengatur _isLoading dan menyimpan hasilnya ke _allTodos
  Future<void> fetchTodos() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners(); // Memberi tahu UI untuk update (tampilkan loading)

    try {
      _allTodos = await _service.fetchTodos();
    } catch (e) {
      _errorMessage = e.toString();
    }

    _isLoading = false;
    notifyListeners(); // Memberi tahu UI untuk update (tampilkan data/error)
  }

  //? Aksi untuk mengubah filter
  void setFilter(FilterStatus status) {
    _filterStatus = status;
    notifyListeners(); // UI akan otomatis me-render ulang `filteredTodos`
  }

  //? Aksi untuk mengubah query pencarian
  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners(); // UI akan otomatis me-render ulang `filteredTodos`
  }
}
