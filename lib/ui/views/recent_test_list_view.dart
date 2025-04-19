import 'dart:convert';

import 'package:appwrite/appwrite.dart';
import 'package:fetosense_remote_flutter/core/model/doctor_model.dart';
import 'package:fetosense_remote_flutter/core/model/organization_model.dart';
import 'package:fetosense_remote_flutter/core/model/test_model.dart';
import 'package:fetosense_remote_flutter/core/model/user_model.dart';
import 'package:fetosense_remote_flutter/core/network/appwrite_config.dart';
import 'package:fetosense_remote_flutter/core/utils/app_constants.dart';
import 'package:fetosense_remote_flutter/core/view_models/test_crud_model.dart';
import 'package:fetosense_remote_flutter/locater.dart';
import 'package:fetosense_remote_flutter/ui/shared/constant.dart';
import 'package:fetosense_remote_flutter/ui/widgets/allTestCard.dart';
import 'package:fetosense_remote_flutter/ui/widgets/scanWidget.dart';
import 'package:fetosense_remote_flutter/ui/widgets/youtube_player_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:provider/provider.dart';

import 'package:fluttertoast/fluttertoast.dart';

import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// A StatefulWidget that displays a list of recent tests for a doctor.
///
/// This widget shows a list of recent tests associated with the doctor's organization.
class RecentTestListView extends StatefulWidget {
  final Doctor? doctor;

  final Function(Organization?)? orgCallback;
  final Organization? organization;

  /// [doctor] is the doctor model containing the details to be displayed.
  /// [organization] is the organization model.
  const RecentTestListView(
      {super.key, this.doctor, this.organization, this.orgCallback});

  @override
  RecentTestListViewState createState() => RecentTestListViewState();
}

class RecentTestListViewState extends State<RecentTestListView> {
  late List<Test> tests;

  bool isEdit = false;
  bool isEditOrg = false;
  Organization? organization;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String? code;
  final databases = Databases(locator<AppwriteService>().client);
  Doctor  doctor = Doctor();
  Map<String, dynamic>? passKeys = {};

  final TextEditingController _passkeyController = TextEditingController();

  @override
  void initState() {
    super.initState();
    getPaasKeys();
    doctor = widget.doctor ?? Doctor();
  }

