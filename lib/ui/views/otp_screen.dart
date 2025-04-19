/*
import 'dart:async';
import 'package:fetosense_remote_flutter/ui/views/splash_view.dart';
import 'package:fetosense_remote_flutter/ui/widgets/custom_otp_field.dart';
import 'package:fetosense_remote_flutter/core/services/authentication.dart';
import 'package:fetosense_remote_flutter/core/model/doctor_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:quiver/async.dart';

import 'mobile_update.dart';

/// A StatefulWidget that handles the OTP login process.
///
/// This widget verifies the OTP sent to the user's phone number and logs the user in.
class LoginOtp extends StatefulWidget {
  String? _phoneNumber;
  int? _forceResendToken;
  Doctor? _doctor;
  BaseAuth? _auth;
  late VoidCallback logoutCallback;

  /// [phoneNumber] is the phone number to which the OTP is sent.
  /// [doctor] is the doctor model.
  /// [auth] is the authentication service.
  /// [logoutCallback] is the callback function to log out the user.
  LoginOtp(String phoneNumber, Doctor? doctor, BaseAuth? auth, logoutCallback, {super.key});

  @override
  LoginOtpState createState() => LoginOtpState();
}

class LoginOtpState extends State<LoginOtp> {
  final TextEditingController _otpController = TextEditingController();
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  bool _isValidOTP = true;
  bool _isOptValidationError = false;
  bool _isLoading = false;
  bool _isTimeElapse = false;
  var _loadingMsg;
  StreamSubscription<Duration>? _sub;

  String? _phoneNumber;
  bool _isOtpSent = false;
  bool _isAutoOtp = false;
  late String _smsVerificationCode;
  final databaseReference = FirebaseFirestore.instance;
  int _remainingTime = 60;
  late CountdownTimer countdownTimer;

  @override
  void initState() {
    super.initState();
    _initializeTimer();

    _verifyPhoneNumber(context);
  }

  @override
  void dispose() {
    super.dispose();
    _otpController.dispose();
    countdownTimer.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
          child: Container(
        height: MediaQuery.of(context).size.height,
        color: Colors.white,
        child:
            Column(
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
              child: CircleAvatar(
                backgroundColor: Colors.transparent,
                radius: 140.0,
                child: Image.asset('images/ic_banner.png'),
              ),
            ),
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(50),
                      topRight: Radius.circular(50)),
                ),
                child: Stack(
                  //crossAxisAlignment: CrossAxisAlignment.center,
                  alignment: Alignment.center,
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.only(
                          left: MediaQuery.of(context).size.width * 0.08,
                          right: MediaQuery.of(context).size.width * 0.08,
                          top: MediaQuery.of(context).size.width * 0.15,
                          bottom: MediaQuery.of(context).size.height * 0.1),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              const Padding(
                                padding: EdgeInsets.only(
                                  bottom: 15,
                                ),
                                child: Text(
                                  'Enter your Verification Code.',
                                  // style: Utils().smallBlack36SB(),
                                ),
                              ),
                              const Padding(
                                padding: EdgeInsets.only(bottom: 10),
                                child: Text(
                                  'We have sent you 6 digit OTP on',
                                  // style: Utils().smallGrey16M(),
                                ),
                              ),
                              Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Text(
                                    '+91 ${widget._phoneNumber}',
                                    // style: Utils().smallBlack20R(),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      // _sub.cancel();
                                      countdownTimer.cancel();
                                      Navigator.pushReplacement(
                                        context,
                                        CupertinoPageRoute(
                                          builder: (context) => MobileUpdate(
                                            doctor: widget._doctor,
                                            auth: widget._auth,
                                          ),
                                        ),
                                      );
                                    },
                                    child: const Text(
                                      'CHANGE',
                                      // style: Utils().upperGreen16M(),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              CustomOtptextfield(
                                autofocus: true,
                                controller: _otpController,
                                hideCharacter: false,
                                highlight: true,
                                highlightPinBoxColor: Colors.tealAccent,
                                pinBoxRadius: 10,
                                pinBoxColor: Colors.tealAccent,
                                highlightColor: Colors.teal,
                                defaultBorderColor: Colors.tealAccent,
                                hasTextBorderColor: Colors.tealAccent,
                                maxLength: 6,
                                // maskCharacter: "😎",
                                onTextChanged: (text) {
                                  setState(() {
                                    _isOptValidationError = false;
                                  });
                                },
                                hasError: _isOptValidationError,
                                errorBorderColor: Colors.white,
                                onDone: (text) {
                                  print("DONE $text");
                                  print(
                                      "DONE CONTROLLER ${_otpController.text}");
                                },
                                pinBoxWidth: 40,
                                pinBoxHeight: 40,
                                hasUnderline: true,
                                wrapAlignment: WrapAlignment.spaceAround,
                                pinBoxDecoration: ProvidedPinBoxDecoration
                                    .defaultPinBoxDecoration,
                                pinTextStyle: const TextStyle(fontSize: 16.0),
                                pinTextAnimatedSwitcherTransition:
                                    ProvidedPinBoxTextAnimation
                                        .scalingTransition,
                          //                    pinBoxColor: Colors.green[100],
                                pinTextAnimatedSwitcherDuration:
                                    const Duration(milliseconds: 300),
                          //                    highlightAnimation: true,
                                highlightAnimationBeginColor: Colors.black,
                                highlightAnimationEndColor: Colors.white12,
                                keyboardType: TextInputType.number,
                              ),
                              _isOptValidationError
                                  ? Container(
                                      margin: const EdgeInsets.only(top: 6),
                                      child: const Text(
                                        'Please Enter Valid OTP',
                                        // style: Utils().smallRed16SB(),
                                      ))
                                  : Container(),
                              Padding(
                                  padding:
                                      const EdgeInsets.only(top: 20.0, bottom: 5),
                                  child: _isTimeElapse
                                      ? InkWell(
                                          onTap: () {
                                            debugPrint("resent otp");
                                            _otpController.text = "";
                                            _verifyPhoneNumber(context);
                                            _initializeTimer();
                                            setState(() {
                                              _isLoading = true;

                                              // _loadingMsg =
                                              //     "Sending OTP.Please wait...";
                                            });
                                          },
                                          child: const Text(
                                            'RESEND OTP',
                                            // style: Utils().upperGreen18M(),
                                          ),
                                        )
                                      :
                                      Text(
                                          'RESEND IN ${_remainingTime}',
                                          // style: Utils().smallGrey16M(),
                                        )
                                  //     }),
                                  ),
                              _isOtpSent
                                  ? Container(
                                      alignment: Alignment.center,
                                      child: Text(
                                        "OTP sent to your number +91 ${widget._phoneNumber}",
                                        textAlign: TextAlign.center,
                                      ),
                                    )
                                  : Container(),
                              _isAutoOtp
                                  ? Container(
                                      alignment: Alignment.center,
                                      child: const Column(
                                        mainAxisSize: MainAxisSize.max,
                                        children: <Widget>[
                                          Padding(
                                            padding: EdgeInsets.only(
                                                top: 5.0, bottom: 5),
                                            child: Text(
                                              'Trying to auto retrieve OTP. Please wait...',
                                              // style: Utils().smallBlack16M(),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                          */
