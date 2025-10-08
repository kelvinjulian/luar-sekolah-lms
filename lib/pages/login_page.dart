import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart'; // Buat pakai gambar SVG (seperti logo Google atau logo aplikasi)

// Import widget custom InputField kita
import '../widgets/input_field.dart';
import 'register_page.dart'; // Import halaman Register, buat kalau user mau daftar
import 'home_page.dart'; // Import halaman Home, buat kalau login sukses

/// ================================
/// HALAMAN LOGIN
/// ================================
// Widget utama kita, dia Stateful karena isinya bisa berubah-ubah (misalnya saat ngetik)
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

// Ini adalah State dari LoginPage, tempat semua logika dan data disimpan
class _LoginPageState extends State<LoginPage> {
  // GlobalKey ini penting banget buat mengakses dan nge-validasi Form-nya
  final _formKey = GlobalKey<FormState>();

  // =========================
  // CONTROLLER UNTUK TEXTFIELD: buat ambil inputan dari user
  // =========================
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  // =========================
  // VARIABLE STATE: semua yang ada di sini akan merubah UI kalau di-setState
  // =========================
  bool isPasswordVisible =
      false; // buat toggle icon mata (lihat/sembunyikan password)
  bool isRobotChecked = false; // status checkbox "I'm not a robot"
  bool isFormFilled = false; // buat ngecek apakah semua field sudah terisi

  // Validasi real-time: status untuk setiap kriteria validasi (hanya dipakai di sini untuk mengecek status tombol)
  bool isEmailValid = false; // cek format email (@, .com, dll)
  bool isEmailRegistered =
      false; // cek apakah email ini terdaftar (di login, harusnya terdaftar)
  bool isPasswordMinLength = false; // cek apakah minimal 8 karakter
  bool isPasswordHasUppercase = false; // cek apakah ada huruf kapital
  bool isPasswordHasNumber = false; // cek apakah ada angka
  bool isPasswordHasSymbol = false; // cek apakah ada simbol

  // Fungsi ini dipanggil setiap kali user ngetik. Ngecek apakah Email & Password terisi.
  void checkFormFilled() {
    setState(() {
      isFormFilled =
          emailController.text.isNotEmpty && passwordController.text.isNotEmpty;
    });
  }

  // Logika validasi untuk Email
  void validateEmail(String value) {
    // Ekspresi reguler (RegExp) buat ngecek format email yang bener
    final emailRegex = RegExp(r'^[\w\.-]+@[\w\.-]+\.\w+$');
    setState(() {
      isEmailValid = emailRegex.hasMatch(value); // Update status format
      // Ini cuma contoh mocking. Di Login, ini harusnya dicek ke server apakah emailnya ADA.
      isEmailRegistered = value == "ahmad@gmail.com";
    });
    checkFormFilled(); // Jangan lupa cek lagi apakah semua field sudah terisi
  }

  // Logika validasi untuk Password (meski login, kita tetap bisa cek apakah password memenuhi kriteria pendaftaran)
  void validatePassword(String value) {
    setState(() {
      isPasswordMinLength = value.length >= 8;
      isPasswordHasUppercase = value.contains(RegExp(r'[A-Z]'));
      isPasswordHasNumber = value.contains(RegExp(r'[0-9]'));
      isPasswordHasSymbol = value.contains(RegExp(r'[!@#\$%^&*(),.?":{}|<>]'));
    });
    checkFormFilled();
  }

  // =========================
  // LIFECYCLE METHODS
  // =========================

  @override
  void initState() {
    super.initState();
    // Kita "dengarkan" setiap controller agar bisa update status isFormFilled
    emailController.addListener(checkFormFilled);
    passwordController.addListener(checkFormFilled);
  }

