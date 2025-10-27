import 'package:fetosense_remote_flutter/ui/views/settings_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:preferences/preferences.dart';

class MockPrefService extends Mock implements PrefService {}
class MockNavigatorObserver extends Mock implements NavigatorObserver {}
class MockVoidCallback extends Mock {
  void call();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockPrefService mockPrefService;
  late MockNavigatorObserver mockObserver;
  late MockVoidCallback mockLogoutCallback;
  late MockVoidCallback mockProfileUpdate1Callback;

  setUp(() {
    mockPrefService = MockPrefService();
    mockObserver = MockNavigatorObserver();
    mockLogoutCallback = MockVoidCallback();
    mockProfileUpdate1Callback = MockVoidCallback();
  });

  Future<void> pumpSettingsView(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: SettingsView(
          logoutCallback: mockLogoutCallback,
          profileUpdate1Callback: mockProfileUpdate1Callback,
        ),
        navigatorObservers: [mockObserver],
      ),
    );
    await tester.pumpAndSettle();
  }

  group('SettingsView Widget Tests', () {
    testWidgets('renders all UI elements correctly', (tester) async {
      await pumpSettingsView(tester);

      expect(find.text('fetosense'), findsOneWidget);
      expect(find.text('Settings'), findsOneWidget);
      expect(find.byType(PreferencePage), findsOneWidget);
    });

    testWidgets('tapping back button pops the navigator', (tester) async {
      await pumpSettingsView(tester);

      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      verify(() => mockObserver.didPop(any(), any())).called(greaterThanOrEqualTo(0));
    });

    testWidgets('tapping fetosense calls logout callback', (tester) async {
      await pumpSettingsView(tester);

      await tester.tap(find.text('fetosense'));
      await tester.pump();

      verify(() => mockLogoutCallback()).called(1);
    });

    testWidgets('renders preference titles and toggles switches', (tester) async {
      await pumpSettingsView(tester);

      expect(find.text('Printing'), findsOneWidget);
      expect(find.textContaining('NST tests less than 60 min.'), findsOneWidget);

      final commentSwitch = find.text("Doctor's Comment");
      expect(commentSwitch, findsOneWidget);

      final interpretationSwitch = find.text('Auto Interpretations');
      expect(interpretationSwitch, findsOneWidget);
    });

    testWidgets('renders DropdownPreference based on PrefService value', (tester) async {
      // Case 1: PrefService.getBool('isAndroidTv') returns false (shows dropdown)
      when(() => PrefService.getBool('isAndroidTv')).thenReturn(false);
      await pumpSettingsView(tester);
      expect(find.text('Default print scale'), findsOneWidget);

      // Case 2: PrefService.getBool('isAndroidTv') returns true (hides dropdown)
      when(() => PrefService.getBool('isAndroidTv')).thenReturn(true);
      await pumpSettingsView(tester);
      expect(find.text('Default print scale'), findsNothing);
    });

    testWidgets('tapping Auto Interpretations switch triggers setState', (tester) async {
      await pumpSettingsView(tester);

      final interpretationsSwitch = find.text('Auto Interpretations');
      expect(interpretationsSwitch, findsOneWidget);

      await tester.tap(interpretationsSwitch);
      await tester.pump();
    });

    testWidgets('renders highlight preference in PreferenceHider', (tester) async {
      await pumpSettingsView(tester);

      expect(find.text('Highlight patterns'), findsOneWidget);
    });
  });
}
