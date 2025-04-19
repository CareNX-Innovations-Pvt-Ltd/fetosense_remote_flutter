import 'package:fetosense_remote_flutter/core/model/doctor_model.dart';
import 'package:fetosense_remote_flutter/core/model/organization_model.dart';
import 'package:fetosense_remote_flutter/core/services/authentication.dart';
import 'package:flutter/material.dart';
import 'package:preferences/preferences.dart';


/// A StatefulWidget that represents the settings view of the application.
/// It includes various settings options for the user to configure.
class SettingsView extends StatefulWidget {
  final Doctor? doctor;
  final Organization? organization;
  final BaseAuth? auth;
  final VoidCallback? logoutCallback;
  final VoidCallback? profileUpdate1Callback;
  // final VoidCallback? profileUpdate2Callback;

  /// [doctor] - The doctor object.
  /// [organization] - The organization object.
  /// [auth] - The authentication service.
  /// [logoutCallback] - Callback function for logout.
  /// [profileUpdate1Callback] - Callback function for profile update 1.
  /// [profileUpdate2Callback] - Callback function for profile update 2.
  const SettingsView(
      {super.key, this.doctor,
      this.organization,
      this.auth,
      this.logoutCallback,
      this.profileUpdate1Callback,
      // this.profileUpdate2Callback
      });

  @override
  SettingsPageState createState() => SettingsPageState();
}

class SettingsPageState extends State<SettingsView> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                leading: IconButton(
                    iconSize: 35,
                    icon: const Icon(Icons.arrow_back, size: 30, color: Colors.teal),
                    onPressed: () {
                      Navigator.pop(context);
                    }),
                subtitle: const Text(
                  "Settings",
                  style: TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: 20,
                      color: Colors.black87),
                ),
                title: GestureDetector(
                  onTap: () {
                    widget.logoutCallback!();
                  },
                  child: const Text(
                    "fetosense",
                    style: TextStyle(
                        fontWeight: FontWeight.w300,
                        fontSize: 14,
                        color: Colors.black87),
                  ),
                ),
                trailing: Image.asset('images/ic_logo_good.png'),
              ),
            ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                child: PreferencePage(
                  [
                    PreferenceTitle('Printing',
                        style: const TextStyle(
                            fontWeight: FontWeight.w500, fontSize: 18)),
                    const Padding(
                        padding: EdgeInsets.only(left: 14),
                        child: Text(
                          "The settings apply only to NST tests less than 60 min.",
                          style: TextStyle(color: Colors.teal),
                        )),
                    PrefService.getBool('isAndroidTv') ?? false
                        ? Container()
                        : DropdownPreference(
                            'Default print scale',
                            'scale',
                            defaultVal: 1,
                            displayValues: const [
                              '1 cm/min',
                              '3 cm/min',
                            ],
                            values: const [1, 3],
                          ),
                    SwitchPreference(
                      'Doctor\'s Comment',
                      'comments',
                      defaultVal: false,
                      desc: 'This option will print comments by doctor',
                      switchActiveColor: Colors.teal,
                    ),
                    SwitchPreference(
                      'Auto Interpretations',
                      'interpretations',
                      defaultVal: false,
                      switchActiveColor: Colors.teal,
                      onChange: () {
                        setState(() {});
                      },
                      desc: 'Interpretations will be printed if on',
                    ),
                    PrefService.getBool('isAndroidTv') ?? false
                        ? DropdownPreference(
                            'Default Live scale',
                            'gridPreMin',
                            defaultVal: 1,
                            displayValues: const [
                              '1 cm/min',
                              '3 cm/min',
                            ],
                            values: const [1, 3],
                          )
                        : Container(),
                    PreferenceHider([
                      SwitchPreference(
                        'Highlight patterns',
                        'highlight',
                        defaultVal: false,
                        switchActiveColor: Colors.teal,
                        desc:
                            'Identified patterns such as accelerations decelerations will be highlighted on the print. We recommend to use color printer for this feature',
                      ),
                    ], '!interpretations'),
                    // Use ! to get reversed boolean values
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
