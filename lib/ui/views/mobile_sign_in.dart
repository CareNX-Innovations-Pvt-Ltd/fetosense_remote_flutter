import 'package:flutter/material.dart';
import 'package:flutter/services.dart';


/// A StatefulWidget that handles the mobile login view for the application.
class MobileLogin extends StatefulWidget  {
  final Function? otpCallback;
  final VoidCallback? emailCallBack;

  /// [otpCallback] is the callback function to be called after OTP generation.
  /// [emailCallBack] is the callback function to be called for email login.
  const MobileLogin({super.key, this.otpCallback, this.emailCallBack});

  @override
  MobileLoginState createState() => MobileLoginState();
}

TextEditingController _mobileNumberController = TextEditingController();

class MobileLoginState extends State<MobileLogin> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  @override
  void initState() {
    debugPrint("mobile Signin Init");
    debugPrint(_mobileNumberController.text);

    _mobileNumberController.text = '';
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
        key: _scaffoldKey,
        body: GestureDetector(
          onTap: () {

            FocusScope.of(context).requestFocus(FocusNode());
          },
          child: Center(
            child: Container(
              padding: const EdgeInsets.all(16),
              alignment: Alignment.topCenter,
              constraints: BoxConstraints(maxHeight: size.height * 0.9,maxWidth: 480 ),
              child: _showForm(),
            ),
          ),
        ));
  }

  /// Displays the form for mobile login.
  Widget _showForm() {
    return  ListView(
      //mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        showLogo(),
        const SizedBox(
          height: 60,
        ),
        showMobileInput(),
        showPrimaryButton(),

        showSecondaryButton(),
      ],
    );
  }


  /// Displays the logo.
  Widget showLogo() {
    return Hero(
      tag: 'hero',
      child: Container(
        padding: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
        height: MediaQuery.of(context).size.height * 0.4,
        child: CircleAvatar(
          backgroundColor: Colors.transparent,
          radius: 140.0,
          child: Image.asset('images/ic_banner.png'),
        ),
      ),
    );
  }


  /// Displays the mobile input field.
  Widget showMobileInput() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
      child: TextFormField(
        controller: _mobileNumberController,
        keyboardType: TextInputType.number,
        textInputAction: TextInputAction.done,
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
            )),
        // style: Utils().smallBlack18M(),
      ),
    );
  }


  /// Displays the primary button for generating OTP.
  Widget showPrimaryButton() {
    return Padding(
        padding: const EdgeInsets.fromLTRB(30.0, 45.0, 30.0, 10.0),
        child: SizedBox(
          height: 40.0,
          child: MaterialButton(
            elevation: 5.0,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.0)),
            color: Colors.teal,
            child: const Text('GENERATE OTP',
                style: TextStyle(fontSize: 17.0, color: Colors.white)),
            onPressed: () {
              debugPrint(_mobileNumberController.text);
              bool isValidateNO = validateMobileNumber(_mobileNumberController);
              if (isValidateNO) {
                // _users.phoneNumber = _mobileNumberController.value.text;

                widget.otpCallback!(_mobileNumberController.text);

                // Navigator.of(context).pushNamed('/userName');
              } else {
                showSnackbar("Enter valid mobile number!");
              }
            },
          ),
        ));
  }

  /// Displays the secondary button for email login.
  Widget showSecondaryButton() {
    return MaterialButton(
        onPressed: () {
          widget.emailCallBack!();
        },
        child: RichText(
          text: const TextSpan(
            // Note: Styles for TextSpans must be explicitly defined.
            // Child text spans will inherit styles from parent
            style: TextStyle(
              fontSize: 14.0,
              color: Colors.black,
            ),
            children: <TextSpan>[
              TextSpan(
                text: 'Have an email account?',
              ),
              TextSpan(
                  text: ' Sign in',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurpleAccent)),
            ],
          ),
        ));
  }


  /// Displays a snackbar with the given message.
  void showSnackbar(message) {
    final snackBar = SnackBar(
      content: Text(message),
      duration: const Duration(milliseconds: 3000),
    );
    ScaffoldMessenger.of(_scaffoldKey.currentState!.context).showSnackBar(snackBar);
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
