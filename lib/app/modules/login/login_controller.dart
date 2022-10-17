import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:water_meassurement/app/config/app_constants.dart';
import 'package:water_meassurement/app/config/app_routes.dart';
import 'package:water_meassurement/app/modules/auth/auth_controller.dart';
import 'package:water_meassurement/app/shared/models/user_model.dart';

class LoginController extends GetxController {
  var isLoading = false.obs;
  var isPasswordObscure = true.obs;

  checkUser(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final userPrefs = prefs.getString(AppConstants.CURRENT_USER_SHARED_PREFS,);

    if (userPrefs != null) {
      final authProvider = Provider.of<AuthController>(
        context,
        listen: false,
      );

      authProvider.currentUser = UserModel.fromJson(json.decode(userPrefs));
      authProvider.currentUser.loginOnlineOffline = LoginOnlineOffline.offline;
      Get.offAllNamed(Routes.HOME);
    }
  }
}
