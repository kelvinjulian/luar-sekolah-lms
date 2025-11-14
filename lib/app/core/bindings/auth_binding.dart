import 'package:get/get.dart';
import '../../data/datasources/auth_firebase_data_source.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/repositories/i_auth_repository.dart';
import '../../domain/usecases/auth/login_use_case.dart';
import '../../domain/usecases/auth/register_use_case.dart';
import '../../domain/usecases/auth/logout_use_case.dart';
import '../../presentation/controllers/auth_controller.dart';

class AuthBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AuthFirebaseDataSource>(
      () => AuthFirebaseDataSource(),
      fenix: true,
    );
    Get.lazyPut<IAuthRepository>(
      () => AuthRepositoryImpl(Get.find<AuthFirebaseDataSource>()),
      fenix: true,
    );
    Get.lazyPut(() => LoginUseCase(Get.find<IAuthRepository>()));
    Get.lazyPut(() => RegisterUseCase(Get.find<IAuthRepository>()));
    Get.lazyPut(() => LogoutUseCase(Get.find<IAuthRepository>()));
    Get.lazyPut(
      () => AuthController(
        loginUseCase: Get.find<LoginUseCase>(),
        registerUseCase: Get.find<RegisterUseCase>(),
        logoutUseCase: Get.find<LogoutUseCase>(),
        authRepository: Get.find<IAuthRepository>(),
      ),
    );
  }
}
