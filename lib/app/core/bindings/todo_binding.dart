// lib/app/core/bindings/todo_binding.dart
import 'package:get/get.dart';

//? --- PERBAIKAN: Import file yang relevan ---
import '../../data/datasources/todo_remote_data_source.dart';
import '../../data/repositories/todo_repository_impl.dart';
import '../../domain/repositories/i_todo_repository.dart';
import '../../domain/usecases/todo/add_todo.dart';
import '../../domain/usecases/todo/delete_todo.dart';
import '../../domain/usecases/todo/get_all_todos.dart';
import '../../domain/usecases/todo/update_todo.dart';
import '../../presentation/controllers/todo_controller.dart';

class TodoBinding extends Bindings {
  @override
  void dependencies() {
    // --- DATA ---
    //? --- PERBAIKAN: Langsung inject RemoteDataSource ---
    Get.lazyPut<TodoRemoteDataSource>(
      () => TodoRemoteDataSource(),
      fenix: true,
    );

    //? --- PERBAIKAN: Repository di-inject dengan class konkret ---
    Get.lazyPut<ITodoRepository>(
      () => TodoRepositoryImpl(Get.find<TodoRemoteDataSource>()),
      fenix: true,
    );

    // --- DOMAIN (USE CASES) ---
    Get.lazyPut(() => GetAllTodosUseCase(Get.find<ITodoRepository>()));
    Get.lazyPut(() => AddTodoUseCase(Get.find<ITodoRepository>()));
    Get.lazyPut(() => UpdateTodoUseCase(Get.find<ITodoRepository>()));
    Get.lazyPut(() => DeleteTodoUseCase(Get.find<ITodoRepository>()));

    // --- PRESENTATION ---
    Get.lazyPut(
      () => TodoController(
        getAllTodosUseCase: Get.find<GetAllTodosUseCase>(),
        addTodoUseCase: Get.find<AddTodoUseCase>(),
        updateTodoUseCase: Get.find<UpdateTodoUseCase>(),
        deleteTodoUseCase: Get.find<DeleteTodoUseCase>(),
      ),
    );
  }
}
