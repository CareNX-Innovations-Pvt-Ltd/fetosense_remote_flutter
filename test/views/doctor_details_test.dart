
import 'package:fetosense_remote_flutter/core/model/doctor_model.dart';
import 'package:fetosense_remote_flutter/ui/views/doctor_details.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

class MockDoctor extends Mock implements Doctor {}

void main() {
  group('DoctorDetails', () {
    testWidgets('should render correctly', (WidgetTester tester) async {
      final doctor = Doctor(
        name: 'John Doe',
        email: 'john.doe@example.com',
      );

      await tester.pumpWidget(MaterialApp(
        home: DoctorDetails(doctor: doctor),
      ));

      expect(find.text('John Doe'), findsOneWidget);
      expect(find.text('john.doe@example.com'), findsOneWidget);
      expect(find.text('Test Organization'), findsOneWidget);
    });

    testWidgets('should allow editing personal details', (WidgetTester tester) async {
      final doctor = Doctor(
        name: 'John Doe',
        email: 'john.doe@example.com',
      );

      await tester.pumpWidget(MaterialApp(
        home: DoctorDetails(doctor: doctor),
      ));

      await tester.tap(find.text('Edit'));
      await tester.pump();

      expect(find.text('Update'), findsOneWidget);

      await tester.enterText(find.widgetWithText(TextFormField, 'John Doe'), 'Jane Doe');
      await tester.enterText(find.widgetWithText(TextFormField, 'john.doe@example.com'), 'jane.doe@example.com');

      await tester.tap(find.text('Update'));
      await tester.pump();

      expect(find.text('Jane Doe'), findsOneWidget);
      expect(find.text('jane.doe@example.com'), findsOneWidget);
    });

    // Add more tests for other functionalities like updating organization, etc.
  });
}

