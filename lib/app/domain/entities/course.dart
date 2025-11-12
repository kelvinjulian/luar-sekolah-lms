// lib/app/domain/entities/course.dart

//? --- PERBAIKAN DI SINI ---
//? Kita ubah nilai hex string di sini sesuai permintaan Anda.

//? Diubah dari 0xFF2592F7 menjadi 0xFF2893F7 (hex #2893f7)
const String tagBlueHex = "0xFF2893F7";

//? Diubah dari 0xFF0DA680 menjadi 0xFF00A67F (hex #00a67f)
const String tagGreenHex = "0xFF00A67F";

const String tagPurpleHex = "0xFF800080"; // Warna 'Lainnya' (tetap)
//? --------------------------

class Course {
  final String id;
  final String nama;
  final String harga;
  final String thumbnail;
  final List<String> tags;
  final List<String> tagColorsHex;

  Course({
    required this.id,
    required this.nama,
    required this.harga,
    required this.thumbnail,
    required this.tags,
    required this.tagColorsHex,
  });

  // 'fromJson' (Data Mentah -> Entity)
  factory Course.fromMap(Map<String, dynamic> map) {
    return Course(
      id: map['id'] as String,
      nama: map['nama'] as String,
      harga: map['harga'] as String,
      thumbnail: map['thumbnail'] as String,
      tags: (map['tags'] as List<dynamic>).cast<String>(),
      tagColorsHex: (map['tagColorsHex'] as List<dynamic>).cast<String>(),
    );
  }

  // 'toMap' (Entity -> Data Mentah)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nama': nama,
      'harga': harga,
      'thumbnail': thumbnail,
      'tags': tags,
      'tagColorsHex': tagColorsHex,
    };
  }
}
