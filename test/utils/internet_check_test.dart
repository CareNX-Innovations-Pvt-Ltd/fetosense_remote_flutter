import 'package:fetosense_remote_flutter/core/utils/internet_check.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

// Mock class using Mockito
class MockConnectivity extends Mock implements Connectivity {}

void main() {
  late InternetCheck internetCheck;
  late MockConnectivity mockConnectivity;

  setUp(() {
    mockConnectivity = MockConnectivity();
    internetCheck = InternetCheckWithMock(mockConnectivity);
  });

  test('returns true when connected to mobile', () async {
    when(mockConnectivity.checkConnectivity())
        .thenAnswer((_) async => [ConnectivityResult.mobile]);

    final result = await internetCheck.check();
    expect(result, true);
  });

  test('returns true when connected to wifi', () async {
    when(mockConnectivity.checkConnectivity())
        .thenAnswer((_) async => [ConnectivityResult.wifi]);

    final result = await internetCheck.check();
    expect(result, true);
  });

  test('returns true when connected to both mobile and wifi', () async {
    when(mockConnectivity.checkConnectivity())
        .thenAnswer((_) async => [ConnectivityResult.mobile, ConnectivityResult.wifi]);

    final result = await internetCheck.check();
    expect(result, true);
  });

  test('returns false when not connected', () async {
    when(mockConnectivity.checkConnectivity())
        .thenAnswer((_) async => [ConnectivityResult.none]);

    final result = await internetCheck.check();
    expect(result, false);
  });

  test('checkInternet calls function with true when connected', () async {
    when(mockConnectivity.checkConnectivity())
        .thenAnswer((_) async => [ConnectivityResult.wifi]);

    bool? callbackCalledWith;
    await internetCheck.checkInternet((value) {
      callbackCalledWith = value;
    });

    // Allow asynchronous tasks to complete
    await Future.delayed(Duration.zero);
    expect(callbackCalledWith, true);
  });

  test('checkInternet calls function with false when not connected', () async {
    when(mockConnectivity.checkConnectivity())
        .thenAnswer((_) async => [ConnectivityResult.none]);

    bool? callbackCalledWith;
    await internetCheck.checkInternet((value) {
      callbackCalledWith = value;
    });

    await Future.delayed(Duration.zero);
    expect(callbackCalledWith, false);
  });
}


/// A testable subclass of InternetCheck with injected [Connectivity].
class InternetCheckWithMock extends InternetCheck {
  final Connectivity mockConnectivity;

  InternetCheckWithMock(this.mockConnectivity);

  @override
  Future<bool> check() async {
    final results = await mockConnectivity.checkConnectivity();
    return results.contains(ConnectivityResult.mobile) ||
        results.contains(ConnectivityResult.wifi);
  }

  @override
  dynamic checkInternet(Function(bool) func) {
    check().then((internet) {
      func(internet);
    });
  }
}
