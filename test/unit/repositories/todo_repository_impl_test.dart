import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:luar_sekolah_lms/app/data/repositories/todo_repository_impl.dart';
import 'package:luar_sekolah_lms/app/data/datasources/todo_firestore_data_source.dart';
import 'package:luar_sekolah_lms/app/domain/entities/todo.dart';

class MockTodoFirestoreDataSource extends Mock
    implements TodoFirestoreDataSource {}

void main() {
  late TodoRepositoryImpl repository;
  late MockTodoFirestoreDataSource mockDataSource;

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
    // 1. GET TODOS
    test('getTodos should return list of todos from dataSource', () async {
      when(
        () => mockDataSource.fetchTodos(
          limit: any(named: 'limit'),
          startAfter: any(named: 'startAfter'),
        ),
      ).thenAnswer((_) async => todoList);

      final result = await repository.getTodos();

      expect(result, equals(todoList));
      verify(() => mockDataSource.fetchTodos(limit: 20)).called(1);
    });

    // 2. ADD TODO (UPDATED)
    test('addTodo should call dataSource.addTodo with Todo object', () async {
      // ARRANGE
      final newTodo = Todo(text: 'New Task', completed: false);

      // Stubbing
      when(() => mockDataSource.addTodo(any())).thenAnswer((_) async {});

      // ACT
      await repository.addTodo(newTodo);

      // ASSERT
      verify(() => mockDataSource.addTodo(newTodo)).called(1);
    });

    test('addTodo should throw Exception when dataSource fails', () async {
      final newTodo = Todo(text: 'Fail Task', completed: false);
      when(
        () => mockDataSource.addTodo(any()),
      ).thenThrow(Exception('Network Error'));

      expect(() => repository.addTodo(newTodo), throwsA(isA<Exception>()));
    });
  });
}
