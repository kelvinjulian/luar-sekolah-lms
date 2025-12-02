import 'dart:io';
import '../../domain/entities/course.dart';
import '../../domain/repositories/i_course_repository.dart';
import '../datasources/course_remote_data_source.dart'; // Pastikan import ini benar

class CourseRepositoryImpl implements ICourseRepository {
  // PERBAIKAN: Tipe datanya harus CourseRemoteDataSource, JANGAN 'Course'
  final CourseRemoteDataSource dataSource;

  CourseRepositoryImpl(this.dataSource);

  @override
  Future<List<Course>> getCourses({
    int limit = 20,
    int offset = 0,
    String? tag,
  }) async {
    return await dataSource.getCourses(limit: limit, offset: offset, tag: tag);
  }

  @override
  Future<void> addCourse(Course course, File? imageFile) async {
    await dataSource.addCourse(course, imageFile);
  }

  @override
  Future<void> updateCourse(Course course, File? imageFile) async {
    await dataSource.updateCourse(course, imageFile);
  }

  @override
  Future<void> deleteCourse(String id) async {
    await dataSource.deleteCourse(id);
  }
}
