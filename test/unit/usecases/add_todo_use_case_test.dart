import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:luar_sekolah_lms/app/domain/usecases/todo/add_todo.dart';
import 'package:luar_sekolah_lms/app/domain/repositories/i_todo_repository.dart';
import 'package:luar_sekolah_lms/app/domain/entities/todo.dart';

class MockITodoRepository extends Mock implements ITodoRepository {}

void main() {
  late AddTodoUseCase useCase;
  late MockITodoRepository mockRepository;

  setUpAll(() {
    registerFallbackValue(Todo(id: '0', text: 'fallback', completed: false));
  });

  setUp(() {
    mockRepository = MockITodoRepository();
    useCase = AddTodoUseCase(mockRepository);
  });

  group('AddTodoUseCase Tests', () {
    // 1. HAPPY PATH
    test(
      'should call repository with trimmed text inside Todo object',
      () async {
        // ARRANGE
        const rawText = '   Makan Siang   ';
        const cleanText = 'Makan Siang';

        // Input berupa Object
        final inputTodo = Todo(text: rawText, completed: false);

        // (HAPUS BARIS 'expectedCleanTodo' KARENA TIDAK DIPAKAI)

        // Stub
        when(() => mockRepository.addTodo(any())).thenAnswer((_) async {});

        // ACT
        await useCase(inputTodo);

        // ASSERT
        // Kita memverifikasi property 'text' di dalam objek yang dikirim ke repo
        verify(
          () => mockRepository.addTodo(
            any(that: isA<Todo>().having((t) => t.text, 'text', cleanText)),
          ),
        ).called(1);
      },
    );

    // ... (Test case lainnya tetap sama)

    // 2. VALIDASI KOSONG
    test('should throw ValidationException when text is empty', () async {
      final emptyTodo = Todo(text: '', completed: false);
      expect(() => useCase(emptyTodo), throwsA(isA<ValidationException>()));
      verifyZeroInteractions(mockRepository);
    });

    // 3. VALIDASI WHITESPACE
    test('should throw ValidationException when text is only spaces', () async {
      final spaceTodo = Todo(text: '     ', completed: false);
      expect(() => useCase(spaceTodo), throwsA(isA<ValidationException>()));
      verifyZeroInteractions(mockRepository);
    });

    // 4. REPOSITORY ERROR
    test('should rethrow exception when repository fails', () async {
      final todo = Todo(text: 'Test Error', completed: false);
      when(
        () => mockRepository.addTodo(any()),
      ).thenThrow(Exception('Database Error'));
      expect(() => useCase(todo), throwsA(isA<Exception>()));
    });
  });
}
