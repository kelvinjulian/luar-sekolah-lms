import '../../repositories/i_course_repository.dart';
import '../../entities/course.dart';

class GetAllCoursesUseCase {
  final ICourseRepository repository;
  GetAllCoursesUseCase(this.repository);

  // Update signature
  Future<List<Course>> call({
    int limit = 20,
    int offset = 0,
    String? tag,
  }) async {
    return await repository.getCourses(limit: limit, offset: offset, tag: tag);
  }
}
