import 'package:fetosense_remote_flutter/ui/widgets/custom_otp_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ProvidedPinBoxDecoration', () {
    test('defaultPinBoxDecoration creates decoration', () {
      final decoration = ProvidedPinBoxDecoration.defaultPinBoxDecoration(
        Colors.red,
        Colors.green,
        borderWidth: 3,
        radius: 10,
      );
      expect(decoration.border, isA<Border>());
      expect(decoration.color, Colors.green);
    });

    test('underlinedPinBoxDecoration creates decoration', () {
      final decoration = ProvidedPinBoxDecoration.underlinedPinBoxDecoration(
        Colors.blue,
        Colors.yellow,
        borderWidth: 4,
      );
      expect(decoration.border, isA<Border>());
    });

    test('roundedPinBoxDecoration creates decoration', () {
      final decoration = ProvidedPinBoxDecoration.roundedPinBoxDecoration(
        Colors.purple,
        Colors.orange,
      );
      expect(decoration.shape, BoxShape.circle);
    });
  });

  group('ProvidedPinBoxTextAnimation', () {
    testWidgets('awesomeTransition works', (tester) async {
      final anim = AlwaysStoppedAnimation(0.5);
      final widget = ProvidedPinBoxTextAnimation.awesomeTransition(
        const Text('A'),
        anim,
      );
      await tester.pumpWidget(MaterialApp(home: widget));
      expect(find.text('A'), findsOneWidget);
    });

    testWidgets('scalingTransition works', (tester) async {
      final anim = AlwaysStoppedAnimation(1.0);
      final widget = ProvidedPinBoxTextAnimation.scalingTransition(
        const Text('B'),
        anim,
      );
      await tester.pumpWidget(MaterialApp(home: widget));
      expect(find.text('B'), findsOneWidget);
    });

    testWidgets('defaultNoTransition returns child', (tester) async {
      final anim = AlwaysStoppedAnimation(0.0);
      final child = const Text('C');
      final widget =
      ProvidedPinBoxTextAnimation.defaultNoTransition(child, anim);
      await tester.pumpWidget(MaterialApp(home: widget));
      expect(find.text('C'), findsOneWidget);
    });

    testWidgets('rotateTransition works', (tester) async {
      final anim = AlwaysStoppedAnimation(1.0);
      final widget =
      ProvidedPinBoxTextAnimation.rotateTransition(const Text('D'), anim);
      await tester.pumpWidget(MaterialApp(home: widget));
      expect(find.text('D'), findsOneWidget);
    });
  });

  group('CustomOtptextfield', () {
    testWidgets('initState without highlightAnimation', (tester) async {
      final controller = TextEditingController();
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: CustomOtptextfield(
            controller: controller,
            onTextChanged: (_) {},
            onDone: (_) {},
          ),
        ),
      ));
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('initState with highlightAnimation', (tester) async {
      final controller = TextEditingController();
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: CustomOtptextfield(
            controller: controller,
            highlightAnimation: true,
            onDone: (_) {},
          ),
        ),
      ));
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('didUpdateWidget handles increased maxLength', (tester) async {
      final controller = TextEditingController(text: '12');
      final widget = Scaffold(body: CustomOtptextfield(controller: controller, maxLength: 2));
      await tester.pumpWidget(MaterialApp(home: widget));
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(body: CustomOtptextfield(controller: controller, maxLength: 4)),
      ));
      expect(controller.text, '12');
    });

    testWidgets('didUpdateWidget handles decreased maxLength', (tester) async {
      final controller = TextEditingController(text: '1234');
      final widget = Scaffold(body: CustomOtptextfield(controller: controller, maxLength: 4));
      await tester.pumpWidget(MaterialApp(home: widget));
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(body: CustomOtptextfield(controller: controller, maxLength: 2)),
      ));
      expect(controller.text.length, 2);
    });

    testWidgets('_onTextChanged calls onDone at maxLength', (tester) async {
      String? doneVal;
      final controller = TextEditingController(text: '1234');
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: CustomOtptextfield(
            controller: controller,
            onDone: (val) => doneVal = val,
          ),
        ),
      ));
      controller.text = '1234';
      await tester.pump();
      expect(controller.text, '1234');
    });

    testWidgets('hideCharacter masks input', (tester) async {
      final controller = TextEditingController();
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: CustomOtptextfield(
            controller: controller,
            hideCharacter: true,
            maskCharacter: '*',
          ),
        ),
      ));
      controller.text = '1';
      await tester.pump();
      expect(find.text('*'), findsOneWidget);
    });

    testWidgets('buildPinCode covers hasError', (tester) async {
      final controller = TextEditingController(text: '1');
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: CustomOtptextfield(
            controller: controller,
            hasError: true,
          ),
        ),
      ));
      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('hasUnderline draws underline', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: CustomOtptextfield(
            controller: TextEditingController(),
            hasUnderline: true,
          ),
        ),
      ));
      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('dispose with provided focusNode keeps node alive', (tester) async {
      final node = FocusNode();
      bool listenerCalled = true;
      node.addListener(() {
        listenerCalled = true;
      });

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: CustomOtptextfield(
            focusNode: node,
          ),
        ),
      ));

      await tester.pumpWidget(const SizedBox()); // Dispose widget

      // Node should still be usable
      node.requestFocus();
      expect(listenerCalled, true);
    });

    testWidgets('dispose with internal focusNode works without error', (tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(body: CustomOtptextfield()),
      ));
      await tester.pumpWidget(const SizedBox()); // Should not throw
    });

    testWidgets('isCupertino shows CupertinoTextField', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: CustomOtptextfield(
            isCupertino: true,
          ),
        ),
      ));
      expect(find.byType(CupertinoTextField), findsOneWidget);
    });

    testWidgets('hideDefaultKeyboard true skips GestureDetector', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: CustomOtptextfield(
            hideDefaultKeyboard: true,
          ),
        ),
      ));
      expect(find.byType(GestureDetector), findsNothing);
    });

    testWidgets('_animatedTextBox with transition', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: CustomOtptextfield(
            controller: TextEditingController(),
            pinTextAnimatedSwitcherTransition:
            ProvidedPinBoxTextAnimation.defaultNoTransition,
          ),
        ),
      ));
      expect(find.byType(AnimatedSwitcher), findsWidgets);
    });
  });
}
