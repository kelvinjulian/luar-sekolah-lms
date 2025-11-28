//* 1. IMPORT
// Mengimpor library testing, mocking, dan file arsitektur aplikasi (Domain Layer).
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:luar_sekolah_lms/app/domain/usecases/todo/add_todo.dart';
import 'package:luar_sekolah_lms/app/domain/repositories/i_todo_repository.dart';
import 'package:luar_sekolah_lms/app/domain/entities/todo.dart';

//* 2. MOCK CLASS DEFINITIONS
// Kita membuat tiruan (Mock) dari Repository.
// Tujuannya: Agar UseCase bisa dites tanpa menyentuh Database/API asli.
class MockITodoRepository extends Mock implements ITodoRepository {}

void main() {
  // Variabel yang akan digunakan di seluruh test
  late AddTodoUseCase useCase;
  late MockITodoRepository mockRepository;

  //* 3. SETUP (Jalan sebelum setiap test)
  setUp(() {
    mockRepository = MockITodoRepository();
    // Inject Mock Repository ke dalam UseCase (Dependency Injection)
    useCase = AddTodoUseCase(mockRepository);
  });

  group('AddTodoUseCase Tests', () {
    //* SKENARIO 1: HAPPY PATH (SUKSES)
    // Menguji apakah UseCase membersihkan data (trim) sebelum dikirim.
    test('should call repository with trimmed text and return Todo', () async {
      //? ARRANGE (Persiapan Data)
      const rawText = '   Makan Siang   '; // Input kotor (ada spasi)
      const cleanText = 'Makan Siang'; // Harapan input bersih
      final mockTodo = Todo(id: '1', text: cleanText, completed: false);

      //? Stubbing: Jika repo dipanggil dengan text BERSIH, kembalikan objek Todo
      when(
        () => mockRepository.addTodo(cleanText),
      ).thenAnswer((_) async => mockTodo);

      //? ACT (Aksi)
      final result = await useCase(rawText); // Kirim text kotor

      //? ASSERT (Verifikasi)
      // 1. Pastikan hasil kembalian sesuai
      expect(result, equals(mockTodo));
      // 2. KUNCI: Pastikan repo dipanggil dengan 'Makan Siang', BUKAN '   Makan Siang   '
      verify(() => mockRepository.addTodo(cleanText)).called(1);
    });

    //* SKENARIO 2: VALIDASI KOSONG (Negative Path)
    // Memastikan "Satpam" menolak string kosong.
    test('should throw ValidationException when text is empty', () async {
      //? ACT & ASSERT
      // Kita mengharapkan fungsi ini melempar error ValidationException
      expect(() => useCase(''), throwsA(isA<ValidationException>()));

      // Keamanan: Pastikan Repository TIDAK PERNAH dipanggil sama sekali
      verifyZeroInteractions(mockRepository);
    });

    //* SKENARIO 3: VALIDASI WHITESPACE (Negative Path)
    // Memastikan "Satpam" menolak string yang isinya cuma spasi.
    test('should throw ValidationException when text is only spaces', () async {
      expect(() => useCase('     '), throwsA(isA<ValidationException>()));

      // Pastikan database aman tidak tersentuh
      verifyZeroInteractions(mockRepository);
    });

    //* SKENARIO 4: REPOSITORY ERROR (Exception Propagation)
    // Memastikan jika Database error, UseCase meneruskannya ke Controller (tidak ditelan).
    test('should rethrow exception when repository fails', () async {
      //? ARRANGE
      const text = 'Test Error';
      // Simulasi Database Error
      when(
        () => mockRepository.addTodo(text),
      ).thenThrow(Exception('Database Error'));

      //? ACT & ASSERT
      expect(() => useCase(text), throwsA(isA<Exception>()));
    });
  });
}
