import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:luar_sekolah_lms/app/domain/usecases/auth/login_use_case.dart';
import 'package:luar_sekolah_lms/app/domain/repositories/i_auth_repository.dart';

// --- MOCK CLASSES ---
class MockIAuthRepository extends Mock implements IAuthRepository {}

class MockUserCredential extends Mock implements UserCredential {}

void main() {
  late LoginUseCase useCase;
  late MockIAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockIAuthRepository();
    useCase = LoginUseCase(mockRepository);
  });

  test('should call loginWithEmail on the repository', () async {
    // ARRANGE
    const email = 'test@example.com';
    const password = 'password123';

    // Stub: Repository akan mengembalikan MockUserCredential saat dipanggil
    when(
      () => mockRepository.loginWithEmail(email, password),
    ).thenAnswer((_) async => MockUserCredential());

    // ACT
    await useCase(email, password);

    // ASSERT
    verify(() => mockRepository.loginWithEmail(email, password)).called(1);
  });
}
