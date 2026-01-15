import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/course.dart';

class CourseRemoteDataSource {
  final String _baseUrl = "https://ls-lms.zoidify.my.id/api";

  // --- HELPER METHODS ---

  Future<String> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token') ?? '';
  }

  Future<Map<String, String>> _getHeaders() async {
    final token = await _getToken();
    return {'Authorization': 'Bearer $token', 'Accept': 'application/json'};
  }

  /// Fungsi sentral untuk menangani error dari server.
  /// Mencegah kode HTML (seperti 502 Bad Gateway) bocor ke UI.
  void _processResponseError(http.Response response, String defaultMessage) {
    // 1. Log detail ke konsol untuk kebutuhan debugging developer
    debugPrint("--- API ERROR LOG ---");
    debugPrint("Status Code: ${response.statusCode}");
    debugPrint("Body: ${response.body}");
    debugPrint("---------------------");

    // 2. Deteksi jika respon adalah HTML (Cloudflare, Nginx, atau Apache error page)
    if (response.body.contains('<!DOCTYPE html>') ||
        response.body.contains('<html>')) {
      if (response.statusCode == 502) {
        throw Exception(
          "Server sedang sibuk (Bad Gateway). Silakan coba beberapa saat lagi.",
        );
      } else if (response.statusCode == 404) {
        throw Exception("Layanan tidak ditemukan (404).");
      } else {
        throw Exception("Terjadi gangguan pada server. Silakan hubungi admin.");
      }
    }

    // 3. Jika respon JSON, coba ambil pesan error spesifik dari backend
    try {
      final Map<String, dynamic> data = jsonDecode(response.body);
      final String errorMessage =
          data['message'] ?? data['error'] ?? defaultMessage;
      throw Exception(errorMessage);
    } catch (e) {
      // Jika bukan JSON atau format tidak dikenal, lempar pesan default
      if (e is Exception) rethrow;
      throw Exception(defaultMessage);
    }
  }

  // --- CRUD OPERATIONS ---

  Future<List<Course>> getCourses({
    int limit = 20,
    int offset = 0,
    String? tag,
  }) async {
    String query = "?limit=$limit&offset=$offset";
    if (tag != null && tag.isNotEmpty) {
      query += "&categoryTag[]=${tag.toLowerCase()}";
    }

    final url = '$_baseUrl/courses$query';

    try {
      final response = await http
          .get(Uri.parse(url), headers: await _getHeaders())
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> coursesJson = data['courses'];
        return coursesJson.map((json) => Course.fromMap(json)).toList();
      } else {
        _processResponseError(response, 'Gagal mengambil data kelas.');
        return [];
      }
    } on SocketException {
      throw Exception('Tidak ada koneksi internet.');
    } catch (e) {
      rethrow;
    }
  }

  Future<void> addCourse(Course course, File? imageFile) async {
    var uri = Uri.parse('$_baseUrl/courses');
    var request = http.MultipartRequest('POST', uri);

    request.headers.addAll(await _getHeaders());
    request.fields['name'] = course.nama;
    request.fields['price'] = course.harga.toString();

    if (course.tags.isNotEmpty) {
      for (int i = 0; i < course.tags.length; i++) {
        request.fields['categoryTag[$i]'] = course.tags[i].toLowerCase();
      }
    } else {
      request.fields['categoryTag[0]'] = 'lainnya';
    }

    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode != 200 && response.statusCode != 201) {
      _processResponseError(response, 'Gagal menambahkan kelas baru.');
    }

    // Step 2: Auto Update Image jika ada file
    if (imageFile != null) {
      final responseData = jsonDecode(response.body);
      String? newId;
      if (responseData is Map) {
        newId =
            responseData['id']?.toString() ??
            responseData['data']?['id']?.toString() ??
            responseData['course']?['id']?.toString();
      }

      if (newId != null) {
        final tempCourse = Course(
          id: newId,
          nama: course.nama,
          harga: course.harga,
          thumbnail: '',
          tags: course.tags,
          tagColorsHex: [],
        );
        await updateCourse(tempCourse, imageFile);
      }
    }
  }

  Future<void> updateCourse(Course course, File? imageFile) async {
    if (course.id.isEmpty) throw Exception("ID Kelas tidak valid.");
    final String cleanId = course.id.trim();

    var uri = Uri.parse('$_baseUrl/course/$cleanId');
    var request = http.MultipartRequest('PUT', uri);

    request.headers.addAll(await _getHeaders());

    request.fields['data[name]'] = course.nama;
    request.fields['data[price]'] = course.harga.toString();

    for (int i = 0; i < course.tags.length; i++) {
      request.fields['data[categoryTag][$i]'] = course.tags[i].toLowerCase();
    }
    if (course.tags.isEmpty) request.fields['data[categoryTag][0]'] = 'lainnya';

    if (imageFile != null) {
      // Trik agar lolos validasi string backend
      request.fields['data[thumbnail]'] = "upload.jpg";

      var stream = http.ByteStream(imageFile.openRead());
      var length = await imageFile.length();
      var multipartFile = http.MultipartFile(
        'thumbnail',
        stream,
        length,
        filename: imageFile.path.split('/').last,
      );
      request.files.add(multipartFile);
    } else if (course.thumbnail.isNotEmpty) {
      request.fields['data[thumbnail]'] = course.thumbnail;
    }

    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode != 200) {
      // Untuk update, kita gunakan log peringatan saja jika hanya gagal di gambar
      debugPrint("Update Warning: ${response.body}");
      if (response.body.contains('<html>')) {
        _processResponseError(response, 'Gagal memperbarui data kelas.');
      }
    }
  }

  Future<void> deleteCourse(String id) async {
    final String cleanId = id.trim();
    final uri = Uri.parse('$_baseUrl/course/$cleanId');

    final response = await http.delete(uri, headers: await _getHeaders());

    if (response.statusCode != 200) {
      _processResponseError(response, 'Gagal menghapus kelas.');
    }
  }
}
