// lib/app/presentation/pages/account_page.dart

import 'package:flutter/material.dart';
//? --- PERBAIKAN 1: Hapus go_router, import Get ---
// import 'package:go_router/go_router.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/input_field.dart';
import '../widgets/dropdown_field.dart';

const Color lsGreen = Color(0xFF0DA680);

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  // ... (Semua state & fungsi internal tidak berubah) ...
  final TextEditingController nameController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  String _dateOfBirth = 'Masukkan tanggal lahirmu';
  String _gender = 'Pilih laki-laki atau perempuan';
  String _jobStatus = 'Pilih status pekerjaanmu';
  final List<String> genderOptions = [
    'Pilih laki-laki atau perempuan',
    'Laki-laki',
    'Perempuan',
  ];
  final List<String> jobOptions = [
    'Pilih status pekerjaanmu',
    'Pelajar',
    'Karyawan',
    'Wiraswasta',
    'Lainnya',
  ];

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  void _loadProfileData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      nameController.text = prefs.getString('profile_name') ?? 'Ahmad Sahroni';
      addressController.text = prefs.getString('profile_address') ?? '';
      _dateOfBirth =
          prefs.getString('profile_dob') ?? 'Masukkan tanggal lahirmu';
      _gender = prefs.getString('profile_gender') ?? genderOptions[0];
      _jobStatus = prefs.getString('profile_job') ?? jobOptions[0];
    });
  }

  void _saveProfileData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('profile_name', nameController.text);
    await prefs.setString('profile_address', addressController.text);
    await prefs.setString('profile_dob', _dateOfBirth);
    await prefs.setString('profile_gender', _gender);
    await prefs.setString('profile_job', _jobStatus);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Perubahan profil berhasil disimpan!',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.grey[800],
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.only(
            bottom: MediaQuery.of(context).size.height - 200,
            right: 40,
            left: 40,
          ),
          padding: const EdgeInsets.symmetric(vertical: 15),
          duration: const Duration(seconds: 3),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked.toString().split(' ')[0] != _dateOfBirth) {
      setState(() {
        _dateOfBirth = picked.toString().split(' ')[0];
      });
    }
  }

  Future<void> _showLogoutConfirmationDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: const Text('Konfirmasi Logout'),
          content: const Text('Apakah Anda yakin ingin keluar dari akun Anda?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Batal'),
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Ya, Keluar'),
              //? --- PERBAIKAN 2: Ganti context.go ke Get.offAllNamed ---
              onPressed: () => Get.offAllNamed('/login'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ... (Semua UI Header, Form, Tombol... tidak berubah) ...
            // (Ini semua SAMA seperti file yang Anda upload)
            const SizedBox(height: 20),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const CircleAvatar(
                  backgroundImage: AssetImage("assets/images/avatar.jpg"),
                  radius: 20,
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Semangat Belajarnya.",
                      style: TextStyle(fontSize: 16, color: Colors.black),
                    ),
                    Text(
                      nameController.text.isNotEmpty
                          ? nameController.text
                          : "Pengguna",
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black87,
                  side: const BorderSide(color: Colors.grey),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                onPressed: () {},
                icon: const Icon(Icons.dashboard_customize_outlined, size: 20),
                label: const Text("Buka Navigasi Menu"),
              ),
            ),
            const SizedBox(height: 30),
            const Text(
              "Edit Profil",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 15),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    const CircleAvatar(
                      backgroundImage: AssetImage("assets/images/avatar.jpg"),
                      radius: 45,
                    ),
                    Positioned(
                      top: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Upload foto baru dengan ukuran < 1 MB, dan bertipe JPG atau PNG.",
                        style: TextStyle(fontSize: 14, color: Colors.black),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () {},
                          icon: const Icon(
                            Icons.file_upload_outlined,
                            size: 20,
                          ),
                          label: const Text("Upload Foto"),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.black87,
                            side: const BorderSide(color: Colors.grey),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),
            const Text(
              "Informasi Kontak",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 15),
            InputField(
              label: "Nama Lengkap",
              labelSize: 16,
              labelWeight: FontWeight.w500,
              controller: nameController,
              hint: "Ahmad Sahroni",
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () => _selectDate(context),
              child: AbsorbPointer(
                child: InputField(
                  controller: TextEditingController(text: _dateOfBirth),
                  label: "Tanggal Lahir",
                  labelSize: 16,
                  labelWeight: FontWeight.w500,
                  hint: _dateOfBirth,
                  suffixIcon: const Icon(
                    Icons.calendar_today_outlined,
                    size: 20,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            DropdownField(
              label: "Jenis Kelamin",
              labelSize: 16,
              labelWeight: FontWeight.w500,
              value: _gender,
              options: genderOptions,
              onChanged: (newValue) => setState(() => _gender = newValue!),
            ),
            const SizedBox(height: 20),
            DropdownField(
              label: "Status Pekerjaan",
              labelSize: 16,
              labelWeight: FontWeight.w500,
              value: _jobStatus,
              options: jobOptions,
              onChanged: (newValue) => setState(() => _jobStatus = newValue!),
            ),
            const SizedBox(height: 20),
            InputField(
              label: "Alamat Lengkap",
              labelSize: 16,
              labelWeight: FontWeight.w500,
              controller: addressController,
              hint: "Masukkan alamat lengkap",
              minLines: 3,
              maxLines: 4,
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveProfileData,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  backgroundColor: lsGreen,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                child: const Text("Simpan Perubahan"),
              ),
            ),
            const SizedBox(height: 15),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _showLogoutConfirmationDialog,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  backgroundColor: Colors.red[700],
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                icon: const Icon(Icons.logout),
                label: const Text("Logout"),
              ),
            ),
            const SizedBox(height: 15),
          ],
        ),
      ),
    );
  }
}
