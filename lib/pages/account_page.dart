// account_page.dart (UPDATED)

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Buat simpan data profil permanen
import '../widgets/input_field.dart'; // Input field custom kita
import '../widgets/input_label.dart'; // Label teks custom kita
import '../widgets/custom_dropdown.dart'; // Dropdown custom kita

// Warna yang sering dipakai di layout
const Color lsGreen = Color(0xFF0DA680);
const Color backgroundLight = Color(0xFFFAFAFA);

// Widget utama halaman Akun, dia Stateful karena isinya bisa diubah user
class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

// State untuk menyimpan semua data, controller, dan logika form
class _AccountPageState extends State<AccountPage> {
  // Controller buat ambil dan simpan teks dari field Nama dan Alamat
  final TextEditingController nameController = TextEditingController();
  final TextEditingController addressController = TextEditingController();

  // Variabel state untuk data yang pakai Dropdown atau Date Picker
  String _dateOfBirth = 'Masukkan tanggal lahirmu';
  String _gender = 'Pilih laki-laki atau perempuan';
  String _jobStatus = 'Pilih status pekerjaanmu';

  // Daftar opsi untuk Dropdown Jenis Kelamin
  final List<String> genderOptions = [
    'Pilih laki-laki atau perempuan', // Placeholder
    'Laki-laki',
    'Perempuan',
  ];
  // Daftar opsi untuk Dropdown Status Pekerjaan
  final List<String> jobOptions = [
    'Pilih status pekerjaanmu', // Placeholder
    'Pelajar',
    'Karyawan',
    'Wiraswasta',
    'Lainnya',
  ];

  @override
  void initState() {
    super.initState();
    _loadProfileData(); // Langsung muat data profil saat halaman pertama kali dibuka
  }

  // =====================================
  // FUNGSI SHAREDPREFERENCES & LOGIKA
  // =====================================

  // Fungsi untuk memuat data dari SharedPreferences
  void _loadProfileData() async {
    final prefs = await SharedPreferences.getInstance(); // Ambil storage
    setState(() {
      // Baca data dari storage. Kalau nggak ada, pakai nilai default yang kita tentukan
      nameController.text = prefs.getString('profile_name') ?? 'Ahmad Sahroni';
      addressController.text = prefs.getString('profile_address') ?? '';
      _dateOfBirth =
          prefs.getString('profile_dob') ?? 'Masukkan tanggal lahirmu';
      _gender = prefs.getString('profile_gender') ?? genderOptions[0];
      _jobStatus = prefs.getString('profile_job') ?? jobOptions[0];
    });
  }

