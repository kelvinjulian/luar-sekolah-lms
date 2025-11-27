import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

// Import sesuai path project Anda
import 'package:luar_sekolah_lms/app/data/repositories/todo_repository_impl.dart';
import 'package:luar_sekolah_lms/app/data/datasources/todo_firestore_data_source.dart';
import 'package:luar_sekolah_lms/app/domain/entities/todo.dart';

// --- MOCK CLASSES ---
class MockTodoFirestoreDataSource extends Mock
    implements TodoFirestoreDataSource {}

void main() {
  late TodoRepositoryImpl repository;
  late MockTodoFirestoreDataSource mockDataSource;

  // Data Dummy untuk test
  final dummyTodo = Todo(id: 't1', text: 'Test Todo', completed: false);
  final todoList = [dummyTodo];

  setUpAll(() {
    registerFallbackValue(Todo(id: '0', text: 'fallback', completed: false));
  });

  setUp(() {
    mockDataSource = MockTodoFirestoreDataSource();
    repository = TodoRepositoryImpl(mockDataSource);
  });

  group('TodoRepositoryImpl', () {
    // --- 1. GET TODOS (Perbaikan Nama Method) ---

    test(
      'getTodos should return list of todos from dataSource.fetchTodos',
      () async {
        // ARRANGE
        // DataSource menggunakan 'fetchTodos' (sesuai file yang Anda kirim)
        when(
          () => mockDataSource.fetchTodos(),
        ).thenAnswer((_) async => todoList);

        // ACT
        // PERBAIKAN: Mengganti 'getAllTodos' menjadi 'getTodos'
        // Jika masih merah, coba ganti jadi 'fetchTodos' agar sama dengan dataSource
        final result = await repository.getTodos();

        // ASSERT
        expect(result, equals(todoList));
        verify(() => mockDataSource.fetchTodos()).called(1);
      },
    );

    test('getTodos should throw Exception when dataSource fails', () async {
      // ARRANGE
      when(
        () => mockDataSource.fetchTodos(),
      ).thenThrow(Exception('Server Error'));

      // ACT & ASSERT
      expect(
        () => repository
            .getTodos(), // PERBAIKAN: Mengganti 'getAllTodos' menjadi 'getTodos'
        throwsA(isA<Exception>()),
      );
    });

    // --- 2. ADD TODO ---

    test(
      'addTodo should call dataSource.createTodo and return created Todo',
      () async {
        // ARRANGE
        const text = 'New Task';
        // DataSource menggunakan 'createTodo'
        when(
          () => mockDataSource.createTodo(text),
        ).thenAnswer((_) async => dummyTodo);

        // ACT
        // Repository menggunakan 'addTodo'
        final result = await repository.addTodo(text);

        // ASSERT
        expect(result, equals(dummyTodo));
        verify(() => mockDataSource.createTodo(text)).called(1);
      },
    );

    test('addTodo should throw Exception when dataSource fails', () async {
      // ARRANGE
      const text = 'Fail Task';
      when(
        () => mockDataSource.createTodo(text),
      ).thenThrow(Exception('Network Error'));

      // ACT & ASSERT
      expect(() => repository.addTodo(text), throwsA(isA<Exception>()));
    });

    // --- 3. UPDATE TODO ---

    test('updateTodo should call dataSource.updateTodo with ID', () async {
      // ARRANGE
      final updatedTodo = dummyTodo.copyWith(completed: true);

      // DataSource butuh (id, todo)
      when(
        () => mockDataSource.updateTodo(updatedTodo.id!, updatedTodo),
      ).thenAnswer((_) async => Future<void>.value());

      // ACT
      await repository.updateTodo(updatedTodo);

      // ASSERT
      verify(
        () => mockDataSource.updateTodo(updatedTodo.id!, updatedTodo),
      ).called(1);
    });

    test('updateTodo should throw Exception when dataSource fails', () async {
      // ARRANGE
      when(
        () => mockDataSource.updateTodo(any(), any()),
      ).thenThrow(Exception('Update Failed'));

      // ACT & ASSERT
      expect(() => repository.updateTodo(dummyTodo), throwsA(isA<Exception>()));
    });

    // --- 4. DELETE TODO ---

    test('deleteTodo should call dataSource.deleteTodo', () async {
      // ARRANGE
      const id = 't1';
      when(
        () => mockDataSource.deleteTodo(id),
      ).thenAnswer((_) async => Future<void>.value());

      // ACT
      await repository.deleteTodo(id);

      // ASSERT
      verify(() => mockDataSource.deleteTodo(id)).called(1);
    });

    test('deleteTodo should throw Exception when dataSource fails', () async {
      // ARRANGE
      const id = 't1';
      when(
        () => mockDataSource.deleteTodo(id),
      ).thenThrow(Exception('Delete Failed'));

      // ACT & ASSERT
      expect(() => repository.deleteTodo(id), throwsA(isA<Exception>()));
    });
  });
}
