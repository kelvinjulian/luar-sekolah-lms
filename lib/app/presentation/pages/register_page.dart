// lib/app/presentation/pages/register_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:slider_captcha/slider_captcha.dart'; // IMPORT PENTING

import '../controllers/auth_controller.dart';
import '../widgets/input_field.dart';
import '../widgets/checklist_item.dart';

const Color lsGreen = Color(0xFF0DA680);

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool isPasswordVisible = false;

  // State Captcha
  bool isRobotChecked = false; // False = Belum verifikasi

  bool isFormFilled = false;
  bool isEmailValid = false;
  bool isEmailRegistered = false;
  bool isPhoneValid62 = false;
  bool isPhoneValidLength = false;
  bool isPhoneValidNumber = false;
  bool isPasswordMinLength = false;
  bool isPasswordHasUppercase = false;
  bool isPasswordHasNumber = false;
  bool isPasswordHasSymbol = false;
  bool _isLoading = false;

  void checkFormFilled() {
    setState(() {
      isFormFilled =
          nameController.text.isNotEmpty &&
          emailController.text.isNotEmpty &&
          phoneController.text.isNotEmpty &&
          passwordController.text.isNotEmpty;
    });
  }

  void validateEmail(String value) {
    final emailRegex = RegExp(r'^[\w\.-]+@[\w\.-]+\.\w+$');
    setState(() {
      isEmailValid = emailRegex.hasMatch(value);
      // Mock validation
      isEmailRegistered = value == "ahmad@gmail.com";
    });
    checkFormFilled();
  }

  void validatePhone(String value) {
    setState(() {
      isPhoneValid62 = value.startsWith('62');
      isPhoneValidLength = value.length >= 10;
      isPhoneValidNumber = RegExp(r'^[0-9]+$').hasMatch(value);
    });
    checkFormFilled();
  }

  void validatePassword(String value) {
    setState(() {
      isPasswordMinLength = value.length >= 8;
      isPasswordHasUppercase = value.contains(RegExp(r'[A-Z]'));
      isPasswordHasNumber = value.contains(RegExp(r'[0-9]'));
      isPasswordHasSymbol = value.contains(RegExp(r'[!@#\$%^&*(),.?":{}|<>]'));
    });
    checkFormFilled();
  }

  @override
  void initState() {
    super.initState();
    nameController.addListener(checkFormFilled);
    emailController.addListener(checkFormFilled);
    phoneController.addListener(checkFormFilled);
    passwordController.addListener(checkFormFilled);
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  // --- LOGIKA CAPTCHA PUZZLE ---
  void _showCaptchaDialog() {
    showDialog(
      context: context,
      barrierDismissible: false, // User harus selesaikan atau klik batal
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            padding: const EdgeInsets.all(16),
            height: 380, // Tinggi area puzzle
            width: double.infinity,
            child: Column(
              children: [
                const Text(
                  "Verifikasi Keamanan",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                const SizedBox(height: 8),
                const Text("Geser slider untuk melengkapi puzzle"),
                const SizedBox(height: 16),

                // WIDGET PUZZLE
                Expanded(
                  child: SliderCaptcha(
                    // image: Image.asset(
                    //   'assets/images/banner1.png', // Gunakan gambar asetmu sbg background
                    //   fit: BoxFit.cover,
                    // ),
                    image: Image.network(
                      'https://picsum.photos/300/150', // Gambar acak dari internet
                      fit: BoxFit.cover,
                    ),
                    colorBar: lsGreen,
                    colorCaptChar: lsGreen,
                    onConfirm: (bool value) async {
                      if (value) {
                        // Jika puzzle cocok
                        Navigator.of(context).pop(); // Tutup dialog
                        setState(() {
                          isRobotChecked = true; // Set verified
                        });
                        Get.snackbar(
                          "Berhasil",
                          "Verifikasi manusia berhasil!",
                          backgroundColor: Colors.green,
                          colorText: Colors.white,
                          snackPosition: SnackPosition.BOTTOM,
                          margin: const EdgeInsets.all(16),
                        );
                      } else {
                        // Jika gagal geser
                        // SliderCaptcha biasanya reset otomatis, atau bisa tambah logika fail
                      }
                    },
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text(
                    "Batal",
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final authC = Get.find<AuthController>();

    bool isEmailValidFull = isEmailValid && !isEmailRegistered;
    bool isPhoneValidFull =
        isPhoneValid62 && isPhoneValidLength && isPhoneValidNumber;
    bool isPasswordValidFull =
        isPasswordMinLength &&
        isPasswordHasUppercase &&
        isPasswordHasNumber &&
        isPasswordHasSymbol;
    bool isAllCriteriaMet =
        isEmailValidFull && isPhoneValidFull && isPasswordValidFull;

    // Syarat tombol aktif: Form isi + Robot Verified + Kriteria Password/Email OK
    bool isButtonActive = isFormFilled && isRobotChecked && isAllCriteriaMet;

    return Scaffold(
      backgroundColor: Colors.white,
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const SizedBox(height: 40),
          Align(
            alignment: Alignment.centerLeft,
            child: SvgPicture.asset(
              "assets/logos/luarsekolah-logo.svg",
              height: 48,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            "Daftarkan Akun Untuk Lanjut Akses ke Luarsekolah",
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontSize: 22,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 15),
          Text(
            "Satu akun untuk akses Luarsekolah dan BelajarBekerja",
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.w300,
              color: const Color(0xFF7B7F95),
            ),
          ),
          const SizedBox(height: 20),

          // ... (Bagian Tombol Google & Divider Sama Saja) ...
          Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              children: [
                InputField(
                  label: "Nama Lengkap",
                  controller: nameController,
                  hint: "Masukkan nama lengkapmu",
                  validator: (value) => (value == null || value.isEmpty)
                      ? 'Nama tidak boleh kosong'
                      : null,
                ),
                const SizedBox(height: 15),
                InputField(
                  label: "Email Aktif",
                  controller: emailController,
                  hint: "Masukkan alamat emailmu",
                  onChanged: validateEmail,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) => (value == null || value.isEmpty)
                      ? 'Email tidak boleh kosong'
                      : null,
                ),
                // Validasi Email UI
                if (emailController.text.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  if (!isEmailRegistered && !isEmailValid)
                    ChecklistItem(
                      condition: isEmailValid,
                      text: "Format tidak sesuai. Contoh:\nuser@mail.com",
                    ),
                  if (isEmailRegistered)
                    ChecklistItem(
                      condition: !isEmailRegistered,
                      text: "Email ini sudah terdaftar. Silakan masuk.",
                    ),
                ],

                const SizedBox(height: 15),
                InputField(
                  label: "Nomor WhatsApp Aktif",
                  controller: phoneController,
                  hint: "Masukkan nomor WhatsApp",
                  onChanged: validatePhone,
                  keyboardType: TextInputType.phone,
                  validator: (value) => (value == null || value.isEmpty)
                      ? 'Nomor WhatsApp tidak boleh kosong'
                      : null,
                ),
                // Validasi HP UI
                if (phoneController.text.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  ChecklistItem(
                    condition: isPhoneValid62,
                    text: "Format nomor diawali 62",
                  ),
                  ChecklistItem(
                    condition: isPhoneValidLength,
                    text: "Minimal 10 angka",
                  ),
                ],

                const SizedBox(height: 15),
                InputField(
                  label: "Password",
                  controller: passwordController,
                  hint: "Masukkan password",
                  obscureText: !isPasswordVisible,
                  onChanged: validatePassword,
                  validator: (value) => (value == null || value.isEmpty)
                      ? 'Password tidak boleh kosong'
                      : null,
                  suffixIcon: IconButton(
                    icon: Icon(
                      isPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () =>
                        setState(() => isPasswordVisible = !isPasswordVisible),
                  ),
                ),
                // Validasi Password UI
                if (passwordController.text.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  ChecklistItem(
                    condition: isPasswordMinLength,
                    text: "Minimal 8 karakter",
                  ),
                  ChecklistItem(
                    condition: isPasswordHasUppercase,
                    text: "Terdapat 1 huruf kapital",
                  ),
                  ChecklistItem(
                    condition: isPasswordHasNumber,
                    text: "Terdapat 1 angka",
                  ),
                  ChecklistItem(
                    condition: isPasswordHasSymbol,
                    text: "Terdapat 1 karakter simbol (!, @, dst)",
                  ),
                ],
                const SizedBox(height: 25),
              ],
            ),
          ),

          // =========================
          //* REAL CAPTCHA SECTION
          // =========================
          GestureDetector(
            onTap: () {
              // Jika belum checked, tampilkan dialog puzzle
              if (!isRobotChecked) {
                _showCaptchaDialog();
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFF9F9F9),
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(6),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 2,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Checkbox Area
                  Container(
                    height: 24,
                    width: 24,
                    decoration: BoxDecoration(
                      color: isRobotChecked ? Colors.green : Colors.white,
                      border: Border.all(
                        color: isRobotChecked ? Colors.green : Colors.grey,
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: isRobotChecked
                        ? const Icon(Icons.check, size: 18, color: Colors.white)
                        : const SizedBox(),
                  ),
                  const SizedBox(width: 12),

                  const Expanded(
                    child: Text(
                      "I'm not a robot",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),

                  // Icon Recaptcha (Visual Only)
                  SizedBox(
                    width: 60,
                    height: 40,
                    child: Image.network(
                      'https://picsum.photos/300/150',
                      fit: BoxFit.cover,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 25),

          // =========================
          //* TOMBOL DAFTAR
          // =========================
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: isButtonActive && !_isLoading
                  ? () async {
                      if (_formKey.currentState!.validate()) {
                        setState(() => _isLoading = true);

                        await authC.register(
                          nameController.text,
                          emailController.text,
                          passwordController.text,
                        );

                        if (mounted) setState(() => _isLoading = false);
                      }
                    }
                  : null, // Disable jika belum verified
              style: ElevatedButton.styleFrom(
                backgroundColor: (isButtonActive
                    ? const Color(0xFF077d60)
                    : Colors.grey),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
                      "Daftarkan Akun",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 20),

          // ... (Syarat Ketentuan & Link Login di bawah tetap sama) ...
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 27, vertical: 18),
              decoration: BoxDecoration(
                color: const Color(0xFFeff5ff),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: const Color(0xFF5b94f0)),
              ),
              child:
                  // Row(
                  //   mainAxisSize: MainAxisSize.min,
                  //   children: [
                  //     const Text("👋 ", style: TextStyle(fontSize: 15)),
                  //     const Text(
                  //       "Sudah punya akun? ",
                  //       style: TextStyle(fontSize: 15),
                  //     ),
                  //     GestureDetector(
                  //       onTap: () => Get.toNamed('/login'),
                  //       child: const Text(
                  //         "Masuk ke akunmu",
                  //         style: TextStyle(
                  //           fontSize: 15,
                  //           color: Color(0xFF5b94f0),
                  //           decoration: TextDecoration.underline,
                  //           decorationColor: Color(0xFF5b94f0),
                  //         ),
                  //       ),
                  //     ),
                  //   ],
                  // ),
                  Wrap(
                    alignment: WrapAlignment
                        .center, // Ratakan tengah secara horizontal
                    crossAxisAlignment: WrapCrossAlignment
                        .center, // Ratakan tengah secara vertikal
                    spacing: 4, // Jarak antar elemen (pengganti SizedBox width)
                    runSpacing:
                        4, // Jarak antar baris (jika teks turun ke bawah)
                    children: [
                      const Text("👋 ", style: TextStyle(fontSize: 15)),
                      const Text(
                        "Sudah punya akun?",
                        style: TextStyle(fontSize: 15),
                      ),
                      GestureDetector(
                        onTap: () => Get.toNamed('/login'),
                        child: const Text(
                          "Masuk ke akunmu",
                          style: TextStyle(
                            fontSize: 15,
                            color: Color(0xFF5b94f0), // Sesuaikan warna birumu
                            decoration: TextDecoration.underline,
                            decorationColor: Color(0xFF5b94f0),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }
}
