// lib/app/domain/usecases/course/add_course.dart
import '../../entities/course.dart';
import '../../repositories/i_course_repository.dart';

class AddCourseUseCase {
  final ICourseRepository repository;

  AddCourseUseCase(this.repository);

  // Menerima Map data mentah dari form
  Future<Course> call(Map<String, dynamic> data) {
    return repository.addCourse(data);
  }
}
