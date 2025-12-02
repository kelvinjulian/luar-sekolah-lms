import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mocktail/mocktail.dart';

import 'package:luar_sekolah_lms/app/presentation/controllers/todo_controller.dart';
import 'package:luar_sekolah_lms/app/domain/entities/todo.dart';
import 'package:luar_sekolah_lms/app/domain/usecases/todo/add_todo.dart';
import 'package:luar_sekolah_lms/app/domain/usecases/todo/get_all_todos.dart';
import 'package:luar_sekolah_lms/app/domain/usecases/todo/update_todo.dart';
import 'package:luar_sekolah_lms/app/domain/usecases/todo/delete_todo.dart';
// Jika kamu sudah membuat SearchTodosUseCase, import juga di sini dan mock
import 'package:luar_sekolah_lms/app/domain/usecases/todo/search_todos.dart';
import 'package:luar_sekolah_lms/app/core/services/notification_service.dart';

class MockGetAllTodosUseCase extends Mock implements GetAllTodosUseCase {}

class MockAddTodoUseCase extends Mock implements AddTodoUseCase {}

class MockUpdateTodoUseCase extends Mock implements UpdateTodoUseCase {}

class MockDeleteTodoUseCase extends Mock implements DeleteTodoUseCase {}

class MockSearchTodosUseCase extends Mock implements SearchTodosUseCase {}

class MockNotificationService extends Mock implements NotificationService {}

void main() {
  late TodoController controller;
  late MockGetAllTodosUseCase mockGetAll;
  late MockAddTodoUseCase mockAdd;
  late MockUpdateTodoUseCase mockUpdate;
  late MockDeleteTodoUseCase mockDelete;
  late MockNotificationService mockNotif;

  setUpAll(() {
    registerFallbackValue(Todo(id: '0', text: 'fallback', completed: false));
  });

  setUp(() {
    mockGetAll = MockGetAllTodosUseCase();
    mockAdd = MockAddTodoUseCase();
    mockUpdate = MockUpdateTodoUseCase();
    mockDelete = MockDeleteTodoUseCase();
    mockNotif = MockNotificationService();

    // Default Stub untuk getAll (agar onInit tidak crash)
    when(
      () => mockGetAll(
        limit: any(named: 'limit'),
        startAfter: any(named: 'startAfter'),
      ),
    ).thenAnswer((_) async => []);

    Get.testMode = true;
    Get.reset();

    // Inject Controller (Tambahkan mockSearch jika kamu sudah implementasi fitur search)
    controller = TodoController(
      getAllTodosUseCase: mockGetAll,
      searchTodosUseCase: MockSearchTodosUseCase(), // Uncomment jika ada
      addTodoUseCase: mockAdd,
      updateTodoUseCase: mockUpdate,
      deleteTodoUseCase: mockDelete,
      notificationService: mockNotif,
      // searchTodosUseCase: MockSearchTodosUseCase(), // Uncomment jika ada
    );
  });

  group('TodoController Tests', () {
    // 1. FETCH
    test('fetchTodos success updates allTodos list', () async {
      final dummyList = [Todo(id: '1', text: 'Test', completed: false)];

      when(
        () => mockGetAll(
          limit: any(named: 'limit'),
          startAfter: any(named: 'startAfter'),
        ),
      ).thenAnswer((_) async => dummyList);

      await controller.fetchTodos(isRefresh: true);

      expect(controller.isLoading.value, isFalse);
      expect(controller.allTodos.length, 1);
    });

    // 2. ADD TODO (Updated Signature)
    test('addTodo success triggers UseCase and Refresh', () async {
      const newText = "New Task";

      // Stub Add UseCase: Menerima Todo Object
      when(() => mockAdd(any())).thenAnswer((_) async {});

      // Stub Notification
      when(
        () => mockNotif.showLocalNotification(
          title: any(named: 'title'),
          body: any(named: 'body'),
        ),
      ).thenAnswer((_) async {});

      // ACT: Panggil dengan 2 parameter (Text, Null Date)
      await controller.addTodo(newText, null);

      // ASSERT
      // Verifikasi UseCase dipanggil dengan object Todo yang berisi text yang benar
      verify(
        () => mockAdd(
          any(that: isA<Todo>().having((t) => t.text, 'text', newText)),
        ),
      ).called(1);

      // Verifikasi Refresh dipanggil
      verify(
        () => mockGetAll(
          limit: any(named: 'limit'),
          startAfter: any(named: 'startAfter'),
        ),
      ).called(greaterThan(0));
    });
  });
}
