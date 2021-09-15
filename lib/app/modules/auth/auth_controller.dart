import 'package:flutter/material.dart';
import 'package:water_meassurement/app/modules/login/login_service.dart';
import 'package:water_meassurement/app/shared/models/user_model.dart';

class AuthController {
  final LoginService _service;
  AuthController(this._service);

  var currentUser = UserModel();
  final emailEC = TextEditingController();
  final passwordEC = TextEditingController();

  Future login(UserModel user) async {
    final tempUser = await _service.login(user);
    currentUser = tempUser;
    currentUser.password = passwordEC.text;
  }

  Future getImage() async {
    final image = await _service.getImage(currentUser.partnerId!);
    currentUser.image = image;
  }

  Future sendImage() async {
    await _service.sendImage(
      id: currentUser.partnerId!,
      values: {'image': currentUser.image},
    );
  }
}
