// lib/pages/todo_list_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart'; // <-- IMPORT PENTING
import '../viewmodels/todo_viewmodel.dart';
import '../models/todo.dart';

// Kita gunakan 'ChangeNotifierProvider' untuk 'membuat' ViewModel
// saat halaman ini pertama kali dibuat.
class TodoListPage extends StatelessWidget {
  const TodoListPage({super.key});

  @override
  Widget build(BuildContext context) {
    //? Membungkus Scaffold dengan ChangeNotifierProvider, ini membuat ViewModel saat halaman dibuka pertama kali dan otomatis memanggil fetchTodos() pertama kali
    return ChangeNotifierProvider(
      create: (context) =>
          TodoViewModel()..fetchTodos(), // Langsung panggil fetchTodos
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Daftar Tugas (Todos)"),
          backgroundColor: Colors.white,
          elevation: 1,
        ),
        body: Column(
          children: [
            // --- BAGIAN SEARCH & FILTER ---
            _buildSearchAndFilter(),

            // --- BAGIAN LIST DATA ---
            Expanded(
              // 'Consumer' mendengarkan perubahan pada TodoViewModel
              child: Consumer<TodoViewModel>(
                builder: (context, viewModel, child) {
                  //? 1. Loading State
                  if (viewModel.isLoading && viewModel.filteredTodos.isEmpty) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  //? 2. Error State
                  if (viewModel.errorMessage != null) {
                    return _buildErrorState(context, viewModel.errorMessage!);
                  }

                  //? 3. Empty State (setelah filter atau search)
                  if (viewModel.filteredTodos.isEmpty) {
                    return _buildEmptyState();
                  }

                  //? 4. Success/Data State
                  // (Tugas: Pull to Refresh)
                  return RefreshIndicator(
                    onRefresh:
                        viewModel.fetchTodos, // Panggil fungsi fetch lagi
                    //? listView.builder menggunakan viewModel.filteredTodos (bukan _allTodos) untuk menampilkan data yang sudah di-filter
                    child: ListView.builder(
                      itemCount: viewModel.filteredTodos.length,
                      itemBuilder: (context, index) {
                        final todo = viewModel.filteredTodos[index];
                        return _buildTodoTile(context, todo);
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  //? Widget untuk Error State
  Widget _buildErrorState(BuildContext context, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 50),
            const SizedBox(height: 10),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 20),
            // (Tugas: Tombol Retry)
            ElevatedButton(
              onPressed: () {
                // Panggil fetchTodos lagi
                context.read<TodoViewModel>().fetchTodos();
              },
              child: const Text("Coba Lagi (Retry)"),
            ),
          ],
        ),
      ),
    );
  }

  //? Widget untuk Empty State
  Widget _buildEmptyState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 50, color: Colors.grey),
            SizedBox(height: 10),
            Text(
              "Tidak ada data",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              "Tidak ada todo yang sesuai dengan filter atau pencarian Anda.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  //? Widget untuk Search dan Filter
  Widget _buildSearchAndFilter() {
    // Kita pakai Consumer di sini agar tidak me-rebuild seluruh halaman
    return Consumer<TodoViewModel>(
      builder: (context, viewModel, child) {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              // (Tugas: Pencarian Judul Todo)
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Cari judul todo...',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  // Panggil fungsi di ViewModel
                  viewModel.setSearchQuery(value);
                },
              ),
              const SizedBox(height: 10),
              // (Tugas: Filter Status)
              SegmentedButton<FilterStatus>(
                // Gunakan style dari PR Minggu 5 jika perlu
                style: SegmentedButton.styleFrom(
                  //... kustomisasi style jika ada
                ),
                segments: const [
                  ButtonSegment(value: FilterStatus.all, label: Text('All')),
                  ButtonSegment(
                    value: FilterStatus.completed,
                    label: Text('Completed'),
                  ),
                  ButtonSegment(
                    value: FilterStatus.pending,
                    label: Text('Pending'),
                  ),
                ],
                // 'selected' butuh Set, dan 'filterStatus' adalah getter
                selected: {viewModel.filterStatus},
                onSelectionChanged: (newSelection) {
                  // Panggil fungsi di ViewModel
                  viewModel.setFilter(newSelection.first);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  //? Widget untuk satu item Todo
  Widget _buildTodoTile(BuildContext context, Todo todo) {
    return ListTile(
      // (Tugas: Menampilkan title dan completed)
      title: Text(todo.title),
      leading: Checkbox(
        value: todo.completed,
        onChanged: null, // Biar non-aktif
      ),
      trailing: Icon(
        todo.completed ? Icons.check_circle : Icons.radio_button_unchecked,
        color: todo.completed ? Colors.green : Colors.grey,
      ),
      onTap: () {
        // ===============================================
        // --- PERUBAHAN NAVIGASI MENGGUNAKAN GO_ROUTER ---
        // ===============================================

        // Ganti Navigator.of(context).push
        // menjadi context.push

        // Kita 'push' rute '/todo-detail' yang sudah kita daftarkan
        // dan mengirim objek 'todo' sebagai 'extra'.
        // GoRouter akan menangani sisanya (animasi, data passing).
        context.push('/todo-detail', extra: todo);

        // --- Versi Lama ---
        // Navigator.of(context).push(MaterialPageRoute(
        //   builder: (context) => TodoDetailPage(todo: todo),
        // ));
      },
    );
  }
}

// =======================================================
// --- HALAMAN DETAIL TODO ---
// =======================================================
// Tidak ada perubahan di sini, GoRouter akan menampilkannya
// dengan benar.

class TodoDetailPage extends StatelessWidget {
  final Todo todo;
  const TodoDetailPage({super.key, required this.todo});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Detail Tugas")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              todo.title,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Text("Status: ", style: const TextStyle(fontSize: 16)),
                Text(
                  todo.completed ? "Selesai" : "Pending",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: todo.completed ? Colors.green : Colors.orange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text("User ID: ${todo.userId}"),
            Text("Todo ID: ${todo.id}"),
          ],
        ),
      ),
    );
  }
}
