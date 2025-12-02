class Course {
  final String id;
  final String nama;
  final int harga;
  final String thumbnail;
  final List<String> tags;
  final List<String> tagColorsHex;

  // Konstanta Warna
  static const String tagBlueHex = "0xFF2893F7"; // Prakerja
  static const String tagGreenHex = "0xFF00A67F"; // SPL
  static const String tagPurpleHex =
      "0xFF800080"; // Populer (UBAH KE UNGU) & Lainnya
  static const String tagGreyHex =
      "0xFF9E9E9E"; // Opsional untuk Lainnya jika mau beda

  Course({
    required this.id,
    required this.nama,
    required this.harga,
    required this.thumbnail,
    required this.tags,
    required this.tagColorsHex,
  });

  factory Course.fromMap(Map<String, dynamic> map) {
    // 1. NORMALISASI TAG (API Lowercase -> UI Title Case)
    List<String> parsedTags = [];
    if (map['categoryTag'] != null) {
      parsedTags = (map['categoryTag'] as List).map((tag) {
        String t = tag.toString().toLowerCase(); // Pastikan lowercase dulu

        if (t == 'populer') return 'Populer';
        if (t == 'spl') return 'SPL';
        if (t == 'prakerja') return 'Prakerja';

        // Capitalize huruf pertama untuk tag lain
        if (t.length > 1) return t[0].toUpperCase() + t.substring(1);
        return t;
      }).toList();
    }

    // 2. GENERATE WARNA (Berdasarkan Tag yang sudah dinormalisasi)
    List<String> colors = [];
    for (var tag in parsedTags) {
      if (tag == 'Populer') {
        colors.add(tagPurpleHex); // <-- SEKARANG UNGU
      } else if (tag == 'Prakerja') {
        colors.add(tagBlueHex);
      } else if (tag == 'SPL') {
        colors.add(tagGreenHex);
      } else {
        colors.add(
          tagPurpleHex,
        ); // Lainnya juga ungu (atau ganti tagGreyHex jika mau beda)
      }
    }
    // Fallback warna jika kosong
    if (colors.isEmpty && parsedTags.isNotEmpty) colors.add(tagPurpleHex);

    // 3. PARSE HARGA
    int parsedPrice = 0;
    if (map['price'] != null) {
      parsedPrice = double.tryParse(map['price'].toString())?.toInt() ?? 0;
    }

    return Course(
      id: map['id']?.toString() ?? '',
      nama: map['name'] ?? '',
      harga: parsedPrice,
      thumbnail: map['thumbnail'] ?? '', // Pastikan ini URL (https://...)
      tags: parsedTags,
      tagColorsHex: colors,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nama': nama,
      'harga': harga.toString(),
      'thumbnail': thumbnail,
      'tags': tags,
      'tagColorsHex': tagColorsHex,
    };
  }
}
