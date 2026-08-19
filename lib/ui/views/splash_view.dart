import 'package:fetosense_remote_flutter/app_router.dart';
import 'package:fetosense_remote_flutter/core/model/doctor_model.dart';
import 'package:fetosense_remote_flutter/core/services/authentication.dart';
import 'package:fetosense_remote_flutter/core/utils/preferences.dart';
import 'package:fetosense_remote_flutter/locater.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<StatefulWidget> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  final prefs = locator<PreferenceHelper>();
  final auth = locator<BaseAuth>();

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 2)).then((onValue) {
      _initialize();
    });
  }

  Future<void> _initialize() async {
    if (prefs.getAutoLogin()) {
      _handleAutoLogin();
    } else {
      if(mounted){
        context.goNamed(AppRoutes.login);
      }
    }
  }

  Future<void> _handleAutoLogin() async {
    try {
      Doctor? doctor = prefs.getDoctor();
      debugPrint("Splash: ${doctor?.documentId}");
      if (mounted) {
        context.goNamed(AppRoutes.home, extra: doctor);
      }
    } catch (e) {
      if (mounted) {
        context.goNamed(AppRoutes.login);
      }
      debugPrint("Auto-login failed: $e");
    }
  }

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
