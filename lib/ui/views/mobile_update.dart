/*
import 'package:fetosense_remote_flutter/core/model/doctor_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:fetosense_remote_flutter/core/services/authentication.dart';
import 'otp_screen.dart';

/// A StatefulWidget that handles the mobile number update for the application.
class MobileUpdate extends StatefulWidget {
  Doctor? doctor;
  final BaseAuth? auth;
  final VoidCallback? logoutCallback;

  /// [doctor] is the doctor model.
  /// [auth] is the authentication service.
  /// [logoutCallback] is the callback function to be called after logout.
  MobileUpdate({super.key, this.doctor, this.auth, this.logoutCallback});

  @override
  MobileUpdateState createState() => MobileUpdateState();
}

TextEditingController _mobileNumberController = TextEditingController();

class MobileUpdateState extends State<MobileUpdate> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: Center(
        child: Stack(
          children: <Widget>[
            _showForm(),
          ],
        ),
      ),
    );
  }

  /// Displays the form for updating the mobile number.
  Widget _showForm() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 0.0),
        child: ListView(
          // shrinkWrap: true,
          children: <Widget>[
            showLogo(),
            const SizedBox(
              height: 60,
            ),
            const Text(
              " We are switching our login from email to mobile number and OTP. So, please provide your mobile number to continue",
              style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
            ),
            const SizedBox(
              height: 20,
            ),
            showMobileInput(),
            showPrimaryButton(),
          ],
        ),
      ),
    );
  }

  /// Displays the logo.
  Widget showLogo() {
    return Hero(
      tag: 'hero',
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
        child: CircleAvatar(
          backgroundColor: Colors.transparent,
          radius: 140.0,
          child: Image.asset('images/ic_banner.png'),
        ),
      ),
    );
  }

  /// Displays the mobile number input field.
  Widget showMobileInput() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
      child: TextFormField(
        controller: _mobileNumberController,
        keyboardType: TextInputType.number,
        autofocus: false,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        onFieldSubmitted: (text) {
          setState(() {
            debugPrint("onFieldSubmitted $text");
          });
        },
        onChanged: (txt) {
          setState(() {
            // _isMobileValidationError = false;
            // _isOtpVisible = false;
            // _otpController.text = '';
          });
        },
        maxLength: 10,
        maxLines: 1,
        decoration: InputDecoration(
          // labelText: 'Phone Number',
          //hasFloatingPlaceholder: true,
          prefixIcon: const Padding(
              padding: EdgeInsets.only(left: 15, top: 15, bottom: 15),
              child: Text(
                "+91",
              )),
          counterStyle: const TextStyle(
            height: double.minPositive,
          ),
          counterText: "",
          hintText: "Enter mobile number",
          fillColor: Colors.teal.withOpacity(0.2),
          filled: true,
          //  floatingLabelBehavior: FloatingLabelBehavior.always,
          // labelStyle: Utils().smallBlack16R(),
          // errorStyle: TextStyle(
          //   color: Colors.transparent,
          //   fontSize: 0,
          // ),
          contentPadding:
              const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
          errorText: null,
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.teal),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.teal),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.teal),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Colors.teal),
          ),
        ),
        // style: Utils().smallBlack18M(),
      ),
    );
  }

  /// Displays the primary button for submitting the mobile number.
  Widget showPrimaryButton() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(30.0, 45.0, 30.0, 10.0),
      child: SizedBox(
        height: 40.0,
        child: MaterialButton(
          elevation: 5.0,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
          color: Colors.teal,
          child: const Text('Submit',
              style: TextStyle(fontSize: 20.0, color: Colors.white)),
          onPressed: () {
            debugPrint(_mobileNumberController.text);
            bool isValidateNO = validateMobileNumber(_mobileNumberController);
            if (isValidateNO) {
              // _users.phoneNumber = _mobileNumberController.value.text;

              Navigator.pushReplacement(
                context,
                CupertinoPageRoute(
                  builder: (context) => LoginOtp(
                    _mobileNumberController.text,
                    widget.doctor,
                    widget.auth,
                    widget.logoutCallback,
                  ),
                ),
              );

              // Navigator.of(context).pushNamed('/userName');
            } else {
              showSnackbar("Enter valid mobile number!");
            }
          },
        ),
      ),
    );
  }

  /// Displays a snackbar with the given message.
  void showSnackbar(message) {
    final snackBar = SnackBar(
      content: Text(message),
      duration: const Duration(milliseconds: 3000),
    );
    ScaffoldMessenger.of(_scaffoldKey.currentState!.context)
        .showSnackBar(snackBar);
  }
}

/// Validates the mobile number entered by the user.
bool validateMobileNumber(TextEditingController controller) {
  if (controller.value.text.length < 10) {
    debugPrint(controller.value.text);
    return false;
  } else {
    debugPrint(controller.value.text);
    return true;
  }
}
*/
