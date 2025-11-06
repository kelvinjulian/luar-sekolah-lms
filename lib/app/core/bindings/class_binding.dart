// lib/app/core/bindings/class_binding.dart
import 'package:get/get.dart';

import '../../data/datasources/course_dummy_data_source.dart';
import '../../data/repositories/course_repository_impl.dart';
import '../../domain/repositories/i_course_repository.dart';
import '../../domain/usecases/course/add_course.dart';
import '../../domain/usecases/course/delete_course.dart';
import '../../domain/usecases/course/get_all_courses.dart';
import '../../domain/usecases/course/update_course.dart';
import '../../presentation/controllers/class_controller.dart';

class ClassBinding extends Bindings {
  @override
  void dependencies() {
    // --- DATA ---
    Get.lazyPut<CourseDummyDataSource>(
      () => CourseDummyDataSource(),
      fenix: true,
    );
    Get.lazyPut<ICourseRepository>(
      () => CourseRepositoryImpl(Get.find<CourseDummyDataSource>()),
      fenix: true,
    );

    // --- DOMAIN (USE CASES) ---
    Get.lazyPut(() => GetAllCoursesUseCase(Get.find<ICourseRepository>()));
    Get.lazyPut(() => AddCourseUseCase(Get.find<ICourseRepository>()));
    Get.lazyPut(() => UpdateCourseUseCase(Get.find<ICourseRepository>()));
    Get.lazyPut(() => DeleteCourseUseCase(Get.find<ICourseRepository>()));

    // --- PRESENTATION ---
    Get.lazyPut(
      () => ClassController(
        getAllCoursesUseCase: Get.find<GetAllCoursesUseCase>(),
        addCourseUseCase: Get.find<AddCourseUseCase>(),
        updateCourseUseCase: Get.find<UpdateCourseUseCase>(),
        deleteCourseUseCase: Get.find<DeleteCourseUseCase>(),
      ),
    );
  }
}
