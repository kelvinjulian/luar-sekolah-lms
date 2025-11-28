//* 1. IMPORT
// Mengimpor library testing, state management, dan mocking.
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mocktail/mocktail.dart';

// Import Domain (Entities & UseCases) dan Controller yang akan dites
import 'package:luar_sekolah_lms/app/presentation/controllers/todo_controller.dart';
import 'package:luar_sekolah_lms/app/domain/entities/todo.dart';
import 'package:luar_sekolah_lms/app/domain/usecases/todo/add_todo.dart';
import 'package:luar_sekolah_lms/app/domain/usecases/todo/get_all_todos.dart';
import 'package:luar_sekolah_lms/app/domain/usecases/todo/update_todo.dart';
import 'package:luar_sekolah_lms/app/domain/usecases/todo/delete_todo.dart';
import 'package:luar_sekolah_lms/app/core/services/notification_service.dart';

//* 2. MOCK CLASS DEFINITIONS
// Kita membuat tiruan (Mock) untuk semua dependensi eksternal.
// Tujuannya agar Controller bisa dites secara TERISOLASI tanpa menyentuh Database/Plugin asli.
class MockGetAllTodosUseCase extends Mock implements GetAllTodosUseCase {}

class MockAddTodoUseCase extends Mock implements AddTodoUseCase {}

class MockUpdateTodoUseCase extends Mock implements UpdateTodoUseCase {}

class MockDeleteTodoUseCase extends Mock implements DeleteTodoUseCase {}

class MockNotificationService extends Mock implements NotificationService {}