/*SizedBox(
                                            height: 22,
                                            width: 22,
                                            child: CircularProgressIndicator(
                                                valueColor:
                                                    AlwaysStoppedAnimation(
                                                        AppColors.themeColor),
                                                strokeWidth: 2.5),
                                          ),*//*

                                        ],
                                      ),
                                    )
                                  : Container(),
                              _isLoading
                                  ? Container(
                                      alignment: Alignment.center,
                                      child: Column(
                                        mainAxisSize: MainAxisSize.max,
                                        children: <Widget>[
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                top: 5.0, bottom: 10),
                                            child: Text(
                                              _loadingMsg != null
                                                  ? _loadingMsg
                                                  : "",
                                              // style: Utils().smallBlack16M(),
                                            ),
                                          ),
                                          const SizedBox(
                                            height: 22,
                                            width: 22,
                                            child: CircularProgressIndicator(
                                                valueColor:
                                                    AlwaysStoppedAnimation(
                                                        Colors.teal),
                                                strokeWidth: 2.5),
                                          ),
                                        ],
                                      ),
                                    )
                                  : Container(),
                              Container(
                                margin: const EdgeInsets.only(top: 25),
                                width: MediaQuery.of(context).size.width,
                                child: MaterialButton(
                                  padding: const EdgeInsets.all(17),
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(10.0)),
                                  elevation: 2,
                                  onPressed: () {
                                    bool isValidateOtp =
                                        validateOtp(_otpController);

                                    setState(() {
                                      _isValidOTP = isValidateOtp;
                                      _isOptValidationError = !isValidateOtp;
                                    });

                                    if (_isValidOTP) {
                                      FocusScope.of(context).unfocus();
                                      _isLoading = true;
                                      setState(() {
                                        _isAutoOtp = false;
                                        _loadingMsg = "Verifying OTP...";
                                      });
                                      _signInWithPhoneNumber(
                                          context,
                                          _smsVerificationCode,
                                          _otpController.value.text);
                                    }

                                    debugPrint(
                                        "validate $_isValidOTP Verify");
                                  },
                                  color: Colors.teal,
                                  child: const Text(
                                    "VERIFY",
                                  ),
                                ),
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      )),
    );
  }

  /// Validates the OTP entered by the user.
  ///
  /// [controller] is the TextEditingController for the OTP input field.
  /// Returns true if the OTP is valid, false otherwise.
  bool validateOtp(TextEditingController controller) {
    if (controller.value.text.length < 6) {
      debugPrint(controller.value.text);
      return false;
    } else {
      debugPrint(controller.value.text);
      return true;
    }
  }

  /// Signs in the user with the provided phone number and OTP.
  ///
  /// [context] is the BuildContext.
  /// [verificationId] is the verification ID received from Firebase.
  /// [otp] is the OTP entered by the user.
  void _signInWithPhoneNumber(
      BuildContext context, String verificationId, String otp) async {
    debugPrint("smsCode $verificationId otp $otp");
    AuthCredential _authCredential = PhoneAuthProvider.credential(
        verificationId: verificationId, smsCode: otp);
    _verificationComplete(_authCredential, context);
  }

  /// Handles sign-in errors.
  ///
  /// [error] is the error encountered during sign-in.
  _onSignInError(error) {
    debugPrint("_signInWithPhoneNumber manual failed ${error.toString()}");

    setState(() {
      _isLoading = false;
    });

    final snackBar = const SnackBar(
        content: Text("Authentication Failed"), duration: Duration(seconds: 1));
    ScaffoldMessenger.of(_scaffoldKey.currentState!.context)
        .showSnackBar(snackBar);
  }


  /// Verifies the phone number by sending an OTP.
  ///
  /// [context] is the BuildContext.
  _verifyPhoneNumber(BuildContext context) async {
    String phoneNumber = "+91" + _phoneNumber!;
    debugPrint("phoneNo $phoneNumber");
    final FirebaseAuth _auth = FirebaseAuth.instance;
    await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        timeout: const Duration(seconds: 60),
        verificationCompleted: (authCredential) =>
            _verificationComplete(authCredential, context),
        verificationFailed: (authException) =>
            _verificationFailed(authException, context),
        codeAutoRetrievalTimeout: (verificationId) =>
            _codeAutoRetrievalTimeout(verificationId),
        // called when the SMS code is sent
        codeSent: (verificationId, [int? forceResendToken]) =>
            _smsCodeSent(verificationId, forceResendToken));
  }

  /// Completes the verification process.
  ///
  /// [authCredential] is the AuthCredential object.
  /// [context] is the BuildContext.
  _verificationComplete(
      AuthCredential authCredential, BuildContext context) async {
    final authResult = await FirebaseAuth.instance
        .signInWithCredential(authCredential)
        .catchError((error) => _onSignInError);
    if (authResult != null) {
      debugPrint("_signInWithPhoneNumber auto success ${authResult.user!.uid}");
      debugPrint("verification complete");

      setState(() {
        _uid = authResult.user!.uid;
        _isAutoOtp = false;
      });

      Map data = new Map<String, String?>();

      data["mobileNo"] = _phoneNumber;

      await databaseReference
          .collection("users")
          .doc(widget._doctor!.documentId)
          .update(data as Map<Object, Object?>);

      widget._doctor!.mobileNo = _phoneNumber;
      await FirebaseAuth.instance.signOut();
      widget.logoutCallback();
      Navigator.pushReplacement(
          context,
          CupertinoPageRoute(
              builder: (context) => SplashView(auth: new Auth())));
    } else {
      _onSignInError(new Error());
    }
  }


  /// Handles the event when the SMS code is sent.
  ///
  /// [verificationId] is the verification ID received from Firebase.
  /// [forceResendToken] is the token to force resend the OTP.
  _smsCodeSent(String verificationId, forceResendToken) {
    setState(() {
      _isLoading = false;
      _isOtpSent = true;
    });
    // set the verification code so that we can use it to log the user in
    _smsVerificationCode = verificationId;

    debugPrint("_smsVerificationCode $_smsVerificationCode ");
    debugPrint("verificationId $verificationId");
    setState(() {
      _currentTime = 60;
      _isTimeElapse = false;
      // _initializeTimer();
    });
    final snackBar = SnackBar(
      content: Text(
        "OTP sent to your number +91 $_phoneNumber",
      ),
      duration: const Duration(seconds: 2),
      behavior: SnackBarBehavior.floating,
    );
    Timer(const Duration(milliseconds: 2500), () {
      setState(() {
        _isOtpSent = false;
        _isAutoOtp = true;
      });
    });
    // _scaffoldKey.currentState.showSnackBar(snackBar);
  }


  /// Handles verification failures.
  ///
  /// [authException] is the exception encountered during verification.
  /// [context] is the BuildContext.
  _verificationFailed(
      FirebaseAuthException authException, BuildContext context) {
    debugPrint("authException ${authException.message.toString()}");
    setState(() {
      _isLoading = false;
      _isAutoOtp = false;
    });

    final snackBar = SnackBar(
      content: Text(authException.message.toString()),
      duration: const Duration(seconds: 2),
    );
    ScaffoldMessenger.of(_scaffoldKey.currentState!.context)
        .showSnackBar(snackBar);
  }


  /// Handles the event when the code auto retrieval times out.
  ///
  /// [verificationId] is the verification ID received from Firebase.
  _codeAutoRetrievalTimeout(String verificationId) {
    // set the verification code so that we can use it to log the user in
    debugPrint("timeout");
    debugPrint("sms code auto retrieval");

    setState(() {
      _isLoading = false;
      _smsVerificationCode = verificationId;
      _isAutoOtp = false;
    });
    debugPrint("_codeAutoRetrievalTimeout $verificationId");
  }


  /// Initializes the countdown timer for OTP resend.
  void _initializeTimer() {
    if (this.mounted) {
      // endTime = DateTime.now().millisecondsSinceEpoch + 1000 * 60;
      new CountdownTimer(new Duration(seconds: 61), new Duration(seconds: 1))
          .listen((data) {
        print('Remaining time: ${data.remaining.inSeconds}');
        countdownTimer = data;
        setState(() {
          _remainingTime = countdownTimer.remaining.inSeconds;
          if (_remainingTime == 0) {
            _remainingTime = 60;
            _isTimeElapse = true;
          }
        });
      });
    }
  }
}
*/
