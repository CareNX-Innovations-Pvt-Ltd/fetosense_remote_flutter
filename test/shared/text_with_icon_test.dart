import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fetosense_remote_flutter/ui/shared/textWithIcon.dart';

void main() {
  testWidgets('TextWithIcon renders correctly', (WidgetTester tester) async {
    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(360, 690), // Provide a design size
        builder: (context, child) => MaterialApp(
          home: Scaffold(
            body: TextWithIcon(
              icon: Icons.star,
              text: 'Test Text',
            ),
          ),
        ),
      ),
    );

    expect(find.byType(TextWithIcon), findsOneWidget);
    expect(find.byType(Icon), findsOneWidget);
    expect(find.byType(Text), findsOneWidget);
  });

  testWidgets('TextWithIcon displays correct icon and text', (WidgetTester tester) async {
    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(360, 690), // Provide a design size
        builder: (context, child) => MaterialApp(
          home: Scaffold(
            body: TextWithIcon(
              icon: Icons.star,
              text: 'Test Text',
            ),
          ),
        ),
      ),
    );

    expect(find.byIcon(Icons.star), findsOneWidget);
    expect(find.text('Test Text'), findsOneWidget);
  });

  testWidgets('TextWithIcon applies custom icon size', (WidgetTester tester) async {
    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(360, 690), // Provide a design size
        builder: (context, child) => MaterialApp(
          home: Scaffold(
            body: TextWithIcon(
              icon: Icons.star,
              text: 'Test Text',
              size: 30.0,
            ),
          ),
        ),
      ),
    );

    final Icon iconWidget = tester.widget(find.byType(Icon));
    expect(iconWidget.size, 30.0);
  });

  testWidgets('TextWithIcon applies default icon size when not provided', (WidgetTester tester) async {
    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(360, 690), // Provide a design size
        builder: (context, child) => MaterialApp(
          home: Scaffold(
            body: TextWithIcon(
              icon: Icons.star,
              text: 'Test Text',
            ),
          ),
        ),
      ),
    );

    // Find the icon widget and check its size in the rendered tree
    final iconFinder = find.byIcon(Icons.star);
    expect(iconFinder, findsOneWidget);

    final Size iconSize = tester.getSize(iconFinder);
    expect(iconSize.width, 14.0);
    expect(iconSize.height, 14.0);
  });
}
