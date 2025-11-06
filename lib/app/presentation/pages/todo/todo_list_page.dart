// lib/app/presentation/pages/todo/todo_list_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

// --- VERIFIKASI IMPORT ---
import '../../controllers/todo_controller.dart';
import '../../../domain/entities/todo.dart';
// -------------------------

class TodoListPage extends StatelessWidget {
  const TodoListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<TodoController>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Daftar Tugas (LMS)"),
        backgroundColor: Colors.white,
        elevation: 1,
        automaticallyImplyLeading: false,
        actions: [
          // Obx ini sudah benar
          Obx(() {
            if (controller.isLoading.value &&
                controller.filteredTodos.isNotEmpty) {
              return const Padding(
                padding: EdgeInsets.all(16.0),
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              );
            } else {
              return IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: controller.fetchTodos,
              );
            }
          }),
        ],
      ),
      body: Column(
        children: [
          _buildSearchAndFilter(
            controller,
          ), // Obx di dalam widget ini sudah benar
          //? --- PERBAIKAN DI SINI ---
          //? Kita hapus widget 'Builder' yang tidak perlu dari dalam Obx
          Expanded(
            child: Obx(() {
              // 'context' yang digunakan di sini adalah 'context'
              // dari 'build' method utama, ini sudah benar.

              if (controller.isLoading.value &&
                  controller.filteredTodos.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }

              if (controller.errorMessage.value != null &&
                  controller.filteredTodos.isEmpty) {
                return _buildErrorState(
                  context, // <-- Menggunakan context dari build method
                  controller.errorMessage.value!,
                );
              }

              if (controller.filteredTodos.isEmpty) {
                return _buildEmptyState();
              }

              return ListView.builder(
                itemCount: controller.filteredTodos.length,
                itemBuilder: (listContext, index) {
                  // 'listContext' adalah context baru dari ListView
                  final todo = controller.filteredTodos[index];
                  return _buildTodoTile(listContext, todo, controller);
                },
              );
            }),
          ),
          //? --------------------------
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddTodoDialog(context);
        },
        child: const Icon(Icons.add),
        tooltip: 'Tambah Tugas',
      ),
    );
  }

  // --- TIDAK ADA PERUBAHAN DARI SINI KE BAWAH ---

  void _showAddTodoDialog(BuildContext context) {
    final TextEditingController textController = TextEditingController();
    final controller = Get.find<TodoController>();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Tambah Tugas Baru'),
          content: TextField(
            controller: textController,
            decoration: const InputDecoration(hintText: 'Tulis tugas...'),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (textController.text.isEmpty) return;
                await controller.addTodo(textController.text);
                if (dialogContext.mounted) Navigator.pop(dialogContext);
              },
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildErrorState(BuildContext context, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: Colors.red.shade400, size: 60),
            const SizedBox(height: 16),
            const Text(
              "Oops, terjadi kesalahan",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Get.find<TodoController>().fetchTodos();
              },
              child: const Text("Coba Lagi (Retry)"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.check_circle_outline,
            color: Colors.grey.shade400,
            size: 60,
          ),
          const SizedBox(height: 16),
          const Text(
            "Tidak ada data",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const Text(
            "Filter Anda saat ini tidak menemukan hasil.",
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilter(TodoController controller) {
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
            onChanged: controller.setSearchQuery,
          ),
          const SizedBox(height: 10),
          Obx(
            () => SegmentedButton<FilterStatus>(
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
              selected: {controller.filterStatus.value},
              onSelectionChanged: (newSelection) {
                controller.setFilter(newSelection.first);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTodoTile(
    BuildContext context,
    Todo todo,
    TodoController controller,
  ) {
    return ListTile(
      title: Text(
        todo.text,
        style: TextStyle(
          decoration: todo.completed ? TextDecoration.lineThrough : null,
          color: todo.completed ? Colors.grey[600] : null,
        ),
      ),
      leading: Checkbox(
        value: todo.completed,
        onChanged: (bool? value) {
          controller.toggleTodoStatus(todo);
        },
      ),
      trailing: IconButton(
        icon: Icon(Icons.delete_outline, color: Colors.red.shade700),
        onPressed: () async {
          final bool? shouldDelete = await showDialog<bool>(
            context: context,
            builder: (dialogContext) {
              return AlertDialog(
                title: const Text('Konfirmasi Hapus'),
                content: Text(
                  'Apakah Anda yakin ingin menghapus "${todo.text}"?',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(dialogContext, false),
                    child: const Text('Batal'),
                  ),
                  TextButton(
                    style: TextButton.styleFrom(foregroundColor: Colors.red),
                    onPressed: () => Navigator.pop(dialogContext, true),
                    child: const Text('Hapus'),
                  ),
                ],
              );
            },
          );

          if (shouldDelete == true) {
            if (todo.id != null) {
              controller.removeTodo(todo.id!);
            }
          }
        },
      ),
      onTap: () {
        Get.toNamed('/todo-detail', arguments: todo);
      },
    );
  }
}
