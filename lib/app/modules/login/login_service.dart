import 'package:get/get.dart';
import 'package:water_meassurement/app/shared/utils/global.dart';
import 'package:water_meassurement/app/shared/models/user_model.dart';

class LoginService extends GetxService {
  Future<UserModel> login(UserModel user) async {
    final auth = await odoo.authenticate(user.username!, user.password!);
    final userResponse = UserModel.fromJson(auth);
    return userResponse;
  }

  getImage(int id) async {
    final auth = await odoo.searchRead(
      'res.partner',
      [
        ["id", "=", "$id"]
      ],
      ["image"],
    );
    final List list = auth.getRecords();
    return list[0]['image'];
  }

  sendImage({required int id, required Map values}) async {
    await odoo.write(
      'res.partner',
      [id],
      values,
    );
  }
}
