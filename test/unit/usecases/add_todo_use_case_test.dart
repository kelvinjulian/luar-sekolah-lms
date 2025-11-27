import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:luar_sekolah_lms/app/domain/usecases/todo/add_todo.dart';
import 'package:luar_sekolah_lms/app/domain/repositories/i_todo_repository.dart';
import 'package:luar_sekolah_lms/app/domain/entities/todo.dart';

// --- MOCK CLASSES ---
class MockITodoRepository extends Mock implements ITodoRepository {}

void main() {
  late AddTodoUseCase useCase;
  late MockITodoRepository mockRepository;

  setUp(() {
    mockRepository = MockITodoRepository();
    useCase = AddTodoUseCase(mockRepository);
  });

  test('should call repository.addTodo and return Todo entity', () async {
    // ARRANGE
    const todoText = 'New Task from UseCase';
    final mockTodo = Todo(id: 'a1', text: todoText, completed: false);

    // Stub: Repository akan mengembalikan mockTodo saat dipanggil
    when(
      () => mockRepository.addTodo(todoText),
    ).thenAnswer((_) async => mockTodo);

    // ACT
    final result = await useCase(todoText);

    // ASSERT
    // Pastikan repository.addTodo dipanggil 1 kali
    verify(() => mockRepository.addTodo(todoText)).called(1);

    // Pastikan UseCase mengembalikan objek yang benar
    expect(result, equals(mockTodo));
  });
}
