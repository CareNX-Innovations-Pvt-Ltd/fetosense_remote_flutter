import 'package:fetosense_remote_flutter/core/network/appwrite_config.dart';
import 'package:fetosense_remote_flutter/core/services/appwrite_api.dart';
import 'package:fetosense_remote_flutter/core/services/authentication.dart';
import 'package:fetosense_remote_flutter/core/services/notificationapi.dart';
import 'package:fetosense_remote_flutter/core/services/testapi.dart';
import 'package:fetosense_remote_flutter/core/utils/preferences.dart';
import 'package:fetosense_remote_flutter/core/view_models/crud_view_model.dart';
import 'package:fetosense_remote_flutter/core/view_models/notification_crud_model.dart';
import 'package:fetosense_remote_flutter/core/view_models/test_crud_model.dart';
import 'package:fetosense_remote_flutter/locater.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:appwrite/appwrite.dart';

// Create mocks for any external dependencies
class MockAppwriteService extends Mock implements AppwriteService {
  @override
  Client get client => Client();
}

void main() {
  final locator = GetIt.instance;

  setUp(() {
    locator.reset();
  });

  test('setupLocator registers all dependencies', () {
    // Call setupLocator
    setupLocator();

    // Verify each service is registered
    expect(locator.isRegistered<AppwriteService>(), isTrue);
    expect(locator.isRegistered<BaseAuth>(), isTrue);
    expect(locator.isRegistered<Databases>(), isTrue);
    expect(locator.isRegistered<AppwriteApi>(), isTrue);
    expect(locator.isRegistered<CRUDModel>(), isTrue);
    expect(locator.isRegistered<TestApi>(), isTrue);
    expect(locator.isRegistered<TestCRUDModel>(), isTrue);
    expect(locator.isRegistered<AppwriteNotificationApi>(), isTrue);
    expect(locator.isRegistered<NotificationCRUDModel>(), isTrue);
    expect(locator.isRegistered<PreferenceHelper>(), isTrue);
  });

  test('setupLocator can be called twice without throwing', () {
    setupLocator();
    expect(() => setupLocator(), returnsNormally);
  });

  test('services return correct instance types', () {
    setupLocator();

    expect(locator<AppwriteService>(), isA<AppwriteService>());
    expect(locator<BaseAuth>(), isA<BaseAuth>());
    expect(locator<Databases>(), isA<Databases>());
    expect(locator<AppwriteApi>(), isA<AppwriteApi>());
    expect(locator<CRUDModel>(), isA<CRUDModel>());
    expect(locator<TestApi>(), isA<TestApi>());
    expect(locator<TestCRUDModel>(), isA<TestCRUDModel>());
    expect(locator<AppwriteNotificationApi>(), isA<AppwriteNotificationApi>());
    expect(locator<NotificationCRUDModel>(), isA<NotificationCRUDModel>());
    expect(locator<PreferenceHelper>(), isA<PreferenceHelper>());
  });
}
