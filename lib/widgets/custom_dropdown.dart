// custom_dropdown.dart

import 'package:flutter/material.dart';

// Widget ini adalah cetakan custom kita untuk Dropdown Button.
// Kita buat sendiri agar kotak dan styling-nya selalu sama dengan InputField lainnya.
class CustomDropdown extends StatelessWidget {
  // =========================
  //* PROPERTI (Apa yang dibutuhkan widget ini dari luar)
  // =========================
  final String value; // Nilai yang sedang terpilih saat ini
  final List<String> options; // Daftar semua pilihan yang tersedia
  final void Function(String?)
  onChanged; // Fungsi yang dipanggil saat user memilih opsi baru

  // Constructor
  const CustomDropdown({
    super.key,
    required this.value, // Wajib diisi!
    required this.options, // Wajib diisi!
    required this.onChanged, // Wajib diisi!
  });

  @override
  Widget build(BuildContext context) {
    // Kita pakai Container untuk membungkus Dropdown agar bisa kita kasih border
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
      ), // Padding horizontal di dalam kotak
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.grey.shade400,
        ), // Bikin border/garis luar tipis
        borderRadius: BorderRadius.circular(6), // Sudut melengkung yang seragam
      ),
      child: DropdownButtonHideUnderline(
        // Widget ini gunanya untuk menyembunyikan garis bawah default dari DropdownButton
        child: DropdownButton<String>(
          isExpanded: true, // Bikin DropdownButton selebar mungkin
          value: value, // Nilai yang sedang terpilih
          icon: const Icon(Icons.keyboard_arrow_down), // Icon panah ke bawah
          style: const TextStyle(
            fontSize: 15,
            color: Colors.black,
          ), // Style teks yang terpilih
          // Menerjemahkan List<String> options menjadi List<DropdownMenuItem>
          items: options.map<DropdownMenuItem<String>>((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(
                item,
                style: TextStyle(
                  // Kalau item adalah opsi pertama (placeholder), kasih warna abu-abu (Color(0xFF7B7F95))
                  color: item == options[0]
                      ? const Color(0xFF7B7F95)
                      : Colors.black, // Selain itu, kasih warna hitam
                  fontSize: 15,
                ),
              ),
            );
          }).toList(),

          onChanged:
              onChanged, // Fungsi yang akan dijalankan saat pilihan berubah
        ),
      ),
    );
  }
}
