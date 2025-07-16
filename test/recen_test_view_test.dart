import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as models; // Import models to access Response
import 'package:fetosense_remote_flutter/core/network/appwrite_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview_platform_interface/flutter_inappwebview_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';
import 'package:mocktail/mocktail.dart';
import 'package:fetosense_remote_flutter/ui/views/recent_test_list_view.dart';
import 'package:fetosense_remote_flutter/core/view_models/test_crud_model.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:http/http.dart' as http;

class FakeInAppWebViewPlatform extends InAppWebViewPlatform {
  @override
  PlatformInAppWebViewWidget createPlatformInAppWebViewWidget(
    PlatformInAppWebViewWidgetCreationParams params,
  ) {
    return _FakePlatformInAppWebViewWidget(params);
  }
}

class _FakePlatformInAppWebViewWidget with MockPlatformInterfaceMixin implements PlatformInAppWebViewWidget {
  final PlatformInAppWebViewWidgetCreationParams params;

  _FakePlatformInAppWebViewWidget(this.params);

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();

  @override
  T controllerFromPlatform<T>(PlatformInAppWebViewController controller) {
    throw UnimplementedError();
  }

  @override
  void dispose() {}
}

class MockTestCRUDModel extends Mock implements TestCRUDModel {}

class MockClient extends Mock implements Client {}

class MockAppwriteService extends Mock implements AppwriteService {
  @override
  final client = MockClient();
}

void main() {
  final getIt = GetIt.instance;

  setUp(() {
    registerFallbackValue(HttpMethod.get);
    InAppWebViewPlatform.instance = FakeInAppWebViewPlatform();
    getIt.reset();

    final mockTestCRUDModel = MockTestCRUDModel();
    final mockAppwriteService = MockAppwriteService();

    // Stub the call method using named parameters
    when(() => mockAppwriteService.client.call(
          any(named: 'method'),
          path: any(named: 'path'),
          params: any(named: 'params'),
          headers: any(named: 'headers'),
          responseType: any(named: 'responseType'),
        )).thenAnswer((_) async => models.Response(data: {}));

    getIt.registerSingleton<TestCRUDModel>(mockTestCRUDModel);
    getIt.registerSingleton<AppwriteService>(mockAppwriteService);
  });

  testWidgets('RecentTestListView shows welcome text when no org', (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<TestCRUDModel>(
            create: (_) => getIt<TestCRUDModel>(),
          ),
        ],
        child: const MaterialApp(
          home: RecentTestListView(),
        ),
      ),
    );

    expect(find.text('Welcome back,'), findsOneWidget);
    expect(find.text('Scan QR'), findsOneWidget);
  });
}