import 'dart:io'; // Penting untuk File
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../widgets/input_field.dart';
// import '../../../domain/entities/course.dart';

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

  String? _currentThumbnailUrl;
  File? _selectedImageFile;
  final ImagePicker _picker = ImagePicker();

  bool _isPopuler = false;
  bool _isPrakerja = false;
  bool _isSPL = false;

  @override
  void initState() {
    super.initState();
    _namaController = TextEditingController();
    _hargaController = TextEditingController();

    if (widget.initialData != null) {
      _namaController.text = widget.initialData!['nama'] ?? '';
      _hargaController.text = widget.initialData!['harga']?.toString() ?? '';
      _currentThumbnailUrl = widget.initialData!['thumbnail'];

      List<String> tags = (widget.initialData!['tags'] as List<dynamic>)
          .cast<String>();

      setState(() {
        _isPopuler = tags.contains('Populer');
        _isPrakerja = tags.contains('Prakerja');
        _isSPL = tags.contains('SPL');
      });
    }
  }

  @override
  void dispose() {
    _namaController.dispose();
    _hargaController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        setState(() {
          _selectedImageFile = File(pickedFile.path);
        });
      }
    } catch (e) {
      debugPrint("Error picking image: $e");
    }
  }

  void _simpanPerubahan() {
    if (_formKey.currentState!.validate()) {
      List<String> tags = [];
      List<String> tagColorsHex = [];

      // Sesuai dengan pilihan checkbox Anda
      if (_isPopuler) {
        tags.add('Populer');
        tagColorsHex.add("0xFF0DA680");
      }
      if (_isPrakerja) {
        tags.add('Prakerja');
        tagColorsHex.add("0xFF9C27B0");
      }
      if (_isSPL) {
        tags.add('SPL');
        tagColorsHex.add("0xFF2196F3");
      }

      if (tags.isEmpty) {
        tags.add('Lainnya');
        tagColorsHex.add("0xFF808080");
      }

      final dataKelas = {
        'id': widget.initialData?['id'],
        'nama': _namaController.text,
        'harga': _hargaController.text,
        'thumbnail': _currentThumbnailUrl,
        'imageFile': _selectedImageFile,
        'tags': tags,
        'tagColorsHex': tagColorsHex,
      };

      Navigator.pop(context, dataKelas);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      child: SafeArea(
        top: false,
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(24.0),
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 16.0, bottom: 24.0),
                child: Text(
                  widget.initialData == null
                      ? 'Tambah Kelas Baru'
                      : 'Edit Informasi Kelas',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const Text(
                "Informasi Kelas",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(height: 15),
              InputField(
                label: 'Nama Kelas',
                controller: _namaController,
                hint: 'e.g Marketing Communication',
              ),
              const SizedBox(height: 24),
              InputField(
                label: 'Harga Kelas (Rp)',
                controller: _hargaController,
                hint: 'e.g 100000',
                keyboardType: TextInputType.number,
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
                      title: const Text('Populer'),
                      value: _isPopuler,
                      onChanged: (val) => setState(() => _isPopuler = val!),
                      activeColor: lsGreen,
                      controlAffinity: ListTileControlAffinity.leading,
                    ),
                    const Divider(height: 1),
                    CheckboxListTile(
                      title: const Text('Prakerja'),
                      value: _isPrakerja,
                      onChanged: (val) => setState(() => _isPrakerja = val!),
                      activeColor: lsGreen,
                      controlAffinity: ListTileControlAffinity.leading,
                    ),
                    const Divider(height: 1),
                    CheckboxListTile(
                      title: const Text('SPL'),
                      value: _isSPL,
                      onChanged: (val) => setState(() => _isSPL = val!),
                      activeColor: lsGreen,
                      controlAffinity: ListTileControlAffinity.leading,
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
                onTap: _pickImage,
                child: Container(
                  height: 180,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade400),
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.grey.shade50,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: _buildImagePreview(),
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

  // PERBAIKAN PADA BAGIAN INI
  Widget _buildImagePreview() {
    // 1. Jika ada file yang baru dipilih dari galeri
    if (_selectedImageFile != null) {
      return Image.file(
        _selectedImageFile!,
        fit: BoxFit.cover,
        width: double.infinity,
      );
    }

    // 2. Jika dalam mode edit (memuat data lama)
    if (_currentThumbnailUrl != null && _currentThumbnailUrl!.isNotEmpty) {
      if (_currentThumbnailUrl!.startsWith('http')) {
        // Gambar dari internet
        return Image.network(
          _currentThumbnailUrl!,
          fit: BoxFit.cover,
          width: double.infinity,
          errorBuilder: (ctx, _, __) =>
              const Center(child: Icon(Icons.broken_image)),
        );
      } else {
        // PERBAIKAN: Gunakan Image.file untuk path lokal dummy
        return Image.file(
          File(_currentThumbnailUrl!),
          fit: BoxFit.cover,
          width: double.infinity,
        );
      }
    }

    // 3. Tampilan default
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: const [
        Icon(Icons.add_a_photo_outlined, color: Colors.grey, size: 40),
        SizedBox(height: 8),
        Text('Upload Foto', style: TextStyle(color: Colors.grey)),
      ],
    );
  }
}
