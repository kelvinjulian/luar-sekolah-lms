// lib/pages/class_page.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart'; // Digunakan untuk navigasi antar halaman
import '../widgets/custom_cards.dart'; // Mengimpor widget kartu kustom kita, termasuk AdminCourseCard

// Definisi warna yang konsisten agar mudah diubah di satu tempat
const Color lsGreen = Color(0xFF0DA680);
const Color tagBlue = Color.fromARGB(255, 37, 146, 247);
const Color tagGreen = Color(0xFF0DA680);

// ClassPage diubah menjadi StatefulWidget agar bisa menyimpan dan mengelola data (state)
// yang bisa berubah, seperti daftar kelas.
class ClassPage extends StatefulWidget {
  const ClassPage({super.key});

  @override
  State<ClassPage> createState() => _ClassPageState();
}

class _ClassPageState extends State<ClassPage> {
  //? Ini adalah "database sementara" kita.
  // Sebuah List yang berisi Map, di mana setiap Map adalah satu data kelas.
  // Di aplikasi nyata, data ini akan diambil dari server/API.
  final List<Map<String, dynamic>> _allClasses = [
    {
      'id': '1',
      'nama': "Teknik Pemilahan dan Pengolahan Sampah",
      'harga': "1500000",
      'kategori': "SPL",
      'thumbnail': "assets/images/course1.png",
      'tags': ["Prakerja", "SPL"],
      'tagColors': [tagBlue, tagGreen],
    },
    {
      'id': '2',
      'nama': "Meningkatkan Pertumbuhan Tanaman untuk Petani Terampil",
      'harga': "1500000",
      'kategori': "Prakerja",
      'thumbnail': "assets/images/course2.png",
      'tags': ["Prakerja"],
      'tagColors': [tagBlue],
    },
  ];

  //* Fungsi ini dibuat terpisah untuk menampilkan dialog konfirmasi
  // sebelum melakukan aksi hapus. Ini adalah praktik UX yang baik.
  Future<void> _showDeleteConfirmationDialog(
    Map<String, dynamic> classData,
  ) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Konfirmasi Hapus'),
          content: Text(
            'Apakah Anda yakin ingin menghapus kelas "${classData['nama']}"?',
          ),
          actions: <Widget>[
            // Tombol untuk membatalkan aksi
            TextButton(
              child: const Text('Batal'),
              onPressed: () =>
                  Navigator.of(dialogContext).pop(), // Cukup tutup dialog
            ),
            // Tombol untuk mengkonfirmasi aksi hapus
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Ya, Hapus'),
              onPressed: () {
                // setState() memberitahu Flutter bahwa ada perubahan data,
                // sehingga UI perlu di-render ulang.
                setState(() {
                  // Hapus item dari list _allClasses yang memiliki 'id' yang sama.
                  _allClasses.removeWhere(
                    (item) => item['id'] == classData['id'],
                  );
                });
                Navigator.of(
                  dialogContext,
                ).pop(); // Tutup dialog setelah menghapus
              },
            ),
          ],
        );
      },
    );
  }

  //* Method build() adalah tempat semua UI untuk halaman ini dibuat.
  @override
  Widget build(BuildContext context) {
    // DefaultTabController adalah widget yang mengatur state untuk TabBar
    // dan TabBarView, membuatnya saling terhubung.
    return DefaultTabController(
      length: 3, // Jumlah tab yang kita miliki
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Manajemen Kelas',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.white,
          elevation: 1.0,
          bottom: const TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            labelColor: lsGreen,
            unselectedLabelColor: Colors.grey,
            indicatorColor: lsGreen,
            tabs: [
              Tab(text: 'Kelas Terpopuler'),
              Tab(text: 'Kelas SPL'),
              Tab(text: 'Kelas Lainnya'),
            ],
          ),
        ),
        // TabBarView berisi konten untuk setiap tab. Urutannya harus sama dengan
        // urutan Tab di dalam TabBar.
        body: TabBarView(
          children: [
            _buildClassList(context), // Konten untuk tab pertama
            _buildClassList(
              context,
            ), // Konten untuk tab kedua (bisa difilter nanti)
            const Center(
              child: Text('Belum ada kelas lainnya'),
            ), // Konten untuk tab ketiga
          ],
        ),
      ),
    );
  }

  //* Ini adalah widget helper yang dibuat terpisah untuk membangun UI daftar kelas.
  //? Tujuannya agar method build() utama tetap bersih dan mudah dibaca.
  Widget _buildClassList(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        // ======================
        //* Tambah Kelas Button
        // ======================
        ElevatedButton.icon(
          //? Fungsi onPressed dijadikan 'async' agar kita bisa menggunakan 'await'.
          onPressed: () async {
            //? 'await context.push(...)' akan membuka halaman form dan MENUNGGU
            //? sampai halaman tersebut ditutup dan mengembalikan data.
            final result = await context.push('/class/form');

            //? Setelah kembali dari form, kita cek apakah ada data yang dikembalikan.
            //? Pengguna bisa saja menekan 'Kembali' tanpa menyimpan, maka result akan null.
            if (result != null && result is Map<String, dynamic>) {
              setState(() {
                // Jika ada data baru, tambahkan ke list _allClasses.
                // UI akan otomatis diperbarui.
                _allClasses.add(result);
              });
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: lsGreen,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
          icon: const Icon(Icons.add),
          label: const Text('Tambah Kelas'),
        ),
        const SizedBox(height: 20),

        //* Ini adalah cara dinamis untuk membuat daftar widget dari daftar data.
        //* Operator '...' (spread) digunakan untuk memasukkan semua widget
        //* yang dihasilkan oleh .map() ke dalam list children dari ListView.
        ..._allClasses.map((classData) {
          // Untuk setiap item 'classData' di dalam list '_allClasses',
          //? kita buat satu widget AdminCourseCard.
          return AdminCourseCard(
            title: classData['nama'],
            image: classData['thumbnail'],
            //? Kita perlu melakukan casting (.cast<String>()) untuk memastikan tipe datanya benar
            tags: (classData['tags'] as List<dynamic>).cast<String>(),
            tagColors: (classData['tagColors'] as List<dynamic>).cast<Color>(),
            price: "Rp ${classData['harga']}",
            onEdit: () async {
              // Logikanya sama seperti 'Tambah', tapi kita mengirim 'classData'
              // melalui 'extra' agar form berjalan dalam mode edit.
              final result = await context.push(
                '/class/form',
                extra: classData,
              );

              if (result != null && result is Map<String, dynamic>) {
                setState(() {
                  // Jika ada data yang dikembalikan (perubahan disimpan),
                  // kita cari item yang lama di dalam list berdasarkan 'id'.
                  final index = _allClasses.indexWhere(
                    (item) => item['id'] == result['id'],
                  );
                  if (index != -1) {
                    // Lalu kita ganti data lama dengan data baru (hasil editan).
                    _allClasses[index] = result;
                  }
                });
              }
            },
            onDelete: () {
              // Memanggil dialog konfirmasi sebelum menghapus data.
              _showDeleteConfirmationDialog(classData);
            },
          );
        }),
      ],
    );
  }
}
