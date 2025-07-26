import 'package:fetosense_remote_flutter/core/utils/date_format_utils.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('en_IN', null);
  });

  group('DateTimeExtension', () {
    final date = DateTime(2022, 5, 15); // May 15, 2022

    test('format() returns correct formatted date', () {
      expect(date.format('dd/MM/yyyy'), '15/05/2022');
      expect(date.format('yyyy-MM-dd'), '2022-05-15');
    });

    test('getMonth() returns correct month name', () {
      expect(date.getMonth(), 'May');
      expect(date.getMonth('MMM'), 'May');
    });

    test('getDate() returns correct date part', () {
      expect(date.getDate(), '15');
    });

    test('getDay() returns correct day abbreviation', () {
      // May 15, 2022 was a Sunday
      expect(date.getDay(), 'Sun');
    });

    test('getAge() returns correct age for birth year', () {
      final birthDate = DateTime(DateTime.now().year - 25, 1, 1); // 25 years ago
      expect(birthDate.getAge(), 25);
    });

    test('getGestAge() returns correct gestational age in weeks', () {
      final conceptionDate = DateTime.now().subtract(const Duration(days: 14 * 7)); // 14 weeks ago
      expect(conceptionDate.getGestAge(), 14);
    });
  });
}
