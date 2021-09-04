import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:water_meassurement/app/modules/login/login_service.dart';
import 'package:water_meassurement/app/shared/models/user_model.dart';

class AuthController {
  UserModel? currentUser;
  final _service = LoginService();
  final emailEC = TextEditingController();
  final passwordEC = TextEditingController();

  Future login(UserModel user) async {
    final tempUser = await _service.login(user);
    currentUser = tempUser;
    currentUser!.password = passwordEC.text;
    log('Current User: ${currentUser!.toJson()}');
  }
}
