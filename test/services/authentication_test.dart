import 'package:fetosense_remote_flutter/core/network/appwrite_config.dart';
import 'package:fetosense_remote_flutter/core/services/authentication.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import 'package:get_it/get_it.dart';

class MockAccount extends Mock implements Account {}
class MockAppwriteService extends Mock implements AppwriteService {}
class MockSession extends Mock implements Session {}
class MockUser extends Mock implements User {}

void main() {
  late MockAccount mockAccount;
  late Auth auth;
  late MockAppwriteService mockService;
  late MockSession mockSession;
  late MockUser mockUser;

  setUp(() {
    mockAccount = MockAccount();
    mockService = MockAppwriteService();
    mockSession = MockSession();
    mockUser = MockUser();

    when(() => mockSession.$id).thenReturn('sessionId');
    when(() => mockSession.userId).thenReturn('userId');
    when(() => mockUser.$id).thenReturn('userId');
    when(() => mockUser.email).thenReturn('test@example.com');

    GetIt.I.reset();
    GetIt.I.registerSingleton<AppwriteService>(mockService);

    auth = Auth.internalTest(mockAccount);
  });


  // group('Auth Singleton', () {
  //   test('factory returns same instance', () {
  //     final instance1 = Auth();
  //     final instance2 = Auth();
  //     expect(instance1, same(instance2));
  //   });
  // });

  group('signIn', () {
    test('success', () async {
      when(() => mockAccount.createEmailPasswordSession(
        email: any(named: 'email'),
        password: any(named: 'password'),
      )).thenAnswer((_) async => mockSession);

      final result = await auth.signIn('email', 'pass');
      expect(result, 'userId');
    });

    test('failure throws exception', () async {
      when(() => mockAccount.createEmailPasswordSession(
        email: any(named: 'email'),
        password: any(named: 'password'),
      )).thenThrow(AppwriteException( 'Bad login'));

      expect(() => auth.signIn('email', 'pass'), throwsException);
    });
  });

  group('signUp', () {
    test('success', () async {
      when(() => mockAccount.create(
        userId: any(named: 'userId'),
        email: any(named: 'email'),
        password: any(named: 'password'),
      )).thenAnswer((_) async => mockUser);

      final result = await auth.signUp('email', 'pass');
      expect(result, isA<String>());
    });

    test('failure throws exception', () async {
      when(() => mockAccount.create(
        userId: any(named: 'userId'),
        email: any(named: 'email'),
        password: any(named: 'password'),
      )).thenThrow(AppwriteException('Signup fail'));

      expect(() => auth.signUp('email', 'pass'), throwsException);
    });
  });

  group('getCurrentUser', () {
    test('success', () async {
      when(() => mockAccount.get()).thenAnswer((_) async => mockUser);

      final result = await auth.getCurrentUser();
      expect(result, mockUser);
    });

    test('failure throws exception', () async {
      when(() => mockAccount.get())
          .thenThrow(AppwriteException('Get user fail'));

      expect(() => auth.getCurrentUser(), throwsException);
    });
  });

  group('signOut', () {
    test('success', () async {
      when(() => mockAccount.deleteSessions())
          .thenAnswer((_) async => {});

      await auth.signOut();
      verify(() => mockAccount.deleteSessions()).called(1);
    });

    test('failure throws exception', () async {
      when(() => mockAccount.deleteSessions())
          .thenThrow(AppwriteException( 'Sign out fail'));

      expect(() => auth.signOut(), throwsException);
    });
  });
}