void main() {
  // Variabel yang akan digunakan di setiap test
  late TodoController controller;
  late MockGetAllTodosUseCase mockGetAll;
  late MockAddTodoUseCase mockAdd;
  late MockUpdateTodoUseCase mockUpdate;
  late MockDeleteTodoUseCase mockDelete;
  late MockNotificationService mockNotif;

  //* 3. SETUP (Jalan sebelum setiap unit test)
  setUp(() {
    // Inisialisasi Mock Object
    mockGetAll = MockGetAllTodosUseCase();
    mockAdd = MockAddTodoUseCase();
    mockUpdate = MockUpdateTodoUseCase();
    mockDelete = MockDeleteTodoUseCase();
    mockNotif = MockNotificationService();

    //? Register Fallback Value:
    //? Penting agar Mocktail mengerti tipe data 'Todo' kustom kita saat menggunakan 'any()'.
    registerFallbackValue(Todo(id: '0', text: 'fallback', completed: false));

    //? Stub Default:
    //? Pastikan getAllTodos mengembalikan list kosong atau null saat Controller diinisialisasi (onInit),
    //? agar tidak terjadi crash sebelum test dimulai.
    when(
      () => mockGetAll(
        limit: any(named: 'limit'),
        startAfter: any(named: 'startAfter'),
      ),
    ).thenAnswer((_) async => []);

    // Setup Environment GetX untuk testing
    Get.testMode = true;
    Get.reset();

    //? INJECT DEPENDENCIES VIA CONSTRUCTOR:
    //? Ini adalah hasil refactoring kita agar Controller mudah dites (Testable).
    controller = TodoController(
      getAllTodosUseCase: mockGetAll,
      addTodoUseCase: mockAdd,
      updateTodoUseCase: mockUpdate,
      deleteTodoUseCase: mockDelete,
      notificationService: mockNotif,
    );

    // Trigger manual onInit untuk memuat data awal (jika diperlukan logic onInit)
    controller.onInit();
  });

  tearDown(() {
    Get.reset();
  });

  group('TodoController Tests', () {
    //* SKENARIO 1: TEST FETCH DATA (Pagination Logic)
    test('fetchTodos success updates allTodos list', () async {
      //? ARRANGE
      final dummyList = [Todo(id: '1', text: 'Test', completed: false)];

      // Stub: UseCase menerima parameter pagination (limit, startAfter)
      when(
        () => mockGetAll(
          limit: any(named: 'limit'),
          startAfter: any(named: 'startAfter'),
        ),
      ).thenAnswer((_) async => dummyList);

      //? ACT
      // PENTING: Gunakan isRefresh: true untuk mereset state pagination (hasMore)
      // agar controller mau mengambil data baru.
      await controller.fetchTodos(isRefresh: true);

      //? ASSERT
      expect(controller.isLoading.value, isFalse); // Loading mati
      expect(controller.allTodos.length, 1); // Data masuk
      expect(controller.allTodos.first.text, 'Test'); // Data benar
    });

    //* SKENARIO 2: TEST ADD TODO (Orkestrasi Logic + Notifikasi)
    test(
      'addTodo success triggers UseCase, Fetch, and Local Notification',
      () async {
        //? ARRANGE
        const newText = "New Task";
        // Stub Add UseCase: Sukses & return object baru
        when(() => mockAdd(newText)).thenAnswer(
          (_) async => Todo(id: '2', text: newText, completed: false),
        );

        // Stub Notification: Sukses (return void)
        when(
          () => mockNotif.showLocalNotification(
            title: any(named: 'title'),
            body: any(named: 'body'),
          ),
        ).thenAnswer((_) async {});

        //? ACT
        await controller.addTodo(newText);

        //? ASSERT
        // 1. Cek Logic Utama (Simpan ke DB)
        verify(() => mockAdd(newText)).called(1);
        // 2. Cek Refresh List (Fetch dipanggil ulang)
        // Kita pakai any() untuk parameter karena kita cuma peduli fungsinya dipanggil
        verify(
          () => mockGetAll(
            limit: any(named: 'limit'),
            startAfter: any(named: 'startAfter'),
          ),
        ).called(greaterThan(0));

        // 3. Cek Side Effect (Notifikasi Muncul)
        // Gunakan 'contains' untuk memastikan pesan notifikasi mengandung teks Todo yang diinput.
        verify(
          () => mockNotif.showLocalNotification(
            title: "Catatan Baru Ditambahkan",
            body: any(named: 'body', that: contains(newText)),
          ),
        ).called(1);
      },
    );

    //* SKENARIO 3: TEST TOGGLE STATUS
    test(
      'toggleTodoStatus updates Todo and sends correct notification',
      () async {
        //? ARRANGE
        final todo = Todo(id: '1', text: 'Task A', completed: false);

        // Stub Update: Sukses
        when(() => mockUpdate(any())).thenAnswer((_) async => Future.value());

        // Stub Notif: Sukses
        when(
          () => mockNotif.showLocalNotification(
            title: any(named: 'title'),
            body: any(named: 'body'),
          ),
        ).thenAnswer((_) async {});

        //? ACT
        await controller.toggleTodoStatus(todo);

        //? ASSERT
        // Cek apakah UseCase dipanggil dengan status yang SUDAH DIBALIK (completed: true)
        final capturedArg =
            verify(() => mockUpdate(captureAny())).captured.first as Todo;
        expect(capturedArg.completed, true);

        // Cek apakah Notifikasi menampilkan pesan "Selesai dikerjakan"
        verify(
          () => mockNotif.showLocalNotification(
            title: "Status Diperbarui",
            body: any(named: 'body', that: contains("Selesai dikerjakan")),
          ),
        ).called(1);
      },
    );

    //* SKENARIO 4: TEST REMOVE TODO (Logic Khusus)
    test(
      'removeTodo finds title locally before deleting and notifying',
      () async {
        //? ARRANGE
        // Kita harus isi dulu state 'allTodos' dengan data dummy,
        // karena logika removeTodo perlu mencari judul item sebelum dihapus.
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

        //? ACT
        await controller.removeTodo('99');

        //? ASSERT
        // 1. Pastikan UseCase Delete dipanggil
        verify(() => mockDelete('99')).called(1);

        // 2. Pastikan Notifikasi menggunakan Judul Todo yang benar ("Delete Me")
        // Ini membuktikan logika "Find before Delete" bekerja.
        verify(
          () => mockNotif.showLocalNotification(
            title: "Catatan Dihapus",
            body: any(named: 'body', that: contains("Delete Me")),
          ),
        ).called(1);
      },
    );

    //* SKENARIO 5: TEST FILTERING (UI Logic)
    test('filteredTodos returns correct list based on status', () {
      //? ARRANGE: Siapkan data campuran
      controller.allTodos.addAll([
        Todo(id: '1', text: 'Pending Task', completed: false),
        Todo(id: '2', text: 'Done Task', completed: true),
      ]);

      //? ACT & ASSERT (Cek Filter Pending)
      controller.setFilter(FilterStatus.pending);
      expect(controller.filteredTodos.length, 1);
      expect(controller.filteredTodos.first.text, 'Pending Task');

      //? ACT & ASSERT (Cek Filter Completed)
      controller.setFilter(FilterStatus.completed);
      expect(controller.filteredTodos.length, 1);
      expect(controller.filteredTodos.first.text, 'Done Task');
    });

    //* SKENARIO 6: TEST SCHEDULE REMINDER (Reactive State Feedback)
    test('scheduleTodoReminder sets successMessage for Snackbar', () async {
      //? ARRANGE
      final todo = Todo(id: '1', text: 'Schedule Me', completed: false);

      // Stub Schedule Notification
      when(
        () => mockNotif.scheduleNotification(
          id: any(named: 'id'),
          title: any(named: 'title'),
          body: any(named: 'body'),
          scheduledDate: any(named: 'scheduledDate'),
        ),
      ).thenAnswer((_) async {});

      //? ACT
      await controller.scheduleTodoReminder(todo);

      //? ASSERT
      // Kita tidak mengecek Snackbar UI (Get.snackbar) agar tidak crash.
      // Kita mengecek apakah variabel state 'successMessage' terisi.
      // Ini membuktikan feedback berhasil dikirim ke UI.
      expect(controller.successMessage.value, "Tunggu 5 detik...");
      expect(controller.errorMessage.value, isNull);
    });
  });
}
