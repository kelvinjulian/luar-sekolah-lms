import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart'; // Buat pakai gambar SVG (seperti logo Google atau logo aplikasi)
import '../widgets/input_field.dart'; // Ini ambil widget custom InputField kita dari folder widgets
import 'login_page.dart'; // Import halaman Login, buat kalau user mau pindah
import 'home_page.dart'; // Import halaman Home, buat kalau pendaftaran sukses

// Ini adalah Widget utama kita, dia Stateful karena isinya bisa berubah-ubah (misalnya saat ngetik)
class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

// Ini adalah State dari RegisterPage, tempat semua logika dan data disimpan
class _RegisterPageState extends State<RegisterPage> {
  //? GlobalKey ini penting buat mengakses dan nge-validasi Form-nya
  final _formKey = GlobalKey<FormState>();

  // =========================
  //* TEXT EDITING CONTROLLER: buat ambil inputan dari user di setiap field
  // =========================
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  // =========================
  //* VARIABLE STATE: semua yang ada di sini akan merubah UI kalau di-setState
  // =========================
  bool isPasswordVisible =
      false; // buat toggle icon mata (lihat/sembunyikan password)
  bool isRobotChecked = false; // status checkbox "I'm not a robot"
  bool isFormFilled = false; // buat ngecek apakah semua field sudah terisi

  // Validasi real-time: status untuk setiap kriteria validasi (ceklist)
  bool isEmailValid = false; // cek format email (@, .com, dll)
  bool isEmailRegistered =
      false; // cek apakah email ini sudah ada di database (mocking)
  bool isPhoneValid62 = false; // cek apakah diawali "62"
  bool isPhoneValidLength = false; // cek apakah minimal 10 digit
  bool isPhoneValidNumber = false; // cek apakah isinya cuma angka
  bool isPasswordMinLength = false; // cek apakah minimal 8 karakter
  bool isPasswordHasUppercase = false; // cek apakah ada huruf kapital
  bool isPasswordHasNumber = false; // cek apakah ada angka
  bool isPasswordHasSymbol = false; // cek apakah ada simbol

  // =========================
  //* FUNGSI UTILITY & VALIDASI
  // =========================

  //? Fungsi ini dipanggil setiap kali user ngetik di salah satu field.
  // Dia cuma ngecek, semua field udah ada isinya apa belum.
  void checkFormFilled() {
    setState(() {
      isFormFilled =
          nameController.text.isNotEmpty &&
          emailController.text.isNotEmpty &&
          phoneController.text.isNotEmpty &&
          passwordController.text.isNotEmpty;
    });
  }

  //? Logika validasi untuk Email
  void validateEmail(String value) {
    // Ekspresi reguler (RegExp) buat ngecek format email yang bener
    final emailRegex = RegExp(r'^[\w\.-]+@[\w\.-]+\.\w+$');
    setState(() {
      isEmailValid = emailRegex.hasMatch(value); // Update status format
      // Ini cuma contoh, aslinya harusnya cek ke server
      isEmailRegistered = value == "ahmad@gmail.com";
    });
    checkFormFilled(); // Jangan lupa cek lagi apakah semua field sudah terisi
  }

  //? Logika validasi untuk Nomor Telepon
  void validatePhone(String value) {
    setState(() {
      isPhoneValid62 = value.startsWith('62');
      isPhoneValidLength = value.length >= 10;
      // Cek pakai RegExp lagi, buat memastikan semua karakternya angka
      isPhoneValidNumber = RegExp(r'^[0-9]+$').hasMatch(value);
    });
    checkFormFilled();
  }

  //? Logika validasi untuk Password
  void validatePassword(String value) {
    setState(() {
      isPasswordMinLength = value.length >= 8;
      // Cek apakah ada huruf kapital
      isPasswordHasUppercase = value.contains(RegExp(r'[A-Z]'));
      // Cek apakah ada angka
      isPasswordHasNumber = value.contains(RegExp(r'[0-9]'));
      // Cek apakah ada simbol (seperti !, @, #, dll)
      isPasswordHasSymbol = value.contains(RegExp(r'[!@#\$%^&*(),.?":{}|<>]'));
    });
    checkFormFilled();
  }

  // =========================
  //* LIFECYCLE METHODS
  // =========================
  @override
  void initState() {
    super.initState();
    // Penting! Kita "dengarkan" setiap controller.
    // Setiap kali teks berubah, panggil fungsi checkFormFilled()
    nameController.addListener(checkFormFilled);
    emailController.addListener(checkFormFilled);
    phoneController.addListener(checkFormFilled);
    passwordController.addListener(checkFormFilled);
  }

