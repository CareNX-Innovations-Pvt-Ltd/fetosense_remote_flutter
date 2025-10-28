import 'package:fetosense_remote_flutter/core/model/doctor_model.dart';
import 'package:fetosense_remote_flutter/ui/views/notificationView.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';

@GenerateMocks([Doctor, NavigatorObserver])
void main() {
  group('NotificationView static methods', () {
    test('getTitle returns correct value', () {
      expect(NotificationView.getTitle(), equals('fetosense'));
    });

    test('getSubtitle returns correct value with doctor', () {
      final doctor = Doctor(name: 'John Doe');
      expect(NotificationView.getSubtitle(doctor),
          equals('Notifications for Dr. John Doe'));
    });

    test('getSubtitle returns correct value without doctor', () {
      expect(NotificationView.getSubtitle(null), equals('Notifications'));
    });

    test('getImageAsset returns correct asset path', () {
      expect(NotificationView.getImageAsset(), equals('images/ic_logo_good.png'));
    });
  });

  group('NotificationView widget', () {
    testWidgets('renders correctly with doctor details', (tester) async {
      final doctor = Doctor(name: 'Jane Doe');

      await tester.pumpWidget(
        MaterialApp(
          home: NotificationView(doctor: doctor),
        ),
      );

      // Verify static text and UI elements
      expect(find.text('fetosense'), findsOneWidget);
      expect(find.text('Notifications for Dr. Jane Doe'), findsOneWidget);
      expect(find.byType(Image), findsOneWidget);
      expect(find.byType(IconButton), findsOneWidget);
      expect(find.byType(ListTile), findsOneWidget);
    });

    testWidgets('renders correctly with null doctor', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: NotificationView(doctor: null),
        ),
      );

      expect(find.text('fetosense'), findsOneWidget);
      expect(find.text('Notifications'), findsOneWidget);
    });

    testWidgets('tapping back button pops the route', (tester) async {
      final doctor = Doctor(name: 'Pop Test');

      await tester.pumpWidget(
        MaterialApp(
          home: Navigator(
            onGenerateRoute: (_) => MaterialPageRoute(
              builder: (_) => NotificationView(doctor: doctor),
            ),
          ),
        ),
      );

      // Ensure the widget builds
      await tester.pumpAndSettle();
      expect(find.byType(NotificationView), findsOneWidget);

      // Tap the back icon
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      // After popping, NotificationView should be gone
      expect(find.byType(NotificationView), findsNothing);
    });
  });
}
