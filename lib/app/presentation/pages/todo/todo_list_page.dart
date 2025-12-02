// lib/app/presentation/pages/todo/todo_list_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/todo_controller.dart';
import '../../../domain/entities/todo.dart';

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
              return Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: () => controller.fetchTodos(isRefresh: true),
                  ),

                  //! TOMBOL DEBUG (Hapus semua / Inject Dummy Data)
                  PopupMenuButton<String>(
                    onSelected: (value) async {
                      if (value == 'inject') {
                        controller.injectDummyData();
                      } else if (value == 'delete_all') {
                        // Konfirmasi dulu agar tidak kepencet tidak sengaja
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text("Hapus Semua?"),
                            content: const Text(
                              "Ini akan menghapus semua data yang tampil di layar.",
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(ctx, false),
                                child: const Text("Batal"),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(ctx, true),
                                child: const Text(
                                  "Hapus",
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                            ],
                          ),
                        );

                        if (confirm == true) {
                          controller.deleteAllTodos();
                        }
                      }
                    },
                    itemBuilder: (BuildContext context) {
                      return [
                        const PopupMenuItem<String>(
                          value: 'inject',
                          child: Row(
                            children: [
                              Icon(Icons.download, color: Colors.blue),
                              SizedBox(width: 8),
                              Text('Inject 50 Dummy Data'),
                            ],
                          ),
                        ),
                        const PopupMenuItem<String>(
                          value: 'delete_all',
                          child: Row(
                            children: [
                              Icon(Icons.delete_forever, color: Colors.red),
                              SizedBox(width: 8),
                              Text(
                                'Hapus Semua Data',
                                style: TextStyle(color: Colors.red),
                              ),
                            ],
                          ),
                        ),
                      ];
                    },
                  ),
                ],
              );
            }
          }),
        ],
      ),
      body: Column(
        children: [
          _buildSearchAndFilter(controller),

          // FITUR BARU: TOTAL DATA COUNTER
          _buildTotalCount(controller),

          Expanded(
            child: Obx(() {
              // 1. Error State
              if (controller.errorMessage.value != null &&
                  controller.filteredTodos.isEmpty) {
                return _buildErrorState(
                  context,
                  controller.errorMessage.value!,
                );
              }

              // 2. Loading State (Init)
              if (controller.isLoading.value &&
                  controller.filteredTodos.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }

              // 3. Empty State
              if (controller.filteredTodos.isEmpty) {
                return _buildEmptyState();
              }

              // 4. List Data
              return ListView.builder(
                controller: controller.scrollController,
                physics:
                    const AlwaysScrollableScrollPhysics(), // Agar enak di-scroll
                itemCount:
                    controller.filteredTodos.length +
                    (controller.isMoreLoading.value ? 1 : 0),
                itemBuilder: (listContext, index) {
                  if (index == controller.filteredTodos.length) {
                    return const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }

                  final todo = controller.filteredTodos[index];
                  return _buildTodoTile(listContext, todo, controller);
                },
              );
            }),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTodoDialog(context),
        tooltip: 'Tambah Tugas',
        child: const Icon(Icons.add),
      ),
    );
  }

  // --- WIDGET BARU: PENAMPIL TOTAL DATA ---
  Widget _buildTotalCount(TodoController controller) {
    return Obx(
      () => Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        color: Colors.grey.shade100, // Background tipis biar rapi
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              // Menampilkan jumlah data yang ada di list saat ini
              "Data dimuat: ${controller.filteredTodos.length}",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
              ),
            ),
            // Indikator kecil jika sedang memuat halaman berikutnya
            if (controller.isMoreLoading.value)
              Text(
                "Memuat lebih banyak...",
                style: TextStyle(fontSize: 12, color: Colors.blue.shade700),
              ),
          ],
        ),
      ),
    );
  }

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
              onPressed: () =>
                  Get.find<TodoController>().fetchTodos(isRefresh: true),
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
            "Mulai dengan menambahkan tugas baru.",
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
        onChanged: (bool? value) => controller.toggleTodoStatus(todo),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.alarm, color: Colors.orange),
            tooltip: 'Ingatkan 5 detik lagi',
            onPressed: () => controller.scheduleTodoReminder(todo),
          ),
          IconButton(
            icon: Icon(Icons.delete_outline, color: Colors.red.shade700),
            tooltip: 'Hapus',
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
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.red,
                        ),
                        onPressed: () => Navigator.pop(dialogContext, true),
                        child: const Text('Hapus'),
                      ),
                    ],
                  );
                },
              );

              if (shouldDelete == true && todo.id != null) {
                controller.removeTodo(todo.id!);
              }
            },
          ),
        ],
      ),
      onTap: () {
        Get.toNamed('/todo-detail', arguments: todo);
      },
    );
  }
}
