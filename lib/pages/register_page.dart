import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

// Import widget InputField
import '../widgets/input_field.dart';
import 'login_page.dart';
import 'home_page.dart';

/// ================================
/// HALAMAN REGISTER
/// ================================
class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  // =========================
  // CONTROLLER UNTUK TEXTFIELD
  // =========================
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
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
    nameController.addListener(checkFormFilled);
    emailController.addListener(checkFormFilled);
    phoneController.addListener(checkFormFilled);
    passwordController.addListener(checkFormFilled);
  }

  // =========================
  // FUNGSI UNTUK CEK FORM
  // =========================
  void checkFormFilled() {
    // Jika semua field tidak kosong, set isFormFilled menjadi true
    setState(() {
      isFormFilled =
          nameController.text.isNotEmpty &&
          emailController.text.isNotEmpty &&
          phoneController.text.isNotEmpty &&
          passwordController.text.isNotEmpty;
    });
  }

  @override
  void dispose() {
    // Jangan lupa dispose controller untuk mencegah memory leak
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Tombol "Daftarkan Akun" akan aktif jika semua field diisi AND checkbox dicentang
    bool isButtonActive = isFormFilled && isRobotChecked;

    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(24), // padding di semua sisi
        children: [
          // isi dalam ListView adalah logo, judul, form, tombol, dll
          const SizedBox(height: 40), // Jarak atas
          // =========================
          // LOGO DI POJOK KIRI
          // =========================
          Align(
            alignment: Alignment.centerLeft, // rata kiri
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
            "Daftarkan Akun Untuk Lanjut Akses ke Luarsekolah",
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
              color: const Color(0xFF7B7F95), // warna abu-abu
            ),
          ),
          const SizedBox(height: 20),

          // =========================
          // TOMBOL GOOGLE
          // =========================
          SizedBox(
            // membungkus tombol agar bisa full width
            width: double.infinity, // full width
            child: ElevatedButton.icon(
              // tombol dengan icon
              style: ElevatedButton.styleFrom(
                // styling tombol
                padding: const EdgeInsets.symmetric(
                  vertical: 10,
                ), // padding vertikal 10
                backgroundColor: Colors.white, // background putih
                foregroundColor: Colors.black87, // teks hitam
                side: const BorderSide(
                  color: Color.fromARGB(255, 0, 0, 0),
                ), // border hitam tipis
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    6,
                  ), // radius 6 agar tidak tajam
                ),
              ),
              onPressed: () {}, // aksi saat ditekan, untuk sekarang kosong
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
            // menggunakan Row agar garis di kiri dan kanan bisa memanjang
            children: [
              const Expanded(
                // Expanded agar garis memanjang memenuhi ruang yang ada
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
                // Expanded agar garis memanjang memenuhi ruang yang ada
                child: Divider(color: Color(0xFF7B7F95), thickness: 1),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // =========================
          // FORM FIELD MENGGUNAKAN WIDGET InputField
          // =========================
          // Nama Lengkap
          InputField(
            // menggunakan widget InputField yang sudah dibuat di widgets/input_field.dart
            label: "Nama Lengkap",
            controller: nameController,
            hint: "Masukkan nama lengkapmu",
            minLines: 1, // kegunaan untuk multiline
            maxLines: 2, // kegunaannya untuk jika user punya nama panjang
          ),

          const SizedBox(height: 15),

          // Email
          InputField(
            label: "Email Aktif",
            controller: emailController,
            hint: "Masukkan alamat emailmu",
            minLines: 1,
            maxLines: 2,
          ),

          const SizedBox(height: 15),

          // Nomor WhatsApp
          InputField(
            label: "Nomor WhatsApp Aktif",
            controller: phoneController,
            hint: "Masukkan nomor whatapp yang bisa dihubungi",
            minLines: 1,
            maxLines: 2,
          ),

          const SizedBox(height: 15),

          // Password
          InputField(
            label: "Password",
            controller: passwordController,
            hint: "Masukkan password untuk akunmu",
            obscureText: !isPasswordVisible, // sembunyikan teks jika password
            // menambahkan icon untuk toggle visibility password
            suffixIcon: IconButton(
              icon: Icon(
                isPasswordVisible
                    ? Icons.visibility
                    : Icons
                          .visibility_off, // ganti icon sesuai state, jika password visible maka icon visibility, jika tidak maka icon visibility_off
              ),
              onPressed: () {
                // toggle visibility password
                setState(() {
                  isPasswordVisible =
                      !isPasswordVisible; // jika false jadi true, jika true jadi false
                });
              },
            ),
          ),

          const SizedBox(height: 25),

          // =========================
          // "I'M NOT A ROBOT" CHECKBOX
          // =========================
          GestureDetector(
            onTap: () {
              // ketika area ini ditekan, toggle isRobotChecked
              setState(() {
                isRobotChecked =
                    !isRobotChecked; // jika false jadi true, jika true jadi false
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
                // isi Row adalah icon dan teks
                children: [
                  Icon(
                    // icon berubah sesuai isRobotChecked
                    isRobotChecked // jika true maka icon check_box, jika false maka icon check_box_outline_blank
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
          // TOMBOL "DAFTARKAN AKUN" DINAMIS
          // =========================
          SizedBox(
            // membungkus tombol agar bisa full width
            width: double.infinity,
            child: ElevatedButton(
              // tombol utama
              style: ElevatedButton.styleFrom(
                // styling tombol
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor:
                    isButtonActive // jika aktif hijau, jika tidak maka abu-abu
                    ? const Color(0xFF077d60)
                    : Colors.grey,
                foregroundColor: Colors.white, // teks putih jika aktif
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    6,
                  ), // radius 6 agar tidak tajam
                ),
              ),
              onPressed:
                  isButtonActive // jika tombol aktif, maka bisa ditekan
                  ? () {
                      // Navigasi ke halaman Homepage
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              const HomePage(), // ganti dengan halaman homepage yang sebenarnya
                        ),
                      );
                    }
                  : null, // jika tidak aktif, maka onPressed null sehingga tombol tidak bisa ditekan
              child: const Text("Daftarkan Akun"),
            ),
          ),

          const SizedBox(height: 15),

          // =========================
          // TEXT SYARAT DAN KETENTUAN DENGAN LINK
          // =========================
          RichText(
            text: TextSpan(
              // menggunakan TextSpan agar bisa ada bagian yang berbeda style
              text:
                  "Dengan mendaftar di Luarsekolah, kamu menyetujui ", // bagian biasa
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontSize: 15,
                fontWeight: FontWeight.w100,
                color: const Color(0xFF7B7F95), // warna abu-abu
              ),
              children: [
                TextSpan(
                  text:
                      "syarat dan ketentuan kami", // bagian berwarna biru dan underline
                  style: const TextStyle(
                    color: Colors.blue, // warna biru
                    decoration: TextDecoration.underline, // underline
                    decorationColor: Colors.blue, // warna underline sama biru
                    fontWeight: FontWeight.w500, // bisa lebih tebal sedikit
                  ),
                  // ini jika kemudian ingin ditekan seperti link, namun untuk sekarang kita belum ada pagenya
                  // recognizer: TapGestureRecognizer()..onTap = () { print("Link ditekan"); },
                ),
              ],
            ),
          ),

          const SizedBox(height: 25),

          // =========================
          // LINK LOGIN
          // =========================
          Center(
            // agar teks di tengah
            child: Container(
              // membungkus agar bisa kasih padding dan box decoration (agar mirip tombol tapi bukan tombol)
              padding: const EdgeInsets.symmetric(
                // menyesuaikan agar sama dengan TextField
                horizontal: 27, // menyesuaikan agar sama dengan TextField
                vertical: 18,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFFeff5ff), // background
                borderRadius: BorderRadius.circular(6), // radius 6
                border: Border.all(color: const Color(0xFF5b94f0)), // outline
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min, // agar Row hanya selebar isinya
                children: [
                  const Text("👋 ", style: TextStyle(fontSize: 15)),
                  const Text(
                    "Sudah punya akun? ",
                    style: TextStyle(fontSize: 15),
                  ),
                  GestureDetector(
                    // agar bisa ditekan
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              const LoginPage(), // ganti dengan halaman login yang sebenarnya
                        ),
                      );
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