  /// Fetches the pass keys from Firestore.
  Future<void> getPaasKeys() async {
    try {
      final document = await databases.getDocument(
          databaseId: AppConstants.appwriteDatabaseId,
          collectionId: AppConstants.configCollectionId,
          documentId: 'PassKeys',
          queries: []);

      if (mounted) {
        setState(() {
          passKeys = Map<String, dynamic>.from(document.data);
        });
      }
    } on AppwriteException catch (e) {
      debugPrint("Error fetching PassKeys: ${e.message}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Container(
              margin: const EdgeInsets.symmetric(vertical: 5),
              decoration: const BoxDecoration(
                border:
                    Border(bottom: BorderSide(width: 0.5, color: Colors.grey)),
              ),
              child: ListTile(
                subtitle: const Text(
                  "Recent Tests",
                  style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 20,
                      color: Colors.black87),
                ),
                title: const Text(
                  "Fetosense",
                  style: TextStyle(
                      fontWeight: FontWeight.w300,
                      fontSize: 14,
                      color: Colors.black87),
                ),
                trailing: Image.asset('images/ic_logo_good.png'),
              ),
            ),
            doctor.organizationId?.isNotEmpty == true
                ? Expanded(
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(10, 0, 8, 8),
                      child: StreamBuilder(
                        stream: Provider.of<TestCRUDModel>(context)
                            .fetchAllTestsAsStream(
                                doctor.organizationId),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            tests = snapshot.data!;

                            return tests.isEmpty
                                ? const Center(
                                    child: Text(
                                      'No test yet',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w800,
                                        color: Colors.grey,
                                        fontSize: 20,
                                      ),
                                    ),
                                  )
                                : ListView.builder(
                                    itemCount: tests.length,
                                    shrinkWrap: true, // use this
                                    itemBuilder: (buildContext, index) =>
                                        AllTestCard(
                                      testDetails: tests[index],
                                    ),
                                  );
                          } else {
                            return const Center(
                              child: CircularProgressIndicator(
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.black),
                              ),
                            );
                          }
                        },
                      ),
                    ),
                  )
                : Expanded(
                    child: SingleChildScrollView(
                    child: Column(
                      children: [
                        const SizedBox(
                          height: 20,
                        ),
                        const Padding(
                          padding: EdgeInsets.only(left: 16),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              "Welcome back,",
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 16),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              "Dr. ${doctor.name}",
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: Colors.teal,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 16, right: 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  "To get started, scan your \n FETOSENSE QR Code",
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              !isEditOrg
                                  ? MaterialButton(
                                      elevation: 2,
                                      color: Colors.teal,
                                      textColor: Colors.white,
                                      highlightElevation: 2,
                                      onPressed: () async {
                                        setState(() {
                                          isEditOrg = true;
                                          // scanQR();
                                        });
                                        var result = await Navigator.push(
                                          context,
                                          CupertinoPageRoute(
                                            builder: (context) => ScanWidget(),
                                          ),
                                        );

                                        // debugPrint("Result : " + result.toString());

                                        if (result != null &&
                                            result != 'Unknown') {
                                          scanQR(result);
                                        } else {
                                          setState(() {
                                            isEditOrg = false;
                                            // scanQR();
                                          });
                                        }
                                      },
                                      child: const Text(
                                        'Scan QR',
                                        style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600),
                                      ),
                                    )
                                  : IconButton(
                                      iconSize: 35,
                                      icon: const CircularProgressIndicator(
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                                Colors.black),
                                      ),
                                      onPressed: () {},
                                    ),
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        Container(
                          margin: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey[400]!,
                                  blurRadius: 5.0,
                                ),
                              ]),
                          child: Column(
                            children: [
                              FeedsYoutube("QuiCSDtXoIc"),
                              Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      flex: 4,
                                      child: Align(
                                        alignment: Alignment.centerLeft,
                                        child: Text(
                                          "Explore India’s Most Advanced Wireless Fetal Monitoring Machine. For Demo, Call: +91 9326775598 or WhatsApp",
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                            color: greyRegular,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 8,
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: GestureDetector(
                                        onTap: () {
                                          String text = "";
                                          if (doctor.mobileNo != null) {
                                            text =
                                                "Hello\nI am ${doctor.name} and my mobile no is ${doctor.mobileNo}.\nI Need demo for fetosense.";
                                          } else {
                                            text =
                                                "Hello\nI am ${doctor.name} and my mobile no is ${doctor.email}.\nI Need demo for fetosense.";
                                          }

                                          String phone = "919326775598";
                                          //if(Platform.isIOS){
                                          String url =
                                              "whatsapp://send?phone=$phone&text=$text";
                                          String urlOk = url
                                              .split(' ')
                                              .join('%20')
                                              .toString();
                                          urlOk = urlOk
                                              .split('\n')
                                              .join('%0A')
                                              .toString();

                                          debugPrint(urlOk);
                                          launchUrl(
                                            Uri.parse(urlOk),
                                          );
                                        },
                                        child: Align(
                                          alignment: Alignment.bottomCenter,
                                          child: Container(
                                            padding: const EdgeInsets.all(12),
                                            decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: Colors.white,
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.grey[400]!,
                                                    blurRadius: 5.0,
                                                  ),
                                                ]),
                                            child: const FaIcon(
                                              FontAwesomeIcons.whatsapp,
                                              color: Colors.teal,
                                              size: 30,
                                            ),
                                          ),
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ))
          ],
        ),
      ),
    );
  }

  /// Scans the QR code and updates the organization.
  ///
  /// [barcodeScanRes] is the result of the QR code scan.
  Future<void> scanQR(String barcodeScanRes) async {
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
      try {
        String result;
        result = barcodeScanRes;
        result = result.replaceAll("FETOSENSE:", "");
        result = result.replaceAll("fetosense:", "");

        String decoded = utf8.decode(base64.decode(result));

        debugPrint('decoded id is $decoded');
        updateOrg(decoded);
      } on FormatException {
        ScaffoldMessenger.of(_scaffoldKey.currentState!.context)
            .showSnackBar(const SnackBar(
          content: Text('Invalid QR CODE'),
        ));
      }
    }
  }

  /// Updates the organization based on the scanned code.
  ///
  /// [code] is the scanned code.
  Future<void> updateOrg(String code) async {
    //String cameraScanResult = code ;//await scanner.scanPhoto();
    if (code.isEmpty) {
      setState(() {
        isEditOrg = false;
      });
      return;
    }

    if (code.contains("CMFETO")) {
      //cameraScanResult = cameraScanResult.replaceAll("FETOSENSE:", "");
      //String result = utf8.decode(base64.decode(cameraScanResult));
      getDevice(code);
    } else {
      setState(() {
        isEditOrg = false;
      });
      Fluttertoast.showToast(
          msg: 'Invalid code', toastLength: Toast.LENGTH_LONG);
    }
  }

  /// Fetches the device details based on the scanned code.
  ///
  /// [key] is the scanned code.
  Future<void> getDevice(String key) async {
    try {
      final response = await databases.listDocuments(
        databaseId: AppConstants.appwriteDatabaseId,
        collectionId: AppConstants.deviceCollectionId,
        queries: [
          Query.equal('type', 'device'),
          Query.equal('deviceCode', key),
        ],
      );

      if (response.documents.isNotEmpty) {
        final deviceDoc = response.documents.first;
        final data = deviceDoc.data;

        final organizationId = data['organizationId'];
        final hospitalName = data['hospitalName'];
        final deviceCode = data['deviceCode'];

        debugPrint('getDevice - $deviceCode');
        getOrganization(organizationId);

        _enterMPIDBottomSheet(organizationId, hospitalName);

        setState(() {
          code = deviceCode;
        });
      } else {
        debugPrint("No device found for code: $key");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Device not found."),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      debugPrint("Error fetching device: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Something went wrong while fetching the device."),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  /// Displays a modal bottom sheet to enter the passkey.
  ///
  /// [hospitalid] is the hospital ID.
  /// [hospitalName] is the hospital name.
  void _enterMPIDBottomSheet(String? hospitalid, String? hospitalName) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) =>
          StatefulBuilder(builder: (context, StateSetter state) {
        return Wrap(
          children: <Widget>[
            Container(
              padding: const EdgeInsets.only(top: 12),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(50),
                  topLeft: Radius.circular(50),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  SizedBox(
                      width: MediaQuery.of(context).size.width * 0.13,
                      child: Divider(
                        thickness: 2,
                        color: greyRegular,
                      )),
                  Container(
                    margin: const EdgeInsets.only(
                      top: 20,
                      left: 25,
                      right: 25,
                    ),
                    child: const Text(
                      "Your Hospital name is :",
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(
                      top: 5,
                      left: 25,
                      right: 25,
                    ),
                    child: Text(
                      hospitalName!,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.width * 0.10,
                  ),
                  const Text(
                    "Please enter your passkey to continue",
                    textAlign: TextAlign.left,
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                        bottom: MediaQuery.of(context).viewInsets.bottom),
                    child: Container(
                      margin: const EdgeInsets.only(
                          top: 20, left: 25, right: 25, bottom: 30),
                      child: TextFormField(
                        controller: _passkeyController,
                        keyboardType: TextInputType.text,
                        autofocus: false,
                        onFieldSubmitted: (text) {
                          setState(() {
                            debugPrint("onFieldSubmitted $text");
                          });
                        },
                        onChanged: (txt) {
                          // setState(() {
                          //   _isMobileValidationError = false;
                          //   _isOtpVisible = false;
                          //   _otpController.text = '';
                          // });
                        },
                        maxLength: 20,
                        maxLines: 1,
                        decoration: InputDecoration(
                            // labelText: 'Phone Number',

                            counterStyle: const TextStyle(
                              height: double.minPositive,
                            ),
                            counterText: "",
                            hintText: "Enter Pass Key",
                            fillColor: lightTealColor,
                            filled: true,
                            //  floatingLabelBehavior: FloatingLabelBehavior.always,

                            // errorStyle: TextStyle(
                            //   color: Colors.transparent,
                            //   fontSize: 0,
                            // ),
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 10.0, horizontal: 20.0),
                            errorText: null,
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: greenColor),
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: greenColor),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: greenColor),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(color: greenColor),
                            )),
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      color: themeColor,
                      child: MaterialButton(
                        padding: const EdgeInsets.all(20),
                        onPressed: () async {
                          if (_passkeyController.text.trim() ==
                              passKeys!['fetosense']) {
                            try {
                              await databases.updateDocument(
                                databaseId: AppConstants.appwriteDatabaseId,
                                collectionId: AppConstants.userCollectionId,
                                documentId: doctor.documentId!,
                                data: {
                                  'organizationId': hospitalid,
                                  'organizationName': hospitalName,
                                },
                              );

                              debugPrint(
                                  "Organization assigned to doctor successfully.");
                              getOrganization("$hospitalid");
                              Navigator.pop(context);
                            } catch (error) {
                              debugPrint("Appwrite error: $error");
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Something went wrong!'),
                                  behavior: SnackBarBehavior.floating,
                                  duration: Duration(milliseconds: 3000),
                                ),
                              );
                            }
                          } else {
                            ScaffoldMessenger.of(
                                    _scaffoldKey.currentState!.context)
                                .showSnackBar(
                              const SnackBar(
                                content: Text('Invalid Pass Key!'),
                                behavior: SnackBarBehavior.floating,
                                duration: Duration(milliseconds: 3000),
                              ),
                            );
                            Navigator.pop(context);
                          }
                        },
                        color: greenColor,
                        elevation: 0,
                        child: const Text(
                          'OK',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ],
        );
      }),
    );
  }

  /// Fetches the organization details based on the organization ID.
  ///
  /// [id] is the organization ID.
  void getOrganization(String id) async {
    try {
      final document = await databases.getDocument(
        databaseId: AppConstants.appwriteDatabaseId,
        collectionId: AppConstants.userCollectionId,
        documentId: id,
      );

      if (document.data.isNotEmpty) {
        setState(() {
          organization = Organization.fromMap(
            document.data,
            // document.$id,
          );
          organization!.deviceCode = id;
          isEditOrg = false;
        });

        if (widget.orgCallback != null) {
          widget.orgCallback!(organization);
        }

        setDeviceAssociations(document.$id);
      } else {
        setState(() => isEditOrg = false);
        Fluttertoast.showToast(
          msg: 'No organization found',
          toastLength: Toast.LENGTH_LONG,
        );
      }
    } catch (e) {
      setState(() => isEditOrg = false);
      debugPrint('getOrganization error: $e');
      Fluttertoast.showToast(
        msg: 'Something went wrong fetching the organization',
        toastLength: Toast.LENGTH_LONG,
      );
    }
  }

  /// Sets the device associations for the organization.
  ///
  /// [orgId] is the organization ID.
  Future<void> setDeviceAssociations(String orgId) async {
    try {
      // Fetch all devices for the given organization
      final response = await databases.listDocuments(
        databaseId: AppConstants.appwriteDatabaseId,
        collectionId: AppConstants.userCollectionId,
        queries: [
          Query.equal('type', 'device'),
          Query.equal('organizationId', orgId),
        ],
      );

      final devices = response.documents
          .map((doc) => UserModel.fromMap(doc.data, ))
          .toList();

      for (final device in devices) {
        debugPrint('getOrganization  -  ${device.documentId}');

        // Create doctor association map
        final Map<String, String?> doctorAssoc = {
          "name": doctor.name,
          "type": "doctor",
          "id": doctor.documentId,
        };

        // Ensure existing associations are preserved
        Map<String, dynamic> updatedAssociations = {};
        if (device.associations != null) {
          updatedAssociations = Map<String, dynamic>.from(device.associations!);
        }

        updatedAssociations[doctor.documentId!] = doctorAssoc;

        // Update the device user with merged associations
        await databases.updateDocument(
          databaseId: 'your_database_id',
          collectionId: 'users',
          documentId: device.documentId!,
          data: {
            'associations': updatedAssociations,
          },
        );
      }
    } catch (e) {
      debugPrint('Error in setDeviceAssociations: $e');
    }
  }
}
