import 'package:fetosense_remote_flutter/core/utils/preferences.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fetosense_remote_flutter/core/model/doctor_model.dart';

void main() {
  late PreferenceHelper preferenceHelper;

  setUp(() async {
    SharedPreferences.setMockInitialValues({}); // reset storage before each test
    await PreferenceHelper.init(); // initialize static _prefs
    preferenceHelper = PreferenceHelper(); // instance for non-static methods
  });

  group('PreferenceHelper', () {
    test('set and get auto login flag', () {
      preferenceHelper.setAutoLogin(true);
      expect(preferenceHelper.getAutoLogin(), true);
    });

    test('set and get doctor model', () async {
      final doctor = Doctor( name: 'Dr. Test');
      await preferenceHelper.saveDoctor(doctor);

      final retrieved = preferenceHelper.getDoctor();
      expect(retrieved?.name, 'Dr. Test');
    });

    test('remove doctor clears data', () async {
      final doctor = Doctor(name: 'Dr. Remove');
      await preferenceHelper.saveDoctor(doctor);

      preferenceHelper.removeDoctor();
      expect(preferenceHelper.getDoctor(), null);
    });

    test('set and get app open timestamp', () {
      preferenceHelper.setAppOpenAt(1234567890);
      expect(preferenceHelper.getAppOpenAt(), 1234567890);
    });

    test('set and get linkage flag', () {
      preferenceHelper.setLinkageFlag(true);
      expect(preferenceHelper.getLinkageFlag(), true);
    });

    test('set and get read article list by week key', () {
      final articles = ['a1', 'a2'];
      preferenceHelper.saveReadArticleList(articles, 'week1');
      expect(preferenceHelper.getReadArticleList('week1'), equals(articles));
    });

    test('set and get update flag', () {
      preferenceHelper.setUpdate(true);
      expect(preferenceHelper.getUpdate(), true);
    });

    test('set and get first time flag', () {
      preferenceHelper.setIsFirstTime(false);
      expect(preferenceHelper.getIsFirstTime(), false);
    });

    test('set and get int value', () {
      preferenceHelper.setInt('intKey', 42);
      expect(preferenceHelper.getInt('intKey'), 42);
    });

    test('set and get bool value', () {
      preferenceHelper.setBool('boolKey', true);
      expect(preferenceHelper.getBool('boolKey'), true);
    });

    test('set and get string value', () {
      preferenceHelper.setString('stringKey', 'test');
      expect(preferenceHelper.getString('stringKey'), 'test');
    });

    test('throws exception if PreferenceHelper not initialized', () async {
      PreferenceHelper.prefs = null; // simulate uninitialized
      expect(() => preferenceHelper.getAutoLogin(), throwsException);
    });
  });
}
