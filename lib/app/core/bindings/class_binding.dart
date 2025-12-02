import 'package:get/get.dart';

import '../../data/repositories/course_repository_impl.dart';
import '../../domain/repositories/i_course_repository.dart';
import '../../domain/usecases/course/add_course.dart';
import '../../domain/usecases/course/delete_course.dart';
import '../../domain/usecases/course/get_all_courses.dart';
import '../../domain/usecases/course/update_course.dart';
import '../../presentation/controllers/class_controller.dart';

// IMPORT YANG BARU (API), HAPUS YANG FIRESTORE/DUMMY
import '../../data/datasources/course_remote_data_source.dart';

class ClassBinding extends Bindings {
  @override
  void dependencies() {
    // --- 1. DATA SOURCE: Ganti ke Remote (API) ---
    // Hapus baris CourseFirestoreDataSource atau CourseDummyDataSource
    Get.lazyPut<CourseRemoteDataSource>(() => CourseRemoteDataSource());

    // --- 2. REPOSITORY ---
    // Pastikan dia menerima CourseRemoteDataSource
    Get.lazyPut<ICourseRepository>(
      () => CourseRepositoryImpl(Get.find<CourseRemoteDataSource>()),
    );

    // --- 3. USE CASES (Tetap sama) ---
    Get.lazyPut(() => GetAllCoursesUseCase(Get.find<ICourseRepository>()));
    Get.lazyPut(() => AddCourseUseCase(Get.find<ICourseRepository>()));
    Get.lazyPut(() => UpdateCourseUseCase(Get.find<ICourseRepository>()));
    Get.lazyPut(() => DeleteCourseUseCase(Get.find<ICourseRepository>()));

    // --- 4. CONTROLLER (Tetap sama) ---
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
