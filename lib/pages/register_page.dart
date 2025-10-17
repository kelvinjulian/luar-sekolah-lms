import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart'; // Buat pakai gambar SVG (seperti logo Google atau logo aplikasi)
import 'package:go_router/go_router.dart'; // Buat navigasi antar halaman
import '../widgets/input_field.dart'; // Ini ambil widget custom InputField kita dari folder widgets
import '../widgets/checklist_item.dart'; // Ambil widget ChecklistItem dari folder widgets

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

  // TODO
  bool _isLoading = false; // Untuk mengontrol status loading
  bool _isSuccess = false; // Untuk menandakan pendaftaran berhasil

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
                //* Nama Lengkap
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

                // Jarak antar field
                const SizedBox(height: 15),

                //* Email
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
                //? Mengontrol kapan seluruh checklist muncul
                // TODO MODIFIKASI: Animasi kemunculan checklist Email
                AnimatedSize(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOut,
                  child: emailController.text.isNotEmpty
                      ? Opacity(
                          opacity: 1.0,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Beri sedikit jarak di dalam agar lebih rapi saat animasi
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
                      // Widget ini akan ditampilkan saat kondisi false (ukuran 0x0)
                      : const SizedBox.shrink(),
                ),

                // Jarak antar field
                const SizedBox(height: 15),

                //* Nomor WhatsApp
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
                //? Checklist WhatsApp hanya muncul ketika user mulai mengetik
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

                // Jarak antar field
                const SizedBox(height: 15),

                //* Password
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
                //? Checklist Password hanya muncul ketika user mulai mengetik
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
          // TODO
          SizedBox(
            width: double.infinity,
            height:
                54, // Beri tinggi tetap agar layout tidak "loncat" saat loading
            child: ElevatedButton(
              //? Tampilkan animasi loading ketika isLoading true
              onPressed: isButtonActive && !_isLoading
                  ? () async {
                      //? Validasi form sebelum melanjutkan
                      if (_formKey.currentState!.validate()) {
                        // 1. Mulai animasi loading
                        setState(() {
                          _isLoading = true;
                        });

                        // 2. Simulasikan proses login (misal: 2 detik)
                        await Future.delayed(const Duration(seconds: 2));

                        // 3. Tandai sukses dan hentikan loading
                        setState(() {
                          _isLoading = false; // Selesai loading
                          _isSuccess = true;
                        });

                        // 4. Tampilkan pesan sukses
                        //? Tampilkan SnackBar konfirmasi, kenapa menggunakan if (mounted) karena ini async jadi perlu dicek dulu apakah widget masih ada di layar
                        if (mounted) {
                          // ignore: use_build_context_synchronously
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Pendaftaran berhasil! Anda akan diarahkan ke halaman login.',
                              ),
                              backgroundColor: Colors.green,
                              behavior: SnackBarBehavior
                                  .floating, // Agar terlihat lebih modern
                            ),
                          );
                        }

                        // 5. Beri jeda agar user melihat animasi & pesan
                        await Future.delayed(
                          const Duration(milliseconds: 1500),
                        );

                        // 6. Arahkan ke Halaman Login
                        if (mounted) {
                          // ignore: use_build_context_synchronously
                          context.go(
                            '/login',
                            //TODO
                          ); //? menggunakan go() untuk pindah dan hapus halaman sebelumnya
                        }
                      }
                    }
                  : null,

              // Tombol aktif hanya jika semua kriteria terpenuhi
              style: ElevatedButton.styleFrom(
                backgroundColor: _isSuccess
                    ? Colors
                          .green // Warna hijau saat sukses
                    : (isButtonActive ? const Color(0xFF077d60) : Colors.grey),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              // Ganti child untuk menampilkan konten dinamis
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : _isSuccess
                  ? const Icon(Icons.check, size: 28)
                  : const Text("Daftarkan Akun"),
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
                      //TODO
                      //? Pindah ke Login (menambahkan halaman baru ke stack) sehingga bisa back lagi ke sini
                      context.push('/login');
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
