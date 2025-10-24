// lib/pages/todo_detail_page.dart
import 'package:flutter/material.dart';
import '../models/todo.dart';
import 'package:provider/provider.dart'; // 1. import provider untuk 'watch' dan 'read'
import '../viewmodels/todo_viewmodel.dart'; // 2. Import ViewModel (Otak) kita

//? Ini adalah 'View' (UI) untuk halaman detail.
// Halaman ini bersifat 'Stateless' karena semua state-nya dikelola oleh ViewModel.
class TodoDetailPage extends StatelessWidget {
  //? 3. Halaman ini Menerima data 'todo' (versi lama)
  //?    yang dikirim dari halaman daftar (via GoRouter 'extra')
  final Todo todo;

  const TodoDetailPage({super.key, required this.todo});

  //* --- FUNGSI BARU UNTUK MENAMPILKAN DIALOG EDIT ---
  //? --- 10. FUNGSI UNTUK MEMUNCULKAN DIALOG EDIT ---
  //?    (Dipanggil oleh Tombol FAB 'Edit' di bawah)
  void _showEditTodoDialog(BuildContext context) {
    // Kita 'pass' context dari Scaffold dan todo dari widget
    showDialog(
      context: context,
      builder: (dialogContext) {
        // 11. Tampilkan widget _EditDialog (yang ada di bawah)
        return _EditDialog(
          // 12. Kirim data 'todo' lama ke dialog
          todo: todo,

          // 13. Tentukan apa yang terjadi saat dialog menekan 'Simpan'
          onSave: (newText) async {
            // 14. Ambil ViewModel global (pakai 'read' karena kita di dalam callback)
            final viewModel = context.read<TodoViewModel>();

            // 15. Panggil fungsi di ViewModel untuk melakukan update
            //     Ini akan memanggil Service -> API -> fetchTodos() -> notifyListeners()
            await viewModel.updateTodoText(todo, newText);

            // 16. Tutup dialog edit
            if (dialogContext.mounted) Navigator.pop(dialogContext);
            // 17. Tutup halaman detail (kembali ke halaman daftar)
            if (context.mounted) Navigator.pop(context);
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    //? 4. "TONTON" VIEWMODEL GLOBAL
    //?    'context.watch' berarti: "Setiap kali ViewModel (Otak) memanggil
    //?    notifyListeners(), bangun ulang (rebuild) widget ini."
    //?    ➡️ Ini PENTING agar data di halaman ini otomatis refresh
    final viewModel = context.watch<TodoViewModel>();

    //? 5. LOGIKA DATA 'FRESH'
    //?    Daripada cuma menampilkan 'todo' (yang mungkin datanya basi),
    //?    kita cari 'todo' dengan ID yang sama di dalam state ViewModel (filteredTodos)
    //?    yang kita tahu adalah data terbaru dari server.
    final currentTodo = viewModel.filteredTodos.firstWhere(
      (item) => item.id == todo.id,
      // Jika tidak ketemu (misal, baru dihapus), pakai data 'todo' lama
      orElse: () => todo,
    );

    //? 6. BANGUN UI
    return Scaffold(
      appBar: AppBar(title: const Text("Detail Tugas")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  // 7. Tampilkan data dari 'currentTodo' (data 'fresh')
                  currentTodo.text, // Tampilkan teks terbaru
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Text(
                      "Status: ",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    // 8. Tampilkan status terbaru
                    Text(
                      currentTodo.completed ? "Selesai" : "Pending",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: currentTodo.completed
                            ? Colors.green.shade700
                            : Colors.orange.shade700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  "ID: ${currentTodo.id ?? 'N/A'}",
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
      ),

      //? 9. TOMBOL AKSI 'EDIT'
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Panggil fungsi no. 10 (di atas)
          _showEditTodoDialog(context);
        },
        child: Icon(Icons.edit),
        tooltip: 'Edit Tugas',
      ),
    );
  }
}

//* ==========================================================
//* --- WIDGET HELPER UNTUK DIALOG EDIT ---
//* ==========================================================
//? Kita buat StatefulWidget TERPISAH karena dialog ini perlu
//? mengelola state-nya sendiri, yaitu 'TextEditingController'
class _EditDialog extends StatefulWidget {
  final Todo todo; // Data todo lama
  final Function(String newText) onSave; // Callback 'Simpan'

  const _EditDialog({required this.todo, required this.onSave});

  @override
  State<_EditDialog> createState() => _EditDialogState();
}

class _EditDialogState extends State<_EditDialog> {
  // 1. Buat controller untuk TextField
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    // 2. Saat dialog pertama kali dibuat,
    //    isi TextField dengan teks 'todo' yang ada
    _controller = TextEditingController(text: widget.todo.text);
  }

  @override
  void dispose() {
    // 3. Bersihkan controller saat dialog ditutup
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 4. Bangun UI Dialog
    return AlertDialog(
      title: Text('Edit Tugas'),
      content: TextField(
        controller: _controller, // Hubungkan controller
        autofocus: true,
        decoration: InputDecoration(labelText: 'Teks tugas'),
        maxLines: 3, // Izinkan beberapa baris
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context), // Tutup dialog (Batal)
          child: Text('Batal'),
        ),
        ElevatedButton(
          onPressed: () {
            // 5. Saat "Simpan" ditekan
            if (_controller.text.isNotEmpty) {
              // 6. Panggil callback 'onSave' (yang ada di TodoDetailPage)
              //    dan kirim teks baru dari controller
              widget.onSave(_controller.text);
            }
          },
          child: Text('Simpan'),
        ),
      ],
    );
  }
}
