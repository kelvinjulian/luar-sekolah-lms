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

  group('AddTodoUseCase Tests', () {
    // 1. SKENARIO SUKSES (Happy Path)
    test('should call repository with trimmed text and return Todo', () async {
      // ARRANGE
      const rawText = '   Makan Siang   '; // Ada spasi
      const cleanText = 'Makan Siang'; // Harapan setelah di-trim
      final mockTodo = Todo(id: '1', text: cleanText, completed: false);

      when(
        () => mockRepository.addTodo(cleanText),
      ).thenAnswer((_) async => mockTodo);

      // ACT
      final result = await useCase(rawText);

      // ASSERT
      expect(result, equals(mockTodo));
      // Pastikan repository dipanggil dengan teks yang SUDAH BERSIH
      verify(() => mockRepository.addTodo(cleanText)).called(1);
    });

    // 2. SKENARIO VALIDASI KOSONG
    test('should throw ValidationException when text is empty', () async {
      // ACT & ASSERT
      // Cara test exception di mocktail:
      expect(() => useCase(''), throwsA(isA<ValidationException>()));

      // Pastikan repository TIDAK PERNAH dipanggil
      verifyZeroInteractions(mockRepository);
    });

    // 3. SKENARIO VALIDASI WHITESPACE ONLY
    test('should throw ValidationException when text is only spaces', () async {
      expect(() => useCase('     '), throwsA(isA<ValidationException>()));
      verifyZeroInteractions(mockRepository);
    });

    // 4. SKENARIO REPOSITORY ERROR (Exception Propagation)
    test('should rethrow exception when repository fails', () async {
      // ARRANGE
      const text = 'Test Error';
      when(
        () => mockRepository.addTodo(text),
      ).thenThrow(Exception('Database Error'));

      // ACT & ASSERT
      expect(() => useCase(text), throwsA(isA<Exception>()));
    });
  });
}
