// lib/app/domain/usecases/course/update_course.dart
import '../../entities/course.dart';
import '../../repositories/i_course_repository.dart';

class UpdateCourseUseCase {
  final ICourseRepository repository;

  UpdateCourseUseCase(this.repository);

  // Menerima Map data mentah dari form
  Future<Course> call(Map<String, dynamic> data) {
    return repository.updateCourse(data);
  }
}
