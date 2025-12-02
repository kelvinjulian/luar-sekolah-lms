import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/course.dart';

class CourseRemoteDataSource {
  final String _baseUrl = "https://ls-lms.zoidify.my.id/api";

  Future<String> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token') ?? '';
  }

  Future<Map<String, String>> _getHeaders() async {
    final token = await _getToken();
    return {'Authorization': 'Bearer $token', 'Accept': 'application/json'};
  }

  // --- GET (Pakai 'courses' jamak) ---
  Future<List<Course>> getCourses({
    int limit = 20,
    int offset = 0,
    String? tag,
  }) async {
    String query = "?limit=$limit&offset=$offset";
    if (tag != null && tag.isNotEmpty) {
      query += "&categoryTag[]=${tag.toLowerCase()}";
    }

    // URL: /courses (Jamak)
    final url = '$_baseUrl/courses$query';

    final response = await http.get(
      Uri.parse(url),
      headers: await _getHeaders(),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List<dynamic> coursesJson = data['courses'];
      return coursesJson.map((json) => Course.fromMap(json)).toList();
    } else {
      throw Exception('Gagal ambil data: ${response.body}');
    }
  }

  // --- ADD (Pakai 'courses' jamak - Asumsi standar REST) ---
  Future<void> addCourse(Course course, File? imageFile) async {
    // URL: /courses (Jamak)
    var uri = Uri.parse('$_baseUrl/courses');
    var request = http.MultipartRequest('POST', uri);

    request.headers.addAll(await _getHeaders());
    request.fields['name'] = course.nama;
    request.fields['price'] = course.harga.toString();

    // Tag Handling
    if (course.tags.isNotEmpty) {
      for (int i = 0; i < course.tags.length; i++) {
        request.fields['categoryTag[$i]'] = course.tags[i].toLowerCase();
      }
    } else {
      request.fields['categoryTag[0]'] = 'lainnya';
    }

    if (imageFile != null) {
      var stream = http.ByteStream(imageFile.openRead());
      var length = await imageFile.length();
      var multipartFile = http.MultipartFile(
        'thumbnail',
        stream,
        length,
        filename: imageFile.path.split('/').last,
      );
      request.files.add(multipartFile);
    }

    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode != 200 && response.statusCode != 201) {
      print("ADD ERROR: ${response.body}");
      throw Exception('Gagal add: ${response.body}');
    }
  }

  // --- UPDATE COURSE (PUT dengan Wrapper 'data') ---
  Future<void> updateCourse(Course course, File? imageFile) async {
    if (course.id.isEmpty) throw Exception("ID Kelas kosong!");
    final String cleanId = course.id.trim();

    // URL: /course/{id}
    var uri = Uri.parse('$_baseUrl/course/$cleanId');
    print("UPDATE URL: $uri");

    var request = http.MultipartRequest('PUT', uri);

    request.headers.addAll(await _getHeaders());

    // --- PERBAIKAN UTAMA DI SINI ---
    // Server minta format: { "data": { "name": ... } }
    // Di Multipart, kita gunakan format key: data[name]

    request.fields['data[name]'] = course.nama;
    request.fields['data[price]'] = course.harga.toString();

    // Tag array juga dibungkus: data[categoryTag][0]
    for (int i = 0; i < course.tags.length; i++) {
      request.fields['data[categoryTag][$i]'] = course.tags[i].toLowerCase();
    }
    if (course.tags.isEmpty) {
      request.fields['data[categoryTag][0]'] = 'lainnya';
    }

    // Image juga dimasukkan ke dalam 'data'
    if (imageFile != null) {
      var stream = http.ByteStream(imageFile.openRead());
      var length = await imageFile.length();

      // Nama field file: data[thumbnail]
      var multipartFile = http.MultipartFile(
        'data[thumbnail]',
        stream,
        length,
        filename: imageFile.path.split('/').last,
      );
      request.files.add(multipartFile);
    }
    // Jika tidak ada gambar baru, API mungkin butuh URL gambar lama?
    // Coba kirim link thumbnail lama sebagai text jika tidak ada file baru
    else if (course.thumbnail.isNotEmpty) {
      request.fields['data[thumbnail]'] = course.thumbnail;
    }

    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode != 200) {
      print("UPDATE ERROR BODY: ${response.body}");
      throw Exception(
        'Gagal update (${response.statusCode}): ${response.body}',
      );
    }
  }

  // --- DELETE (Pakai 'course' TUNGGAL - Asumsi mengikuti pola Update) ---
  Future<void> deleteCourse(String id) async {
    final String cleanId = id.trim();

    // URL: /course/{id} (TUNGGAL)
    final uri = Uri.parse('$_baseUrl/course/$cleanId');
    print("DELETE URL: $uri");

    final response = await http.delete(uri, headers: await _getHeaders());

    if (response.statusCode != 200) {
      print("DELETE ERROR: ${response.body}");
      throw Exception('Gagal hapus: ${response.body}');
    }
  }
}
