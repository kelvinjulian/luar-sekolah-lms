import 'package:flutter/material.dart';

// Ini adalah widget custom kita buat bikin input field yang rapi
// Dia StatelessWidget karena cuma menampilkan UI, nggak menyimpan data yang berubah (datanya diatur di Controller)
class InputField extends StatelessWidget {
  // =========================
  //* PROPERTI (Apa yang dibutuhkan widget ini dari luar)
  // =========================
  final String label; // Teks label di atas field (contoh: "Nama Lengkap")
  final TextEditingController
  controller; // Controller buat ngatur dan ambil isi teksnya
  final String
  hint; // Teks placeholder di dalam field (contoh: "Masukkan emailmu")
  final bool
  obscureText; // True kalau teksnya harus disembunyikan (untuk password)
  final Widget? suffixIcon; // Icon tambahan di kanan field (contoh: icon mata)
  final int minLines; // Jumlah baris minimum (penting buat field alamat)
  final int maxLines; // Jumlah baris maksimum
  final String? Function(String?)?
  validator; // Fungsi buat cek validasi saat form disubmit
  final void Function(String)?
  onChanged; // Fungsi yang dipanggil setiap kali teks berubah (buat validasi real-time)
  final TextInputType
  keyboardType; // Tipe keyboard yang muncul (email, angka, atau teks biasa)

  // Constructor: Ini yang menentukan properti apa saja yang harus diisi saat memanggil widget ini
  const InputField({
    super.key,
    required this.label, // Wajib diisi!
    required this.controller, // Wajib diisi!
    required this.hint, // Wajib diisi!
    this.obscureText = false, // Nilai defaultnya false
    this.suffixIcon,
    this.minLines = 1, // Defaultnya 1 baris
    this.maxLines = 1, // Defaultnya 1 baris
    this.validator,
    this.onChanged,
    this.keyboardType = TextInputType.text, // Defaultnya keyboard teks biasa
  });

  @override
  Widget build(BuildContext context) {
    // Kita pakai Column agar label (di atas) dan field (di bawah) bisa bertumpuk
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start, // Semua isinya rata kiri
      children: [
        // ----------------------------
        //* LABEL TEKS (Teks di atas field)
        // ----------------------------
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
            fontSize: 15,
            color: Colors.black,
          ),
        ),

        // Jarak vertikal 8 piksel antara label dan field input
        const SizedBox(height: 8),

        // ----------------------------
        //* FIELD INPUT UTAMA (TextFormField)
        // ----------------------------
        // ubah jadi TextFormField supaya bisa pakai validator
        TextFormField(
          controller: controller, // Pasang controller kita
          obscureText: obscureText, // Sembunyikan teks kalau ini true
          minLines: minLines, // Atur baris minimum
          maxLines: maxLines, // Atur baris maksimum
          validator: validator, // Pasang fungsi validator
          onChanged: onChanged, // Pasang fungsi saat teks berubah
          keyboardType: keyboardType, // Tentukan tipe keyboard yang muncul
          // Styling dan dekorasi field (kotak, hint, dll)
          decoration: InputDecoration(
            hintText: hint, // Pasang hint/placeholder
            hintStyle: const TextStyle(
              fontSize: 15,
              color: Color(0xFF7B7F95),
            ), // Warna dan ukuran hint
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
            ), // Bikin kotak dengan sudut melengkung 6
            contentPadding: const EdgeInsets.symmetric(
              vertical: 10,
              horizontal: 12,
            ), // Padding di dalam field biar nggak terlalu mepet
            suffixIcon: suffixIcon, // Pasang icon di kanan (kalau ada)
            isDense: true, // Biar field-nya agak lebih ramping/padat
          ),

          // Style teks saat user mengetik
          style: const TextStyle(fontSize: 15, color: Colors.black),
        ),
      ],
    );
  }
}
