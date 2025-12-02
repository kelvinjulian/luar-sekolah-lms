import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../domain/entities/todo.dart';
import '../../controllers/todo_controller.dart';

const Color lsGreen = Color(0xFF0DA680);

class TodoDetailPage extends StatelessWidget {
  // PERBAIKAN: Ubah nama variabel dari 'todoIdOnly' menjadi 'todo'
  final Todo todo;

  const TodoDetailPage({super.key, required this.todo});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<TodoController>();

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          "Detail Tugas",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          IconButton(
            icon: Icon(Icons.delete_outline, color: Colors.red[400]),
            onPressed: () => _confirmDelete(context, controller),
          ),
        ],
      ),
      body: Obx(() {
        // Cari data terbaru (Live Update)
        final Todo currentTodo = controller.allTodos.firstWhere(
          (t) => t.id == todo.id,
          orElse: () => todo, // Gunakan data awal jika tidak ketemu
        );

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. KARTU UTAMA
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.08),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildStatusChip(currentTodo.completed),
                        Icon(
                          currentTodo.completed
                              ? Icons.check_circle
                              : Icons.pending,
                          color: currentTodo.completed
                              ? lsGreen
                              : Colors.orange,
                          size: 28,
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Text(
                      currentTodo.text,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                        decoration: currentTodo.completed
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "ID: ${currentTodo.id ?? '-'}",
                      style: TextStyle(fontSize: 12, color: Colors.grey[400]),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // 2. KARTU WAKTU
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.08),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Tenggat Waktu",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: lsGreen.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.calendar_month,
                            color: lsGreen,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _formatDate(currentTodo.scheduledTime),
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (currentTodo.scheduledTime != null)
                                Text(
                                  _getTimeRemaining(currentTodo.scheduledTime!),
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: _getRemainingColor(
                                      currentTodo.scheduledTime!,
                                    ),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          final currentTodo = controller.allTodos.firstWhere(
            (t) => t.id == todo.id,
            orElse: () => todo,
          );
          _showEditDialog(context, controller, currentTodo);
        },
        backgroundColor: lsGreen,
        icon: const Icon(Icons.edit),
        label: const Text("Edit Tugas"),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  // --- WIDGET HELPERS ---

  Widget _buildStatusChip(bool isCompleted) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isCompleted
            ? lsGreen.withOpacity(0.1)
            : Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isCompleted ? lsGreen : Colors.orange,
          width: 1,
        ),
      ),
      child: Text(
        isCompleted ? "Selesai" : "Belum Selesai",
        style: TextStyle(
          color: isCompleted ? lsGreen : Colors.orange[800],
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return "Belum diatur";
    return DateFormat('EEEE, dd MMMM yyyy • HH:mm', 'id_ID').format(date);
  }

  String _getTimeRemaining(DateTime date) {
    final now = DateTime.now();
    final diff = date.difference(now);
    if (diff.isNegative) return "Terlewat";
    if (diff.inDays > 0) return "${diff.inDays} hari lagi";
    if (diff.inHours > 0) return "${diff.inHours} jam lagi";
    return "${diff.inMinutes} menit lagi";
  }

  Color _getRemainingColor(DateTime date) {
    if (date.isBefore(DateTime.now())) return Colors.red;
    if (date.difference(DateTime.now()).inHours < 24) return Colors.orange;
    return Colors.blue;
  }

  void _showEditDialog(
    BuildContext context,
    TodoController controller,
    Todo todoItem,
  ) {
    final textC = TextEditingController(text: todoItem.text);
    final ValueNotifier<DateTime?> dateNotifier = ValueNotifier(
      todoItem.scheduledTime,
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
            left: 20,
            right: 20,
            top: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Edit Tugas",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: textC,
                autofocus: true,
                maxLines: 2,
                minLines: 1,
                decoration: InputDecoration(
                  labelText: "Deskripsi Tugas",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: lsGreen, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ValueListenableBuilder<DateTime?>(
                valueListenable: dateNotifier,
                builder: (context, date, child) {
                  return InkWell(
                    onTap: () async {
                      final d = await showDatePicker(
                        context: context,
                        initialDate: date ?? DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2030),
                      );
                      if (d != null && context.mounted) {
                        final t = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.fromDateTime(
                            date ?? DateTime.now(),
                          ),
                        );
                        if (t != null) {
                          dateNotifier.value = DateTime(
                            d.year,
                            d.month,
                            d.day,
                            t.hour,
                            t.minute,
                          );
                        }
                      }
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade400),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.event, color: lsGreen),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Tenggat Waktu",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                              Text(
                                date == null
                                    ? "Atur Jadwal"
                                    : DateFormat(
                                        'dd MMM yyyy, HH:mm',
                                      ).format(date),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),
                          if (date != null)
                            IconButton(
                              icon: const Icon(Icons.clear, color: Colors.grey),
                              onPressed: () => dateNotifier.value = null,
                            )
                          else
                            const Icon(
                              Icons.arrow_forward_ios,
                              size: 16,
                              color: Colors.grey,
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (textC.text.isNotEmpty) {
                      final updatedTodo = todoItem.copyWith(
                        text: textC.text,
                        scheduledTime: dateNotifier.value,
                      );
                      controller.updateTodo(updatedTodo);
                      Navigator.pop(ctx);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: lsGreen,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "Simpan Perubahan",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  void _confirmDelete(BuildContext context, TodoController controller) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text("Hapus Tugas?"),
        content: const Text("Tugas ini akan dihapus permanen."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Batal", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              if (todo.id != null) {
                controller.removeTodo(todo.id!);
                Navigator.pop(ctx);
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text("Hapus"),
          ),
        ],
      ),
    );
  }
}
