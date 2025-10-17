// lib/pages/class_form_page.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../widgets/input_field.dart';

// Definisi warna yang konsisten
const Color lsGreen = Color(0xFF0DA680);
const Color lsGreenLight = Color(0xFF18C093);
const Color tagBlue = Color.fromARGB(255, 37, 146, 247);
const Color tagGreen = Color(0xFF0DA680);

class ClassFormPage extends StatefulWidget {
  // Properti ini opsional. Jika diisi, halaman akan masuk mode 'Edit'.
  // Jika null, halaman akan masuk mode 'Tambah'.
  final Map<String, dynamic>? initialData;

  const ClassFormPage({super.key, this.initialData});

  @override
  State<ClassFormPage> createState() => _ClassFormPageState();
}

class _ClassFormPageState extends State<ClassFormPage> {
  // GlobalKey untuk mengelola state dari Form (misalnya untuk validasi).
  final _formKey = GlobalKey<FormState>();

  // Controller untuk setiap field teks.
  late TextEditingController _namaController;
  late TextEditingController _hargaController;
  String? _thumbnailPath;

  // State baru menggunakan boolean untuk setiap pilihan kategori.
  bool _isPrakerja = false;
  bool _isSPL = false;

  // initState() dipanggil satu kali saat widget pertama kali dibuat.
  @override
  void initState() {
    super.initState();
    // Inisialisasi controller.
    _namaController = TextEditingController();
    _hargaController = TextEditingController();

    // Cek apakah halaman ini dalam mode Edit.
    if (widget.initialData != null) {
      _namaController.text = widget.initialData!['nama'] ?? '';
      _hargaController.text = widget.initialData!['harga'] ?? '';
      _thumbnailPath = widget.initialData!['thumbnail'];

      // Mengisi state checkbox berdasarkan data 'tags' yang diterima dari halaman sebelumnya.
      List<String> tags = (widget.initialData!['tags'] as List<dynamic>)
          .cast<String>();
      setState(() {
        _isPrakerja = tags.contains('Prakerja');
        _isSPL = tags.contains('SPL');
      });
    }
  }

  // dispose() dipanggil saat widget akan dihancurkan.
  // Penting untuk membersihkan controller agar tidak terjadi memory leak.
  @override
  void dispose() {
    _namaController.dispose();
    _hargaController.dispose();
    super.dispose();
  }

  //* Fungsi yang dieksekusi saat tombol "Simpan Perubahan" ditekan.
  void _simpanPerubahan() {
    // Pertama, validasi semua field di dalam Form.
    if (_formKey.currentState!.validate()) {
      // Membuat list 'tags' dan 'tagColors' secara dinamis
      // berdasarkan status checkbox yang dicentang.
      List<String> tags = [];
      List<Color> tagColors = [];

      if (_isPrakerja) {
        tags.add('Prakerja');
        tagColors.add(tagBlue);
      }
      if (_isSPL) {
        tags.add('SPL');
        tagColors.add(tagGreen);
      }

      //? Menyiapkan data lengkap yang akan dikembalikan ke halaman sebelumnya.
      final dataKelas = {
        //? Jika mode edit, gunakan ID yang ada. Jika mode tambah, buat ID baru yang unik.
        'id':
            widget.initialData?['id'] ??
            DateTime.now().millisecondsSinceEpoch.toString(),
        'nama': _namaController.text,
        'harga': _hargaController.text,
        'kategori': tags.isNotEmpty
            ? tags.first
            : null, // Ambil tag pertama sebagai kategori utama
        'thumbnail':
            _thumbnailPath ??
            "assets/images/course1.png", // Beri gambar default
        'tags': tags, // Kirim list tags yang sudah dibuat
        'tagColors': tagColors, // Kirim list tagColors yang sesuai
      };

      //? Menampilkan notifikasi sukses.
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

      //? Ini bagian kuncinya: menutup halaman DAN mengirim 'dataKelas' kembali.
      context.pop(dataKelas);
    }
  }

  // Method build() untuk membangun UI halaman form.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          // Judul AppBar berubah tergantung mode (Tambah atau Edit).
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

            // Mengganti Dropdown dengan dua CheckboxListTile untuk multi-seleksi.
            const Text(
              'Kategori Kelas',
              style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade400),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  // Checkbox untuk 'Prakerja'
                  CheckboxListTile(
                    title: const Text('Prakerja'),
                    value: _isPrakerja,
                    onChanged: (bool? value) {
                      setState(() {
                        _isPrakerja = value ?? false;
                      });
                    },
                    controlAffinity: ListTileControlAffinity
                        .leading, // Checkbox di kiri teks
                    activeColor: lsGreen,
                  ),
                  const Divider(
                    height: 1,
                    thickness: 1,
                    indent: 16,
                    endIndent: 16,
                  ), // Garis pemisah
                  // Checkbox untuk 'SPL'
                  CheckboxListTile(
                    title: const Text('SPL'),
                    value: _isSPL,
                    onChanged: (bool? value) {
                      setState(() {
                        _isSPL = value ?? false;
                      });
                    },
                    controlAffinity: ListTileControlAffinity.leading,
                    activeColor: lsGreen,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            const Text(
              'Thumbnail Kelas',
              style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () {
                // TODO: Implementasi logika untuk memilih gambar (misal: pakai package image_picker)
                print('Upload Foto Tapped!');
              },
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

            // Tombol "Simpan Perubahan"
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

            // Tombol "Kembali"
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () =>
                    context.pop(), // Hanya menutup halaman, tidak mengirim data
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
