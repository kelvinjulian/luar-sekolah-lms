import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
//? --- PERBAIKAN: Hapus go_router, import Get ---
import 'package:get/get.dart';
//? --- PERBAIKAN: Import AuthController ---
import '../controllers/auth_controller.dart';
import '../widgets/input_field.dart';
import '../widgets/checklist_item.dart';

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

  // ... (State UI tidak berubah) ...
  bool isPasswordVisible = false;
  bool isRobotChecked = false;
  bool isFormFilled = false;
  bool isEmailValid = false;
  bool isEmailRegistered = false; // (Mock)
  bool isPhoneValid62 = false;
  bool isPhoneValidLength = false;
  bool isPhoneValidNumber = false;
  bool isPasswordMinLength = false;
  bool isPasswordHasUppercase = false;
  bool isPasswordHasNumber = false;
  bool isPasswordHasSymbol = false;
  bool _isLoading = false;
  // bool _isSuccess = false; // <-- Tidak lagi diperlukan

  // ... (Semua fungsi validasi & state tidak berubah) ...
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

  @override
  Widget build(BuildContext context) {
    //? --- PERBAIKAN: Panggil Manajer (Controller) ---
    final authC = Get.find<AuthController>();

    // ... (Logika validasi tombol tidak berubah) ...
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
    bool isButtonActive = isFormFilled && isRobotChecked && isAllCriteriaMet;

    return Scaffold(
      backgroundColor: Colors.white,
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          // ... (UI Logo, Judul, Google, Divider, Form... tidak berubah) ...
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
              fontWeight: FontWeight.w100,
              color: const Color(0xFF7B7F95),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 10),
                backgroundColor: Colors.white,
                foregroundColor: Colors.black87,
                side: const BorderSide(color: Color.fromARGB(255, 0, 0, 0)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              onPressed: () {},
              icon: SvgPicture.asset(
                "assets/icons/google-icon.svg",
                height: 20,
              ),
              label: Text(
                "Daftar dengan Google",
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: Colors.black87,
                ),
              ),
            ),
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              const Expanded(
                child: Divider(color: Color(0xFF7B7F95), thickness: 1),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  "atau gunakan email",
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                    color: const Color(0xFF7B7F95),
                  ),
                ),
              ),
              const Expanded(
                child: Divider(color: Color(0xFF7B7F95), thickness: 1),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              children: [
                // ... (InputField Nama, Email, Phone, Password & Checklist... tidak berubah) ...
                InputField(
                  label: "Nama Lengkap",
                  controller: nameController,
                  hint: "Masukkan nama lengkapmu",
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Nama tidak boleh kosong';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 15),
                InputField(
                  label: "Email Aktif",
                  controller: emailController,
                  hint: "Masukkan alamat emailmu",
                  onChanged: validateEmail,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Email tidak boleh kosong';
                    }
                    return null;
                  },
                ),
                AnimatedSize(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOut,
                  child: emailController.text.isNotEmpty
                      ? Opacity(
                          opacity: 1.0,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 8),
                              if (!isEmailRegistered && !isEmailValid)
                                ChecklistItem(
                                  condition: isEmailValid,
                                  text:
                                      "Format tidak sesuai. Contoh:\nuser@mail.com",
                                ),
                              if (isEmailRegistered)
                                ChecklistItem(
                                  condition: !isEmailRegistered,
                                  text:
                                      "Email ini sudah terdaftar. Silakan masuk.",
                                ),
                            ],
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
                const SizedBox(height: 15),
                InputField(
                  label: "Nomor WhatsApp Aktif",
                  controller: phoneController,
                  hint: "Masukkan nomor WhatsApp yang bisa dihubungi",
                  onChanged: validatePhone,
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Nomor WhatsApp tidak boleh kosong';
                    }
                    return null;
                  },
                ),
                AnimatedSize(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOut,
                  child: phoneController.text.isNotEmpty
                      ? Opacity(
                          opacity: 1.0,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
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
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
                const SizedBox(height: 15),
                InputField(
                  label: "Password",
                  controller: passwordController,
                  hint: "Masukkan password",
                  obscureText: !isPasswordVisible,
                  onChanged: validatePassword,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Password tidak boleh kosong';
                    }
                    return null;
                  },
                  suffixIcon: IconButton(
                    icon: Icon(
                      isPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        isPasswordVisible = !isPasswordVisible;
                      });
                    },
                  ),
                ),
                AnimatedSize(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOut,
                  child: passwordController.text.isNotEmpty
                      ? Opacity(
                          opacity: 1.0,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
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
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
                const SizedBox(height: 15),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              setState(() {
                isRobotChecked = !isRobotChecked;
              });
            },
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                children: [
                  Icon(
                    isRobotChecked
                        ? Icons.check_box
                        : Icons.check_box_outline_blank,
                    color: isRobotChecked ? Colors.green : Colors.grey,
                  ),
                  const SizedBox(width: 8),
                  const Text("I'm not a robot"),
                ],
              ),
            ),
          ),
          const SizedBox(height: 25),

          // =========================
          //* TOMBOL "Daftarkan Akun" DINAMIS
          // =========================
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: isButtonActive && !_isLoading
                  ? () async {
                      if (_formKey.currentState!.validate()) {
                        // 1. Mulai animasi loading
                        setState(() {
                          _isLoading = true;
                        });

                        //? --- PERBAIKAN: Panggil AuthController ---
                        await authC.register(
                          emailController.text,
                          passwordController.text,
                        );
                        //? --- Hapus navigasi ---
                        //? Navigasi (Get.offAllNamed) akan di-handle
                        //? oleh Stream di SplashPage/AuthController

                        // 3. Hentikan loading jika widget masih ada
                        if (mounted) {
                          setState(() {
                            _isLoading = false;
                          });
                        }
                      }
                    }
                  : null,
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
                  //? Hapus state _isSuccess
                  : const Text("Daftarkan Akun"),
            ),
          ),
          const SizedBox(height: 20),

          // ... (UI Syarat & Ketentuan... tidak berubah) ...
          RichText(
            text: TextSpan(
              text: "Dengan mendaftar di Luarsekolah, kamu menyetujui ",
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontSize: 15,
                fontWeight: FontWeight.w100,
                color: const Color(0xFF7B7F95),
              ),
              children: [
                TextSpan(
                  text: "syarat dan ketentuan kami",
                  style: const TextStyle(
                    color: Colors.blue,
                    decoration: TextDecoration.underline,
                    decorationColor: Colors.blue,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 25),

          // =========================
          //* LINK PINDAH KE LOGIN
          // =========================
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 27, vertical: 18),
              decoration: BoxDecoration(
                color: const Color(0xFFeff5ff),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: const Color(0xFF5b94f0)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text("👋 ", style: TextStyle(fontSize: 15)),
                  const Text(
                    "Sudah punya akun? ",
                    style: TextStyle(fontSize: 15),
                  ),
                  GestureDetector(
                    onTap: () {
                      //? --- PERBAIKAN: Ganti context.push ke Get.toNamed ---
                      Get.toNamed('/login');
                    },
                    child: const Text(
                      "Masuk ke akunmu",
                      style: TextStyle(
                        fontSize: 15,
                        color: Color(0xFF5b94f0),
                        decoration: TextDecoration.underline,
                        decorationColor: Color(0xFF5b94f0),
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