  @override
  void dispose() {
    // Kalau widget-nya hilang dari layar, controllernya harus dibersihkan
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  // Widget custom untuk menampilkan item di checklist (icon centang/silang + teks)
  Widget checklistItem(bool condition, String text) {
    return Row(
      children: [
        Icon(
          condition ? Icons.check_circle : Icons.error,
          color: condition ? Colors.green : Colors.red,
          size: 18,
        ),
        const SizedBox(width: 6),
        Text(
          text,
          style: TextStyle(
            color: condition ? Colors.green : Colors.red,
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  // =========================
  // BUILD METHOD (INI TEMPAT UI DIBUAT)
  // =========================
  @override
  Widget build(BuildContext context) {
    // Perhitungan status Email: harus valid format DAN TERDAFTAR (karena ini halaman login)
    bool isEmailValidFull = isEmailValid && isEmailRegistered;

    // Status validasi penuh untuk Password (harus memenuhi 4 kriteria pendaftaran, agar tombol aktif)
    bool isPasswordValidFull =
        isPasswordMinLength &&
        isPasswordHasUppercase &&
        isPasswordHasNumber &&
        isPasswordHasSymbol;

    // Status apakah SEMUA kriteria validasi field sudah terpenuhi
    bool isAllCriteriaMet = isEmailValidFull && isPasswordValidFull;

    // Tombol aktif HANYA JIKA form terisi, robot dicentang, DAN semua kriteria validasi terpenuhi
    bool isButtonActive = isFormFilled && isRobotChecked && isAllCriteriaMet;

    return Scaffold(
      body: ListView(
        // ListView agar bisa di-scroll
        padding: const EdgeInsets.all(24),
        children: [
          const SizedBox(height: 40),

          // =========================
          // LOGO DI POJOK KIRI
          // =========================
          Align(
            alignment: Alignment.centerLeft,
            child: SvgPicture.asset(
              "assets/logos/luarsekolah-logo.svg",
              height: 48,
            ),
          ),
          const SizedBox(height: 20),

          // =========================
          // JUDUL DAN DESKRIPSI
          // =========================
          Text(
            "Masuk ke Akunmu untuk Lanjut Akses ke Luarsekolah", // Judul utama
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontSize: 22,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 15),

          Text(
            "Satu akun untuk akses Luarsekolah dan BelajarBekerja", // Deskripsi
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.w100,
              color: const Color(0xFF7B7F95), // Warna abu-abu
            ),
          ),
          const SizedBox(height: 20),

          // =========================
          // TOMBOL LOGIN DENGAN GOOGLE
          // =========================
          SizedBox(
            width: double.infinity, // Bikin tombol full width
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
              onPressed: () {}, // Aksi login Google belum ada
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
          // DIVIDER "atau gunakan email"
          // =========================
          Row(
            children: [
              const Expanded(
                child: Divider(
                  color: Color(0xFF7B7F95),
                  thickness: 1,
                ), // Garis kiri
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
                child: Divider(
                  color: Color(0xFF7B7F95),
                  thickness: 1,
                ), // Garis kanan
              ),
            ],
          ),
          const SizedBox(height: 20),

          // =========================
          // FORM FIELD
          // =========================
          Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode
                .onUserInteraction, // Validasi langsung saat interaksi
            child: Column(
              children: [
                // Email
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
                    // Kalau ada isinya, balikin null. Detail error dihandle checklist!
                    return null;
                  },
                ),
                const SizedBox(height: 5),
                // Checklist Email HANYA muncul ketika user sudah ngetik DAN formatnya BELUM valid
                if (emailController.text.isNotEmpty && !isEmailValid)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      checklistItem(
                        isEmailValid,
                        "Format tidak sesuai. Contoh:\nuser@mail.com",
                      ),
                      // Kalau mau cek terdaftar/tidak terdaftar, bisa ditambahkan di sini
                    ],
                  ),

                // Jarak antar field
                const SizedBox(height: 15),

                // Password
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
                    return null; // Detail error dihandle pesan ringkas di bawah
                  },
                  suffixIcon: IconButton(
                    icon: Icon(
                      // Icon mata
                      isPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        isPasswordVisible =
                            !isPasswordVisible; // Toggle visibilitas
                      });
                    },
                  ),
                ),
                const SizedBox(height: 5),

                // Pesan Ringkas Password (muncul jika ada teks TAPI tidak valid)
                if (passwordController.text.isNotEmpty && !isPasswordValidFull)
                  Padding(
                    padding: const EdgeInsets.only(top: 5),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.error_outline,
                          color: Colors.red,
                          size: 18,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          "Password tidak valid.", // Pesan umum saat password tidak memenuhi kriteria
                          style: TextStyle(color: Colors.red, fontSize: 13),
                        ),
                      ],
                    ),
                  ),

                // Jarak ke link "Lupa password?"
                const SizedBox(height: 5),

                // Link "Lupa password?"
                Align(
                  alignment: Alignment.centerLeft, // Paksa teks rata kiri
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
              ],
            ),
          ),

          const SizedBox(height: 25),

          // =========================
          // "I'M NOT A ROBOT" CHECKBOX
          // =========================
          GestureDetector(
            onTap: () {
              // Toggle status checkbox
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
          // TOMBOL "MASUK" DINAMIS
          // =========================
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              // Tombol aktif HANYA JIKA isButtonActive true
              onPressed: isButtonActive
                  ? () {
                      // Cek validasi form terakhir kali sebelum lanjut
                      if (_formKey.currentState!.validate()) {
                        // Kalau sukses, pindah ke halaman Home
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const HomePage(),
                          ),
                        );
                      }
                    }
                  : null, // Kalau tidak aktif, tombol disable
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                // Warna tombol: hijau kalau aktif, abu-abu kalau tidak
                backgroundColor: isButtonActive
                    ? const Color(0xFF077d60)
                    : Colors.grey,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              child: const Text("Masuk"), // Teks tombol
            ),
          ),

          const SizedBox(height: 40),

          // =========================
          // LINK PINDAH KE DAFTAR (REGISTER)
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
                mainAxisSize: MainAxisSize.min, // Biar kotaknya se-lebar isinya
                children: [
                  const Text("👋 ", style: TextStyle(fontSize: 15)),
                  const Text(
                    "Belum punya akun? ",
                    style: TextStyle(fontSize: 15),
                  ),
                  GestureDetector(
                    onTap: () {
                      // Pindah ke halaman Register
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const RegisterPage(),
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
