import 'dart:convert';
import 'package:appwrite/appwrite.dart';
import 'package:fetosense_remote_flutter/app_router.dart';
import 'package:fetosense_remote_flutter/core/model/doctor_model.dart';
import 'package:fetosense_remote_flutter/core/model/organization_model.dart';
import 'package:fetosense_remote_flutter/core/network/appwrite_config.dart';
import 'package:fetosense_remote_flutter/core/utils/app_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:go_router/go_router.dart';

import '../../locater.dart';

/// A StatefulWidget that handles the initial profile update for a doctor.
class InitialProfileUpdate2 extends StatefulWidget {
  /// [doctor] is the doctor model.
  final Doctor? doctor;

  const InitialProfileUpdate2(
      {super.key, this.doctor,});

  @override
  InitialProfileUpdate2State createState() => InitialProfileUpdate2State();
}

class InitialProfileUpdate2State extends State<InitialProfileUpdate2> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool isMobileVerified = false;
  bool isEditOrg = false;
  Organization? organization;
  final databases = Databases(locator<AppwriteService>().client);
  String? code;
  Doctor doctor = Doctor();

  @override
  void initState() {
    super.initState();
    debugPrint('doctor -> ${widget.doctor?.email}');
    debugPrint('doctor -> ${widget.doctor?.documentId}');
    doctor = widget.doctor!;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: Center(
        child: Stack(
          children: <Widget>[
            _showForm(),
          ],
        ),
      ),
    );
  }

  /// Displays the form for updating the profile.
  Widget _showForm() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 0.0),
        child: ListView(
          shrinkWrap: true,
          children: <Widget>[
            showLogo(),
            const SizedBox(
              height: 30,
            ),
            Container(
              margin: const EdgeInsets.fromLTRB(10, 20, 10, 0),
              width: MediaQuery.of(context).size.width,
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    "Update Organization Details",
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                      color: Colors.black87,
                      fontSize: 20,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 16,
            ),
            showPrimaryButton(),
          ],
        ),
      ),
    );
  }

  /// Displays the logo.
  Widget showLogo() {
    return Hero(
      tag: 'hero',
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
        child: CircleAvatar(
          backgroundColor: Colors.transparent,
          radius: 140.0,
          child: Image.asset('images/ic_banner.png'),
        ),
      ),
    );
  }

  /// Displays the name input field.
  Widget showNameInput() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(32, 10, 32, 8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
            child: Row(
              children: <Widget>[
                const Padding(
                  padding: EdgeInsets.fromLTRB(4, 0, 16, 0),
                  child: Icon(
                    Icons.account_balance,
                    color: Colors.grey,
                  ),
                ),
                Expanded(
                  child: Container(
                    decoration: const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: Colors.grey),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
                      child: Text(
                        (organization == null ? "" : organization?.name!)!,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
              padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
              child: Row(
                children: <Widget>[
                  const Padding(
                    padding: EdgeInsets.fromLTRB(4, 0, 16, 0),
                    child: Icon(
                      Icons.enhanced_encryption,
                      color: Colors.grey,
                    ),
                  ),
                  Expanded(
                    child: Container(
                      decoration: const BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: Colors.grey),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
                        child: Text(
                          organization == null ? "" : organization!.documentId!,
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ),
                ],
              )),
          code != null
              ? Padding(
                  padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
                  child: Row(
                    children: <Widget>[
                      const Padding(
                        padding: EdgeInsets.fromLTRB(4, 0, 16, 0),
                        child: Icon(
                          Icons.code,
                          color: Colors.grey,
                        ),
                      ),
                      Expanded(
                        child: Container(
                          decoration: const BoxDecoration(
                            border: Border(
                              bottom: BorderSide(color: Colors.grey),
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
                            child: Text(
                              code ?? '',
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : const Row(children: <Widget>[])
        ],
      ),
    );
  }

  /// Displays the primary button.
  Widget showPrimaryButton() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(30.0, 45.0, 30.0, 10.0),
      child: SizedBox(
        height: 40.0,
        child: MaterialButton(
          elevation: 5.0,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
          color: Colors.teal,
          child: const Text('Scan QR',
              style: TextStyle(fontSize: 17.0, color: Colors.white)),
          onPressed: () async {
            scanQR();
          },
        ),
      ),
    );
  }

  /// Scans the QR code.
  Future<void> scanQR() async {
    String barcodeScanRes;
    try {
      barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
          "#ff6666", "Cancel", false, ScanMode.QR);
      debugPrint(barcodeScanRes);
    } on PlatformException {
      barcodeScanRes = 'Failed to get platform version.';
    }
    setState(() {
      isEditOrg = false;
    });
    if (!mounted) return;
    debugPrint("Scanned URL $barcodeScanRes");
    if (barcodeScanRes != "-1" && barcodeScanRes.isNotEmpty) {
      String result;
      result = barcodeScanRes;
      result = result.replaceAll("FETOSENSE:", "");
      result = result.replaceAll("fetosense:", "");

      String decoded = utf8.decode(base64.decode(result));

      debugPrint('decoded id is $decoded');
      updateOrg(decoded);
    }
  }

  /// Updates the organization details based on the scanned QR code.
  Future<void> updateOrg(String code) async {
    //String cameraScanResult = code ;//await scanner.scanPhoto();
    if (code.isEmpty) {
      setState(() {
        isEditOrg = false;
      });
      return;
    }

    if (code.contains("CMFETO")) {
      getDevice(code);
    } else {
      setState(() {
        isEditOrg = false;
      });
      Fluttertoast.showToast(
          msg: 'Invalid code', toastLength: Toast.LENGTH_LONG);
    }
  }

  /// Retrieves the device details from the database using the scanned code.
  Future<void> getDevice(String key) async {
    debugPrint('device code --> $key');
    try {
      // 1. Query devices where deviceCode == key
      final result = await databases.listDocuments(
        databaseId: AppConstants.appwriteDatabaseId,
        collectionId: AppConstants.deviceCollectionId,
        queries: [
          Query.equal('deviceCode', key),
        ],
      );

      if (result.documents.isNotEmpty) {
        final deviceDoc = result.documents.first;
        final deviceData = deviceDoc.data;

        debugPrint('getDevice - ${deviceData["deviceCode"]}');

        final Map<String, dynamic> updateData = {
          "organizationId": deviceData["organizationId"],
          "organizationName": deviceData["hospitalName"],
        };

        // 2. Update user document
        await databases.updateDocument(
          databaseId: AppConstants.appwriteDatabaseId,
          collectionId: AppConstants.userCollectionId,
          documentId: doctor.documentId!,
          data: updateData,
        );

        context.pushReplacement(AppRoutes.home);
        setState(() {
          code = deviceData["deviceCode"];
        });
      } else {
        debugPrint("No device found with code: $key");
        showSnackbar("No device found with this code.");
      }
    } catch (e) {
      debugPrint("Appwrite error in getDevice: $e");
      showSnackbar("Something went wrong while fetching the device.");
    }
  }

  /// Displays a snackbar with the given message.
  void showSnackbar(message) {
    final snackBar = SnackBar(
      content: Text(message),
      duration: const Duration(milliseconds: 3000),
    );
    ScaffoldMessenger.of(_scaffoldKey.currentState!.context)
        .showSnackBar(snackBar);
  }
}
