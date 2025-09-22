import 'package:flutter/material.dart';

void main() {
  runApp(const LmsApp()); // Jalankan aplikasi utama
}

//! Widget utama aplikasi
class LmsApp extends StatelessWidget {
  const LmsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LMS Luar Sekolah',
      home: const HomePage(), // Halaman pertama yang ditampilkan
      debugShowCheckedModeBanner: false, // Hilangkan banner debug
    );
  }
}

//! Halaman depan aplikasi
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        // Latar belakang gradasi biru
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue, Colors.lightBlueAccent],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min, // Supaya isi di tengah
            children: [
              const Icon(Icons.school, size: 80, color: Colors.white), // Logo
              const SizedBox(height: 20),
              const Text(
                "LMS Luar Sekolah",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () {
                  // Aksi tombol login (kosong dulu)
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.blue,
                ),
                child: const Text("Login"),
              ),
              const SizedBox(height: 10),
              OutlinedButton(
                onPressed: () {
                  // Aksi tombol register (kosong dulu)
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.white),
                  foregroundColor: Colors.white,
                ),
                child: const Text("Register"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
