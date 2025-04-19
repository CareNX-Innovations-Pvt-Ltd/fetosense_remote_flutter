import 'package:fetosense_remote_flutter/app_router.dart';
import 'package:fetosense_remote_flutter/core/utils/preferences.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'core/view_models/crud_view_model.dart';
import 'core/view_models/notification_crud_model.dart';
import 'core/view_models/test_crud_model.dart';
import 'locater.dart';
import 'package:preferences/preferences.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await PrefService.init(prefix: 'pref_');
  PrefService.setDefaultValues({'user_description': 'This is my description!'}) ;
  PreferenceHelper.init();
  setupLocator();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => locator<CRUDModel>()),
        ChangeNotifierProvider(create: (_) => locator<TestCRUDModel>()),
        ChangeNotifierProvider(create: (_) => locator<NotificationCRUDModel>())
      ],
      child: Shortcuts(
        shortcuts: <LogicalKeySet, Intent>{
          LogicalKeySet(LogicalKeyboardKey.select): const ActivateIntent(),
        },
        child: ScreenUtilInit(
          designSize: kIsWeb ?const Size(1440, 1024):const Size(390, 844),
          minTextAdapt: true,
          splitScreenMode: true,
          child: MaterialApp.router(
            debugShowCheckedModeBanner: false,
            title: 'Docror App',
            theme: ThemeData(
              brightness: Brightness.light,
              primaryColor: Colors.white,
              fontFamily: 'Montserrat',
              textTheme: const TextTheme(
                displayLarge : TextStyle(fontSize: 72.0, fontWeight: FontWeight.bold),
                titleLarge: TextStyle(fontSize: 36.0, fontStyle: FontStyle.italic),
                bodyLarge: TextStyle(fontSize: 14.0, fontFamily: 'Hind'),
              ),
              appBarTheme: const AppBarTheme(
                  iconTheme: IconThemeData(color: Colors.teal),
                  color: Colors.teal,
                  //foregroundColor: const LightScheme().primary,
                  systemOverlayStyle: SystemUiOverlayStyle(
                    systemNavigationBarColor: Color(0XFF0A0E28),
                    systemNavigationBarDividerColor: Color(0XFF000749),
                    systemNavigationBarIconBrightness: Brightness.light,
                    statusBarBrightness: Brightness.dark,
                    statusBarIconBrightness: Brightness.light,
                  )),
              inputDecorationTheme: const InputDecorationTheme(
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.green),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue),
                ),
                disabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                ),
                errorBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.red),
                ),
              ),
            ),
            routerConfig: AppRouter.router,
          ),
        ),
      ),
    );
  }
}
