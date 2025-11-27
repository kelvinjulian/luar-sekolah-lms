import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mocktail/mocktail.dart';
import 'package:luar_sekolah_lms/app/domain/entities/todo.dart';
import 'package:luar_sekolah_lms/app/presentation/controllers/todo_controller.dart';
import 'package:luar_sekolah_lms/app/domain/usecases/todo/add_todo.dart';
import 'package:luar_sekolah_lms/app/domain/usecases/todo/get_all_todos.dart';
import 'package:luar_sekolah_lms/app/domain/usecases/todo/update_todo.dart';
import 'package:luar_sekolah_lms/app/domain/usecases/todo/delete_todo.dart';
import 'package:luar_sekolah_lms/app/core/services/notification_service.dart';

// --- MOCK CLASSES ---
class MockAddTodoUseCase extends Mock implements AddTodoUseCase {}

class MockGetAllTodosUseCase extends Mock implements GetAllTodosUseCase {}

class MockUpdateTodoUseCase extends Mock implements UpdateTodoUseCase {}

class MockDeleteTodoUseCase extends Mock implements DeleteTodoUseCase {}

// Menggunakan GetxService with Mock untuk menghindari error lifecycle
class MockNotificationService extends GetxService
    with Mock
    implements NotificationService {}

void main() {
  late TodoController controller;
  late MockAddTodoUseCase mockAddTodo;
  late MockGetAllTodosUseCase mockGetAllTodos;
  late MockNotificationService mockNotificationService;

  setUp(() {
    mockAddTodo = MockAddTodoUseCase();
    mockGetAllTodos = MockGetAllTodosUseCase();
    mockNotificationService = MockNotificationService();
    final mockUpdate = MockUpdateTodoUseCase();
    final mockDelete = MockDeleteTodoUseCase();

    Get.put<NotificationService>(mockNotificationService);

    // Setup default: fetch data mengembalikan list kosong
    when(() => mockGetAllTodos.call()).thenAnswer((_) async => []);

    controller = TodoController(
      addTodoUseCase: mockAddTodo,
      getAllTodosUseCase: mockGetAllTodos,
      updateTodoUseCase: mockUpdate,
      deleteTodoUseCase: mockDelete,
    );
  });

  tearDown(() {
    Get.reset();
  });

  test(
    'addTodo should call UseCase, refresh list, and trigger notification',
    () async {
      // ARRANGE
      const todoText = "Test Testing";
      final dummyTodo = Todo(id: 'test_id', text: todoText, completed: false);

      // STUB 1: UseCase mengembalikan objek Todo yang sudah dibuat
      when(() => mockAddTodo.call(todoText)).thenAnswer((_) async => dummyTodo);

      // STUB 2: Notifikasi harus sukses (Future<void>)
      when(
        () => mockNotificationService.showLocalNotification(
          title: any(named: 'title'),
          body: any(named: 'body'),
        ),
      ).thenAnswer((_) async => Future<void>.value());

      // ACT
      await controller.addTodo(todoText);

      // ASSERT
      verify(() => mockAddTodo.call(todoText)).called(1);
      verify(() => mockGetAllTodos.call()).called(greaterThan(0));
      verify(
        () => mockNotificationService.showLocalNotification(
          title: any(named: 'title'),
          body: any(named: 'body'),
        ),
      ).called(1);
    },
  );
}
