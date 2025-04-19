/*
import 'dart:async';
import 'package:fetosense_remote_flutter/core/model/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';

/// Enum representing different authentication problems.
enum authProblems { UserNotFound, PasswordNotValid, NetworkError, UnknownError }

/// [Auth] class provides methods for user authentication and user management.
class Auth {
  static final FirebaseAuth _auth = FirebaseAuth.instance;


  /// Signs in a user with the given email and password.
  ///
  /// [email] is the user's email.
  /// [password] is the user's password.
  ///
  /// Returns the user's UID.
  static Future<String> signIn(String email, String password) async {
    User user = (await _auth.signInWithEmailAndPassword(
            email: email, password: password))
        .user!;
    return user.uid;
  }


  /// Signs up a new user with the given email and password.
  ///
  /// [email] is the user's email.
  /// [password] is the user's password.
  ///
  /// Returns the user's UID.
  static Future<String> signUp(String email, String password) async {
    User user = (await _auth.createUserWithEmailAndPassword(
            email: email, password: password))
        .user!;
    return user.uid;
  }


  /// Signs out the current user.
  static Future<void> signOut() async {
    return FirebaseAuth.instance.signOut();
  }


  /// Gets the current Firebase user.
  ///
  /// Returns the current user or null if no user is signed in.
  static Future<User?> getCurrentFirebaseUser() async {
    User? user = await FirebaseAuth.instance.currentUser;
    return user;
  }


  /// Adds a new user to the Firestore database.
  ///
  /// [user] is the user model to add.
  static void addUser(UserModel user) async {
    checkUserExist(user.documentId).then((value) {
      if (!value) {
        print("user ${user.name} ${user.email} added");
        FirebaseFirestore.instance
            .doc("users/${user.documentId}")
            .set(user.toJson());
      } else {
        print("user ${user.name} ${user.email} exists");
      }
    });
  }


  /// Checks if a user exists in the Firestore database.
  ///
  /// [userID] is the user's ID.
  ///
  /// Returns true if the user exists, false otherwise.
  static Future<bool> checkUserExist(String? userID) async {
    bool exists = false;
    try {
      await FirebaseFirestore.instance.doc("users/$userID").get().then((doc) {
        if (doc.exists)
          exists = true;
        else
          exists = false;
      });
      return exists;
    } catch (e) {
      return false;
    }
  }


  /// Gets a stream of user data from the Firestore database.
  ///
  /// [userID] is the user's ID.
  ///
  /// Returns a stream of [UserModel].
  static Stream<UserModel> getUser(String userID) {
    return FirebaseFirestore.instance
        .collection("users")
        .where("userID", isEqualTo: userID)
        .snapshots()
        .map((QuerySnapshot snapshot) {
      return snapshot.docs.map((doc) {
        return UserModel.fromDocument(doc);
      }).first;
    });
  }


  /// Gets the exception message for a given exception.
  ///
  /// [e] is the exception.
  ///
  /// Returns the exception message as a string.
  static String getExceptionText(Exception e) {
    if (e is PlatformException) {
      switch (e.message) {
        case 'There is no user record corresponding to this identifier. The user may have been deleted.':
          return 'User with this e-mail not found.';
        case 'The password is invalid or the user does not have a password.':
          return 'Invalid password.';
        case 'A network error (such as timeout, interrupted connection or unreachable host) has occurred.':
          return 'No internet connection.';
        case 'The email address is already in use by another account.':
          return 'Email address is already taken.';
        default:
          return 'Unknown error occured.';
      }
    } else {
      return 'Unknown error occured.';
    }
  }
}
*/
