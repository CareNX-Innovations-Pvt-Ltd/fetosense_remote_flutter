import 'dart:async';
import 'package:appwrite/appwrite.dart';
import 'package:fetosense_remote_flutter/core/network/appwrite_config.dart';
import 'package:fetosense_remote_flutter/locater.dart';
import 'package:fetosense_remote_flutter/ui/widgets/custom_otp_field.dart';
import 'package:flutter/foundation.dart';
import 'package:fetosense_remote_flutter/core/services/authentication.dart';
import 'package:flutter/material.dart';
import 'package:quiver/async.dart';

/// A StatefulWidget that handles the otp view for the application.
// class LoginOtpScreen extends StatefulWidget  {
//   String? _phoneNumber;
//   final VoidCallback loginCallback;
//   final VoidCallback phoneCallback;
//   BaseAuth? _auth;
//
//   /// [phoneNumber] is the phone number to which the OTP is sent.
//   /// [auth] is the authentication service.
//   /// [loginCallback] is the callback function to be called after login.
//   /// [phoneCallback] is the callback function to be called for phone number change.
//   LoginOtpScreen(String? phoneNumber, BaseAuth? auth, this.loginCallback,
//       this.phoneCallback, {super.key}) {
//     _phoneNumber = phoneNumber;
//
//     _auth = auth;
//   }
//
//   @override
//   LoginOtpScreenState createState() =>
//       LoginOtpScreenState();
// }

