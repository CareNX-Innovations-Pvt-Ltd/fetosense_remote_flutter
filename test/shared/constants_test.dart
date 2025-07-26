import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fetosense_remote_flutter/ui/shared/constant.dart';

void main() {
  testWidgets('screenHeight returns correct height', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: Builder(builder: (context) {
      expect(screenHeight(context), equals(MediaQuery.of(context).size.height));
      return Container();
    })));
  });

  testWidgets('screenWidth returns correct width', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: Builder(builder: (context) {
      expect(screenWidth(context), equals(MediaQuery.of(context).size.width));
      return Container();
    })));
  });

  test('themeColor is correct', () {
    expect(themeColor, equals(Color(0xFF874A9C)));
  });

  test('secondaryColor is correct', () {
    expect(secondaryColor, equals(Color(0xFFF0B4B5)));
  });

  test('lightsecondaryColor is correct', () {
    expect(lightsecondaryColor, equals(Color(0xFFEFE1E5)));
  });

  test('greenColor is correct', () {
    expect(greenColor, equals(Color(0xFF59B9B3)));
  });

  test('blueColor is correct', () {
    expect(blueColor, equals(Color(0xFF7092FF)));
  });

  test('lightTealColor is correct', () {
    expect(lightTealColor, equals(Color(0xFFc8e8e4)));
  });

  test('lightThemeColor is correct', () {
    expect(lightThemeColor, equals(Color(0xFFf7dce1)));
  });

  test('lightPinkColor is correct', () {
    expect(lightPinkColor, equals(Color(0xFFFEF7F9)));
  });

  test('borderLightColor is correct', () {
    expect(borderLightColor, equals(Color(0xFFdadada)));
  });

  test('greyRegular is correct', () {
    expect(greyRegular, equals(Color(0xFF888888)));
  });

  test('greyLight is correct', () {
    expect(greyLight, equals(Color(0xFFC4C9E1)));
  });

  test('bgColor is correct', () {
    expect(bgColor, equals(Color(0xFFEAF6F5)));
  });
}
