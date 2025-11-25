import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:image_picker/image_picker.dart';

class ScanWidget extends StatefulWidget {
  const ScanWidget({super.key});

  @override
  ScanWidgetState createState() => ScanWidgetState();
}

class ScanWidgetState extends State<ScanWidget> {
  final MobileScannerController controller = MobileScannerController();
  bool _popped = false;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void _return(String value) {
    if (!_popped && mounted) {
      _popped = true;
      controller.stop();
      Navigator.pop(context, value);
    }
  }

  void _onDetect(BarcodeCapture capture) {
    final barcode = capture.barcodes.first;
    final value = barcode.rawValue;
    if (value != null) _return(value);
  }

  Future<void> pickFromGallery() async {
    final image = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (image == null) return;

    final result = await controller.analyzeImage(image.path);
    final barcode = result?.barcodes.first.rawValue;

    if (barcode != null) _return(barcode);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          MobileScanner(
            controller: controller,
            onDetect: _onDetect,
          ),

          Align(
            alignment: Alignment.bottomCenter,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                InkWell(
                  onTap: pickFromGallery,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                        color: Colors.white, borderRadius: BorderRadius.circular(100)),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.image),
                        SizedBox(width: 10),
                        Text("Upload From Gallery"),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 100),
              ],
            ),
          ),

          Positioned(
            bottom: 30,
            right: 20,
            child: GestureDetector(
              onTap: () => _return("-1"),
              child: const Text("Cancel", style: TextStyle(fontSize: 18)),
            ),
          ),
        ],
      ),
    );
  }
}