import 'package:fetosense_remote_flutter/app_router.dart';
import 'package:fetosense_remote_flutter/core/model/doctor_model.dart';
import 'package:fetosense_remote_flutter/core/model/organization_model.dart';
import 'package:fetosense_remote_flutter/core/services/authentication.dart';
import 'package:fetosense_remote_flutter/locater.dart';
import 'package:fetosense_remote_flutter/ui/views/settings_view.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:fetosense_remote_flutter/ui/views/notificationView.dart';
import 'package:fetosense_remote_flutter/ui/views/doctor_details.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// A StatefulWidget that displays the profile view for a doctor.
///
/// This widget shows the doctor's profile information, including email, name, and various options like edit profile, notifications, settings, and logout.
class ProfileView extends StatefulWidget {
  final Doctor doctor;

  final Organization? organization;

  /// [doctor] is the doctor model containing the details to be displayed.
  /// [organization] is the organization model.
  /// [organizationBabyBeat] is the organization model for BabyBeat.
  /// [orgCallbackBabyBeat] is the callback function to set the BabyBeat organization.
  /// [auth] is the authentication service.
  const ProfileView({
    super.key,
    required this.doctor,
    required this.organization,
  });

  @override
  ProfileViewState createState() => ProfileViewState();
}

class ProfileViewState extends State<ProfileView> {
  bool isMobileVerified = false;
  String versionName = "6.1.0(65)";
  BaseAuth auth = locator<BaseAuth>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          children: <Widget>[
            Container(
              margin: const EdgeInsets.symmetric(vertical: 5),
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(width: 0.5, color: Colors.teal),
                ),
              ),
              child: ListTile(
                subtitle: Row(
                  children: <Widget>[
                    Text(
                      widget.doctor.email ?? "email",
                      style: const TextStyle(
                          fontWeight: FontWeight.w300,
                          fontSize: 10,
                          color: Colors.black87),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 1),
                      child: Icon(
                        Icons.keyboard_arrow_down,
                        size: 22,
                        color: Colors.teal,
                      ),
                    )
                  ],
                ),
                title: Text(
                  widget.doctor.name ?? '',
                  style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 18,
                      color: Colors.black87),
                ),
                trailing: Image.asset('images/ic_logo_good.png'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => DoctorDetails(
                        doctor: widget.doctor,
                        org: widget.organization,
                        // setOrg: setOrganization,
                        // setOrgBabyBeat: setOrganizationBabyBeat,
                        // isMobileVerified: isMobileVerified,
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 0, 8),
              child: ListTile(
                leading: const Icon(
                  Icons.edit,
                  color: Colors.teal,
                ),
                title: const Text(
                  "Edit Profile",
                  style: TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: 16,
                      color: Colors.black87),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => DoctorDetails(
                        doctor: widget.doctor,
                        org: widget.organization,
                        // setOrg: setOrganization,
                        // setOrgBabyBeat: setOrganizationBabyBeat,
                        // isMobileVerified: isMobileVerified,
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 0, 8),
                child: ListTile(
                  leading: const Icon(
                    Icons.notifications,
                    color: Colors.teal,
                  ),
                  title: const Text(
                    "Notifications",
                    style: TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: 16,
                        color: Colors.black87),
                  ),
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) =>
                                NotificationView(doctor: widget.doctor)));
                  },
                )),
            Padding(
                padding: const EdgeInsets.fromLTRB(8, 0, 0, 8),
                child: ListTile(
                  leading: const Icon(
                    Icons.settings,
                    color: Colors.teal,
                  ),
                  title: const Text(
                    "Settings",
                    style: TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: 16,
                        color: Colors.black87),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const SettingsView(),
                      ),
                    );
                  },
                )),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 0, 0, 8),
              child: ListTile(
                leading: const Icon(
                  Icons.arrow_forward,
                  color: Colors.teal,
                ),
                title: const Text(
                  "Logout",
                  style: TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
                onTap: () {auth.signOut();
                  context.pushReplacement(AppRoutes.login);
                  },
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
              decoration: const BoxDecoration(
                border:
                    Border(bottom: BorderSide(width: 0.5, color: Colors.teal),),
              ),
              child: const SizedBox(
                height: 1,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 0, 8),
              child: ListTile(
                leading: const FaIcon(
                  FontAwesomeIcons.whatsapp,
                  color: Colors.teal,
                ),
                title: const Text(
                  "+91 93267 75598",
                  style: TextStyle(
                      fontWeight: FontWeight.w400,
                      color: Colors.black87,
                      fontSize: 16),
                ),
                onTap: () async {
                  String text =
                      "Hello\nI am ${widget.doctor.name}.\nNeed help with fetosense.";
                  String phone = "919326775598";
                  //if(Platform.isIOS){
                  String url = "whatsapp://send?phone=$phone&text=$text";
                  String urlOk = url.split(' ').join('%20').toString();
                  urlOk = urlOk.split('\n').join('%0A').toString();
                  debugPrint(urlOk);
                  launchUrl(Uri.parse(urlOk));
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 0, 0, 8),
              child: ListTile(
                leading: const Icon(
                  Icons.call,
                  color: Colors.teal,
                ),
                title: const Text(
                  "+91 93267 75598",
                  style: TextStyle(
                      fontWeight: FontWeight.w400,
                      color: Colors.black87,
                      fontSize: 16),
                ),
                onTap: () => launchUrl(Uri.parse("tel:+919326775598")),
              ),
            ),
            const Padding(
                padding: EdgeInsets.fromLTRB(8, 0, 0, 8),
                child: ListTile(
                  leading: Icon(
                    Icons.email,
                    color: Colors.teal,
                  ),
                  title: Text(
                    "support@carenx.in",
                    style: TextStyle(
                        fontWeight: FontWeight.w400,
                        color: Colors.black87,
                        fontSize: 16),
                  ),
                ),),
            Padding(
                padding: const EdgeInsets.fromLTRB(8, 0, 0, 8),
                child: ListTile(
                  leading: const Icon(
                    Icons.verified_user,
                    color: Colors.teal,
                  ),
                  title: Text(
                    //"Version 6.0.4(52)",
                    "Version $versionName",
                    style: const TextStyle(
                        fontWeight: FontWeight.w400,
                        color: Colors.black87,
                        fontSize: 16),
                  ),
                )),
            Container(
              margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
              decoration: const BoxDecoration(
                border:
                    Border(bottom: BorderSide(width: 0.5, color: Colors.grey)),
              ),
              child: const SizedBox(
                height: 1,
              ),
            ),
            Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 0, 8),
                child: ListTile(
                  leading: const Icon(
                    Icons.description,
                    color: Colors.teal,
                  ),
                  title: const Text(
                    "Terms of use",
                    style: TextStyle(
                        fontWeight: FontWeight.w400,
                        color: Colors.black87,
                        fontSize: 16),
                  ),
                  onTap: launchPrivacy,
                )),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 0, 0, 8),
              child: ListTile(
                leading: const Icon(
                  Icons.assignment_ind,
                  color: Colors.teal,
                ),
                title: const Text(
                  "Privacy policy",
                  style: TextStyle(
                      fontWeight: FontWeight.w400,
                      color: Colors.black87,
                      fontSize: 16),
                ),
                onTap: launchPrivacy,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Sets the organization using the provided callback.
  ///
  /// [org] is the organization to be set.
  setOrganization(Organization org) {}

  /// Sets the BabyBeat organization using the provided callback.
  ///
  /// [org] is the BabyBeat organization to be set.
  // setOrganizationBabyBeat(Organization org) => widget.orgCallbackBabyBeat(org);

  /// Launches the privacy policy URL.
  launchPrivacy() async {
    const url = 'https://ios-fetosense.firebaseapp.com/privacy-policy';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      throw 'Could not launch $url';
    }
  }
}
