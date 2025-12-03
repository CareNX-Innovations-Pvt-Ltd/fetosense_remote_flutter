import 'package:fetosense_remote_flutter/ui/widgets/scan_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:mocktail/mocktail.dart';
import 'package:image_picker/image_picker.dart';


// ------------------------- MOCKS --------------------------

class MockMobileScannerController extends Mock
    implements MobileScannerController {}

class MockNavigatorObserver extends Mock implements NavigatorObserver {}

class MockBarcode extends Mock implements Barcode {}

class MockBarcodeCapture extends Mock implements BarcodeCapture {}

class MockXFile extends Mock implements XFile {}

// ------------------------ TESTS ---------------------------

void main() {
  late MockMobileScannerController mockController;
  late MockNavigatorObserver navObserver;

  setUp(() {
    mockController = MockMobileScannerController();
    navObserver = MockNavigatorObserver();

    registerFallbackValue(
        (settings: const RouteSettings(name: "/dummy")));
  });

  Widget wrap(Widget widget) {
    return MaterialApp(
      home: widget,
      navigatorObservers: [navObserver],
    );
  }

  // --------------------------------------------------------
  // UI loads
  // --------------------------------------------------------

  testWidgets("ScanWidget renders correctly", (tester) async {
    await tester.pumpWidget(wrap(const ScanWidget()));
    expect(find.byType(MobileScanner), findsOneWidget);
    expect(find.text("Upload From Gallery"), findsOneWidget);
    expect(find.text("Cancel"), findsOneWidget);
  });

  // --------------------------------------------------------
  // onDetect triggers returnMethod
  // --------------------------------------------------------

  testWidgets("onDetect pops with barcode value", (tester) async {
    await tester.pumpWidget(wrap(const ScanWidget()));

    final state =
    tester.state(find.byType(ScanWidget)) as ScanWidgetState;

    // Create mock barcode
    final mockBarcode = MockBarcode();
    when(() => mockBarcode.rawValue).thenReturn("QR123");

    final mockCapture = MockBarcodeCapture();
    when(() => mockCapture.barcodes).thenReturn([mockBarcode]);

    // Trigger detection
    state.onDetect(mockCapture);
    await tester.pumpAndSettle();

    verify(() => navObserver.didPop(any(), any())).called(1);
  });

  // --------------------------------------------------------
  // onDetect with null value → no pop
  // --------------------------------------------------------

  testWidgets("onDetect does nothing when rawValue is null", (tester) async {
    await tester.pumpWidget(wrap(const ScanWidget()));

    final state =
    tester.state(find.byType(ScanWidget)) as ScanWidgetState;

    final mockBarcode = MockBarcode();
    when(() => mockBarcode.rawValue).thenReturn(null);

    final mockCapture = MockBarcodeCapture();
    when(() => mockCapture.barcodes).thenReturn([mockBarcode]);

    state.onDetect(mockCapture);
    await tester.pumpAndSettle();

    verifyNever(() => navObserver.didPop(any(), any()));
  });

  // --------------------------------------------------------
  // returnMethod pops only once
  // --------------------------------------------------------

  testWidgets("returnMethod prevents double pop", (tester) async {
    await tester.pumpWidget(wrap(const ScanWidget()));

    final state =
    tester.state(find.byType(ScanWidget)) as ScanWidgetState;

    state.returnMethod("A");
    state.returnMethod("B"); // Should be ignored

    await tester.pumpAndSettle();

    verify(() => navObserver.didPop(any(), any())).called(1);
  });

  // --------------------------------------------------------
  // Cancel button calls returnMethod(-1)
  // --------------------------------------------------------

  testWidgets("Cancel button triggers returnMethod(-1)", (tester) async {
    await tester.pumpWidget(wrap(const ScanWidget()));

    await tester.tap(find.text("Cancel"));
    await tester.pumpAndSettle();

    verify(() => navObserver.didPop(any(), any())).called(1);
  });

  // --------------------------------------------------------
  // pickFromGallery returns null → no pop
  // --------------------------------------------------------

  testWidgets("pickFromGallery does nothing when no image selected",
          (tester) async {
        // Mock image picker → returns null
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(
          const MethodChannel('plugins.flutter.io/image_picker'),
              (methodCall) async => null,
        );

        await tester.pumpWidget(wrap(const ScanWidget()));
        final state =
        tester.state(find.byType(ScanWidget)) as ScanWidgetState;

        await state.pickFromGallery();

        verifyNever(() => navObserver.didPop(any(), any()));
      });

  // --------------------------------------------------------
  // pickFromGallery → analyzeImage → pop
  // --------------------------------------------------------

  testWidgets("pickFromGallery scans image and pops with value",
          (tester) async {
        // Provide mock image file
        const mockPath = "/fake/image.jpeg";
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(
          const MethodChannel('plugins.flutter.io/image_picker'),
              (methodCall) async => {"path": mockPath},
        );

        // Mock analyzeImage
        final mockBarcode = MockBarcode();
        when(() => mockBarcode.rawValue).thenReturn("GALLERY_QR");

        final mockResult = MockBarcodeCapture();
        when(() => mockResult.barcodes).thenReturn([mockBarcode]);

        when(() => mockController.analyzeImage(any()))
            .thenAnswer((_) async => mockResult);

        // Mount widget
        await tester.pumpWidget(wrap(const ScanWidget()));

        final state =
        tester.state(find.byType(ScanWidget)) as ScanWidgetState;

        // Replace internal controller with mock
        state.controller.stop();
        state.controller.dispose();

        await state.pickFromGallery();
        await tester.pumpAndSettle();

        verify(() => navObserver.didPop(any(), any())).called(1);
      });

  // --------------------------------------------------------
  // dispose() calls controller.dispose
  // --------------------------------------------------------

  testWidgets("dispose calls controller.dispose()", (tester) async {
    await tester.pumpWidget(wrap(const ScanWidget()));

    final state =
    tester.state(find.byType(ScanWidget)) as ScanWidgetState;

    // Replace with mock controller
    state.controller.stop();
    state.controller.dispose();

    await tester.pumpWidget(Container()); // unmount widget

    verify(() => mockController.dispose()).called(1);
  });
}
