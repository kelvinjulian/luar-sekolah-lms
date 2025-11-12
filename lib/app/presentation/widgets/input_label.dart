// input_label.dart

import 'package:flutter/material.dart';

// Widget ini khusus dibuat untuk menampilkan label teks di atas field input.
// Kita pisahkan biar styling label di semua halaman jadi seragam dan rapi.
class InputLabel extends StatelessWidget {
  // =========================
  //* PROPERTI (Cuma butuh 1: Teks Label)
  // =========================
  final String label; // Teks yang akan ditampilkan sebagai label (Wajib diisi!)

  // Constructor
  const InputLabel({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    // Kita pakai Column agar kalau nanti mau nambahin widget lain di bawah label gampang.
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start, // Pastikan teksnya rata kiri (start)
      children: [
        // ----------------------------
        //* TEKS LABEL UTAMA
        // ----------------------------
        Text(
          label,
          // Mengambil styling dari tema utama (Theme.of(context)), lalu kita tiban (copyWith)
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500, // Ketebalan sedang
            fontSize: 15,
            color: Colors.black,
          ),
        ),

        // Catatan: SizedBox(height: 8) DIHAPUS dari sini,
        // karena jarak ke field input akan diatur secara manual
        // di halaman yang menggunakan widget ini (misal: account_page.dart),
        // supaya kita punya kontrol penuh dan nggak ada jarak ganda!
      ],
    );
  }
}
