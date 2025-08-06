import 'package:fetosense_remote_flutter/ui/widgets/update_org_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('UpdateOrgDialog UI and interaction test', (WidgetTester tester) async {
    String? result;

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) => UpdateOrgDialog(
                  callback: (val) => result = val,
                ),
              );
            },
            child: Text('Open Dialog'),
          ),
        ),
      ),
    );

    // Open dialog
    await tester.tap(find.text('Open Dialog'));
    await tester.pumpAndSettle();

    // Check all static texts
    expect(find.text('Update Organization'), findsOneWidget);
    expect(find.text('Code'), findsOneWidget);
    expect(find.text('Cancel'), findsOneWidget);
    expect(find.text('Update'), findsOneWidget);
    expect(find.text('|'), findsOneWidget);

    // Enter value in TextField
    await tester.enterText(find.byType(TextField), 'ORG123');

    // Tap Update and verify result
    await tester.tap(find.text('Update'));
    await tester.pumpAndSettle();
    expect(result, 'ORG123');

    // Reopen and test Cancel button
    await tester.tap(find.text('Open Dialog'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(result, '');
  });
}
