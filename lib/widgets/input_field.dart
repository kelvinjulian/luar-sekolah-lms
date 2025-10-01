import 'package:flutter/material.dart';

/// ================================
/// WIDGET REUSABLE UNTUK INPUT FIELD
/// ================================
/// Widget ini digunakan untuk membuat TextField dengan label, hint, dan optional icon.
/// Supaya kita tidak perlu menulis TextField berulang-ulang di halaman berbeda.
///
class InputField extends StatelessWidget {
  // =========================
  // PROPERTIES WIDGET
  // =========================
  final String label; // Label di atas TextField
  final TextEditingController
  controller; // Controller untuk mengambil/memantau isi TextField
  final String hint; // Hint text di dalam TextField
  final bool obscureText; // Apakah teks disembunyikan (misal untuk password)
  final Widget? suffixIcon; // Icon di akhir TextField (misal visibility toggle)
  final int minLines; // Minimal tinggi baris TextField
  final int maxLines; // Maksimal tinggi baris TextField

  // =========================
  // KONSTRUKTOR
  // =========================
  const InputField({
    // konstruktor
    super.key, // key opsional kegunannya untuk identifikasi widget
    required this.label, // label wajib diisi saat membuat widget
    required this.controller, // controller wajib diisi saat membuat widget
    required this.hint, // hint wajib diisi saat membuat widget
    this.obscureText = false, // default false (teks tidak disembunyikan)
    this.suffixIcon, // default null (tidak ada icon)
    this.minLines = 1, // default 1 baris
    this.maxLines =
        1, // kenapa 1? supaya TextField tidak membesar ke bawah, kecuali diubah saat pemanggilan widget
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // =========================
        // LABEL
        // =========================
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
            fontSize: 15,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 8),

        // =========================
        // TEXTFIELD
        // =========================
        TextField(
          controller: controller,
          obscureText: obscureText, // sembunyikan teks jika password
          style: const TextStyle(fontSize: 15, color: Colors.black),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(fontSize: 15, color: Color(0xFF7B7F95)),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6), // radius 6
            ),
            contentPadding: const EdgeInsets.symmetric(
              vertical: 10,
              horizontal: 12,
            ),
            suffixIcon: suffixIcon, // icon di akhir TextField
            isDense: true, // mengurangi tinggi default
          ),
          minLines: minLines,
          maxLines: maxLines,
        ),
      ],
    );
  }
}
