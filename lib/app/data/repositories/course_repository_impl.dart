import 'dart:io';
import '../../domain/entities/course.dart';
import '../../domain/repositories/i_course_repository.dart';
import '../datasources/course_remote_data_source.dart';
import '../datasources/course_dummy_data_source.dart';

class CourseRepositoryImpl implements ICourseRepository {
  final CourseRemoteDataSource remoteDataSource;
  final CourseDummyDataSource dummyDataSource;

  /// FLAG KONTROL: Ubah ke 'false' jika server Zoidify sudah normal (tidak 502).
  /// Kita gunakan ini untuk menentukan sumber data mana yang dipakai.
  final bool useDummy = true;

  CourseRepositoryImpl({
    required this.remoteDataSource,
    required this.dummyDataSource,
  });

  @override
  Future<List<Course>> getCourses({
    int limit = 20,
    int offset = 0,
    String? tag,
  }) async {
    if (useDummy) {
      return await dummyDataSource.getCourses(
        limit: limit,
        offset: offset,
        tag: tag,
      );
    } else {
      return await remoteDataSource.getCourses(
        limit: limit,
        offset: offset,
        tag: tag,
      );
    }
  }

  @override
  Future<void> addCourse(Course course, File? imageFile) async {
    if (useDummy) {
      await dummyDataSource.addCourse(course, imageFile);
    } else {
      await remoteDataSource.addCourse(course, imageFile);
    }
  }

  @override
  Future<void> updateCourse(Course course, File? imageFile) async {
    if (useDummy) {
      await dummyDataSource.updateCourse(course, imageFile);
    } else {
      await remoteDataSource.updateCourse(course, imageFile);
    }
  }

  @override
  Future<void> deleteCourse(String id) async {
    if (useDummy) {
      await dummyDataSource.deleteCourse(id);
    } else {
      await remoteDataSource.deleteCourse(id);
    }
  }
}
