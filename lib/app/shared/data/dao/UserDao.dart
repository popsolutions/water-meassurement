import 'package:sqflite/sqflite.dart';
import 'package:water_meassurement/app/shared/data/database/app_database.dart';
import 'package:water_meassurement/app/shared/models/user_model.dart';

class UserDao {
  late Database _db;

  Future<void> saveLoginOffline(UserModel user) async {
    //Esta rotina vai atualizar no Sqlite o <user>(Recebido do servidor)
    String sql = "insert or replace into user (uid,name,image,username,password,partnerDisplayName,companyId,partnerId) values (" +
        user.uid.toString() + ", '" +
        (user.name ?? '') + "', '" +
        (user.image ?? '') + "', '" +
        (user.username ?? '') + "', '" +
        (user.password ?? '') + "', '" +
        (user.partnerDisplayName ?? '') + "', " +
        user.companyId.toString() + ", " +
        user.partnerId.toString() + ")";

    _db = await AppDatabase.instance.database;
    await _db.execute(sql);
    return;
  }

  Future<UserModel> loginOffline(UserModel user) async {
    UserModel userModel = await getuserDaoDao(user.username!);
    return userModel;
  }

  Future<UserModel> getuserDaoDao(String userName) async {
    _db = await AppDatabase.instance.database;
    final userDao = await _db.rawQuery("select * from user where username = '$userName'");

    if (userDao.length == 1) {
      final UserModel userModel = UserModel.fromJson(userDao[0]);
      userModel.loginOnlineOffline = LoginOnlineOffline.offline;
      return userModel;
    } else if (userDao.length == 0) {
      throw 'Usuário não encontrado. Verifique Usuário/Senha ou tente quando o App estiver Online';
    } else {
      throw 'Encontrado mais que um usuário. tente novamente quando o App estiver Online';
    }
  }
}
