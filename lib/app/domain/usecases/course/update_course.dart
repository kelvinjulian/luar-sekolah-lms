import 'dart:io';
import '../../repositories/i_course_repository.dart';
import '../../entities/course.dart';

class UpdateCourseUseCase {
  final ICourseRepository repository;

  UpdateCourseUseCase(this.repository);

  Future<void> call(Course course, File? imageFile) async {
    return repository.updateCourse(course, imageFile);
  }
}
