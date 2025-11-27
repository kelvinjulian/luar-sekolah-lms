import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:luar_sekolah_lms/app/data/repositories/todo_repository_impl.dart';
import 'package:luar_sekolah_lms/app/data/datasources/todo_firestore_data_source.dart';
import 'package:luar_sekolah_lms/app/domain/entities/todo.dart';

// --- MOCK CLASSES ---
class MockTodoFirestoreDataSource extends Mock
    implements TodoFirestoreDataSource {}

void main() {
  late TodoRepositoryImpl repository;
  late MockTodoFirestoreDataSource mockDataSource;

  final dummyTodo = Todo(id: 't1', text: 'Test Todo', completed: false);

  setUp(() {
    mockDataSource = MockTodoFirestoreDataSource();
    repository = TodoRepositoryImpl(mockDataSource);
  });

  group('TodoRepositoryImpl', () {
    test('addTodo should call dataSource.createTodo', () async {
      // ARRANGE
      const text = 'New Task';
      when(
        () => mockDataSource.createTodo(text),
      ).thenAnswer((_) async => dummyTodo);

      // ACT
      final result = await repository.addTodo(text);

      // ASSERT
      expect(result, equals(dummyTodo));
      verify(() => mockDataSource.createTodo(text)).called(1);
    });

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
  });
}
