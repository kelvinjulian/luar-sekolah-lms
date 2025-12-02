import 'dart:io'; // WAJIB ADA untuk File
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';

import '../controllers/auth_controller.dart';
import '../controllers/class_controller.dart';
import 'course/class_page.dart';
import '../widgets/input_field.dart';
import '../widgets/dropdown_field.dart';

const Color lsGreen = Color(0xFF0DA680);

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  final AuthController authC = Get.find<AuthController>();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController addressController = TextEditingController();

  File? _selectedImageFile;
  final ImagePicker _picker = ImagePicker();

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
    final user = authC.user;
    if (user == null) return;
    final uid = user.uid;

    setState(() {
      nameController.text = user.displayName ?? '';
      addressController.text = prefs.getString('profile_address_$uid') ?? '';
      _dateOfBirth =
          prefs.getString('profile_dob_$uid') ?? 'Masukkan tanggal lahirmu';

      String savedGender =
          prefs.getString('profile_gender_$uid') ?? genderOptions[0];
      _gender = genderOptions.contains(savedGender)
          ? savedGender
          : genderOptions[0];

      String savedJob = prefs.getString('profile_job_$uid') ?? jobOptions[0];
      _jobStatus = jobOptions.contains(savedJob) ? savedJob : jobOptions[0];

      // --- PERBAIKAN: LOAD FOTO KE STATE LOKAL ---
      // Ambil path foto dari SharedPreferences
      String? savedPhotoPath = prefs.getString('profile_photo_path_$uid');

      // Cek apakah path ada DAN filenya masih ada di HP
      if (savedPhotoPath != null && savedPhotoPath.isNotEmpty) {
        File fileCek = File(savedPhotoPath);
        if (fileCek.existsSync()) {
          _selectedImageFile = fileCek; // <--- Set ke variabel tampilan

          // PENTING: Sinkronkan juga ke AuthController biar Homepage tahu
          authC.localPhotoPath.value = savedPhotoPath;
        }
      }
    });
  }

  // --- FUNGSI AMBIL FOTO ---
  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 500,
      );

      if (pickedFile != null) {
        // 1. Simpan ke Controller & Memori HP
        await authC.updateLocalPhoto(pickedFile.path);

        // 2. Update Tampilan Halaman Ini
        setState(() {
          _selectedImageFile = File(pickedFile.path);
        });
      }
    } catch (e) {
      print("Error ambil foto: $e");
    }
  }

  void _saveProfileData() async {
    final user = authC.user;
    if (user == null) return;
    final uid = user.uid;

    if (nameController.text.isNotEmpty) {
      await authC.updateDisplayName(nameController.text);
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('profile_address_$uid', addressController.text);
    await prefs.setString('profile_dob_$uid', _dateOfBirth);
    await prefs.setString('profile_gender_$uid', _gender);
    await prefs.setString('profile_job_$uid', _jobStatus);
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _dateOfBirth = "${picked.day}-${picked.month}-${picked.year}";
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
              onPressed: () {
                Navigator.of(dialogContext).pop();
                authC.logout();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<ClassController>()) {
      try {
        Get.put(
          ClassController(
            getAllCoursesUseCase: Get.find(),
            addCourseUseCase: Get.find(),
            updateCourseUseCase: Get.find(),
            deleteCourseUseCase: Get.find(),
          ),
        );
      } catch (e) {}
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),

              // HEADER PROFIL
              Obx(() {
                final user = authC.user;
                final localPath =
                    authC.localPhotoPath.value; // Dengar perubahan

                ImageProvider bgImage;
                if (_selectedImageFile != null) {
                  bgImage = FileImage(_selectedImageFile!);
                } else if (localPath != null && File(localPath).existsSync()) {
                  bgImage = FileImage(File(localPath));
                } else if (user?.photoURL != null) {
                  bgImage = NetworkImage(user!.photoURL!);
                } else {
                  bgImage = const AssetImage("assets/images/avatar.jpg");
                }

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: Colors.grey[200],
                      backgroundImage: bgImage,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Semangat Belajarnya,",
                            style: TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                          Text(
                            user?.displayName ?? nameController.text,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              }),

              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black87,
                    side: const BorderSide(color: Colors.grey),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  onPressed: () => Get.to(() => const ClassPage()),
                  icon: const Icon(
                    Icons.dashboard_customize_outlined,
                    size: 20,
                  ),
                  label: const Text("Kelola & Telusuri Kelas"),
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
                  GestureDetector(
                    onTap: _pickImage,
                    child: Stack(
                      children: [
                        Obx(() {
                          // Logic yang sama untuk Avatar besar di Edit
                          final user = authC.user;
                          final localPath = authC.localPhotoPath.value;
                          ImageProvider bgImage;
                          if (_selectedImageFile != null) {
                            bgImage = FileImage(_selectedImageFile!);
                          } else if (localPath != null &&
                              File(localPath).existsSync()) {
                            bgImage = FileImage(File(localPath));
                          } else if (user?.photoURL != null) {
                            bgImage = NetworkImage(user!.photoURL!);
                          } else {
                            bgImage = const AssetImage(
                              "assets/images/avatar.jpg",
                            );
                          }
                          return CircleAvatar(
                            backgroundImage: bgImage,
                            radius: 45,
                          );
                        }),
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
                            onPressed: _pickImage,
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
                hint: "Nama Anda",
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
      ),
    );
  }
}
