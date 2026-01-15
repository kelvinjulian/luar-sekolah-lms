// lib/app/presentation/pages/todo/todo_list_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../controllers/todo_controller.dart';
import '../../../domain/entities/todo.dart';
import './todo_detail_page.dart';

const Color lsGreen = Color(0xFF0DA680);

class TodoListPage extends StatelessWidget {
  const TodoListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<TodoController>();

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          "Daftar Tugas",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: lsGreen),
            onPressed: () => controller.fetchTodos(isRefresh: true),
          ),
        ],
      ),
      body: Column(
        children: [
          // BAGIAN HEADER (Search + Tombol Tambah + Filter)
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Column(
              children: [
                // BARIS PENCARIAN & TOMBOL TAMBAH
                Row(
                  children: [
                    // 1. Kolom Pencarian (Expanded)
                    Expanded(
                      child: SizedBox(
                        height: 48, // Tinggi fix agar sejajar
                        child: TextField(
                          onChanged: controller.setSearchQuery,
                          decoration: InputDecoration(
                            hintText: 'Cari tugas...',
                            prefixIcon: const Icon(
                              Icons.search,
                              color: Colors.grey,
                            ),
                            filled: true,
                            fillColor: Colors.grey[100],
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 0,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // 2. Tombol Tambah (Kotak Hijau Sejajar)
                    SizedBox(
                      height: 48, // Samakan tingginya dengan TextField
                      width: 48, // Buat kotak
                      child: ElevatedButton(
                        onPressed: () => _showAddTodoDialog(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: lsGreen,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.zero, // Biar icon di tengah pas
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              10,
                            ), // Samakan radius
                          ),
                          elevation: 0,
                        ),
                        child: const Icon(Icons.add, size: 28),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Segmen Filter
                Obx(
                  () => SizedBox(
                    width: double.infinity,
                    child: SegmentedButton<FilterStatus>(
                      segments: const [
                        ButtonSegment(
                          value: FilterStatus.all,
                          label: Text('Semua'),
                        ),
                        ButtonSegment(
                          value: FilterStatus.pending,
                          label: Text('Belum'),
                        ),
                        ButtonSegment(
                          value: FilterStatus.completed,
                          label: Text('Selesai'),
                        ),
                      ],
                      selected: {controller.filterStatus.value},
                      onSelectionChanged: (Set<FilterStatus> newSelection) {
                        controller.setFilter(newSelection.first);
                      },
                      style: ButtonStyle(
                        visualDensity: VisualDensity.compact,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        backgroundColor: WidgetStateProperty.resolveWith((
                          states,
                        ) {
                          if (states.contains(WidgetState.selected)) {
                            return lsGreen.withOpacity(0.1);
                          }
                          return null;
                        }),
                        foregroundColor: WidgetStateProperty.resolveWith((
                          states,
                        ) {
                          if (states.contains(WidgetState.selected)) {
                            return lsGreen;
                          }
                          return Colors.grey[700];
                        }),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Total Count
          Obx(
            () => Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: Colors.grey[50],
              child: Text(
                "Total Tugas: ${controller.filteredTodos.length}",
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
            ),
          ),

          // List Data
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value &&
                  controller.filteredTodos.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }

              if (controller.filteredTodos.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.assignment_add,
                        size: 64,
                        color: Colors.grey[300],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "Belum ada tugas",
                        style: TextStyle(color: Colors.grey[500]),
                      ),
                    ],
                  ),
                );
              }

              return ListView.separated(
                controller: controller.scrollController, // <--- WAJIB ADA INI
                physics:
                    const AlwaysScrollableScrollPhysics(), // Agar bisa discroll meski item sedikit
                padding: const EdgeInsets.all(16),
                itemCount:
                    controller.filteredTodos.length +
                    (controller.isMoreLoading.value ? 1 : 0),
                separatorBuilder: (ctx, i) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  // Spinner bawah (Indikator 2 detik)
                  if (index == controller.filteredTodos.length) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child:
                            CircularProgressIndicator(), // Loading ini akan muncul 2 detik
                      ),
                    );
                  }

                  final todo = controller.filteredTodos[index];
                  return _buildModernTodoCard(context, todo, controller);
                },
              );
            }),
          ),
        ],
      ),
      // FAB DIHAPUS (Sudah dipindah ke atas)
    );
  }

  Widget _buildModernTodoCard(
    BuildContext context,
    Todo todo,
    TodoController controller,
  ) {
    Color statusColor = Colors.grey.shade300;
    String timeText = "";

    if (todo.scheduledTime != null) {
      final now = DateTime.now();
      final diff = todo.scheduledTime!.difference(now);
      final formatter = DateFormat('dd MMM, HH:mm');

      if (todo.completed) {
        statusColor = lsGreen;
        timeText = "Selesai";
      } else if (diff.isNegative) {
        statusColor = Colors.red;
        timeText = "Terlewat: ${formatter.format(todo.scheduledTime!)}";
      } else if (diff.inHours < 24) {
        statusColor = Colors.orange;
        timeText = diff.inHours == 0
            ? "${diff.inMinutes} menit lagi"
            : "${diff.inHours} jam lagi";
      } else {
        statusColor = Colors.blue;
        timeText = formatter.format(todo.scheduledTime!);
      }
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border(
          left: BorderSide(
            color: todo.completed
                ? lsGreen
                : (todo.scheduledTime != null
                      ? statusColor
                      : Colors.grey.shade300),
            width: 4,
          ),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            Get.to(() => TodoDetailPage(todo: todo));
          },
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => controller.toggleTodoStatus(todo),
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: todo.completed ? lsGreen : Colors.white,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: todo.completed ? lsGreen : Colors.grey.shade400,
                        width: 2,
                      ),
                    ),
                    child: todo.completed
                        ? const Icon(Icons.check, size: 16, color: Colors.white)
                        : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        todo.text,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          decoration: todo.completed
                              ? TextDecoration.lineThrough
                              : null,
                          color: todo.completed ? Colors.grey : Colors.black87,
                        ),
                      ),
                      if (todo.scheduledTime != null) ...[
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Icon(
                              Icons.access_time_rounded,
                              size: 14,
                              color: statusColor,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              timeText,
                              style: TextStyle(
                                fontSize: 12,
                                color: statusColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.notifications_active_outlined,
                    color: Colors.orange,
                  ),
                  tooltip: 'Atur Pengingat',
                  onPressed: () =>
                      _showReminderDialog(context, controller, todo),
                ),
                IconButton(
                  icon: Icon(Icons.delete_outline, color: Colors.red[300]),
                  onPressed: () => _confirmDelete(context, controller, todo),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showReminderDialog(
    BuildContext context,
    TodoController controller,
    Todo todo,
  ) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Atur Pengingat (Alarm)",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: const Icon(Icons.timer_outlined, color: Colors.blue),
                title: const Text("5 Menit Lagi"),
                onTap: () {
                  Navigator.pop(ctx);
                  controller.scheduleReminder(
                    todo,
                    DateTime.now().add(const Duration(minutes: 5)),
                  );
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.hourglass_bottom,
                  color: Colors.purple,
                ),
                title: const Text("1 Jam Lagi"),
                onTap: () {
                  Navigator.pop(ctx);
                  controller.scheduleReminder(
                    todo,
                    DateTime.now().add(const Duration(hours: 1)),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.calendar_month, color: lsGreen),
                title: const Text("Pilih Waktu Spesifik..."),
                onTap: () async {
                  Navigator.pop(ctx);
                  final date = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2030),
                  );
                  if (date != null && context.mounted) {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                    );
                    if (time != null) {
                      final scheduledDate = DateTime(
                        date.year,
                        date.month,
                        date.day,
                        time.hour,
                        time.minute,
                      );
                      controller.scheduleReminder(todo, scheduledDate);
                    }
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showAddTodoDialog(BuildContext context) {
    final TextEditingController textC = TextEditingController();
    final TodoController controller = Get.find<TodoController>();
    final ValueNotifier<DateTime?> selectedDate = ValueNotifier(null);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text("Tugas Baru"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: textC,
              autofocus: true,
              decoration: const InputDecoration(
                hintText: "Apa yang ingin dikerjakan?",
                border: UnderlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            ValueListenableBuilder<DateTime?>(
              valueListenable: selectedDate,
              builder: (context, date, child) {
                return InkWell(
                  onTap: () async {
                    final d = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2030),
                    );
                    if (d != null && context.mounted) {
                      final t = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                      );
                      if (t != null) {
                        selectedDate.value = DateTime(
                          d.year,
                          d.month,
                          d.day,
                          t.hour,
                          t.minute,
                        );
                      }
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.calendar_today, size: 18, color: lsGreen),
                        const SizedBox(width: 8),
                        Text(
                          date == null
                              ? "Atur Deadline (Opsional)"
                              : DateFormat('dd MMM yyyy, HH:mm').format(date),
                          style: TextStyle(
                            color: date == null ? Colors.grey : Colors.black87,
                          ),
                        ),
                        const Spacer(),
                        if (date != null)
                          GestureDetector(
                            onTap: () => selectedDate.value = null,
                            child: const Icon(
                              Icons.close,
                              size: 18,
                              color: Colors.grey,
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Batal", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              if (textC.text.isNotEmpty) {
                controller.addTodo(textC.text, selectedDate.value);
                Navigator.pop(ctx);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: lsGreen,
              foregroundColor: Colors.white,
            ),
            child: const Text("Simpan"),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(
    BuildContext context,
    TodoController controller,
    Todo todo,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Hapus Tugas?"),
        content: Text("Tugas '${todo.text}' akan dihapus."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Batal"),
          ),
          TextButton(
            onPressed: () {
              if (todo.id != null) controller.removeTodo(todo.id!);
              Navigator.pop(ctx);
            },
            child: const Text("Hapus", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
