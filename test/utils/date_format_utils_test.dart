import 'package:fetosense_remote_flutter/core/utils/date_format_utils.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

void main() {
  group('DateTimeExtension', () {
    final date = DateTime(2020, 5, 15); // 15 May 2020

    setUpAll(() async {
      // Initialize Intl for locale-based tests
      await initializeDateFormatting();
    });

    test('format() without locale uses default pattern', () {
      final result = date.format();
      expect(result, DateFormat('dd/MM/yyyy').format(date));
    });

    test('format() with locale formats correctly', () async {
      final result = date.format('dd MMMM yyyy', 'en_US');
      expect(result, DateFormat('dd MMMM yyyy', 'en_US').format(date));
    });

    test('getMonth() without locale returns month name', () {
      final result = date.getMonth();
      expect(result, DateFormat('MMMM').format(date));
    });

    test('getMonth() with locale works', () {
      final result = date.getMonth('MMMM', 'en_US');
      expect(result, DateFormat('MMMM', 'en_US').format(date));
    });

    test('getDate() without locale returns day', () {
      final result = date.getDate();
      expect(result, DateFormat('dd').format(date));
    });

    test('getDate() with locale works', () {
      final result = date.getDate('dd', 'en_US');
      expect(result, DateFormat('dd', 'en_US').format(date));
    });

    test('getDay() without locale returns short day name', () {
      final result = date.getDay();
      expect(result, DateFormat('EEEE').format(date).substring(0, 3));
    });

    test('getDay() with locale works', () {
      final result = date.getDay('EEEE', 'en_US');
      expect(result, DateFormat('EEEE', 'en_US').format(date).substring(0, 3));
    });

    test('getAge() calculates correct age in years', () {
      final pastDate = DateTime(DateTime.now().year - 30, 5, 15); // 30 years ago
      expect(pastDate.getAge(), 30);
    });

    test('getGestAge() calculates gestational weeks correctly', () {
      final twoWeeksAgo = DateTime.now().subtract(Duration(days: 14));
      expect(twoWeeksAgo.getGestAge(), 2);
    });
  });
}
