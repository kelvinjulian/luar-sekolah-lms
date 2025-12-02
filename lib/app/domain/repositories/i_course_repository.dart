import 'dart:io';
import '../entities/course.dart';

abstract class ICourseRepository {
  // Gunakan STREAM, bukan Future
  Future<List<Course>> getCourses({
    int limit = 20,
    int offset = 0,
    String? tag,
  });
  Future<void> addCourse(Course course, File? imageFile);
  Future<void> updateCourse(Course course, File? imageFile);
  Future<void> deleteCourse(String id);
}
