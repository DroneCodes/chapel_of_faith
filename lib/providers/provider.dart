import 'package:chapel_of_faith/auth/auth_methods.dart';
import 'package:chapel_of_faith/models/user_model.dart';
import 'package:flutter/widgets.dart';

class UserProvider extends ChangeNotifier {
  User? _user;
  final AuthMethods authMethods = AuthMethods();

  User get getUser => _user!;

  Future<void> refreshUser() async {
    User user = await authMethods.getUserDetails();
    _user = user;
    notifyListeners();
  }
}