import 'package:flutter/material.dart';
import 'package:water_meassurement/app/modules/home/dao/water_consumption_dao.dart';
import 'package:water_meassurement/app/modules/login/login_service.dart';
import 'package:water_meassurement/app/shared/data/dao/UserDao.dart';
import 'package:water_meassurement/app/shared/models/user_model.dart';

class AuthController {
  bool get loginIsOnline => currentUser.loginIsOnline;
  bool get loginIsOffline => currentUser.loginIsOffline;

  final LoginService _service;
  UserDao _userDao;
  AuthController(this._service, this._userDao);

  var currentUser = UserModel();
  final emailEC = TextEditingController();
  final passwordEC = TextEditingController();

  Future login(UserModel user) async {
    final tempUser = await _service.login(user, _userDao);
    currentUser = tempUser;
    currentUser.password = passwordEC.text;
  }

  Future getImage() async {
    String image;
    if (currentUser.loginIsOnline) {
      image = await _service.getImage(currentUser.partnerId!);
    } else{
      //todo desenvolver. Parece que o getImage não está funcionando para o online tb, pois o partnerId é sempre nulo
      image = '';
    }
    currentUser.image = image;
  }

  Future sendImage() async {
    await _service.sendImage(
      id: currentUser.partnerId!,
      values: {'image': currentUser.image},
    );
  }
}