  // Fungsi untuk menyimpan perubahan data ke SharedPreferences saat tombol ditekan
  void _saveProfileData() async {
    final prefs = await SharedPreferences.getInstance();
    // Simpan semua nilai state dan controller
    await prefs.setString('profile_name', nameController.text);
    await prefs.setString('profile_address', addressController.text);
    await prefs.setString('profile_dob', _dateOfBirth);
    await prefs.setString('profile_gender', _gender);
    await prefs.setString('profile_job', _jobStatus);

    // Tampilkan notifikasi keberhasilan di bagian atas layar (Snac kBar)

    // ignore: use_build_context_synchronously
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          'Perubahan profil berhasil disimpan!',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.grey[800], // Warna background SnackBar
        behavior: SnackBarBehavior.floating, // Bikin SnackBar melayang
        // Menggunakan margin untuk mendorong SnackBar ke bagian atas layar
        margin: EdgeInsets.only(
          // ignore: use_build_context_synchronously
          bottom: MediaQuery.of(context).size.height - 200,
          right: 40,
          left: 40,
        ),
        padding: const EdgeInsets.symmetric(vertical: 15),
        duration: const Duration(seconds: 3), // Durasi muncul
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ), // Sudut melengkung
      ),
    );
  }

  // Fungsi untuk memunculkan kalender (Date Picker)
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(), // Tanggal yang muncul pertama kali
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked.toString().split(' ')[0] != _dateOfBirth) {
      setState(() {
        // Ambil format tanggal YYYY-MM-DD
        _dateOfBirth = picked.toString().split(' ')[0];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Kita nggak pakai Scaffold karena halaman ini dimuat di Body Scaffold milik HomePage
    return SafeArea(
      // Pastikan konten nggak ketutupan notch HP
      child: SingleChildScrollView(
        // Agar bisa di-scroll kalau kontennya panjang
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, // Semua rata kiri
          children: [
            // Header Profil Statis
            const SizedBox(height: 20),

            // === BARIS ATAS: FOTO KECIL + TEKS SAPAAN ===
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // LINGKARAN FOTO KECIL (AVATAR)
                const CircleAvatar(
                  backgroundImage: AssetImage("assets/images/avatar.jpg"),
                  radius: 20,
                ),
                const SizedBox(width: 12), // Jarak horizontal
                // Teks Sapaan dan Nama
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

            // Tombol Buka Navigasi Menu
            SizedBox(
              width: double.infinity, // Full width
              child: OutlinedButton.icon(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black87,
                  side: const BorderSide(color: Color.fromARGB(255, 0, 0, 0)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                onPressed: () {}, // Aksi tombol belum ada
                icon: const Icon(Icons.dashboard_customize_outlined, size: 20),
                label: const Text("Buka Navigasi Menu"),
              ),
            ),

            const SizedBox(height: 30),

            // =========================
            // BAGIAN EDIT PROFIL (FOTO)
            // =========================
            const Text(
              "Edit Profil",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 15),

            // Avatar BESAR dan Tombol Upload (Masih placeholder)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    const CircleAvatar(
                      backgroundImage: AssetImage("assets/images/avatar.jpg"),
                      radius: 45,
                    ),
                    // Icon Kamera Kecil di pojok
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
                        style: TextStyle(
                          fontSize: 14,
                          color: Color.fromARGB(255, 0, 0, 0),
                        ),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () {
                            /* Logika Image Picker */
                          }, // Tombol masih dummy
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

            // =========================
            // SUB-HEADER: DATA DIRI (Form)
            // =========================
            const Text(
              "Informasi Kontak",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 15),

            // 1. Nama Lengkap (pakai label bawaan InputField)
            InputField(
              label: "Nama Lengkap",
              controller: nameController,
              hint: "Ahmad Sahroni",
              validator: (value) => (value == null || value.isEmpty)
                  ? 'Nama tidak boleh kosong'
                  : null,
            ),
            const SizedBox(height: 20),

            // 2. Tanggal Lahir (pakai label terpisah + GestureDetector untuk kalender)
            InputLabel(label: "Tanggal Lahir"), // Label terpisah
            const SizedBox(height: 8), // Jarak manual yang sudah kita setting
            GestureDetector(
              onTap: () => _selectDate(context), // Panggil kalender
              child: AbsorbPointer(
                // Bikin field tidak bisa diketik, hanya bisa diklik
                child: InputField(
                  controller: TextEditingController(text: _dateOfBirth),
                  label:
                      "", // Label dikosongkan agar InputField tidak menampilkan label ganda
                  hint: _dateOfBirth,
                  suffixIcon: const Icon(
                    Icons.calendar_today_outlined,
                    size: 20,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // 3. Jenis Kelamin (pakai Dropdown custom)
            InputLabel(label: "Jenis Kelamin"),
            const SizedBox(height: 8), // Jarak manual
            CustomDropdown(
              value: _gender,
              options: genderOptions,
              onChanged: (newValue) {
                setState(() {
                  _gender = newValue!;
                });
              },
            ),
            const SizedBox(height: 20),

            // 4. Status Pekerjaan (pakai Dropdown custom)
            InputLabel(label: "Status Pekerjaan"),
            const SizedBox(height: 8), // Jarak manual
            CustomDropdown(
              value: _jobStatus,
              options: jobOptions,
              onChanged: (newValue) {
                setState(() {
                  _jobStatus = newValue!;
                });
              },
            ),
            const SizedBox(height: 20),

            // 5. Alamat Lengkap (pakai InputField dengan multi-baris)
            InputField(
              label: "Alamat Lengkap",
              controller: addressController,
              hint: "Masukkan alamat lengkap",
              minLines: 3,
              maxLines: 4,
            ),
            const SizedBox(height: 30),

            // Tombol Simpan Perubahan
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveProfileData, // Panggil fungsi simpan
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
          ],
        ),
      ),
    );
  }
}
