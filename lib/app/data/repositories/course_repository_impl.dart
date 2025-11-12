// lib/app/data/repositories/course_repository_impl.dart
import '../../domain/entities/course.dart';
import '../../domain/repositories/i_course_repository.dart';
import '../datasources/course_dummy_data_source.dart';

class CourseRepositoryImpl implements ICourseRepository {
  final CourseDummyDataSource dataSource;

  CourseRepositoryImpl(this.dataSource);

  @override
  Future<List<Course>> getCourses() async {
    final listMap = await dataSource.getCourses();
    return listMap.map((map) => Course.fromMap(map)).toList();
  }

  @override
  Future<Course> addCourse(Map<String, dynamic> data) async {
    final map = await dataSource.addCourse(data);
    return Course.fromMap(map);
  }

  @override
  Future<Course> updateCourse(Map<String, dynamic> data) async {
    final map = await dataSource.updateCourse(data);
    return Course.fromMap(map);
  }

  @override
  Future<void> deleteCourse(String id) async {
    await dataSource.deleteCourse(id);
  }
}
