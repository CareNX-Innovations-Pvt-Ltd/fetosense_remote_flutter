import 'package:fetosense_remote_flutter/core/model/mother_model.dart';
import 'package:fetosense_remote_flutter/core/view_models/test_crud_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fetosense_remote_flutter/ui/widgets/mother_card.dart';
import 'package:mockito/mockito.dart';


class MockTestCRUDModel extends Mock implements TestCRUDModel {}

void main() {
  group('MotherCard Widget Tests', () {
    Widget wrapWithScreenUtil(Widget child) {
      return ScreenUtilInit(
        designSize: const Size(375, 812),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (_, __) => MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                height: 600, // ✅ Constrain height to avoid overflow
                child: child,
              ),
            ),
          ),
        ),
      );
    }

    testWidgets('displays gestational age when EDD is provided', (tester) async {
      final futureEdd = DateTime.now().add(const Duration(days: 70));
      final mother = Mother()
        ..name = 'Alice'
        ..edd = futureEdd
        ..type = 'BabyBeat';

      await tester.pumpWidget(wrapWithScreenUtil(MotherCard(mother: mother)));
      await tester.pumpAndSettle();

      final expectedGestAge = (280 - futureEdd.difference(DateTime.now()).inDays) ~/ 7;

      expect(find.text(expectedGestAge.toString()), findsOneWidget);
      expect(find.text('weeks'), findsOneWidget);
      expect(find.text('Alice'), findsOneWidget);
      expect(find.textContaining('EDD -'), findsOneWidget);
    });

    testWidgets('displays LMP when EDD is null', (tester) async {
      final lmp = DateTime(2025, 1, 1);
      final mother = Mother()
        ..name = 'Beth'
        ..lmp = lmp
        ..type = 'Other';

      await tester.pumpWidget(wrapWithScreenUtil(MotherCard(mother: mother)));
      await tester.pumpAndSettle();

      expect(find.text('-'), findsOneWidget); // gestAge null
      expect(find.textContaining('LMP -'), findsOneWidget);
    });

    testWidgets('displays empty subtitle when EDD and LMP are null', (tester) async {
      final mother = Mother()
        ..name = 'Clara'
        ..type = 'Other';

      await tester.pumpWidget(wrapWithScreenUtil(MotherCard(mother: mother)));
      await tester.pumpAndSettle();

      expect(find.text('Clara'), findsOneWidget);

      final textWidgets = tester.widgetList<Text>(
        find.descendant(of: find.byType(ListTile), matching: find.byType(Text)),
      );

      final lastText = textWidgets.last;
      expect(lastText.data ?? '', '');
    });

    testWidgets('shows correct image based on mother.type', (tester) async {
      final mother1 = Mother()
        ..name = 'Dana'
        ..type = 'BabyBeat';

      final mother2 = Mother()
        ..name = 'Ella'
        ..type = 'Other';

      await tester.pumpWidget(
        wrapWithScreenUtil(
          Column(
            children: [
              MotherCard(mother: mother1),
              MotherCard(mother: mother2),
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();

      final images = tester.widgetList<Image>(find.byType(Image));
      expect(images.length, 2);

      final asset1 = images.elementAt(0).image as AssetImage;
      final asset2 = images.elementAt(1).image as AssetImage;

      expect(asset1.assetName, 'assets/bbc_icon.png');
      expect(asset2.assetName, 'images/ic_logo_good.png');
    });


  });
}
