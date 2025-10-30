// lib/pages/class_form_page.dart

import 'package:flutter/material.dart';
// import 'package:get/get.dart'; // <-- Hapus import GetX
import '../widgets/input_field.dart';
import '../models/course_model.dart';

// Definisi warna
const Color lsGreen = Color(0xFF0DA680);
const Color lsGreenLight = Color(0xFF18C093);

// Halaman ini TETAP StatefulWidget karena butuh state internal untuk form
class ClassFormPage extends StatefulWidget {
  final Map<String, dynamic>? initialData;
  const ClassFormPage({super.key, this.initialData});

  @override
  State<ClassFormPage> createState() => _ClassFormPageState();
}

class _ClassFormPageState extends State<ClassFormPage> {
  // State internal untuk form
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _namaController;
  late TextEditingController _hargaController;
  String? _thumbnailPath;
  bool _isPrakerja = false;
  bool _isSPL = false;

  // Logika initState ini tetap sama seperti kode asli Anda
  @override
  void initState() {
    super.initState();
    _namaController = TextEditingController();
    _hargaController = TextEditingController();

    if (widget.initialData != null) {
      _namaController.text = widget.initialData!['nama'] ?? '';
      _hargaController.text = widget.initialData!['harga'] ?? '';
      _thumbnailPath = widget.initialData!['thumbnail'];
      List<String> tags = (widget.initialData!['tags'] as List<dynamic>)
          .cast<String>();
      setState(() {
        _isPrakerja = tags.contains('Prakerja');
        _isSPL = tags.contains('SPL');
      });
    }
  }

  // Logika dispose juga tetap sama
  @override
  void dispose() {
    _namaController.dispose();
    _hargaController.dispose();
    super.dispose();
  }

  // Fungsi ini dipanggil saat tombol 'Simpan Perubahan' ditekan
  void _simpanPerubahan() {
    if (_formKey.currentState!.validate()) {
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
      if (tags.isEmpty) {
        tags.add('Lainnya');
        tagColors.add(Colors.purple);
      }

      final dataKelas = {
        'id':
            widget.initialData?['id'] ??
            DateTime.now().millisecondsSinceEpoch.toString(),
        'nama': _namaController.text,
        'harga': _hargaController.text,
        'kategori': tags.isNotEmpty ? tags.first : null,
        'thumbnail': _thumbnailPath ?? "assets/images/course1.png",
        'tags': tags,
        'tagColors': tagColors,
      };

      //? PERBAIKAN CRASH: Ganti 'Get.back()' dengan 'Navigator.pop()'
      // Ini adalah perintah Flutter asli untuk menutup halaman/bottomsheet
      // dan "mengembalikan" data ('dataKelas') ke halaman sebelumnya.
      Navigator.pop(context, dataKelas);
    }
  }

  @override
  Widget build(BuildContext context) {
    //? PERUBAHAN UI: Ganti 'Scaffold' dengan 'Material'
    // Kenapa? Agar bisa ditampilkan di dalam BottomSheet.
    return Material(
      color: Colors.white,
      child: SafeArea(
        top: false,
        child: Form(
          key: _formKey,
          // Dibungkus ListView agar bisa di-scroll
          child: ListView(
            padding: const EdgeInsets.all(24.0),
            children: [
              //? TAMBAHAN UI: Judul Manual (pengganti AppBar)
              Padding(
                padding: const EdgeInsets.only(top: 16.0, bottom: 24.0),
                child: Text(
                  widget.initialData == null
                      ? 'Tambah Kelas Baru'
                      : 'Edit Informasi Kelas',
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              // --- SISA FORM DI BAWAH INI SAMA PERSIS DENGAN KODE ASLI ANDA ---
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
                    CheckboxListTile(
                      title: const Text('Prakerja'),
                      value: _isPrakerja,
                      onChanged: (bool? value) {
                        setState(() {
                          _isPrakerja = value ?? false;
                        });
                      },
                      controlAffinity: ListTileControlAffinity.leading,
                      activeColor: lsGreen,
                    ),
                    const Divider(
                      height: 1,
                      thickness: 1,
                      indent: 16,
                      endIndent: 16,
                    ),
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
                  //? PERBAIKAN CRASH: Ganti 'Get.back()' dengan 'Navigator.pop()'
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: lsGreenLight,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Batal'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
