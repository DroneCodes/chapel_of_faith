import 'package:chapel_of_faith/auth/auth_methods.dart';
import 'package:chapel_of_faith/models/user_model.dart';
import 'package:flutter/material.dart';

class UserProvider extends ChangeNotifier {
  final AuthMethods authMethods = AuthMethods();
  User? _user;

  User get getUser => _user!;

  Future<void> refreshUser() async {
    User user = await authMethods.getUserDetails();
    _user = user;
    notifyListeners();
  }
}