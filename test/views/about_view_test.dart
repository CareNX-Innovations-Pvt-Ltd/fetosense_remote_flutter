import 'package:fetosense_remote_flutter/ui/views/about_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:url_launcher_platform_interface/url_launcher_platform_interface.dart';

class MockUrlLauncher extends Mock implements UrlLauncherPlatform {}

void main() {
  late MockUrlLauncher mockUrlLauncher;

  setUp(() {
    mockUrlLauncher = MockUrlLauncher();
    UrlLauncherPlatform.instance = mockUrlLauncher;
  });

  testWidgets('renders all UI elements correctly', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: AboutView()));

    // AppBar title
    expect(find.text('About'), findsOneWidget);

    // Version Text
    expect(find.text('v2.0'), findsOneWidget);

    // Website TextFormField
    expect(find.text('www.fetosense.com'), findsOneWidget);

    // Email TextFormField
    expect(find.text('support@carenx.in'), findsOneWidget);

    // Phone TextFormField
    expect(find.text('022 4973 8863'), findsOneWidget);

    // Privacy Policy TextFormField
    expect(find.text('PRIVACY POLICY'), findsOneWidget);

    // Image asset (banner)
    expect(find.byType(CircleAvatar), findsOneWidget);
  });

  testWidgets('taps website field and launches fetosense.com', (WidgetTester tester) async {
    when(() => mockUrlLauncher.canLaunch('https://www.fetosense.com'))
        .thenAnswer((_) async => true);
    when(() => mockUrlLauncher.launch(
      'https://www.fetosense.com',
      useSafariVC: any(named: 'useSafariVC'),
      useWebView: any(named: 'useWebView'),
      enableJavaScript: any(named: 'enableJavaScript'),
      enableDomStorage: any(named: 'enableDomStorage'),
      universalLinksOnly: any(named: 'universalLinksOnly'),
      headers: any(named: 'headers'),
      webOnlyWindowName: any(named: 'webOnlyWindowName'),
    )).thenAnswer((_) async => true);

    await tester.pumpWidget(const MaterialApp(home: AboutView()));
    await tester.tap(find.text('www.fetosense.com'));
    await tester.pumpAndSettle();

    verify(() => mockUrlLauncher.launch(
      'https://www.fetosense.com',
      useSafariVC: any(named: 'useSafariVC'),
      useWebView: any(named: 'useWebView'),
      enableJavaScript: any(named: 'enableJavaScript'),
      enableDomStorage: any(named: 'enableDomStorage'),
      universalLinksOnly: any(named: 'universalLinksOnly'),
      headers: any(named: 'headers'),
      webOnlyWindowName: any(named: 'webOnlyWindowName'),
    )).called(1);
  });

  testWidgets('taps phone field and launches tel://02249738863', (WidgetTester tester) async {
    when(() => mockUrlLauncher.canLaunch('tel://02249738863'))
        .thenAnswer((_) async => true);
    when(() => mockUrlLauncher.launch(
      'tel://02249738863',
      useSafariVC: any(named: 'useSafariVC'),
      useWebView: any(named: 'useWebView'),
      enableJavaScript: any(named: 'enableJavaScript'),
      enableDomStorage: any(named: 'enableDomStorage'),
      universalLinksOnly: any(named: 'universalLinksOnly'),
      headers: any(named: 'headers'),
      webOnlyWindowName: any(named: 'webOnlyWindowName'),
    )).thenAnswer((_) async => true);

    await tester.pumpWidget(const MaterialApp(home: AboutView()));
    await tester.tap(find.text('022 4973 8863'));
    await tester.pumpAndSettle();

    verify(() => mockUrlLauncher.launch(
      'tel://02249738863',
      useSafariVC: any(named: 'useSafariVC'),
      useWebView: any(named: 'useWebView'),
      enableJavaScript: any(named: 'enableJavaScript'),
      enableDomStorage: any(named: 'enableDomStorage'),
      universalLinksOnly: any(named: 'universalLinksOnly'),
      headers: any(named: 'headers'),
      webOnlyWindowName: any(named: 'webOnlyWindowName'),
    )).called(1);
  });

  testWidgets('taps privacy policy field and launches privacy URL', (WidgetTester tester) async {
    const url = 'https://ios-fetosense.firebaseapp.com/privacy-policy';

    when(() => mockUrlLauncher.canLaunch(url)).thenAnswer((_) async => true);
    when(() => mockUrlLauncher.launch(
      url,
      useSafariVC: any(named: 'useSafariVC'),
      useWebView: any(named: 'useWebView'),
      enableJavaScript: any(named: 'enableJavaScript'),
      enableDomStorage: any(named: 'enableDomStorage'),
      universalLinksOnly: any(named: 'universalLinksOnly'),
      headers: any(named: 'headers'),
      webOnlyWindowName: any(named: 'webOnlyWindowName'),
    )).thenAnswer((_) async => true);

    await tester.pumpWidget(const MaterialApp(home: AboutView()));
    await tester.tap(find.text('PRIVACY POLICY'));
    await tester.pumpAndSettle();

    verify(() => mockUrlLauncher.launch(
      url,
      useSafariVC: any(named: 'useSafariVC'),
      useWebView: any(named: 'useWebView'),
      enableJavaScript: any(named: 'enableJavaScript'),
      enableDomStorage: any(named: 'enableDomStorage'),
      universalLinksOnly: any(named: 'universalLinksOnly'),
      headers: any(named: 'headers'),
      webOnlyWindowName: any(named: 'webOnlyWindowName'),
    )).called(1);
  });

  testWidgets('throws when launch fails', (WidgetTester tester) async {
    const failedUrl = 'https://www.fetosense.com';

    when(() => mockUrlLauncher.canLaunch(failedUrl)).thenAnswer((_) async => false);

    await tester.pumpWidget(MaterialApp(home: AboutView()));
    await tester.tap(find.text('www.fetosense.com'));
    await tester.pump();

    // This would throw — expect async error
    expect(tester.takeException(), isA<String>());
  });
}
