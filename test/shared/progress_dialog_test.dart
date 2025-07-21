import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fetosense_remote_flutter/ui/shared/progressDialog.dart';

void main() {
  testWidgets('ProgressDialog displays CircularProgressIndicator', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(
        body: ProgressDialog(),
      ),
    ));

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}