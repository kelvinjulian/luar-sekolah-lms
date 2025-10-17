// Import library-library yang dibutuhkan.
import 'package:flutter/material.dart'; // Library dasar Flutter untuk UI.
import 'package:go_router/go_router.dart'; // Library utama untuk navigasi.
import '../pages/login_page.dart'; // Halaman Login.
import '../pages/register_page.dart'; // Halaman Register.
import '../pages/home_page.dart'; // Halaman Home.
import '../pages/class_form_page.dart'; // Halaman Form Tambah/Edit Kelas.

// 'router' adalah objek utama yang akan kita pasang di MaterialApp.
//* Objek ini berisi semua aturan navigasi untuk seluruh aplikasi.
final GoRouter router = GoRouter(
  //? initialLocation menentukan halaman mana yang akan pertama kali ditampilkan
  // saat aplikasi dibuka.
  initialLocation: '/register',

  // 'routes' adalah daftar semua "alamat" atau rute yang dikenali oleh aplikasi.
  routes: [
    // --- Rute untuk Halaman Registrasi ---
    GoRoute(
      // 'path' adalah alamat URL-like untuk halaman ini.
      path: '/register',
      // 'builder' adalah cara paling sederhana untuk menampilkan sebuah halaman.
      // Ia akan menggunakan animasi transisi default dari platform (misal: slide).
      builder: (context, state) => const RegisterPage(),
    ),

    // --- Rute untuk Halaman Login dengan Animasi Kustom ---
    GoRoute(
      path: '/login',
      // 'pageBuilder' digunakan saat kita ingin mengontrol animasi transisi.
      pageBuilder: (context, state) {
        // CustomTransitionPage adalah 'pembungkus' yang memungkinkan kita
        // mendefinisikan transisi kita sendiri.
        return CustomTransitionPage(
          key: state
              .pageKey, // Kunci unik yang penting untuk manajemen state go_router.
          child:
              const LoginPage(), // Widget halaman yang sebenarnya ingin ditampilkan.
          // 'transitionsBuilder' adalah fungsi yang mendefinisikan animasinya.
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            // Kita menggunakan FadeTransition untuk membuat efek 'fade in/out'.
            // Properti 'opacity' dihubungkan ke 'animation' yang disediakan.
            return FadeTransition(opacity: animation, child: child);
          },
          // Menentukan durasi total animasi.
          transitionDuration: const Duration(milliseconds: 350),
        );
      },
    ),

    // --- Rute untuk Halaman Home dengan Animasi Kustom yang Sama ---
    GoRoute(
      path: '/home',
      // Menggunakan pola yang sama seperti rute login untuk konsistensi.
      pageBuilder: (context, state) {
        return CustomTransitionPage(
          key: state.pageKey,
          child: const HomePage(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        );
      },
    ),

    // --- Rute untuk Halaman Form Kelas (Bisa Menerima Data) ---
    GoRoute(
      path: '/class/form',
      // Kita kembali menggunakan 'builder' karena tidak perlu animasi kustom di sini.
      builder: (context, state) {
        //? Ini adalah bagian kunci untuk mode 'Edit'.
        //? 'state.extra' adalah tempat untuk mengambil data yang dikirim saat navigasi
        // (contoh: context.push('/class/form', extra: dataKelas)).
        // 'as Map<String, dynamic>?' melakukan casting tipe data dan
        // tanda '?' membuatnya nullable (bisa bernilai null),
        // yang penting untuk mode 'Tambah' di mana tidak ada data yang dikirim.
        final data = state.extra as Map<String, dynamic>?;

        // Data yang diterima kemudian dilemparkan ke dalam constructor ClassFormPage.
        return ClassFormPage(initialData: data);
      },
    ),
  ],
);
