import 'dart:io' show Platform;
import 'package:fetosense_remote_flutter/app_router.dart';
import 'package:fetosense_remote_flutter/core/model/doctor_model.dart';
import 'package:fetosense_remote_flutter/core/services/authentication.dart';
import 'package:fetosense_remote_flutter/core/utils/preferences.dart';
import 'package:fetosense_remote_flutter/locater.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:device_info/device_info.dart';
import 'package:preferences/preferences.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<StatefulWidget> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  final prefs = locator<PreferenceHelper>();
  final auth = locator<BaseAuth>();
  bool _isAndroidTv = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 2)).then((onValue){
      _initialize();
    });
  }

  Future<void> _initialize() async {
    await _detectDeviceType();
    if (prefs.getAutoLogin()) {
      _handleAutoLogin();
    } else {
      if(mounted){
        context.goNamed(AppRoutes.login);
      }
    }
  }

  Future<void> _detectDeviceType() async {
    if (!kIsWeb && Platform.isAndroid) {
      final info = await DeviceInfoPlugin().androidInfo;
      _isAndroidTv = info.systemFeatures.contains('android.software.leanback');
    }

    await PrefService.setBool(PreferenceHelper.isTv, _isAndroidTv);
    debugPrint("Is Android TV: $_isAndroidTv");
  }

  Future<void> _handleAutoLogin() async {
    try {
      final user = await auth.getCurrentUser();
      debugPrint("User: ${user.email}");
      Doctor? doctor = prefs.getDoctor();
      debugPrint("Splash: ${doctor?.documentId}");
      if(mounted) {
        context.goNamed(AppRoutes.home, extra:doctor);
      }
    } catch (e) {
      if(mounted) {
        context.goNamed(AppRoutes.login);
      }
      debugPrint("Auto-login failed: $e");
    }
  }


  // void _navigateToHome() {
  //   if (_isAndroidTv) {
  //     Navigator.pushReplacement(context, MaterialPageRoute(
  //       builder: (_) => TVHome(
  //         doctor: doctor,
  //       ),
  //     ));
  //   } else {
  //     Navigator.pushReplacement(context, MaterialPageRoute(
  //       builder: (_) => Home(doctor: doctor),
  //     ));
  //   }
  // }
  //
  // void _getDoctorByEmail() {
  //   final userProvider = Provider.of<CRUDModel>(context, listen: false);
  //   userProvider.fetchDoctorByEmailId(_emailId!).listen((doctors) {
  //     if (doctors.isNotEmpty) {
  //       setState(() {
  //         doctor = doctors.first;
  //         authStatus = AuthStatus.loggedIn;
  //       });
  //     } else {
  //       debugPrint("No doctor found");
  //       setState(() => authStatus = AuthStatus.notLoggedIn);
  //     }
  //   }, onError: (e) {
  //     debugPrint("Fetch error: $e");
  //     setState(() => authStatus = AuthStatus.notLoggedIn);
  //   });
  // }
  //
  // void _logoutCallback() {
  //   debugPrint("Logout triggered");
  //   setState(() {
  //     _emailId = null;
  //     doctor = null;
  //     authStatus = AuthStatus.notLoggedIn;
  //   });
  //   auth.signOut();
  // }
  //
  //
  // void _profileUpdate1Callback() =>
  //     setState(() => authStatus = AuthStatus.profileUpdate1);


  Widget _buildWaitingScreen() {
    return SafeArea(
      child: Scaffold(
        body: Center(
          child: Image.asset('images/ic_banner.png'),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
        return _buildWaitingScreen();
    }
  }

