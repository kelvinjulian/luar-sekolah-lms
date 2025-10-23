// lib/pages/todo_list_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart'; // Import untuk navigasi
import '../viewmodels/todo_viewmodel.dart';
import '../models/todo.dart';

//* --- UBAH MENJADI STATEFULWIDGET ---
class TodoListPage extends StatefulWidget {
  const TodoListPage({super.key});

  @override
  State<TodoListPage> createState() => _TodoListPageState();
}

class _TodoListPageState extends State<TodoListPage> {
  //* Kita tidak perlu initState() untuk fetch data lagi
  // karena sekarang dilakukan di main.dart

  @override
  Widget build(BuildContext context) {
    //? 1. "TONTON" VIEWMODEL GLOBAL
    //? 'watch' berarti: "Bangun ulang halaman ini jika ViewModel berubah"
    final viewModel = context.watch<TodoViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Daftar Tugas (LMS)"),
        backgroundColor: Colors.white,
        elevation: 1,
        automaticallyImplyLeading: false,
        actions: [
          //? Tombol refresh memanggil fetchTodos dari ViewModel global
          if (viewModel.isLoading && viewModel.filteredTodos.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else
            IconButton(
              icon: Icon(Icons.refresh),
              onPressed: viewModel.fetchTodos, // Panggil fetch dari VM global
            ),
        ],
      ),
      body: Column(
        children: [
          //? 2. KIRIM VIEWMODEL KE WIDGET FILTER
          _buildSearchAndFilter(viewModel),
          Expanded(
            // Gunakan 'Builder' untuk logika if/else
            child: Builder(
              builder: (context) {
                //? 3. TAMPILKAN UI BERDASARKAN STATE VIEWMODEL
                // ini adalah pengganti future builder
                // Ini seperti 'snapshot.connectionState == ConnectionState.waiting'
                if (viewModel.isLoading && viewModel.filteredTodos.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }
                // Ini seperti 'snapshot.hasError'
                if (viewModel.errorMessage != null &&
                    viewModel.filteredTodos.isEmpty) {
                  return _buildErrorState(context, viewModel.errorMessage!);
                }
                if (viewModel.filteredTodos.isEmpty) {
                  return _buildEmptyState();
                }

                // 4. DATA AMAN, TAMPILKAN LISTVIEW
                // Ini sama dengan 'snapshot.hasData'
                return ListView.builder(
                  itemCount: viewModel.filteredTodos.length,
                  itemBuilder: (context, index) {
                    final todo = viewModel.filteredTodos[index];
                    return _buildTodoTile(context, todo, viewModel);
                  },
                );
              },
            ),
          ),
        ],
      ),

      //? 5. TOMBOL TAMBAH (CREATE)
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddTodoDialog(context); // Panggil dialog
        },
        child: Icon(Icons.add),
        tooltip: 'Tambah Tugas',
      ),
    );
  }

  //? 6. Dialog untuk menambah todo
  void _showAddTodoDialog(BuildContext context) {
    final TextEditingController textController = TextEditingController();
    // Ambil VM global (listen: false)
    final viewModel = context.read<TodoViewModel>();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text('Tambah Tugas Baru'),
          content: TextField(
            controller: textController,
            decoration: InputDecoration(hintText: 'Tulis tugas...'),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (textController.text.isEmpty) return;
                await viewModel.addTodo(textController.text);
                if (dialogContext.mounted) Navigator.pop(dialogContext);
              },
              child: Text('Simpan'),
            ),
          ],
        );
      },
    );
  }

  //? 7. WIDGET HELPERS UNTUK ERROR STATE
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
            ElevatedButton(
              onPressed: () {
                context.read<TodoViewModel>().fetchTodos();
              },
              child: const Text("Coba Lagi (Retry)"),
            ),
          ],
        ),
      ),
    );
  }

  //? 8. WIDGET HELPERS UNTUK EMPTY STATE
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
              "Tekan tombol + untuk menambah data baru.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  //? 9 . WIDGET HELPERS UNTUK SEARCH & FILTER
  Widget _buildSearchAndFilter(TodoViewModel viewModel) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          TextField(
            decoration: const InputDecoration(
              labelText: 'Cari tugas...',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
            onChanged: viewModel.setSearchQuery,
          ),
          const SizedBox(height: 10),
          SegmentedButton<FilterStatus>(
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
            selected: {viewModel.filterStatus},
            onSelectionChanged: (newSelection) {
              viewModel.setFilter(newSelection.first);
            },
          ),
        ],
      ),
    );
  }

  //? 10. WIDGET TILE UNTUK TIAP ITEM
  Widget _buildTodoTile(
    BuildContext context,
    Todo todo,
    TodoViewModel viewModel,
  ) {
    return ListTile(
      title: Text(
        todo.text,
        style: TextStyle(
          decoration: todo.completed ? TextDecoration.lineThrough : null,
          color: todo.completed ? Colors.grey[600] : null,
        ),
      ),

      //? 11. Update (Toggle Status)
      leading: Checkbox(
        value: todo.completed,
        onChanged: (bool? value) {
          viewModel.toggleTodoStatus(todo); // Panggil ViewModel
        },
      ),
      trailing: IconButton(
        icon: Icon(Icons.delete_outline, color: Colors.red.shade700),

        // ? 12. Delete dengan konfirmasi
        onPressed: () async {
          // Jadikan async
          // 1. Tampilkan dialog konfirmasi
          final bool? shouldDelete = await showDialog<bool>(
            context: context,
            builder: (dialogContext) {
              return AlertDialog(
                title: Text('Konfirmasi Hapus'),
                content: Text(
                  'Apakah Anda yakin ingin menghapus "${todo.text}"?',
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      // Tutup dialog, kembalikan 'false' (Batal)
                      Navigator.pop(dialogContext, false);
                    },
                    child: Text('Batal'),
                  ),
                  TextButton(
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.red, // Beri warna merah
                    ),
                    onPressed: () {
                      // Tutup dialog, kembalikan 'true' (Hapus)
                      Navigator.pop(dialogContext, true);
                    },
                    child: Text('Hapus'),
                  ),
                ],
              );
            },
          );

          // 2. Hanya hapus jika pengguna menekan 'Hapus' (true)
          if (shouldDelete == true) {
            if (todo.id != null) {
              // (context.mounted) adalah pengecekan keamanan
              if (context.mounted) {
                context.read<TodoViewModel>().removeTodo(
                  todo.id!,
                ); //? 13. Panggil ViewModel
              }
            }
          }
        },
      ),

      //? 14. Navigasi ke halaman detail
      onTap: () {
        context.push('/todo-detail', extra: todo);
      },
    );
  }
}
