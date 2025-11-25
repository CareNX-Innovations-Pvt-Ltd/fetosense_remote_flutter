import 'dart:convert';
import 'package:appwrite/appwrite.dart';
import 'package:fetosense_remote_flutter/app_router.dart';
import 'package:fetosense_remote_flutter/core/model/doctor_model.dart';
import 'package:fetosense_remote_flutter/core/model/organization_model.dart';
import 'package:fetosense_remote_flutter/core/network/appwrite_config.dart';
import 'package:fetosense_remote_flutter/core/utils/app_constants.dart';
import 'package:fetosense_remote_flutter/locater.dart';
import 'package:fetosense_remote_flutter/ui/widgets/scan_widget.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// A StatefulWidget that handles the initial profile update for a doctor.
class InitialProfileUpdate2 extends StatefulWidget {
  final Doctor? doctor;

  const InitialProfileUpdate2({super.key, this.doctor});

  @override
  InitialProfileUpdate2State createState() => InitialProfileUpdate2State();
}

class InitialProfileUpdate2State extends State<InitialProfileUpdate2> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final databases = Databases(locator<AppwriteService>().client);
  bool isMobileVerified = false;
  bool isEditOrg = false;
  Doctor? doctor;
  String? code;
  Organization? organization;

  @override
  void initState() {
    super.initState();

    if (widget.doctor == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.goNamed(AppRoutes.login);
      });
      return;
    }

    doctor = widget.doctor;
  }

  @override
  Widget build(BuildContext context) {
    if (doctor == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      key: _scaffoldKey,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            showLogo(),
            const SizedBox(height: 30),

            const Text(
              "Update Organization Details",
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.w500, fontSize: 20),
            ),
            const SizedBox(height: 20),

            showPrimaryButton(),
          ],
        ),
      ),
    );
  }

  Widget showLogo() {
    return Hero(
      tag: 'hero',
      child: CircleAvatar(
        radius: 140,
        backgroundColor: Colors.transparent,
        child: Image.asset('images/ic_banner.png'),
      ),
    );
  }

  Widget showPrimaryButton() {
    return SizedBox(
      height: 40,
      child: MaterialButton(
        color: Colors.teal,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        child: const Text("Scan QR", style: TextStyle(color: Colors.white)),
        onPressed: scanQR,
      ),
    );
  }

  /// Scans the QR code.
  Future<void> scanQR() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ScanWidget()),
    );

    if (!mounted) return;

    if (result == null || result == "-1") return;

    debugPrint("SCAN RESULT: $result");

    try {
      String cleaned = result.replaceAll("CMFETO:", "").replaceAll("cmfeto:", "");

      String decoded;
      try {
        decoded = utf8.decode(base64.decode(cleaned));
      } catch (_) {
        decoded = cleaned; // fallback: use raw scan result
      }

      updateOrg(decoded);
    } catch (e) {
      showSnackbar("Invalid QR Code");
    }
  }

  Future<void> updateOrg(String scannedCode) async {
    if (scannedCode.isEmpty) return;

    getDevice(scannedCode);
  }

  Future<void> getDevice(String key) async {
    try {
      final result = await databases.listDocuments(
        databaseId: AppConstants.appwriteDatabaseId,
        collectionId: AppConstants.deviceCollectionId,
        queries: [Query.equal('deviceCode', key)],
      );

      if (result.documents.isEmpty) {
        showSnackbar("No device found with this code.");
        return;
      }

      final deviceData = result.documents.first.data;

      await databases.updateDocument(
        databaseId: AppConstants.appwriteDatabaseId,
        collectionId: AppConstants.userCollectionId,
        documentId: doctor!.documentId!,
        data: {
          "organizationId": deviceData["organizationId"],
          "organizationName": deviceData["hospitalName"],
        },
      );

      doctor!.organizationId = deviceData["organizationId"];
      doctor!.organizationName = deviceData["hospitalName"];

      if (mounted) {
        context.goNamed(AppRoutes.home, extra: doctor);
      }
    } catch (e) {
      debugPrint("Error: $e");
      showSnackbar("Unable to update organization.");
    }
  }

  void showSnackbar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }
}
