import 'dart:async';
import 'package:appwrite/appwrite.dart';
import 'package:fetosense_remote_flutter/app_router.dart';
import 'package:fetosense_remote_flutter/core/model/doctor_model.dart';
import 'package:fetosense_remote_flutter/core/model/organization_model.dart';
import 'package:fetosense_remote_flutter/core/network/appwrite_config.dart';
import 'package:fetosense_remote_flutter/core/services/authentication.dart';
import 'package:fetosense_remote_flutter/core/utils/app_constants.dart';
import 'package:fetosense_remote_flutter/core/utils/preferences.dart';
import 'package:fetosense_remote_flutter/ui/views/recent_test_list_view_baby_beat.dart';
import 'package:fetosense_remote_flutter/ui/views/search_view.dart';
import 'package:fetosense_remote_flutter/ui/views/profile_view.dart';
import 'package:fetosense_remote_flutter/ui/views/recent_test_list_view.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart' as p;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:upgrader/upgrader.dart';

import '../../locater.dart';

/// A stateful widget that represents the Home view of the application.
/// This view displays different sections of the app based on the selected tab.
class Home extends StatefulWidget {
  final Doctor? doctor;

  const Home({
    super.key,
    this.doctor,
  });

  @override
  HomeState createState() => HomeState();
}

class HomeState extends State<Home> {
  int _page = 0;
  final GlobalKey _bottomNavigationKey = GlobalKey();
  Organization? organization;
  Organization? organizationBabyBeat;
  late Map<p.Permission, p.PermissionStatus> permissions;
  final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  final databases = Databases(locator<AppwriteService>().client);
  BaseAuth auth = locator<BaseAuth>();
  Doctor doctor = Doctor();
  static const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'com.carenx.fetosense.channel', // id
    'Fetosense', // title
    importance: Importance.high,
    enableVibration: true,
    playSound: true,
  );
  final prefs = locator<PreferenceHelper>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: SafeArea(
        child: CurvedNavigationBar(
          key: _bottomNavigationKey,
          index: _page,
          items: <Widget>[
            Image.asset(
              "assets/feto_icon.png",
              width: 35,
            ),
            Image.asset(
              "assets/bb_icon.png",
              width: 25,
            ),
            const Icon(Icons.search, size: 30, color: Colors.white),
            const Icon(Icons.perm_identity, size: 30, color: Colors.white),
          ],
          color: Colors.teal,
          buttonBackgroundColor: Colors.black87,
          backgroundColor: Colors.white,
          animationCurve: Curves.easeInOut,
          animationDuration: const Duration(milliseconds: 600),
          onTap: (index) {
            setState(() {
              _page = index;
            });
          },
        ),
      ),
      body: UpgradeAlert(
        child: Container(
          margin: const EdgeInsets.only(bottom: 20),
          child: PopScope(
            canPop: false,
            onPopInvokedWithResult: (didPop, result) {
              if (!didPop) {
                onPop(context);
              }
            },
            child: setUpBottomNavigation(_page),
          ),
        ),
      ),
    );
  }

  /// Sets up the bottom navigation based on the current index.
  Widget setUpBottomNavigation(int currentIndex) {
    switch (currentIndex) {
      case 0:
        return RecentTestListView(doctor: doctor, organization: organization);
      case 1:
        return RecentTestListViewBabyBeat(
            doctor: doctor, organization: organizationBabyBeat);
      case 2:
        return SearchView(doctor: doctor, organization: organization);
      case 3:
        return ProfileView(
          doctor: doctor,
          organization: organization,
          organizationBabyBeat: organizationBabyBeat,
          // orgCallbackBabyBeat: setOrganizationBabyBeat,
        );
      default:
        return RecentTestListView(doctor: doctor, organization: organization);
    }
  }

  @override
  void initState() {
    doctor = (widget.doctor)!;
    if (doctor.organizationName?.isEmpty ?? true) {
      debugPrint('doctor in home ---------> ${doctor.documentId}');
      debugPrint('doctor in home ---------> ${doctor.email}');
      if (mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          context.push(AppRoutes.initProfileUpdate2, extra: doctor);
        });
      }
    }
    if (!kIsWeb) getPermission();
    if (doctor.organizationId?.isNotEmpty == true) {
      getOrganization();
    }
    if (doctor.organizationNameBabyBeat?.isNotEmpty == true) {
      getOrganizationBabyBeat();
    }
    super.initState();
  }

  /// Requests necessary permissions.
  Future<bool> getPermission() async {
    permissions = await [
      p.Permission.storage,
    ].request();
    if (permissions[p.Permission.storage] == p.PermissionStatus.granted) {
      return true;
    } else {
      return false;
    }
  }

  /// Retrieves the organization details.
  void getOrganization() async {
    debugPrint('inside org --> ${doctor.organizationId!}');
    try {
      final document = await databases.getDocument(
        databaseId: AppConstants.appwriteDatabaseId,
        collectionId: AppConstants.userCollectionId,
        documentId: doctor.documentId!,
      );

      debugPrint(document.$id);
      setState(() {
        organization = Organization.fromMap(document.data, );
      });
    } catch (e) {
      debugPrint('Error fetching organization: $e');
    }
  }

  /// Retrieves the BabyBeat organization details.
  void getOrganizationBabyBeat() async {
    try {
      final document = await databases.getDocument(
        databaseId: AppConstants.appwriteDatabaseId,
        collectionId: AppConstants.userCollectionId,
        documentId: doctor.organizationNameBabyBeat!,
      );

      debugPrint(document.$id);
      setState(() {
        organizationBabyBeat =
            Organization.fromMap(document.data, );
      });
    } catch (e) {
      debugPrint('Error fetching organizationBabyBeat: $e');
    }
  }

  /// Sets the organization.
  void setOrganization(Organization org) {
    setState(() {
      organization = org;
    });
  }

  /// Sets the BabyBeat organization.
  void setOrganizationBabyBeat(Organization org) {
    setState(() {
      organizationBabyBeat = org;
    });
  }

  /// Handles the back button press.
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
