import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mocktail/mocktail.dart';

// Import Domain & Controller
import 'package:luar_sekolah_lms/app/presentation/controllers/todo_controller.dart';
import 'package:luar_sekolah_lms/app/domain/entities/todo.dart';
import 'package:luar_sekolah_lms/app/domain/usecases/todo/add_todo.dart';
import 'package:luar_sekolah_lms/app/domain/usecases/todo/get_all_todos.dart';
import 'package:luar_sekolah_lms/app/domain/usecases/todo/update_todo.dart';
import 'package:luar_sekolah_lms/app/domain/usecases/todo/delete_todo.dart';
import 'package:luar_sekolah_lms/app/core/services/notification_service.dart';

// --- MOCKS ---
class MockGetAllTodosUseCase extends Mock implements GetAllTodosUseCase {}

class MockAddTodoUseCase extends Mock implements AddTodoUseCase {}

class MockUpdateTodoUseCase extends Mock implements UpdateTodoUseCase {}

class MockDeleteTodoUseCase extends Mock implements DeleteTodoUseCase {}

class MockNotificationService extends Mock implements NotificationService {}

void main() {
  late TodoController controller;
  late MockGetAllTodosUseCase mockGetAll;
  late MockAddTodoUseCase mockAdd;
  late MockUpdateTodoUseCase mockUpdate;
  late MockDeleteTodoUseCase mockDelete;
  late MockNotificationService mockNotif;

  setUp(() {
    mockGetAll = MockGetAllTodosUseCase();
    mockAdd = MockAddTodoUseCase();
    mockUpdate = MockUpdateTodoUseCase();
    mockDelete = MockDeleteTodoUseCase();
    mockNotif = MockNotificationService();

    // Register Fallback Value (Penting untuk Mocktail jika ada argument object)
    registerFallbackValue(Todo(id: '0', text: 'fallback', completed: false));

    // STUB DEFAULT: Fetch mengembalikan list kosong agar onInit aman
    when(() => mockGetAll()).thenAnswer((_) async => []);

    // Setup GetX Environment
    Get.testMode = true;
    Get.reset();

    // INJECT Service via Constructor
    controller = TodoController(
      getAllTodosUseCase: mockGetAll,
      addTodoUseCase: mockAdd,
      updateTodoUseCase: mockUpdate,
      deleteTodoUseCase: mockDelete,
      notificationService: mockNotif,
    );

    // Trigger onInit manual untuk memuat data awal
    controller.onInit();
  });

  tearDown(() {
    Get.reset();
  });

  group('TodoController Tests', () {
    // 1. TEST FETCH DATA
    test('fetchTodos success updates allTodos list', () async {
      // ARRANGE
      final dummyList = [Todo(id: '1', text: 'Test', completed: false)];
      when(() => mockGetAll()).thenAnswer((_) async => dummyList);

      // ACT
      await controller.fetchTodos();

      // ASSERT
      expect(controller.isLoading.value, isFalse);
      expect(controller.allTodos.length, 1);
      expect(controller.allTodos.first.text, 'Test');
    });

    // 2. TEST ADD TODO
    test(
      'addTodo success triggers UseCase, Fetch, and Local Notification',
      () async {
        // ARRANGE
        const newText = "New Task";
        // Stub Add: sukses
        when(() => mockAdd(newText)).thenAnswer(
          (_) async => Todo(id: '2', text: newText, completed: false),
        );
        // Stub Notif: sukses
        when(
          () => mockNotif.showLocalNotification(
            title: any(named: 'title'),
            body: any(named: 'body'),
          ),
        ).thenAnswer((_) async {});

        // ACT
        await controller.addTodo(newText);

        // ASSERT
        // 1. Pastikan Add UseCase dipanggil
        verify(() => mockAdd(newText)).called(1);
        // 2. Pastikan data di-fetch ulang
        verify(() => mockGetAll()).called(greaterThan(0));

        // 3. Pastikan Notifikasi muncul
        // PERBAIKAN: Gunakan any(named: 'body', that: contains(...))
        verify(
          () => mockNotif.showLocalNotification(
            title: "Catatan Baru Ditambahkan",
            body: any(named: 'body', that: contains(newText)),
          ),
        ).called(1);
      },
    );

    // 3. TEST TOGGLE STATUS
    test(
      'toggleTodoStatus updates Todo and sends correct notification',
      () async {
        // ARRANGE
        final todo = Todo(id: '1', text: 'Task A', completed: false);
        // Stub Update
        when(
          () => mockUpdate(any()),
        ).thenAnswer((_) async => todo.copyWith(completed: true));
        // Stub Notif
        when(
          () => mockNotif.showLocalNotification(
            title: any(named: 'title'),
            body: any(named: 'body'),
          ),
        ).thenAnswer((_) async {});

        // ACT
        await controller.toggleTodoStatus(todo);

        // ASSERT
        // Cek UseCase dipanggil dengan status 'completed: true'
        final capturedArg =
            verify(() => mockUpdate(captureAny())).captured.first as Todo;
        expect(capturedArg.completed, true);

        // Cek Notifikasi pesannya benar ("Selesai dikerjakan")
        // PERBAIKAN: Gunakan any(named: 'body', that: contains(...))
        verify(
          () => mockNotif.showLocalNotification(
            title: "Status Diperbarui",
            body: any(named: 'body', that: contains("Selesai dikerjakan")),
          ),
        ).called(1);
      },
    );

    // 4. TEST REMOVE TODO (Logic Special)
    test(
      'removeTodo finds title locally before deleting and notifying',
      () async {
        // ARRANGE: Isi dulu allTodos dengan data dummy
        final todoToDelete = Todo(
          id: '99',
          text: 'Delete Me',
          completed: false,
        );
        controller.allTodos.add(todoToDelete);

        // Stub Delete
        when(() => mockDelete('99')).thenAnswer((_) async {});
        // Stub Notif
        when(
          () => mockNotif.showLocalNotification(
            title: any(named: 'title'),
            body: any(named: 'body'),
          ),
        ).thenAnswer((_) async {});

        // ACT
        await controller.removeTodo('99');

        // ASSERT
        verify(() => mockDelete('99')).called(1);
        // Notifikasi harus berisi judul "Delete Me" yang diambil dari local state
        // PERBAIKAN: Gunakan any(named: 'body', that: contains(...))
        verify(
          () => mockNotif.showLocalNotification(
            title: "Catatan Dihapus",
            body: any(named: 'body', that: contains("Delete Me")),
          ),
        ).called(1);
      },
    );

    // 5. TEST FILTERING
    test('filteredTodos returns correct list based on status', () {
      // ARRANGE: Setup 2 items
      controller.allTodos.addAll([
        Todo(id: '1', text: 'Pending Task', completed: false),
        Todo(id: '2', text: 'Done Task', completed: true),
      ]);

      // ACT & ASSERT (Pending)
      controller.setFilter(FilterStatus.pending);
      expect(controller.filteredTodos.length, 1);
      expect(controller.filteredTodos.first.text, 'Pending Task');

      // ACT & ASSERT (Completed)
      controller.setFilter(FilterStatus.completed);
      expect(controller.filteredTodos.length, 1);
      expect(controller.filteredTodos.first.text, 'Done Task');
    });

    // 6. TEST SCHEDULE REMINDER (UI Feedback)
    test('scheduleTodoReminder sets successMessage for Snackbar', () async {
      // ARRANGE
      final todo = Todo(id: '1', text: 'Schedule Me', completed: false);
      when(
        () => mockNotif.scheduleNotification(
          id: any(named: 'id'),
          title: any(named: 'title'),
          body: any(named: 'body'),
          scheduledDate: any(named: 'scheduledDate'),
        ),
      ).thenAnswer((_) async {});

      // ACT
      await controller.scheduleTodoReminder(todo);

      // ASSERT
      // Cek apakah successMessage terisi (ini yang memicu Snackbar di UI)
      expect(controller.successMessage.value, "Tunggu 5 detik...");
      expect(controller.errorMessage.value, isNull);
    });
  });
}
