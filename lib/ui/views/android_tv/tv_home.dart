import 'dart:async';

import 'package:appwrite/appwrite.dart';
import 'package:fetosense_remote_flutter/core/model/doctor_model.dart';
import 'package:fetosense_remote_flutter/core/model/organization_model.dart';
import 'package:fetosense_remote_flutter/core/network/appwrite_config.dart';
import 'package:fetosense_remote_flutter/core/utils/app_constants.dart';
import 'package:fetosense_remote_flutter/locater.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart' as p;

import 'live_tacking.dart';


/// [TVHome] is a stateful widget that represents the home screen for the TV application.
/// It displays the live tracking view and handles navigation and permissions.
class TVHome extends StatefulWidget {
  final Doctor? doctor;
  const TVHome(
      {super.key,
      this.doctor,
      });

  @override
  TVHomeState createState() => TVHomeState();
}

class TVHomeState extends State<TVHome> {
  int _page = 0;
  Organization? organization;
  int limit = 0;
  late Map<p.Permission, p.PermissionStatus> permissions;
  final databases = Databases(locator<AppwriteService>().client);
  
  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: LiveTrackingView(
      doctor: widget.doctor,
      organization: organization,
    ));
  }

  @override
  void initState() {
    getPermission();
    if (widget.doctor!.organizationId!.isNotEmpty) {
      getOrganization();
    }
    super.initState();
  }

  /// Requests storage permission from the user.
  ///
  /// Returns true if the permission is granted, false otherwise.
  Future<bool> getPermission() async {
    permissions = await [
      p.Permission.storage,
    ].request();
    /*permissions = await PermissionHandler().requestPermissions([
      Permission.storage,
    ]);
    */
    if (permissions[p.Permission.storage] == p.PermissionStatus.granted) {
      return true;
    } else {
      return false;
    }
  }

  /// Retrieves the organization data from the database and updates the state.
  void getOrganization() async {
    try {
      final document = await databases.getDocument(
        databaseId: AppConstants.appwriteDatabaseId,
        collectionId: AppConstants.userCollectionId,
        documentId: widget.doctor!.organizationId!,
      );

      debugPrint(document.$id);

      setState(() {
        organization = Organization.fromMap(
          document.data,
          // document.$id,
        );
      });
    } catch (e) {
      debugPrint("Error fetching organization: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to load organization details.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }


  /// Sets the organization data in the state.
  ///
  /// [org] is the organization data to be set.
  void setOrganization(Organization org) {
    setState(() {
      organization = org;
    });
  }


  /// Handles the back button press to navigate between pages or close the app.
  ///
  /// [context] is the build context.
  ///
  /// Returns true if the app should close, false otherwise.
  Future<bool> onPop(BuildContext context) async {
    if (_page == 0) {
      debugPrint("close App");

      return true;
    } else {
      setState(() {
        _page = 0;
      });
      return false;
    }
  }

}
