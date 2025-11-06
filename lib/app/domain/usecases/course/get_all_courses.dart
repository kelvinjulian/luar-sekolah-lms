// lib/app/domain/usecases/course/get_all_courses.dart
import '../../entities/course.dart';
import '../../repositories/i_course_repository.dart';

class GetAllCoursesUseCase {
  final ICourseRepository repository;

  GetAllCoursesUseCase(this.repository);

  Future<List<Course>> call() {
    return repository.getCourses();
  }
}
