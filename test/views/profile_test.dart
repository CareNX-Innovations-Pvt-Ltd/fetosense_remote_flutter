import 'package:fetosense_remote_flutter/core/services/authentication.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fetosense_remote_flutter/ui/views/profile_view.dart';
import 'package:fetosense_remote_flutter/core/model/doctor_model.dart';
import 'package:fetosense_remote_flutter/core/model/organization_model.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';

class MockBaseAuth extends Mock implements BaseAuth {}
void main() {
  final locator = GetIt.instance;
  locator.reset();
  group('ProfileView Widget Tests', () {
    late Doctor doctor;
    late Organization org;

    setUp(() {
      locator.registerSingleton<BaseAuth>(MockBaseAuth());
      doctor = Doctor(name: 'Dr. Test', email: 'test@doc.com');
      org = Organization();
    });

    testWidgets('displays doctor name and email', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ProfileView(
            doctor: doctor,
            organization: org,
          ),
        ),
      );

      expect(find.text('Dr. Test'), findsOneWidget);
      expect(find.text('test@doc.com'), findsOneWidget);
    });

    testWidgets('Edit Profile button works', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ProfileView(
            doctor: doctor,
            organization: org,
          ),
        ),
      );

      final editProfile = find.text('Edit Profile');
      expect(editProfile, findsOneWidget);

      await tester.tap(editProfile);
      await tester.pumpAndSettle();

      // Should navigate to DoctorDetails (could check for a widget from that page)
    });

    testWidgets('Logout button exists', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ProfileView(
            doctor: doctor,
            organization: org,
          ),
        ),
      );

      expect(find.text('Logout'), findsOneWidget);
    });
  });
}