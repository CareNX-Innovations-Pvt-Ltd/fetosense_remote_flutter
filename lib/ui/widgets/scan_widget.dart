
import 'package:fetosense_remote_flutter/ui/shared/constant.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:scan/scan.dart';

import 'package:image_picker/image_picker.dart';

/// A widget that provides a QR code scanning functionality.
class ScanWidget extends StatefulWidget {
  const ScanWidget({super.key});

  @override
  ScanWidgetState createState() => ScanWidgetState();
}

class ScanWidgetState extends State<ScanWidget> {

  /// The platform version.
  String _platformVersion = 'Unknown';

  /// The controller for the scan view.
  ScanController controller = ScanController();

  /// The scanned QR code data.
  String qrcode = 'Unknown';

  void onCapture(String data) {
    setState(() {
      qrcode = data;
    });
    Navigator.pop(context, qrcode);
  }

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  /// Initializes the platform state to get the platform version.
  Future<void> initPlatformState() async {
    String platformVersion;
    try {
      platformVersion = await Scan.platformVersion;
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  @override
  Widget build(BuildContext context) {
    return  Scaffold(

      body:  WillPopScope(
        onWillPop: () async {
          Navigator.pop(context, qrcode);
          return true;
        },
        child: Column(
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              child: Stack(
                children: [
                  ScanView(
                    controller: controller,
                    scanAreaScale: .7,
                    scanLineColor: greenColor,
                    onCapture: (data) {
                      setState(() {
                        qrcode = data;
                      });
                      Navigator.pop(context, qrcode);
                    },

                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        InkWell(
                          onTap: () async {
                            final res =  await ImagePicker().pickImage(source: ImageSource.gallery);
                            if (res != null) {
                              String? str = await Scan.parse(res.path);
                              if (str != null) {
                                setState(() {
                                  qrcode = str;
                                });
                                Navigator.pop(context, qrcode);
                              }
                            }
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: borderLightColor,
                              borderRadius: BorderRadius.circular(100)
                            ),

                            // margin: EdgeInsets.only(bottom: 100),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.image),
                                  SizedBox(width: 12,),
                                  Text("Upload From Gallery", style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),),
                                ],
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 100,)
                      ],
                    ),
                  ),

                  GestureDetector(
                    onTap: (){
                      Navigator.pop(context);
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Align(
                        alignment: Alignment.bottomRight,
                        child: Text("Cancel", style: TextStyle(color: greenColor, fontSize: 18),),
                      ),
                    ),
                  )
                ],
              ),
            ),

          ],
        ),

      ),
    );
  }
}