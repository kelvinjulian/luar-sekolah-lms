// lib/app/data/datasources/course_dummy_data_source.dart
import '../../domain/entities/course.dart'; // Import untuk hex constants

class CourseDummyDataSource {
  // Database dummy (data dari ClassController lama Anda)
  final List<Map<String, dynamic>> _dummyCourses = [
    {
      'id': '1',
      'nama': "Teknik Pemilahan dan Pengolahan Sampah",
      'harga': "1500000",
      'thumbnail': "assets/images/course1.png",
      'tags': ["Prakerja", "SPL"],
      'tagColorsHex': [tagBlueHex, tagGreenHex], // <-- REFAKTOR
    },
    {
      'id': '2',
      'nama': "Meningkatkan Pertumbuhan Tanaman untuk Petani Terampil",
      'harga': "1500000",
      'thumbnail': "assets/images/course2.png",
      'tags': ["Prakerja"],
      'tagColorsHex': [tagBlueHex], // <-- REFAKTOR
    },
    {
      'id': '3',
      'nama': "Kursus Public Speaking",
      'harga': "1000000",
      'thumbnail': "assets/images/course1.png",
      'tags': ["Lainnya"],
      'tagColorsHex': [tagPurpleHex], // <-- REFAKTOR
    },
  ];

  Future<void> _simulateDelay() =>
      Future.delayed(const Duration(milliseconds: 800));

  Future<List<Map<String, dynamic>>> getCourses() async {
    await _simulateDelay();
    return List<Map<String, dynamic>>.from(_dummyCourses);
  }

  Future<Map<String, dynamic>> addCourse(Map<String, dynamic> data) async {
    await _simulateDelay();
    _dummyCourses.add(data);
    return data;
  }

  Future<Map<String, dynamic>> updateCourse(Map<String, dynamic> data) async {
    await _simulateDelay();
    final index = _dummyCourses.indexWhere((item) => item['id'] == data['id']);
    if (index != -1) {
      _dummyCourses[index] = data;
    }
    return data;
  }

  Future<void> deleteCourse(String id) async {
    await _simulateDelay();
    _dummyCourses.removeWhere((item) => item['id'] == id);
  }
}
