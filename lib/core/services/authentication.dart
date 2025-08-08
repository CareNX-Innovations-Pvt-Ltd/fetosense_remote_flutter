import 'dart:async';
import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import 'package:fetosense_remote_flutter/core/network/appwrite_config.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';

/// An abstract class that defines the authentication methods.

abstract class BaseAuth {
  Future<String> signIn(String email, String password);
  Future<String> signUp(String email, String password);
  Future<User> getCurrentUser();
  Future<void> signOut();
}

class Auth extends BaseAuth {
  // 🔁 Singleton instance
  static final Auth _instance = Auth._internal();
  final Account _account;

  // 🔐 Private constructor
  Auth._internal() : _account = Account(GetIt.I<AppwriteService>().client);

  // 🧩 Factory constructor returns the same instance
  factory Auth() => _instance;

   // Account _account = Account(GetIt.I<AppwriteService>().client);

  Auth.internalTest(this._account);

  @override
  Future<String> signIn(String email, String password) async {
    try {
      final session = await _account.createEmailPasswordSession(
        email: email,
        password: password,
      );
      debugPrint('Login successful. Session ID: ${session.$id}');
      return session.userId;
    } on AppwriteException catch (e) {
      throw Exception('Failed to sign in: ${e.message}');
    }
  }

  @override
  Future<String> signUp(String email, String password) async {
    final id = ID.unique();
    try {
      final user = await _account.create(
        userId: id,
        email: email,
        password: password,
      );
      debugPrint('User signed up: ${user.$id}');
      return id;
    } on AppwriteException catch (e) {
      throw Exception('Failed to register user: ${e.message}');
    }
  }

  @override
  Future<User> getCurrentUser() async {
    try {
      final user = await _account.get();
      debugPrint('Logged in user: ${user.email}');
      return user;
    } on AppwriteException catch (e) {
      throw Exception('Failed to get user: ${e.message}');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _account.deleteSessions();
      debugPrint('User signed out');
    } on AppwriteException catch (e) {
      throw Exception('Failed to sign out: ${e.message}');
    }
  }
}
