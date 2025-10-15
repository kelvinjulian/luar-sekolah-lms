// lib/pages/class_form_page.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../widgets/input_field.dart';
import '../widgets/dropdown_field.dart'; // Menggunakan widget DropdownField yang baru

// Warna konsisten
const Color lsGreen = Color(0xFF0DA680);
const Color lsGreenLight = Color(0xFF18C093);

class ClassFormPage extends StatefulWidget {
  final Map<String, dynamic>? initialData;

  const ClassFormPage({super.key, this.initialData});

  @override
  State<ClassFormPage> createState() => _ClassFormPageState();
}

class _ClassFormPageState extends State<ClassFormPage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _namaController;
  late TextEditingController _hargaController;
  String? _selectedKategori;
  String? _thumbnailPath;

  // Definisikan placeholder dan opsi di sini
  final String _kategoriPlaceholder = 'Pilih Prakerja atau SPL';
  final List<String> _kategoriOptions = [
    'Pilih Prakerja atau SPL',
    'Prakerja',
    'SPL',
  ];

  @override
  void initState() {
    super.initState();
    _namaController = TextEditingController();
    _hargaController = TextEditingController();

    // Atur nilai awal ke placeholder
    _selectedKategori = _kategoriPlaceholder;

    if (widget.initialData != null) {
      _namaController.text = widget.initialData!['nama'] ?? '';
      _hargaController.text = widget.initialData!['harga'] ?? '';
      _selectedKategori =
          widget.initialData!['kategori'] ?? _kategoriPlaceholder;
      _thumbnailPath = widget.initialData!['thumbnail'] ?? null;
    }
  }

  @override
  void dispose() {
    _namaController.dispose();
    _hargaController.dispose();
    super.dispose();
  }

  void _simpanPerubahan() {
    if (_formKey.currentState!.validate()) {
      // Pastikan placeholder tidak ikut tersimpan
      final kategoriToSave = _selectedKategori == _kategoriPlaceholder
          ? null
          : _selectedKategori;

      final dataKelas = {
        'nama': _namaController.text,
        'harga': _hargaController.text,
        'kategori': kategoriToSave,
        'thumbnail': _thumbnailPath,
      };

      print('Data yang Disimpan: $dataKelas');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.initialData == null
                ? 'Kelas baru berhasil ditambahkan!'
                : 'Perubahan berhasil disimpan!',
          ),
          backgroundColor: Colors.green,
        ),
      );

      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.initialData == null
              ? 'Tambah Kelas Baru'
              : 'Edit Informasi Kelas',
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24.0),
          children: [
            // --- NAMA KELAS ---
            const Text(
              "Informasi Kelas",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 15),
            InputField(
              label: 'Nama Kelas',
              labelSize: 16,
              labelWeight: FontWeight.w500,
              controller: _namaController,
              hint: 'e.g Marketing Communication',
              validator: (value) => value == null || value.isEmpty
                  ? 'Nama kelas tidak boleh kosong'
                  : null,
            ),
            const SizedBox(height: 24),

            // --- HARGA KELAS ---
            InputField(
              label: 'Harga Kelas',
              labelSize: 16,
              labelWeight: FontWeight.w500,
              controller: _hargaController,
              hint: 'e.g 1.000.000',
              keyboardType: TextInputType.number,
              validator: (value) => value == null || value.isEmpty
                  ? 'Harga tidak boleh kosong'
                  : null,
            ),
            const SizedBox(height: 4),
            const Text(
              'Masukkan dalam bentuk angka',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
            const SizedBox(height: 24),

            // --- KATEGORI KELAS ---
            DropdownField(
              label: 'Kategori Kelas',
              labelSize: 16,
              labelWeight: FontWeight.w500,
              value: _selectedKategori!,
              options: _kategoriOptions,
              onChanged: (newValue) {
                setState(() {
                  _selectedKategori = newValue;
                });
              },
            ),
            const SizedBox(height: 24),

            // --- THUMBNAIL KELAS ---
            const Text(
              'Thumbnail Kelas',
              style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () => print('Upload Foto Tapped!'),
              child: Container(
                height: 150,
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade400),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(
                      Icons.photo_camera_outlined,
                      color: Colors.grey,
                      size: 40,
                    ),
                    SizedBox(height: 8),
                    Text('Upload Foto', style: TextStyle(color: Colors.grey)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),

            // --- TOMBOL AKSI ---
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _simpanPerubahan,
                style: ElevatedButton.styleFrom(
                  backgroundColor: lsGreen,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Simpan Perubahan'),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => context.pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: lsGreenLight,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Kembali'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
