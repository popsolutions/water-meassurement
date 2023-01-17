import 'package:get/get.dart';
import 'package:water_meassurement/app/modules/home/dao/water_consumption_dao.dart';
import 'package:water_meassurement/app/shared/data/dao/UserDao.dart';
import 'package:water_meassurement/app/shared/utils/global.dart';
import 'package:water_meassurement/app/shared/models/user_model.dart';

class LoginService extends GetxService {

  Future<UserModel> login(UserModel user, UserDao _userDao) async {

    try {
      final auth = await odoo.authenticate(user.username!, user.password!);
      final userResponse = UserModel.fromJson(auth);
      userResponse.loginOnlineOffline = LoginOnlineOffline.online;

      _userDao.saveLoginOffline(userResponse);
      return userResponse;
    }catch(e){
      if (e.toString().toUpperCase().contains('Odoo Conection error Url'.toUpperCase())) {
        final userResponse = await _userDao.loginOffline(user);
        return userResponse;
      }

      throw e;
    }
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

    final res = list[0]['image'];

    if (res.runtimeType.toString() == 'bool')
      return null;

    return res;
  }

  sendImage({required int id, required Map values}) async {
    await odoo.write(
      'res.partner',
      [id],
      values,
    );
  }
}
