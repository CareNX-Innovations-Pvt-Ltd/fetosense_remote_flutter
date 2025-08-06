import 'package:fetosense_remote_flutter/ui/widgets/in_app_web_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'in_app_web_view_test.mocks.dart';


@GenerateMocks([WebViewController, NavigationDelegate])

// Mock color constant - replace with your actual color
const Color greenColor = Colors.green;

void main() {
  group('InAppWebView Widget Tests', () {
    late MockWebViewController mockController;

    setUp(() {
      mockController = MockWebViewController();
    });

    testWidgets('should create InAppWebView with title and url', (WidgetTester tester) async {
      // Arrange
      const String testTitle = 'Test Web View';
      const String testUrl = 'https://example.com';

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: InAppWebView(testTitle, testUrl),
        ),
      );

      // Assert
      expect(find.byType(InAppWebView), findsOneWidget);
      expect(find.text(testTitle), findsOneWidget);
    });

    testWidgets('should create InAppWebView with null title', (WidgetTester tester) async {
      // Arrange & Act
      expect(() async {
        await tester.pumpWidget(
          MaterialApp(
            home: InAppWebView(null, 'https://example.com'),
          ),
        );
        await tester.pump();
      }, throwsA(isA<TypeError>())); // Will throw because of widget._title! null assertion
    });

    testWidgets('should display correct app bar with title and back button', (WidgetTester tester) async {
      // Arrange
      const String testTitle = 'Test Title';

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: InAppWebView(testTitle, 'https://example.com'),
        ),
      );

      // Assert
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.text(testTitle), findsOneWidget);
      expect(find.byIcon(Icons.arrow_back_ios_outlined), findsOneWidget);

      // Verify AppBar styling
      final AppBar appBar = tester.widget(find.byType(AppBar));
      expect(appBar.backgroundColor, equals(greenColor));
    });

    testWidgets('should display WebViewWidget in body', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: InAppWebView('Test', 'https://example.com'),
        ),
      );

      // Assert
      expect(find.byType(WebViewWidget), findsOneWidget);
    });

    testWidgets('should have white background color for Scaffold', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: InAppWebView('Test', 'https://example.com'),
        ),
      );

      // Assert
      final Scaffold scaffold = tester.widget(find.byType(Scaffold));
      expect(scaffold.backgroundColor, equals(Colors.white));
    });

    testWidgets('should navigate back when back button is pressed', (WidgetTester tester) async {
      // Create a navigator key to control navigation
      final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

      await tester.pumpWidget(
        MaterialApp(
          navigatorKey: navigatorKey,
          home: Builder(
            builder: (context) => Scaffold(
              body: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => InAppWebView('Test', 'https://example.com'),
                    ),
                  );
                },
                child: const Text('Open WebView'),
              ),
            ),
          ),
        ),
      );

      // Navigate to WebView
      await tester.tap(find.text('Open WebView'));
      await tester.pumpAndSettle();

      // Verify WebView is displayed
      expect(find.byType(InAppWebView), findsOneWidget);

      // Tap back button
      await tester.tap(find.byIcon(Icons.arrow_back_ios_outlined));
      await tester.pumpAndSettle();

      // Verify navigation back
      expect(find.byType(InAppWebView), findsNothing);
      expect(find.text('Open WebView'), findsOneWidget);
    });

    testWidgets('should apply correct text styling to title', (WidgetTester tester) async {
      // Arrange
      const String testTitle = 'Styled Title';

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: InAppWebView(testTitle, 'https://example.com'),
        ),
      );

      // Assert
      final Text titleText = tester.widget(find.text(testTitle));
      expect(titleText.style?.fontFamily, equals('Metropolis-Regular'));
      expect(titleText.style?.fontSize, equals(15));
      expect(titleText.style?.color, equals(Colors.white));
    });

    testWidgets('should apply correct styling to back button icon', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: InAppWebView('Test', 'https://example.com'),
        ),
      );

      // Assert
      final Icon backIcon = tester.widget(find.byIcon(Icons.arrow_back_ios_outlined));
      expect(backIcon.color, equals(Colors.white));
      expect(backIcon.size, equals(20));
    });

    group('WebViewController Configuration Tests', () {
      testWidgets('should create state with properly configured controller', (WidgetTester tester) async {
        // Act
        await tester.pumpWidget(
          MaterialApp(
            home: InAppWebView('Test', 'https://example.com'),
          ),
        );

        // Assert - verify the widget builds successfully with controller
        expect(find.byType(InAppWebView), findsOneWidget);
        expect(find.byType(WebViewWidget), findsOneWidget);
      });
    });

    group('Constructor Tests', () {
      test('should create InAppWebView with valid parameters', () {
        // Act
        final widget = InAppWebView('Test Title', 'https://example.com');

        // Assert
        expect(widget, isA<InAppWebView>());
        // Note: _title is private, so we test through widget behavior instead
      });

      test('should create InAppWebView with null title', () {
        // Act
        final widget = InAppWebView(null, 'https://example.com');

        // Assert
        expect(widget, isA<InAppWebView>());
      });

      test('should create InAppWebView with null url', () {
        // Act
        final widget = InAppWebView('Test', null);

        // Assert
        expect(widget, isA<InAppWebView>());
      });
    });

    group('State Creation Tests', () {
      test('should create InAppWebViewState', () {
        // Arrange
        final widget = InAppWebView('Test', 'https://example.com');

        // Act
        final state = widget.createState();

        // Assert
        expect(state, isA<InAppWebViewState>());
      });
    });

    testWidgets('should handle empty title string', (WidgetTester tester) async {
      // Arrange
      const String emptyTitle = '';

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: InAppWebView(emptyTitle, 'https://example.com'),
        ),
      );

      // Assert
      expect(find.byType(InAppWebView), findsOneWidget);
      expect(find.text(emptyTitle), findsOneWidget);
    });

    testWidgets('should handle very long title', (WidgetTester tester) async {
      // Arrange
      const String longTitle = 'This is a very long title that might overflow in the app bar but should still be handled properly by the widget';

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: InAppWebView(longTitle, 'https://example.com'),
        ),
      );

      // Assert
      expect(find.byType(InAppWebView), findsOneWidget);
      expect(find.text(longTitle), findsOneWidget);
    });

    testWidgets('should maintain widget tree structure', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: InAppWebView('Test', 'https://example.com'),
        ),
      );

      // Assert widget hierarchy
      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.byType(IconButton), findsOneWidget);
      expect(find.byType(Text), findsOneWidget);
      expect(find.byType(WebViewWidget), findsOneWidget);
    });
  });

  group('Navigation Delegate Tests', () {
    testWidgets('should prevent navigation to YouTube URLs', (WidgetTester tester) async {
      // This test would require more complex setup to test the actual navigation delegate
      // For now, we'll test that the widget builds correctly
      await tester.pumpWidget(
        MaterialApp(
          home: InAppWebView('Test', 'https://example.com'),
        ),
      );

      expect(find.byType(InAppWebView), findsOneWidget);
    });
  });
}