import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

// Import widget InputField
import '../widgets/input_field.dart';
import 'register_page.dart';
import 'home_page.dart';

/// ================================
/// HALAMAN REGISTER
/// ================================
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // =========================
  // CONTROLLER UNTUK TEXTFIELD
  // =========================
  // final TextEditingController nameController = TextEditingController();
  // final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  // =========================
  // VARIABLE STATE
  // =========================
  bool isPasswordVisible = false; // toggle visibility password
  bool isRobotChecked = false; // apakah checkbox "I'm not a robot" dicentang
  bool isFormFilled = false; // apakah semua field sudah diisi

  @override
  void initState() {
    super.initState();

    // =========================
    // ADD LISTENER UNTUK MEMANTAU TEXTFIELD
    // =========================
    // Setiap kali user mengetik di salah satu field, jalankan fungsi checkFormFilled
    // nameController.addListener(checkFormFilled);
    // phoneController.addListener(checkFormFilled);
    emailController.addListener(checkFormFilled);
    passwordController.addListener(checkFormFilled);
  }

  // =========================
  // FUNGSI UNTUK CEK FORM
  // =========================
  void checkFormFilled() {
    // Jika semua field tidak kosong, set isFormFilled menjadi true
    setState(() {
      isFormFilled =
          // nameController.text.isNotEmpty &&
          // phoneController.text.isNotEmpty &&
          emailController.text.isNotEmpty && passwordController.text.isNotEmpty;
    });
  }

  @override
  void dispose() {
    // Jangan lupa dispose controller untuk mencegah memory leak
    // nameController.dispose();
    // phoneController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Tombol "Daftarkan Akun" akan aktif jika semua field diisi AND checkbox dicentang
    bool isButtonActive = isFormFilled && isRobotChecked;

    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const SizedBox(height: 40),

          // =========================
          // LOGO DI POJOK KIRI
          // =========================
          Align(
            alignment: Alignment.centerLeft,
            child: SvgPicture.asset(
              "assets/logos/luarsekolah-logo.svg", // untuk menggunakan SVG harus import flutter_svg package di pubspec.yaml
              height: 48,
            ),
          ),
          const SizedBox(height: 20),

          // =========================
          // JUDUL DAN DESKRIPSI
          // =========================
          Text(
            "Masuk ke Akunmu untuk Lanjut Akses ke Luarsekolah",
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              // pakai google fonts be vietnam pro yang sudah di set di main.dart
              fontSize: 22,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 15),

          Text(
            "Satu akun untuk akses Luarsekolah dan BelajarBekerja",
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              // pakai google fonts be vietnam pro yang sudah di set di main.dart
              // ini untuk deskripsi, jadi lebih kecil dan lebih tipis
              fontSize: 16,
              fontWeight: FontWeight.w100,
              color: const Color(0xFF7B7F95),
            ),
          ),
          const SizedBox(height: 20),

          // =========================
          // TOMBOL GOOGLE
          // =========================
          SizedBox(
            // membungkus tombol agar bisa full width
            width: double.infinity, // selebar mungkin
            child: ElevatedButton.icon(
              // tombol dengan icon
              style: ElevatedButton.styleFrom(
                // menggunakan styleFrom agar mudah settingnya
                padding: const EdgeInsets.symmetric(
                  vertical: 10,
                ), // tinggi tombol 10
                backgroundColor: Colors.white,
                foregroundColor: Colors.black87,
                side: const BorderSide(color: Color.fromARGB(255, 0, 0, 0)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              onPressed: () {}, // belum ada fungsinya
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

          // =========================
          // DIVIDER ATAU GUNAKAN EMAIL
          // =========================
          Row(
            children: [
              const Expanded(
                // agar Divider selebar mungkin
                child: Divider(
                  color: Color(0xFF7B7F95),
                  thickness: 1,
                ), // garis pembatas
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                ), // jarak kiri kanan
                child: Text(
                  // teks di tengah
                  "atau gunakan email",
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                    color: const Color(0xFF7B7F95),
                  ),
                ),
              ),
              const Expanded(
                // agar Divider selebar mungkin
                child: Divider(
                  color: Color(0xFF7B7F95),
                  thickness: 1,
                ), // garis pembatas
              ),
            ],
          ),
          const SizedBox(height: 20),

          // =========================
          // FORM FIELD MENGGUNAKAN WIDGET InputField
          // =========================

          // Email
          InputField(
            // gunakan widget InputField yang sudah dibuat di widgets/input_field.dart
            label: "Email Aktif",
            controller:
                emailController, // controller untuk mengontrol isi TextField
            hint: "Masukkan email terdaftar",
            minLines: 1, // kegunaan untuk multiline
            maxLines: 2, // kegunaannya untuk jika user punya nama panjang
          ),

          const SizedBox(height: 15),

          // Password
          InputField(
            label: "Password",
            controller: passwordController,
            hint: "Masukkan password untuk akunmu",
            obscureText: !isPasswordVisible,
            suffixIcon: IconButton(
              icon: Icon(
                isPasswordVisible ? Icons.visibility : Icons.visibility_off,
              ),
              onPressed: () {
                setState(() {
                  isPasswordVisible = !isPasswordVisible;
                });
              },
            ),
          ),

          const SizedBox(height: 10),

          // Lupa Password
          Text(
            "Lupa password?",
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
              fontSize: 15,
              color: Color(0xFF5b94f0),
              decoration: TextDecoration.underline,
              decorationColor: Color(0xFF5b94f0),
            ),
          ),

          const SizedBox(height: 25),

          // =========================
          // "I'M NOT A ROBOT" CHECKBOX
          // =========================
          GestureDetector(
            // agar bisa ditekan
            onTap: () {
              setState(() {
                isRobotChecked =
                    !isRobotChecked; // ketika area ini ditekan, toggle isRobotChecked
              });
            },
            child: Container(
              // membungkus checkbox dan teks agar bisa ditekan
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
                    // icon berubah sesuai isRobotChecked
                    // jika true maka icon check_box, jika false maka icon check_box_outline_blank
                    color: isRobotChecked
                        ? Colors.green
                        : Colors
                              .grey, // warna icon berubah sesuai isRobotChecked, jika dicentang hijau, jika tidak abu-abu
                  ),
                  const SizedBox(width: 8),
                  const Text("I'm not a robot"),
                ],
              ),
            ),
          ),

          const SizedBox(height: 25),

          // =========================
          // TOMBOL "DAFTARKAN AKUN" DINAMIS
          // =========================
          SizedBox(
            // membungkus tombol agar bisa full
            width: double.infinity, // selebar mungkin
            child: ElevatedButton(
              // tombol tanpa icon
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor:
                    isButtonActive // jika aktif hijau, jika tidak abu-abu
                    ? const Color(0xFF077d60)
                    : Colors.grey,
                foregroundColor: Colors.white, // warna teks putih
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6), // radius 6
                ),
              ),
              onPressed:
                  isButtonActive // jika tombol aktif, maka onPressed ada isinya, jika tidak maka onPressed null
                  ? () {
                      // Navigasi ke halaman Homepage
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              const HomePage(), // ganti dengan halaman home yang sebenarnya
                        ),
                      );
                    }
                  : null,
              child: const Text("Masuk"),
            ),
          ),

          const SizedBox(height: 40),

          // =========================
          // LINK LOGIN
          // =========================
          Center(
            // agar teks di tengah
            child: Container(
              // membungkus agar bisa kasih padding dan box decoration (agar mirip tombol tapi bukan tombol)
              padding: const EdgeInsets.symmetric(
                horizontal: 34, // menyesuaikan agar sama dengan TextField
                vertical: 18,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFFeff5ff), // background
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: const Color(0xFF5b94f0)), // outline
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
                    // agar bisa ditekan
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              const RegisterPage(), // ganti dengan halaman register yang sebenarnya
                        ),
                      );
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
