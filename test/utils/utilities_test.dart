import 'package:fetosense_remote_flutter/core/utils/utilities.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Utilities', () {
    testWidgets('setScreenUtil initializes ScreenUtil', (tester) async {
      final utilities = Utilities();

      // Build a dummy widget for context
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              utilities.setScreenUtil(context, width: 360, height: 690);
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      expect(ScreenUtil().screenWidth, isNonZero);
      expect(ScreenUtil().screenHeight, isNonZero);
    });

    test('getGestationalAgeWeeks returns correct weeks', () {
      final lmpDate = DateTime.now().subtract(const Duration(days: 21)); // 3 weeks ago
      final result = Utilities.getGestationalAgeWeeks(lmpDate);
      expect(result, 3);
    });

    test('getLmpFromGestationalAgeWeeks returns correct date', () {
      final weeks = 4;
      final expectedDate = DateTime.now().subtract(Duration(days: weeks * 7));

      // We compare only date parts to avoid milliseconds differences
      final result = Utilities.getLmpFromGestationalAgeWeeks(weeks);
      expect(result.year, expectedDate.year);
      expect(result.month, expectedDate.month);
      expect(result.day, expectedDate.day);
    });
  });
}
