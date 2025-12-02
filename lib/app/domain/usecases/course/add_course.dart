import 'dart:io';
import '../../repositories/i_course_repository.dart';
import '../../entities/course.dart';

class AddCourseUseCase {
  final ICourseRepository repository;

  AddCourseUseCase(this.repository);

  // Ubah parameter dari Map ke (Course, File?)
  Future<void> call(Course course, File? imageFile) async {
    return repository.addCourse(course, imageFile);
  }
}
