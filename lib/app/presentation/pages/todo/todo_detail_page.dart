// lib/app/presentation/pages/todo/todo_detail_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

// --- VERIFIKASI IMPORT ---
// Path ini sudah disesuaikan dengan struktur folder Anda
import '../../../domain/entities/todo.dart';
import '../../controllers/todo_controller.dart';
// -------------------------

class TodoDetailPage extends StatelessWidget {
  //? Menerima data 'todo' (versi lama/basi)
  //? yang dikirim dari halaman daftar (via GoRouter 'extra' atau Get.to)
  final Todo todo;

  const TodoDetailPage({super.key, required this.todo});

  //* --- FUNGSI BARU UNTUK MENAMPILKAN DIALOG EDIT ---
  void _showEditTodoDialog(BuildContext context) {
    // Kita 'pass' context dari Scaffold dan todo dari widget
    showDialog(
      context: context,
      builder: (dialogContext) {
        // Tampilkan widget _EditDialog (yang ada di bawah)
        return _EditDialog(
          // Kirim data 'todo' lama ke dialog
          todo: todo,

          // Tentukan apa yang terjadi saat dialog menekan 'Simpan'
          onSave: (newText) async {
            // Ambil Controller global (pakai Get.find)
            final controller = Get.find<TodoController>();

            // Panggil fungsi di Controller untuk melakukan update
            await controller.updateTodoText(todo, newText);

            // Tutup dialog edit
            if (dialogContext.mounted) Navigator.pop(dialogContext);
            // Tutup halaman detail (kembali ke halaman daftar)
            if (context.mounted) Navigator.pop(context);
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    //? 1. "TEMUKAN" CONTROLLER GLOBAL
    //?    Get.find() akan menemukan instance TodoController
    //?    yang sudah dibuat oleh TodoBinding
    final controller = Get.find<TodoController>();

    return Scaffold(
      appBar: AppBar(title: const Text("Detail Tugas")),

      //? 2. "TONTON" STATE DENGAN 'Obx'
      //?    'Obx' berarti: "Setiap kali state .obs di dalamnya
      //?    berubah, bangun ulang (rebuild) widget ini."
      body: Obx(() {
        //? 3. LOGIKA DATA 'FRESH'
        //?    Daripada cuma menampilkan 'todo' (yang mungkin datanya basi),
        //?    kita cari 'todo' dengan ID yang sama di dalam state Controller
        //?    yang kita tahu adalah data terbaru.
        final currentTodo = controller.allTodos.firstWhere(
          (item) => item.id == todo.id,
          // Jika tidak ketemu (misal, baru dihapus), pakai data 'todo' lama
          orElse: () => todo,
        );

        //? 4. BANGUN UI DENGAN DATA 'FRESH'
        return Padding(
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
                    // 5. Tampilkan data dari 'currentTodo'
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
                      // 6. Tampilkan status terbaru
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
        );
      }),

      //? 5. TOMBOL AKSI 'EDIT'
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Panggil fungsi (di atas)
          _showEditTodoDialog(context);
        },
        child: const Icon(Icons.edit),
        tooltip: 'Edit Tugas',
      ),
    );
  }
} // <-- Kurung tutup class TodoDetailPage

//==========================================================
// --- WIDGET HELPER UNTUK DIALOG EDIT ---
//==========================================================
// Ini adalah widget yang menyebabkan error Anda sebelumnya.
// Dia harus ada di file ini.
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
      title: const Text('Edit Tugas'),
      content: TextField(
        controller: _controller, // Hubungkan controller
        autofocus: true,
        decoration: const InputDecoration(labelText: 'Teks tugas'),
        maxLines: 3, // Izinkan beberapa baris
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context), // Tutup dialog (Batal)
          child: const Text('Batal'),
        ),
        ElevatedButton(
          onPressed: () {
            // 5. Saat "Simpan" ditekan
            if (_controller.text.isNotEmpty) {
              // 6. Panggil callback 'onSave'
              widget.onSave(_controller.text);
            }
          },
          child: const Text('Simpan'),
        ),
      ],
    );
  }
}
