import 'package:appwrite/appwrite.dart';
import 'package:fetosense_remote_flutter/app_router.dart';
import 'package:fetosense_remote_flutter/core/model/doctor_model.dart';
import 'package:fetosense_remote_flutter/core/network/appwrite_config.dart';
import 'package:fetosense_remote_flutter/core/services/authentication.dart';
import 'package:fetosense_remote_flutter/core/utils/app_constants.dart';
import 'package:fetosense_remote_flutter/core/utils/preferences.dart';
import 'package:fetosense_remote_flutter/locater.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// A StatefulWidget that handles the login view for the application.
class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<StatefulWidget> createState() => _LoginViewState();
}

final FocusNode _emailFocus = FocusNode();
final FocusNode _passwordFocus = FocusNode();
final FocusNode _confirmFocus = FocusNode();

class _LoginViewState extends State<LoginView> {
  final _formKey = GlobalKey<FormState>();

  String _email = 'test@gmail.com';
  String _password = "delete123";
  String _confirm = "";
  String? _errorMessage;
  final databases = Databases(locator<AppwriteService>().client);
  late bool _isLoginForm;
  late bool _isLoading;
  final prefs = locator<PreferenceHelper>();
  BaseAuth auth = locator<BaseAuth>();

  /// Validates the form and saves the input values.
  bool validateAndSave() {
    final form = _formKey.currentState!;
    if (form.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  // Perform login or signup
  /// Validates the form and performs login or signup.
  void validateAndSubmit() async {
    debugPrint('email --> $_email');
    debugPrint('password --> $_password');
    setState(() {
      _errorMessage = "";
      _isLoading = true;
    });
    if (validateAndSave()) {
      String userId = "";
      try {
        if (_isLoginForm) {
          userId = await Auth().signIn(_email, _password);
          debugPrint('Signed in: $userId');
          if (userId.isNotEmpty) {
            var doctor = await getDoctor();
            debugPrint('Signed in:  $doctor');
              debugPrint('doctor -> ${doctor.email}');
              debugPrint('doctor -> ${doctor.documentId}');
              prefs.setAutoLogin(true);
              prefs.saveDoctor(doctor);
              if (mounted) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  context.pushReplacement(AppRoutes.home, extra: doctor);
                });
              }
          }
        } else {
          userId = await auth.signUp(_email, _confirm);
          debugPrint('Signed up user: $userId');
          await createNewDoctor(
            email: _email,
            password: _password,
            userId: userId,
          );
          var doctor = await getDoctor();
          if (mounted) {
            context.pushReplacement(AppRoutes.initProfileUpdate, extra: doctor);
          }
        }
        setState(() {
          _isLoading = false;
        });
      } catch (e, s) {
        debugPrint('Error: $s');
        setState(() {
          _isLoading = false;
          if (e.toString().contains("There is no user record")) {
            _errorMessage = "Invalid email/username";
          } else {
            _errorMessage = e.toString();
          }
        });
      }
    } else {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void initState() {
    _errorMessage = "";
    _isLoading = false;
    _isLoginForm = true;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Stack(
          children: <Widget>[
            _showForm(),
            _showCircularProgress(),
          ],
        ),
      ),
    );
  }

  /// Displays a circular progress indicator.
  Widget _showCircularProgress() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
        ),
      );
    }
    return const SizedBox(
      height: 0.0,
      width: 0.0,
    );
  }

  /// Displays the login/signup form.
  Widget _showForm() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 0.0),
          child: ListView(
            shrinkWrap: true,
            children: <Widget>[
              showLogo(),
              showEmailInput(),
              showPasswordInput(),
              showConfirmPasswordInput(),
              showErrorMessage(),
              showPrimaryButton(),
              showSecondaryButton(),
            ],
          ),
        ),
      ),
    );
  }

  /// Displays the error message if any.
  Widget showErrorMessage() {
    if (_errorMessage!.isNotEmpty && _errorMessage != null) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 0.0),
        child: Center(
          child: Text(
            _errorMessage!,
            style: const TextStyle(
                fontSize: 13.0,
                color: Colors.red,
                height: 1.0,
                fontWeight: FontWeight.w300),
          ),
        ),
      );
    } else {
      return Container(
        height: 0.0,
      );
    }
  }

  /// Displays the logo.
  Widget showLogo() {
    return InkWell(
      onTap: () => auth.signOut(),
      child: Hero(
        tag: 'hero',
        child: Padding(
          padding: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
          child: CircleAvatar(
            backgroundColor: Colors.transparent,
            radius: 140.0,
            child: Image.asset('images/ic_banner.png'),
          ),
        ),
      ),
    );
  }

  /// Displays the email input field.
  Widget showEmailInput() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
      child: TextFormField(
        maxLines: 1,
        keyboardType: TextInputType.emailAddress,
        textInputAction: TextInputAction.next,
        autofocus: false,
        focusNode: _emailFocus,
        decoration: const InputDecoration(
          hintText: 'Email',
          icon: Icon(
            Icons.mail,
            color: Colors.teal,
          ),
        ),
        validator: (value) => value!.isEmpty ? 'Email can\'t be empty' : null,
        onSaved: (value) => _email = value!.trim(),
        onChanged: (value) => _email = value.trim(),
        onFieldSubmitted: (term) {
          _emailFocus.unfocus();
          FocusScope.of(context).requestFocus(_passwordFocus);
        },
      ),
    );
  }

  /// Displays the password input field.
  Widget showPasswordInput() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 15.0, 0.0, 15),
      child: TextFormField(
        maxLines: 1,
        obscureText: true,
        autofocus: false,
        textInputAction:
            _isLoginForm ? TextInputAction.done : TextInputAction.next,
        focusNode: _passwordFocus,
        decoration: const InputDecoration(
            hintText: 'Password',
            icon: Icon(
              Icons.lock,
              color: Colors.teal,
            )),
        validator: (value) =>
            value!.isEmpty ? 'Password can\'t be empty' : null,
        onChanged: (value) => _password = value.trim(),
        onSaved: (value) => _password = value!.trim(),
        onFieldSubmitted: (term) {
          if (!_isLoginForm) {
            _passwordFocus.unfocus();
            FocusScope.of(context).requestFocus(_confirmFocus);
          }
        },
      ),
    );
  }

  /// Displays the confirm password input field.
  Widget showConfirmPasswordInput() {
    return Visibility(
      visible: !_isLoginForm,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0.0, 0, 0.0, 10),
        child: TextFormField(
          maxLines: 1,
          obscureText: true,
          autofocus: false,
          focusNode: _confirmFocus,
          decoration: const InputDecoration(
              hintText: 'Confirm Password',
              icon: Icon(
                Icons.lock,
                color: Colors.teal,
              )),
          validator: (value) => value!.isEmpty
              ? 'Password can\'t be empty'
              : (value.compareTo(_password) != 0
                  ? 'Password should match'
                  : null),
          onSaved: (value) => _confirm = value!.trim(),
          onChanged: (value) => _confirm = value.trim(),
        ),
      ),
    );
  }

  /// Displays the secondary button for toggling between login and signup.
  Widget showSecondaryButton() {
    return MaterialButton(
      onPressed: () {
        setState(() {
          _isLoginForm = !_isLoginForm;
        });
      },
      child: RichText(
        text: TextSpan(
          style: const TextStyle(
            fontSize: 14.0,
            color: Colors.black,
          ),
          children: <TextSpan>[
            TextSpan(
              text:
                  _isLoginForm ? 'Don\'t have an account?' : 'Have an account?',
            ),
            TextSpan(
                text: _isLoginForm ? ' Sign up' : ' Sign in',
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurpleAccent)),
          ],
        ),
      ),
    );
  }

  /// Displays the primary button for login or signup.
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
          focusColor: Colors.red,
          onPressed: validateAndSubmit,
          child: Text(_isLoginForm ? 'Login' : 'Create account',
              style: const TextStyle(fontSize: 20.0, color: Colors.white)),
        ),
      ),
    );
  }

  /// Creates a new doctor in the database.
  Future<String> createNewDoctor({
    required String email,
    required String password,
    required String userId,
  }) async {
    try {
      debugPrint('email --> $email');
      debugPrint('password --> $password');
      final String documentId = ID.unique();
      final Map<String, dynamic> data = {
        "email": email,
        "type": "doctor",
        "uid": userId,
        "documentId": documentId,
      };

      await databases.createDocument(
        databaseId: AppConstants.appwriteDatabaseId,
        collectionId: AppConstants.userCollectionId,
        documentId: documentId,
        data: data,
      );

      return documentId;
    } on AppwriteException catch (e) {
      debugPrint("Appwrite Error - createNewDoctor: ${e.message}");
      rethrow;
    }
  }

  Future<Doctor> getDoctor() async {
    try {
      final result = await databases.listDocuments(
          databaseId: AppConstants.appwriteDatabaseId,
          collectionId: AppConstants.userCollectionId,
          queries: [
            Query.equal('type', 'doctor'),
            Query.equal('email', _email)
          ]);
      // if (result.total > 0) {
      final doc = result.documents.map((docs) => Doctor.fromMap(
            docs.data,
          ));
      debugPrint('data is here ---> ${doc.first}');
      return doc.first;
      // }
    } on AppwriteException catch (e) {
      debugPrint("Appwrite Error - getDoctor: ${e.message}");
      rethrow;
    }
  }
}
