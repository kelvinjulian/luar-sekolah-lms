import 'package:get/get.dart';

import '../../data/repositories/course_repository_impl.dart';
import '../../domain/repositories/i_course_repository.dart';
import '../../domain/usecases/course/add_course.dart';
import '../../domain/usecases/course/delete_course.dart';
import '../../domain/usecases/course/get_all_courses.dart';
import '../../domain/usecases/course/update_course.dart';
import '../../presentation/controllers/class_controller.dart';

// --- IMPORT DATA SOURCES ---
import '../../data/datasources/course_remote_data_source.dart';
import '../../data/datasources/course_dummy_data_source.dart'; // Tambahkan ini

class ClassBinding extends Bindings {
  @override
  void dependencies() {
    // --- 1. DATA SOURCES ---
    // Kita daftarkan keduanya agar Repository bisa memilih salah satu
    Get.lazyPut<CourseRemoteDataSource>(() => CourseRemoteDataSource());
    Get.lazyPut<CourseDummyDataSource>(() => CourseDummyDataSource());

    // --- 2. REPOSITORY ---
    // Inject kedua data source menggunakan named parameters sesuai constructor terbaru
    Get.lazyPut<ICourseRepository>(
      () => CourseRepositoryImpl(
        remoteDataSource: Get.find<CourseRemoteDataSource>(),
        dummyDataSource: Get.find<CourseDummyDataSource>(),
      ),
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
