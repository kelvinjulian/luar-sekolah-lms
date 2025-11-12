// lib/app/domain/repositories/i_course_repository.dart
import '../entities/course.dart';

abstract class ICourseRepository {
  Future<List<Course>> getCourses();
  Future<Course> addCourse(Map<String, dynamic> data);
  Future<Course> updateCourse(Map<String, dynamic> data);
  Future<void> deleteCourse(String id);
}
