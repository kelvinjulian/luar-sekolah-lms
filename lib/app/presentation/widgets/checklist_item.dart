// lib/widgets/checklist_item.dart

import 'package:flutter/material.dart';

// Mengubah dari method menjadi sebuah StatelessWidget yang mandiri
class ChecklistItem extends StatelessWidget {
  final bool condition;
  final String text;

  // Constructor untuk menerima data yang dibutuhkan
  const ChecklistItem({super.key, required this.condition, required this.text});

  @override
  Widget build(BuildContext context) {
    // Logika UI-nya sama persis seperti method Anda sebelumnya
    return Row(
      children: [
        Icon(
          // Tampilkan check_circle (hijau) kalau kondisi true, error_outline (merah) kalau false
          condition ? Icons.check_circle : Icons.error,
          color: condition ? Colors.green : Colors.red,
          size: 18,
        ),
        const SizedBox(width: 6),
        // Gunakan Expanded agar teks bisa wrap jika terlalu panjang
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: condition ? Colors.green : Colors.red,
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }
}
