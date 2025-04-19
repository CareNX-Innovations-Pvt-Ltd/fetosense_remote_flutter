import 'dart:io' show Platform;

import 'package:fetosense_remote_flutter/app_router.dart';
import 'package:fetosense_remote_flutter/core/model/doctor_model.dart';
import 'package:fetosense_remote_flutter/core/services/authentication.dart';
import 'package:fetosense_remote_flutter/core/utils/preferences.dart';
import 'package:fetosense_remote_flutter/core/view_models/crud_view_model.dart';
import 'package:fetosense_remote_flutter/locater.dart';
import 'package:fetosense_remote_flutter/ui/views/login_view.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'android_tv/tv_home.dart';
import 'home.dart';
import 'initial_profile_update1.dart';
import 'initial_profile_update2.dart';
import 'package:device_info/device_info.dart';
import 'package:preferences/preferences.dart';

/// A StatefulWidget that represents the splash view of the application.
/// It handles the authentication state and navigates to the appropriate screen.
class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<StatefulWidget> createState() => _SplashViewState();
}

/// Enum representing the different authentication statuses.
enum AuthStatus {
  notDetermined,
  emailLogin,
  loggedIn,
  notLoggedIn,
  profileUpdate1,
  profileUpdate2
}

class _SplashViewState extends State<SplashView> {
  final prefs = locator<PreferenceHelper>();
  final auth = locator<BaseAuth>();
  String _userId = '';
  String? _emailId;
  Doctor? doctor;
  bool _isAndroidTv = false;
  AuthStatus authStatus = AuthStatus.emailLogin;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    await _detectDeviceType();

    if (prefs.getAutoLogin()) {
      context.goNamed(AppRoutes.home);
      _handleAutoLogin();
    } else {
      debugPrint("Auto-login disabled");
    }
  }

  Future<void> _detectDeviceType() async {
    if (!kIsWeb && Platform.isAndroid) {
      final info = await DeviceInfoPlugin().androidInfo;
      _isAndroidTv = info.systemFeatures.contains('android.software.leanback');
    }

    await PrefService.setBool('isAndroidTv', _isAndroidTv);
    debugPrint("Is Android TV: $_isAndroidTv");
  }

  Future<void> _handleAutoLogin() async {
    try {
      final user = await auth.getCurrentUser();
      debugPrint("User: ${user.email}");
      setState(() {
        _userId = user.$id;
        _emailId = user.email;
        authStatus = AuthStatus.loggedIn;
      });
    } catch (e) {
      debugPrint("Auto-login failed: $e");
      setState(() => authStatus = AuthStatus.notLoggedIn);
    }
  }


  void _navigateToHome() {
    if (_isAndroidTv) {
      Navigator.pushReplacement(context, MaterialPageRoute(
        builder: (_) => TVHome(
          doctor: doctor,
          auth: auth,
          logoutCallback: _logoutCallback,
          profileupdate1Callback: _profileUpdate1Callback,
        ),
      ));
    } else {
      Navigator.pushReplacement(context, MaterialPageRoute(
        builder: (_) => Home(doctor: doctor),
      ));
    }
  }

  void _getDoctorByEmail() {
    final userProvider = Provider.of<CRUDModel>(context, listen: false);
    userProvider.fetchDoctorByEmailId(_emailId!).listen((doctors) {
      if (doctors.isNotEmpty) {
        setState(() {
          doctor = doctors.first;
          authStatus = AuthStatus.loggedIn;
        });
      } else {
        debugPrint("No doctor found");
        setState(() => authStatus = AuthStatus.notLoggedIn);
      }
    }, onError: (e) {
      debugPrint("Fetch error: $e");
      setState(() => authStatus = AuthStatus.notLoggedIn);
    });
  }

  void _logoutCallback() {
    debugPrint("Logout triggered");
    setState(() {
      _emailId = null;
      doctor = null;
      authStatus = AuthStatus.notLoggedIn;
    });
    auth.signOut();
  }


  void _profileUpdate1Callback() =>
      setState(() => authStatus = AuthStatus.profileUpdate1);


  Widget _buildWaitingScreen() {
    return Scaffold(
      body: Center(
        child: Image.asset('images/ic_banner.png'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    switch (authStatus) {
      case AuthStatus.notDetermined:
        return _buildWaitingScreen();

      case AuthStatus.notLoggedIn:
      case AuthStatus.emailLogin:
        return LoginView();

      case AuthStatus.profileUpdate1:
        return InitialProfileUpdate(doctor: doctor);

      case AuthStatus.profileUpdate2:
        return InitialProfileUpdate2(doctor: doctor);

      case AuthStatus.loggedIn:
        if (_userId.isNotEmpty) {
          if (doctor == null) {
            _getDoctorByEmail();
            return _buildWaitingScreen();
          }
          return _isAndroidTv
              ? TVHome(
            doctor: doctor,
            auth: auth,
            logoutCallback: _logoutCallback,
            profileupdate1Callback: _profileUpdate1Callback,
          )
              : Home(doctor: doctor);
        }
        return _buildWaitingScreen();

      default:
        return LoginView();
    }
  }
}

