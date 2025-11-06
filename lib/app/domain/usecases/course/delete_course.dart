// lib/app/domain/usecases/course/delete_course.dart
import '../../repositories/i_course_repository.dart';

class DeleteCourseUseCase {
  final ICourseRepository repository;

  DeleteCourseUseCase(this.repository);

  Future<void> call(String id) {
    return repository.deleteCourse(id);
  }
}
