import 'package:fetosense_remote_flutter/ui/widgets/scan_widget.dart';
import 'package:mockito/mockito.dart';
import 'package:scan/scan.dart';
import 'package:image_picker/image_picker.dart';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class MockScan extends Mock implements Scan {}

class MockScanController extends Mock implements ScanController {}

class MockImagePicker extends Mock implements ImagePicker {}

class MockXFile extends Mock implements XFile {}

void main() {
  late MockScanController mockController;
  late MockImagePicker mockPicker;

  setUp(() {
    mockController = MockScanController();
    mockPicker = MockImagePicker();
  });

  testWidgets('ScanWidget initializes and shows cancel button', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: const ScanWidget(),
      ),
    );

    expect(find.text('Cancel'), findsOneWidget);
    expect(find.text('Upload From Gallery'), findsOneWidget);
  });

  testWidgets('Tapping Cancel button pops with no value', (tester) async {
    String? result;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            return ElevatedButton(
              onPressed: () async {
                result = await Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ScanWidget()),
                );
              },
              child: const Text('Open'),
            );
          },
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(result, isNull);
  });

  // testWidgets('Tapping Upload From Gallery with null file does nothing',
  //     (tester) async {
  //   final picker = MockImagePicker();
  //   when(picker.pickImage(source: ImageSource.gallery))
  //       .thenAnswer((_) async => null);
  //
  //   await tester.pumpWidget(
  //     MaterialApp(
  //       home: const ScanWidget(),
  //     ),
  //   );
  //
  //   await tester.tap(find.text('Upload From Gallery'));
  //   await tester.pumpAndSettle();
  //
  //   // Since res is null, nothing should happen
  //   expect(find.text('Cancel'), findsOneWidget);
  // });

  testWidgets('onCapture triggers pop with QR code', (tester) async {
    String? result;

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(builder: (context) {
          return ElevatedButton(
            onPressed: () async {
              result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ScanWidget()),
              );
            },
            child: const Text('Open'),
          );
        }),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    // simulate onCapture
    final state = tester.state(find.byType(ScanWidget)) as ScanWidgetState;
    state.onCapture.call('MOCKED_QR_CODE');
    await tester.pumpAndSettle();

    expect(result, 'MOCKED_QR_CODE');
  });

  // testWidgets('Upload From Gallery with valid image parses and pops',
  //     (tester) async {
  //   final mockXFile = MockXFile();
  //   final picker = MockImagePicker();
  //
  //   when(picker.pickImage(source: ImageSource.gallery))
  //       .thenAnswer((_) async => mockXFile);
  //   when(mockXFile.path).thenReturn('mocked_path');
  //   when(Scan.parse('mocked_path')).thenAnswer((_) async => 'PARSED_CODE');
  //
  //   String? result;
  //
  //   await tester.pumpWidget(
  //     MaterialApp(
  //       home: Builder(
  //         builder: (context) {
  //           return ElevatedButton(
  //             onPressed: () async {
  //               result = await Navigator.push(
  //                 context,
  //                 MaterialPageRoute(builder: (_) => const ScanWidget()),
  //               );
  //             },
  //             child: const Text('Open'),
  //           );
  //         },
  //       ),
  //     ),
  //   );
  //
  //   await tester.tap(find.text('Open'));
  //   await tester.pumpAndSettle();
  //
  //   // simulate picking image
  //   final state = tester.state(find.byType(ScanWidget)) as ScanWidgetState;
  //   final galleryButton = find.text('Upload From Gallery');
  //   await tester.tap(galleryButton);
  //   await tester.pumpAndSettle();
  //
  //   expect(result, isNull); // Only works if you inject mocks properly
  // });
}
