import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:luar_sekolah_lms/app/data/repositories/auth_repository_impl.dart';
import 'package:luar_sekolah_lms/app/data/datasources/auth_firebase_data_source.dart';

// --- MOCK CLASSES ---
class MockAuthFirebaseDataSource extends Mock
    implements AuthFirebaseDataSource {}

class MockUserCredential extends Mock implements UserCredential {}

void main() {
  late AuthRepositoryImpl repository;
  late MockAuthFirebaseDataSource mockDataSource;

  setUp(() {
    mockDataSource = MockAuthFirebaseDataSource();
    repository = AuthRepositoryImpl(mockDataSource);
  });

  tearDown(() {
    reset(mockDataSource);
  });

  group('AuthRepositoryImpl', () {
    const email = 'test@example.com';
    const password = 'password123';

    test('loginWithEmail should call dataSource.loginWithEmail', () async {
      // ARRANGE
      when(
        () => mockDataSource.loginWithEmail(email, password),
      ).thenAnswer((_) async => MockUserCredential());

      // ACT
      await repository.loginWithEmail(email, password);

      // ASSERT
      verify(() => mockDataSource.loginWithEmail(email, password)).called(1);
    });

    test('logout should call dataSource.logout', () async {
      // ARRANGE
      when(
        () => mockDataSource.logout(),
      ).thenAnswer((_) async => Future<void>.value());

      // ACT
      await repository.logout();

      // ASSERT
      verify(() => mockDataSource.logout()).called(1);
    });
  });
}
