import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
//? --- PERBAIKAN 1: Hapus go_router, import Get ---
// import 'package:go_router/go_router.dart';
import 'package:get/get.dart';

// Import widget-widget custom
import '../widgets/input_field.dart';
// import '../widgets/checklist_item.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool isPasswordVisible = false;
  bool isFormFilled = false;
  bool _isLoading = false;
  bool _isSuccess = false;

  void checkFormFilled() {
    setState(() {
      isFormFilled =
          emailController.text.isNotEmpty && passwordController.text.isNotEmpty;
    });
  }

  @override
  void initState() {
    super.initState();
    emailController.addListener(checkFormFilled);
    passwordController.addListener(checkFormFilled);
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isButtonActive = isFormFilled;

    return Scaffold(
      backgroundColor: Colors.white,
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          // ... (UI Logo, Judul, Deskripsi, Tombol Google, Divider... tidak berubah) ...
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
            "Masuk ke Akunmu untuk Lanjut Akses ke Luarsekolah",
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
                "Masuk dengan Google",
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

          // ... (UI Form, InputField, Lupa password... tidak berubah) ...
          Form(
            key: _formKey,
            child: Column(
              children: [
                InputField(
                  label: "Email Aktif",
                  controller: emailController,
                  hint: "Masukkan alamat emailmu",
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Email tidak boleh kosong';
                    }
                    if (!RegExp(r'^[\w\.-]+@[\w\.-]+\.\w+$').hasMatch(value)) {
                      return 'Format email tidak valid';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 15),
                InputField(
                  label: "Password",
                  controller: passwordController,
                  hint: "Masukkan password",
                  obscureText: !isPasswordVisible,
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
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerLeft,
                  child: GestureDetector(
                    onTap: () {},
                    child: Text(
                      "Lupa password?",
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                        fontSize: 15,
                        color: const Color(0xFF5b94f0),
                        decoration: TextDecoration.underline,
                        decorationColor: const Color(0xFF5b94f0),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 25),

          // =========================
          //* TOMBOL "MASUK" DENGAN ANIMASI
          // =========================
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: isButtonActive && !_isLoading
                  ? () async {
                      if (_formKey.currentState!.validate()) {
                        setState(() {
                          _isLoading = true;
                        });

                        await Future.delayed(const Duration(seconds: 2));

                        setState(() {
                          _isLoading = false;
                          _isSuccess = true;
                        });

                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Login berhasil! Selamat datang kembali.',
                              ),
                              backgroundColor: Colors.green,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }

                        await Future.delayed(
                          const Duration(milliseconds: 1500),
                        );

                        //? --- PERBAIKAN 2: Ganti context.go ke Get.offAllNamed ---
                        //? 'offAllNamed' pindah halaman dan hapus semua halaman sebelumnya
                        //? (agar tidak bisa 'back' ke login)
                        Get.offAllNamed('/home');
                      }
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: _isSuccess
                    ? Colors.green
                    : (isButtonActive ? const Color(0xFF077d60) : Colors.grey),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : _isSuccess
                  ? const Icon(Icons.check, size: 28)
                  : const Text("Masuk"),
            ),
          ),
          const SizedBox(height: 40),

          // =========================
          //* LINK PINDAH KE DAFTAR
          // =========================
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 34, vertical: 18),
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
                    "Belum punya akun? ",
                    style: TextStyle(fontSize: 15),
                  ),
                  GestureDetector(
                    onTap: () {
                      //? --- PERBAIKAN 3: Ganti context.push ke Get.toNamed ---
                      Get.toNamed('/register');
                    },
                    child: const Text(
                      "Daftar sekarang",
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
