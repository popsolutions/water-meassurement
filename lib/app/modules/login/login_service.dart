import 'package:get/get.dart';
import 'package:water_meassurement/app/config/odoo_api/odoo_api.dart';
import 'package:water_meassurement/app/shared/models/user_model.dart';

class LoginService extends GetxService {
  final _odoo = Odoo();

  Future<UserModel> login(UserModel user) async {
    final authenticate =
        await _odoo.authenticate(user.username!, user.password!);
    final response = UserModel.fromJson(authenticate);
    return response;
  }
}
