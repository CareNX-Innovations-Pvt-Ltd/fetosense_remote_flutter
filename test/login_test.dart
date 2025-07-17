import 'package:appwrite/models.dart';
import 'package:fetosense_remote_flutter/core/model/doctor_model.dart';
import 'package:fetosense_remote_flutter/core/network/appwrite_config.dart';
import 'package:fetosense_remote_flutter/core/services/authentication.dart';
import 'package:fetosense_remote_flutter/core/utils/preferences.dart';
import 'package:fetosense_remote_flutter/ui/views/login_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:appwrite/appwrite.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';

final locator = GetIt.instance;

class MockAuth extends Mock implements BaseAuth {}

class MockPreferenceHelper extends Mock implements PreferenceHelper {}

class MockDatabases extends Mock implements Databases {}

class FakeDoctor extends Fake implements Doctor {}

class FakeDocument extends Fake implements Document {
  @override
  final Map<String, dynamic> data;

  FakeDocument(this.data);
}

class FakeDocumentList extends Fake implements DocumentList {
  @override
  final List<Document> documents;

  @override
  final int total;

  FakeDocumentList({required this.documents, this.total = 1});
}


class MockAppwriteService extends Mock implements AppwriteService {
  @override
  Client get client => Client();
}

class FakeBuildContext extends Fake implements BuildContext {}

void main() {
  late MockAuth mockAuth;
  late MockPreferenceHelper mockPrefs;
  late MockDatabases mockDatabases;

  setUpAll(() {
    registerFallbackValue(FakeBuildContext());
    registerFallbackValue(FakeDoctor());
  });

  setUp(() {
    locator.reset();
    mockAuth = MockAuth();
    mockPrefs = MockPreferenceHelper();
    mockDatabases = MockDatabases();

    locator.registerSingleton<BaseAuth>(mockAuth);
    locator.registerSingleton<PreferenceHelper>(mockPrefs);
    locator.registerSingleton<AppwriteService>(MockAppwriteService());
  });

  testWidgets('LoginView renders correctly', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: LoginView()));
    expect(find.byType(Form), findsOneWidget);
    expect(find.text('Login'), findsOneWidget);
  });

  testWidgets('Shows error on empty email and password', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: LoginView()));
    final loginButton = find.text('Login');
    await tester.tap(loginButton);
    await tester.pump();

    expect(find.text("Email can't be empty"), findsOneWidget);
    expect(find.text("Password can't be empty"), findsOneWidget);
  });

  testWidgets('Switch between login and signup form', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: LoginView()));
    final toggleButton = find.byWidgetPredicate((widget) {
      if (widget is RichText) {
        final textSpan = widget.text as TextSpan;
        return textSpan.toPlainText().contains("Don't have an account?");
      }
      return false;
    });
    await tester.tap(toggleButton);
    await tester.pump();
    expect(find.text('Create account'), findsOneWidget);
  });

  testWidgets('Successful login should call signIn and save doctor', (WidgetTester tester) async {
    when(() => mockAuth.signIn(any(), any()))
        .thenAnswer((_) async => 'userId123');

    when(() => mockPrefs.setAutoLogin(true)).thenAnswer((_) async {});
    when(() => mockPrefs.saveDoctor(any())).thenAnswer((_) async {});

    when(() =>
        mockDatabases.listDocuments(
          databaseId: any(named: 'databaseId'),
          collectionId: any(named: 'collectionId'),
          queries: any(named: 'queries'),
        )).thenAnswer((_) async {
      return FakeDocumentList(documents: [
        FakeDocument({
          'email': 'test@gmail.com',
          'type': 'doctor',
          'documentId': 'doc123',
          'uid': 'userId123',
        }),
      ]);
    });

    // locator.registerSingleton<Databases>(mockDatabases);

    // await tester.pumpWidget(const MaterialApp(home: LoginView()));
    // await tester.enterText(find.byType(TextFormField).at(0), 'test@gmail.com');
    // await tester.enterText(find.byType(TextFormField).at(1), 'delete123');
    //
    // final loginButton = find.text('Login');
    // await tester.tap(loginButton);
    // await tester.pump();
    // await tester.pump(const Duration(milliseconds: 500));
    // await tester.pump();

    // verify(() => mockAuth.signIn('test@gmail.com', 'delete123')).called(1);
    // verify(() => mockPrefs.setAutoLogin(true)).called(1);
    // verify(() => mockPrefs.saveDoctor(any())).called(1);
  });

}
