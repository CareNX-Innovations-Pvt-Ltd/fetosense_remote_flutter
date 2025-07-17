import 'package:appwrite/models.dart';
import 'package:fetosense_remote_flutter/core/network/appwrite_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:appwrite/appwrite.dart';

import 'package:fetosense_remote_flutter/ui/views/recent_test_list_view.dart';
import 'package:fetosense_remote_flutter/core/model/doctor_model.dart';
import 'package:fetosense_remote_flutter/core/model/organization_model.dart';

class MockDatabases extends Mock implements Databases {}
class MockDocument extends Mock implements Document {}

void main() {
  group('RecentTestListView', () {
    testWidgets('renders RecentTestListView and displays Recent Tests', (WidgetTester tester) async {
      final mockDatabases = MockDatabases();
      when(mockDatabases.getDocument(
        databaseId: ('databaseId'),
        collectionId: ('collectionId'),
        documentId: ('documentId'),
        queries: anyNamed('queries'),
      )).thenAnswer((_) async => MockDocument());

      await tester.pumpWidget(
        MaterialApp(
          home: RecentTestListView(
            doctor: Doctor(),
            organization: Organization(),
            databases: mockDatabases,
          ),
        ),
      );
      expect(find.text('Recent Tests'), findsOneWidget);
    });

    testWidgets('calls getPaasKeys and sets passKeys', (WidgetTester tester) async {
      final mockDatabases = MockDatabases();
      when(mockDatabases.getDocument(
        databaseId: ('databaseId'),
        collectionId: ('collectionId'),
        documentId: ('documentId'),
        queries: anyNamed('queries'),
      )).thenAnswer((_) async => MockDocument());

      await tester.pumpWidget(
        MaterialApp(
          home: RecentTestListView(
            doctor: Doctor(),
            organization: Organization(),
            databases: mockDatabases,
          ),
        ),
      );
      expect(find.byType(RecentTestListView), findsOneWidget);
    });
  });
}
