import 'dart:convert';
import 'package:get/get.dart';
import 'package:water_meassurement/app/config/http/odoo_api.dart';

class LoginService extends GetxService {
  final _odoo = Odoo();

  Future login(String username, String password) async {
    final path = _odoo.createPath("/web/session/authenticate");
    final params = {
      "db": 'db.riveira',
      "login": username,
      "password": password,
      "context": {}
    };
    final response =
        await _odoo.callDbRequest(path, _odoo.createPayload(params));

    final data = jsonDecode(response.body);
    if (data["error"] != null) {
      throw ("invalid username or password");
    }
    return data['result'];
  }
}