// class LoginOtpScreenState extends State<LoginOtpScreen> {
//   final TextEditingController _otpController = TextEditingController();
//   final _scaffoldKey = GlobalKey<ScaffoldState>();
//   // final Api? _api = locator<Api>();
//   bool _isValidOTP = true;
//   bool _isOptValidationError = false;
//
//   bool _isOTPRecieved = false;
//   bool _isLoading = false;
//   bool _isTimeElapse = false;
//   var _loadingMsg;
//   var _loadingMsgIntial;
//   bool _isOtpSent = false;
//   bool _isAutoOtp = false;
//   String? _smsVerificationCode;
//   int _remainingTime = 60;
//   CountdownTimer? countdownTimer;
//   late StreamSubscription<CountdownTimer> timer;
//
//   final databases = Databases(locator<AppwriteService>().client);
//
//
//   @override
//   void initState() {
//     super.initState();
//     setState(() {
//       _loadingMsgIntial = "Sending OTP.Please wait...";
//       _isOTPRecieved = false;
//     });
//     _verifyPhoneNumber(context);
//   }
//
//   @override
//   void didChangeDependencies() {
//     super.didChangeDependencies();
//   }
//
//
//   @override
//   Widget build(BuildContext context) {
//     final size = MediaQuery.of(context).size;
//
//     return Scaffold(
//       key: _scaffoldKey,
//       backgroundColor: Colors.white,
//       body: Center(
//         child: Container(
//           padding: const EdgeInsets.all(16),
//           alignment: Alignment.topCenter,
//           constraints:
//               BoxConstraints(maxHeight: size.height * 0.9, maxWidth: 480),
//           child: ListView(
//             //mainAxisSize: MainAxisSize.min,
//             //mainAxisAlignment: MainAxisAlignment.center,
//             shrinkWrap: true,
//             children: <Widget>[
//               SizedBox(
//                 height: MediaQuery.of(context).size.height * 0.4,
//                 child: CircleAvatar(
//                   backgroundColor: Colors.transparent,
//                   radius: 140.0,
//                   child: Image.asset(
//                     'images/ic_banner.png',
//                   ),
//                 ),
//               ),
//               Container(
//                 padding: const EdgeInsets.symmetric(horizontal: 16),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: <Widget>[
//                     const Padding(
//                       padding: EdgeInsets.only(
//                         bottom: 15,
//                       ),
//                       child: Text(
//                         'Enter your Verification Code.',
//                         // style: Utils().smallBlack36SB(),
//                       ),
//                     ),
//                     const Padding(
//                       padding: EdgeInsets.only(bottom: 10),
//                       child: Text(
//                         'We have sent you 6 digit OTP on',
//                         // style: Utils().smallGrey16M(),
//                       ),
//                     ),
//                     Row(
//                       mainAxisSize: MainAxisSize.max,
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: <Widget>[
//                         Text(
//                           '+91 ${widget._phoneNumber}',
//                           // style: Utils().smallBlack20R(),
//                         ),
//                         GestureDetector(
//                           onTap: () {
//                             // _sub.cancel();
//                             if (countdownTimer != null) {
//                               countdownTimer!.cancel();
//                             }
//
//                             widget.phoneCallback();
//                             // if (Navigator.canPop(context)) {
//                             //   Navigator.pop(context);
//                             // }
//                           },
//                           child: const Text(
//                             'CHANGE',
//                             // style: Utils().upperGreen16M(),
//                           ),
//                         ),
//                       ],
//                     ),
//                     const SizedBox(
//                       height: 20,
//                     ),
//                     CustomOtptextfield(
//                       autofocus: true,
//                       controller: _otpController,
//                       hideCharacter: false,
//                       highlight: true,
//                       highlightPinBoxColor: Colors.tealAccent,
//                       pinBoxRadius: 10,
//                       pinBoxColor: Colors.tealAccent,
//                       highlightColor: Colors.teal,
//                       defaultBorderColor: Colors.tealAccent,
//                       hasTextBorderColor: Colors.tealAccent,
//                       maxLength: 6,
//                       // maskCharacter: "😎",
//                       onTextChanged: (text) {
//                         setState(() {
//                           _isOptValidationError = false;
//                         });
//                       },
//                       hasError: _isOptValidationError,
//                       errorBorderColor: Colors.white,
//                       onDone: (text) {
//                         print("DONE $text");
//                         print("DONE CONTROLLER ${_otpController.text}");
//                       },
//                       pinBoxWidth: 40,
//                       pinBoxHeight: 40,
//                       hasUnderline: true,
//                       wrapAlignment: WrapAlignment.spaceAround,
//                       pinBoxDecoration:
//                           ProvidedPinBoxDecoration.defaultPinBoxDecoration,
//                       pinTextStyle: const TextStyle(fontSize: 16.0),
//                       pinTextAnimatedSwitcherTransition:
//                           ProvidedPinBoxTextAnimation.scalingTransition,
//                       //                    pinBoxColor: Colors.green[100],
//                       pinTextAnimatedSwitcherDuration:
//                           const Duration(milliseconds: 300),
//                       //                    highlightAnimation: true,
//                       highlightAnimationBeginColor: Colors.black,
//                       highlightAnimationEndColor: Colors.white12,
//                       keyboardType: TextInputType.number,
//                     ),
//                     _isOptValidationError
//                         ? Container(
//                             margin: const EdgeInsets.only(top: 6),
//                             child: const Text(
//                               'Please Enter Valid OTP',
//                               // style: Utils().smallRed16SB(),
//                             ))
//                         : Container(),
//                     Padding(
//                         padding: const EdgeInsets.only(top: 20.0, bottom: 5),
//                         child: _isTimeElapse
//                             ? InkWell(
//                                 onTap: () {
//                                   debugPrint("resent otp");
//                                   _otpController.text = "";
//                                   _verifyPhoneNumber(context);
//                                   // _initializeTimer();
//                                   setState(() {
//                                     _isLoading = true;
//
//                                     _loadingMsg = "Sending OTP.Please wait...";
//                                   });
//                                 },
//                                 child: const Text(
//                                   'RESEND OTP',
//                                   // style: Utils().upperGreen18M(),
//                                 ),
//                               )
//                             :
//                             // Countdown(
//                             //     countdownController: countdownController,
//                             //     builder: (_, Duration time) {
//                             //         return Text(
//                             //             'RESEND IN ${time?.inSeconds}',
//                             //             style: Utils().smallGrey16M(),
//                             //           );
//                             //       }
//                             //     ),
//                             // CountdownTimer(
//                             //     endTime: endTime,
//                             //     onEnd: () {
//                             //       setState(() {
//                             //         _isTimeElapse = true;
//                             //       });
//                             //       print('onEnd');
//                             //     },
//                             //     widgetBuilder:
//                             //         (_, CurrentRemainingTime time) {
//                             //       debugPrint(
//                             //           "Count down otp time ${time.sec}");
//                             //       return
//
//                             _loadingMsgIntial == '' || _loadingMsgIntial == null
//                                 ? Text(
//                                     'RESEND IN $_remainingTime',
//                                   )
//                                 : Text(
//                                     _loadingMsgIntial,
//                                   )
//                         //     }),
//                         ),
//                     _isOtpSent
//                         ? Container(
//                             alignment: Alignment.center,
//                             child: Text(
//                               "OTP sent to your number +91 ${widget._phoneNumber}",
//                               textAlign: TextAlign.center,
//                             ),
//                           )
//                         : Container(),
//                     _isAutoOtp
//                         ? Container(
//                             alignment: Alignment.center,
//                             child: const Column(
//                               mainAxisSize: MainAxisSize.max,
//                               children: <Widget>[
//                                 Padding(
//                                   padding: EdgeInsets.only(top: 5.0, bottom: 5),
//                                   child: Text(
//                                     'Trying to auto retrieve OTP. Please wait...',
//                                     // style: Utils().smallBlack16M(),
//                                     textAlign: TextAlign.center,
//                                   ),
//                                 ),
//                                 /*SizedBox(
//                               height: 22,
//                               width: 22,
//                               child: CircularProgressIndicator(
//                                   valueColor:
//                                       AlwaysStoppedAnimation(
//                                           AppColors.themeColor),
//                                   strokeWidth: 2.5),
//                             ),*/
//                               ],
//                             ),
//                           )
//                         : Container(),
//                     _isLoading
//                         ? Container(
//                             alignment: Alignment.center,
//                             child: Column(
//                               mainAxisSize: MainAxisSize.max,
//                               children: <Widget>[
//                                 Padding(
//                                   padding:
//                                       const EdgeInsets.only(top: 5.0, bottom: 10),
//                                   child: Text(
//                                     _loadingMsg ?? "",
//                                     // style: Utils().smallBlack16M(),
//                                   ),
//                                 ),
//                                 const SizedBox(
//                                   height: 22,
//                                   width: 22,
//                                   child: CircularProgressIndicator(
//                                       valueColor:
//                                           AlwaysStoppedAnimation(Colors.teal),
//                                       strokeWidth: 2.5),
//                                 ),
//                               ],
//                             ),
//                           )
//                         : Container(),
//                     Container(
//                       margin: const EdgeInsets.only(top: 25),
//                       width: MediaQuery.of(context).size.width,
//                       child: _isOTPRecieved
//                           ? MaterialButton(
//                               padding: const EdgeInsets.all(17),
//                               shape: RoundedRectangleBorder(
//                                   borderRadius: BorderRadius.circular(10.0)),
//                               elevation: 2,
//                               onPressed: () {
//                                 debugPrint('Normal');
//
//                                 bool isValidateOtp =
//                                     validateOtp(_otpController);
//
//                                 setState(() {
//                                   _isValidOTP = isValidateOtp;
//                                   _isOptValidationError = !isValidateOtp;
//                                 });
//
//                                 if (_isValidOTP) {
//                                   FocusScope.of(context).unfocus();
//                                   _isLoading = true;
//                                   setState(() {
//                                     _isAutoOtp = false;
//                                     _loadingMsg = "Verifying otp...";
//                                   });
//                                   _signInWithPhoneNumber(
//                                       context,
//                                       _smsVerificationCode!,
//                                       _otpController.value.text);
//                                 }
//
//                                 debugPrint("validate $_isValidOTP Verify");
//                               },
//                               color: Colors.teal,
//                               child: const Text(
//                                 "Verify",
//                               ),
//                             )
//                           : MaterialButton(
//                               padding: const EdgeInsets.all(17),
//                               shape: RoundedRectangleBorder(
//                                   borderRadius: BorderRadius.circular(10.0)),
//                               elevation: 2,
//                               onPressed: null,
//                               child: const Text(
//                                 "Verify",
//                               ),
//                             ),
//                     )
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   /// Validates the OTP entered by the user.
//   bool validateOtp(TextEditingController controller) {
//     if (controller.value.text.length < 6) {
//       debugPrint(controller.value.text);
//       return false;
//     } else {
//       debugPrint(controller.value.text);
//       return true;
//     }
//   }
//
//   /// Signs in the user with the provided phone number and OTP.
//   void _signInWithPhoneNumber(
//       BuildContext context, String verificationId, String otp) async {
//     debugPrint("smsCode $verificationId otp $otp");
//
//     AuthCredential _authCredential = PhoneAuthProvider.credential(
//         verificationId: verificationId, smsCode: otp);
//     FirebaseAuth.instance
//         .signInWithCredential(_authCredential)
//         .catchError((error) {
//       debugPrint("_signInWithPhoneNumber manual failed ${error.toString()}");
//
//       setState(() {
//         _isLoading = false;
//       });
//
//       const snackBar = SnackBar(
//           content: Text("Authentication Failed"),
//           duration: Duration(seconds: 1));
//       debugPrint(error.toString());
//       ScaffoldMessenger.of(_scaffoldKey.currentState!.context)
//           .showSnackBar(snackBar);
//     }).then((value) async {
//       debugPrint("_signInWithPhoneNumber manual success ${value.user!.uid}");
//       if (value != null) {
//         // _user.uid = value.user.uid;
//         // _userBloc.getUser(widget._users.phoneNumber, widget._users.uid);
//         bool userNotFound = await _api!.isNewUser(widget._phoneNumber);
//
//         debugPrint("_signInWithPhoneNumber auto success $userNotFound");
//         debugPrint(userNotFound.toString());
//
//         if (userNotFound) {
//           print("User not Found");
//           await createNewDoctor(value.user!.uid);
//         } else {
//           print("User Found");
//         }
//         setState(() {
//           _uid = value.user!.uid;
//
//           _isLoading = false;
//         });
//
//         if (value.user!.uid.length > 0 && value.user!.uid != null) {
//           timer.cancel();
//           widget.loginCallback();
//           if (Navigator.canPop(context)) Navigator.pop(context);
//         }
//       }
//     });
//   }
//
//   /// Verifies the phone number by sending an OTP.
//   _verifyPhoneNumber(BuildContext context) async {
//     setState(() {
//       _isOTPRecieved = false;
//     });
//     String phoneNumber = "+91${widget._phoneNumber!}";
//     debugPrint("phoneNo $phoneNumber");
//     final FirebaseAuth _auth = FirebaseAuth.instance;
//
//     if (kIsWeb) {
//       webAuth(phoneNumber);
//     } else {
//       await _auth.verifyPhoneNumber(
//           phoneNumber: phoneNumber,
//           timeout: const Duration(seconds: 60),
//           verificationCompleted: (authCredential) =>
//               _verificationComplete(authCredential, context),
//           verificationFailed: (authException) =>
//               _verificationFailed(authException.message.toString(), context),
//           codeAutoRetrievalTimeout: (verificationId) =>
//               _codeAutoRetrievalTimeout(verificationId),
//           // called when the SMS code is sent
//           codeSent: (verificationId, [int? forceResendToken]) =>
//               _smsCodeSent(verificationId, forceResendToken));
//     }
//   }
//
//   /// Handles web authentication for phone number verification.
//   Future<void> webAuth(String phoneNumber) async {
//     try {
//       final cr = await FirebaseAuth.instance.signInWithPhoneNumber(phoneNumber);
//       confirmationResult = cr;
//       _smsCodeSent(cr.verificationId, cr);
//     } on FirebaseAuthException catch (e) {
//       debugPrint(
//           'PhoneNumberSignInCubit: FirebaseAuthException - ${e.toString()}');
//       _verificationFailed(e.message.toString(), context);
//       if (e.code == 'invalid-phone-number') {
//         _verificationFailed(e.message.toString(), context);
//       } else if (e.code == 'too-many-requests') {
//         _verificationFailed(e.message.toString(), context);
//       } else if (e.code == 'app-not-authorized') {
//         _verificationFailed(e.message.toString(), context);
//       } else {
//         _verificationFailed(e.message.toString(), context);
//       }
//     } on Exception catch (e) {
//       debugPrint(
//           'PhoneNumberSignInCubit: Unknown error occurred - ${e.toString()}');
//       _verificationFailed(e.toString(), context);
//     }
//   }
//
//   /// Completes the verification process with the provided AuthCredential.
//   _verificationComplete(AuthCredential authCredential, BuildContext context) {
//     FirebaseAuth.instance
//         .signInWithCredential(authCredential)
//         .catchError((error) {
//       debugPrint("_signInWithPhoneNumber manual failed ${error.toString()}");
//
//       setState(() {
//         _isLoading = false;
//       });
//
//       const snackBar = SnackBar(
//           content: Text("Authentication Failed"),
//           duration: Duration(seconds: 1));
//       debugPrint(error.toString());
//       ScaffoldMessenger.of(_scaffoldKey.currentState!.context)
//           .showSnackBar(snackBar);
//     }).then((value) async {
//       debugPrint("_signInWithPhoneNumber auto success ${value.user!.uid}");
//       if (value != null) {
//         // _user.uid = value.user.uid;
//         // _userBloc.getUser(widget._users.phoneNumber, widget._users.uid);
//         bool userNotFound = await _api!.isNewUser(widget._phoneNumber);
//
//         debugPrint("_signInWithPhoneNumber auto success $userNotFound");
//         debugPrint(userNotFound.toString());
//
//         if (userNotFound) {
//           print("User not Found");
//           await createNewDoctor(value.user!.uid);
//         } else {
//           print("User Found");
//         }
//         setState(() {
//           _uid = value.user!.uid;
//
//           _isLoading = false;
//         });
//
//         if (value.user!.uid.length > 0 && value.user!.uid != null) {
//           timer.cancel();
//           widget.loginCallback();
//           if (Navigator.canPop(context)) Navigator.pop(context);
//         }
//       }
//     });
//   }
//
//   /// Handles the event when the SMS code is sent.
//   _smsCodeSent(String verificationId, forceResendToken) {
//     setState(() {
//       _isLoading = false;
//       _isOtpSent = true;
//     });
//     // set the verification code so that we can use it to log the user in
//     _smsVerificationCode = verificationId;
//
//     if (_smsVerificationCode != null || _smsVerificationCode != '') {
//       _initializeTimer();
//       setState(() {
//         _loadingMsgIntial = "";
//         _isOTPRecieved = true;
//       });
//     }
//
//     debugPrint("_smsVerificationCode $_smsVerificationCode ");
//     debugPrint("verificationId $verificationId");
//     setState(() {
//       _isTimeElapse = false;
//       // _initializeTimer();
//     });
//     /*final snackBar = SnackBar(
//       content: Text(
//         "OTP sent to your number +91 ${_user.mobileNo}",
//       ),
//       duration: Duration(seconds: 2),
//       behavior: SnackBarBehavior.floating,
//     );*/
//     Timer(const Duration(milliseconds: 2500), () {
//       setState(() {
//         _isOtpSent = false;
//         _isAutoOtp = true;
//       });
//     });
//     // _scaffoldKey.currentState.showSnackBar(snackBar);
//   }
//
//   /// Handles the event when verification fails.
//   _verificationFailed(String authException, BuildContext context) {
//     debugPrint("authException $authException");
//     setState(() {
//       _isLoading = false;
//       _isAutoOtp = false;
//     });
//
//     final snackBar = SnackBar(
//       content: Text(authException),
//       duration: const Duration(seconds: 2),
//     );
//     ScaffoldMessenger.of(_scaffoldKey.currentState!.context)
//         .showSnackBar(snackBar);
//   }
//
//   /// Handles the event when the code auto retrieval times out.
//   _codeAutoRetrievalTimeout(String verificationId) {
//     // set the verification code so that we can use it to log the user in
//     debugPrint("timeout");
//     debugPrint("sms code auto retrieval");
//
//     if (mounted) {
//       setState(() {
//         _isLoading = false;
//         _smsVerificationCode = verificationId;
//         _isAutoOtp = false;
//       });
//     }
//     debugPrint("_codeAutoRetrievalTimeout $verificationId");
//   }
//
//   /// Initializes the countdown timer for OTP resend.
//   void _initializeTimer() {
//     if (mounted) {
//       // endTime = DateTime.now().millisecondsSinceEpoch + 1000 * 60;
//       timer = CountdownTimer(
//               const Duration(seconds: 61), const Duration(seconds: 1))
//           .listen((data) {
//         print('Remaining time: ${data.remaining.inSeconds}');
//         countdownTimer = data;
//         if (mounted) {
//           setState(() {
//             _remainingTime = countdownTimer!.remaining.inSeconds;
//             if (_remainingTime == 0) {
//               _remainingTime = 60;
//               _isTimeElapse = true;
//             }
//           });
//         }
//       });
//     }
//   }
//
//   /// Creates a new doctor in the database.
//   Future<String> createNewDoctor(String userId) async {
//     Map data = <String, String?>{};
//     data["name"] = "Doctor";
//     data["mobileNo"] = widget._phoneNumber;
//     data["email"] = "";
//     data["type"] = "doctor";
//     data["uid"] = userId;
//
//     DocumentReference ref = await FirebaseFirestore.instance
//         .collection("users")
//         .add(data as Map<String, dynamic>);
//     data["documentId"] = ref.id;
//
//     await FirebaseFirestore.instance
//         .collection("users")
//         .doc(ref.id)
//         .set(data, SetOptions(merge: true));
//     return ref.id;
//   }
// }
