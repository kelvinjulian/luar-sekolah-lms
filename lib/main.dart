// lib/main.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'app/core/routes/app_routes.dart';
import 'app/presentation/controllers/auth_controller.dart';
import 'app/data/repositories/auth_repository_impl.dart';
import 'app/data/datasources/auth_firebase_data_source.dart';
import 'app/domain/usecases/auth/login_use_case.dart';
import 'app/domain/usecases/auth/register_use_case.dart';
import 'app/domain/usecases/auth/logout_use_case.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Inisialisasi hanya sekali, dan permanen
  final dataSource = AuthFirebaseDataSource();
  final repo = AuthRepositoryImpl(dataSource);

  Get.put(
    AuthController(
      loginUseCase: LoginUseCase(repo),
      registerUseCase: RegisterUseCase(repo),
      logoutUseCase: LogoutUseCase(repo),
      authRepository: repo,
    ),
    permanent: true, // Penting!
  );

  runApp(const LmsApp());
}

class LmsApp extends StatelessWidget {
  const LmsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'LMS App (Clean Architecture)',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        appBarTheme: const AppBarTheme(
          elevation: 1.0,
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
        ),
      ),
      initialRoute: AppPages.INITIAL,
      getPages: AppPages.pages,
    );
  }
}