  @override
  void dispose() {
    // Penting! Kalau widget-nya hilang dari layar, controllernya harus dibersihkan
    // Biar nggak boros memori (memory leak)
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  //? Widget custom untuk menampilkan item di checklist (icon centang/silang + teks)
  Widget checklistItem(bool condition, String text) {
    return Row(
      children: [
        Icon(
          // Tampilkan check_circle (hijau) kalau kondisi true, error_outline (merah) kalau false
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
  //* BUILD METHOD (INI TEMPAT UI DIBUAT)
  // =========================
  @override
  Widget build(BuildContext context) {
    // Perhitungan di sini akan selalu di-update setiap setState dipanggil

    // Status validasi penuh untuk Email (harus valid format DAN belum terdaftar)
    bool isEmailValidFull = isEmailValid && !isEmailRegistered;

    // Status validasi penuh untuk Nomor Telepon (harus 62, panjang min, dan hanya angka)
    bool isPhoneValidFull =
        isPhoneValid62 && isPhoneValidLength && isPhoneValidNumber;

    // Status validasi penuh untuk Password (harus memenuhi 4 kriteria keamanan)
    bool isPasswordValidFull =
        isPasswordMinLength &&
        isPasswordHasUppercase &&
        isPasswordHasNumber &&
        isPasswordHasSymbol;

    // Status apakah SEMUA kriteria validasi field sudah terpenuhi
    bool isAllCriteriaMet =
        isEmailValidFull && isPhoneValidFull && isPasswordValidFull;

    // Tombol aktif HANYA JIKA semua kriteria terpenuhi DAN form terisi DAN robot dicentang
    bool isButtonActive = isFormFilled && isRobotChecked && isAllCriteriaMet;

    return Scaffold(
      // ListView agar halaman bisa di-scroll kalau kontennya kepanjangan
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const SizedBox(height: 40),

          // =========================
          //* LOGO DI POJOK KIRI
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
          //* JUDUL DAN DESKRIPSI
          // =========================
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
              // ini untuk deskripsi, jadi lebih kecil dan lebih tipis
              fontSize: 16,
              fontWeight: FontWeight.w100,
              color: const Color(0xFF7B7F95), // warna abu-abu
            ),
          ),

          const SizedBox(height: 20),

          // =========================
          //* TOMBOL DAFTAR DENGAN GOOGLE
          // =========================
          SizedBox(
            width: double.infinity, // bikin tombol full width
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 10),
                backgroundColor: Colors.white,
                foregroundColor: Colors.black87,
                side: const BorderSide(
                  color: Color.fromARGB(255, 0, 0, 0),
                ), // border hitam
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              onPressed: () {}, // Aksi login Google belum diimplementasi
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
          //* DIVIDER "atau gunakan email"
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
          //* FORM UTAMA
          // =========================
          Form(
            key: _formKey, // Pasang GlobalKey di sini!
            // Validasi langsung muncul saat user mulai interaksi (ngetik/keluar field)
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              children: [
                //? Nama Lengkap
                InputField(
                  label: "Nama Lengkap",
                  controller: nameController,
                  hint: "Masukkan nama lengkapmu",
                  validator: (value) {
                    // Validator standar Flutter, cuma cek kalau kosong
                    if (value == null || value.isEmpty) {
                      return 'Nama tidak boleh kosong';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 15),

                //? Email
                InputField(
                  label: "Email Aktif",
                  controller: emailController,
                  hint: "Masukkan alamat emailmu",
                  onChanged:
                      validateEmail, // Panggil fungsi validasi saat ngetik
                  keyboardType:
                      TextInputType.emailAddress, // Keyboard khusus email
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Email tidak boleh kosong';
                    }
                    // Kalau ada isinya, balikin null. Error detailnya dihandle checklist!
                    return null;
                  },
                ),
                const SizedBox(height: 5),
                // Mengontrol kapan seluruh checklist muncul
                if (emailController.text.isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 1. Cek Format (MODIFIKASI: Hanya muncul jika TIDAK valid ATAU BELUM terdaftar)
                      // Pesan ini hanya muncul jika:
                      //    A. Email BELUM terdaftar (!isEmailRegistered)
                      //    B. DAN, formatnya TIDAK valid (!isEmailValid)
                      if (!isEmailRegistered && !isEmailValid)
                        checklistItem(
                          isEmailValid, // Kondisi ini pasti FALSE, jadi tampil MERAH
                          "Format tidak sesuai. Contoh:\nuser@mail.com",
                        ),

                      // 2. Cek Status Terdaftar (Tidak Berubah)
                      if (isEmailRegistered)
                        checklistItem(
                          !isEmailRegistered, // Kondisi ini pasti FALSE, jadi tampil MERAH
                          "Email ini sudah terdaftar. Silakan masuk.",
                        ),
                    ],
                  ),

                // Jarak antar field
                const SizedBox(height: 15),

                //? Nomor WhatsApp
                InputField(
                  label: "Nomor WhatsApp Aktif",
                  controller: phoneController,
                  hint: "Masukkan nomor WhatsApp yang bisa dihubungi",
                  onChanged: validatePhone,
                  keyboardType: TextInputType.phone, // Keyboard khusus angka
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Nomor WhatsApp tidak boleh kosong';
                    }
                    return null; // Error detailnya dihandle checklist!
                  },
                ),
                const SizedBox(height: 5),
                // Checklist WhatsApp hanya muncul ketika user mulai mengetik
                if (phoneController.text.isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      checklistItem(isPhoneValid62, "Format nomor diawali 62"),
                      checklistItem(isPhoneValidLength, "Minimal 10 angka"),
                    ],
                  ),

                // Jarak antar field
                const SizedBox(height: 15),

                //? Password
                InputField(
                  label: "Password",
                  controller: passwordController,
                  hint: "Masukkan password",
                  // Obscure text: sembunyikan teks kalau isPasswordVisible false
                  obscureText: !isPasswordVisible,
                  onChanged: validatePassword,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Password tidak boleh kosong';
                    }
                    return null; // Error detailnya dihandle checklist!
                  },
                  suffixIcon: IconButton(
                    icon: Icon(
                      // Icon mata terbuka atau tertutup
                      isPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        // Toggle status visibilitas password
                        isPasswordVisible = !isPasswordVisible;
                      });
                    },
                  ),
                ),
                const SizedBox(height: 5),
                // Checklist Password hanya muncul ketika user mulai mengetik
                if (passwordController.text.isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      checklistItem(isPasswordMinLength, "Minimal 8 karakter"),
                      checklistItem(
                        isPasswordHasUppercase,
                        "Terdapat 1 huruf kapital",
                      ),
                      checklistItem(isPasswordHasNumber, "Terdapat 1 angka"),
                      checklistItem(
                        isPasswordHasSymbol,
                        "Terdapat 1 karakter simbol (!, @, dst)",
                      ),
                    ],
                  ),

                // Jarak antar field
                const SizedBox(height: 15),
              ],
            ),
          ),

          // =========================
          //* "I'M NOT A ROBOT" CHECKBOX
          // =========================
          GestureDetector(
            onTap: () {
              // Toggle status checkbox saat area ini ditekan
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
                    // Icon check_box atau check_box_outline_blank
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
            child: ElevatedButton(
              // Tombol bisa ditekan HANYA JIKA isButtonActive true
              onPressed: isButtonActive
                  ? () {
                      // Jalankan validator form secara manual saat tombol ditekan
                      if (_formKey.currentState!.validate()) {
                        // Kalau sukses, pindah ke halaman Home (ganti halaman, tidak bisa back)
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const HomePage(),
                          ),
                        );
                      }
                    }
                  : null, // Kalau isButtonActive false, tombol dinonaktifkan
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                // Warna tombol: hijau kalau aktif, abu-abu kalau tidak aktif
                backgroundColor: isButtonActive
                    ? const Color(0xFF077d60)
                    : Colors.grey,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              child: const Text("Daftarkan Akun"),
            ),
          ),

          const SizedBox(height: 20),

          // =========================
          //* TEXT SYARAT DAN KETENTUAN
          // =========================
          RichText(
            text: TextSpan(
              // Pakai TextSpan biar ada bagian yang jadi link
              text: "Dengan mendaftar di Luarsekolah, kamu menyetujui ",
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontSize: 15,
                fontWeight: FontWeight.w100,
                color: const Color(0xFF7B7F95), // Warna abu-abu
              ),
              children: [
                TextSpan(
                  text: "syarat dan ketentuan kami", // Bagian yang di-underline
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
                color: const Color(0xFFeff5ff), // Background biru muda
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: const Color(0xFF5b94f0),
                ), // Outline biru
              ),
              child: Row(
                mainAxisSize:
                    MainAxisSize.min, // Biar Row-nya nggak selebar layar
                children: [
                  const Text("👋 ", style: TextStyle(fontSize: 15)),
                  const Text(
                    "Sudah punya akun? ",
                    style: TextStyle(fontSize: 15),
                  ),
                  GestureDetector(
                    // Biar teks ini bisa diklik
                    onTap: () {
                      // Pindah ke halaman Login
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginPage(),
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
