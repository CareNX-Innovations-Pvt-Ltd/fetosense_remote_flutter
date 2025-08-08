import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';

import 'package:fetosense_remote_flutter/ui/widgets/notification_card.dart';
import 'package:fetosense_remote_flutter/core/model/NotificationModel.dart' as n;

void main() {
  group('NotificationCard Widget Tests', () {
    late DateTime testDate;
    late String formattedDate;

    setUp(() {
      testDate = DateTime(2025, 8, 5, 15, 30); // 5 Aug 2025, 3:30 PM
      formattedDate = DateFormat('dd MMM yyyy - kk:mm a').format(testDate);
    });

    Widget buildTestableWidget(n.Notification notification) {
      return MaterialApp(
        home: Scaffold(
          body: NotificationCard(notification: notification),
        ),
      );
    }

    testWidgets('renders unread notification with asset image fallback', (tester) async {
      final notification = n.Notification()
        ..title = 'Unread Title'
        ..message = 'This message ends by John Doe'
        ..read = false
        ..imageUrl = ''
        ..createdOn = testDate;

      await tester.pumpWidget(buildTestableWidget(notification));
      await tester.pumpAndSettle();

      expect(find.text('Unread Title'), findsOneWidget);
      expect(find.text('This message ends '), findsOneWidget); // truncated before 'by'
      expect(find.text(formattedDate), findsOneWidget);

      final container = tester.widget<Container>(find.byType(Container).first);
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, isNot(equals(Colors.transparent)));

      final image = tester.widget<Image>(find.byType(Image));
      expect(image.image, isA<AssetImage>());
    });


    testWidgets('does not truncate message if "by" not found', (tester) async {
      final notification = n.Notification()
        ..title = 'NoBy'
        ..message = 'No keyword here'
        ..read = true
        ..imageUrl = ''
        ..createdOn = testDate;

      await tester.pumpWidget(buildTestableWidget(notification));
      await tester.pumpAndSettle();

      expect(find.text('No keyword here'), findsOneWidget);
    });
  });
}
