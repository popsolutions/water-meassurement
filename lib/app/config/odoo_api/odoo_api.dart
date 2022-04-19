import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:water_meassurement/app/config/app_routes.dart';
import 'odoo_response.dart';
import 'odoo_version.dart';

class Odoo extends GetConnect {
  get _serverURL => 'https://riviera-prod.popsolutions.co';
  get versionInfo => _serverURL + '/web/webclient/version_info';
  Map<String, String> _headers = {};
  var version = OdooVersion();
  String? _sessionId;
  int? _uid;
  String cookie = '';

  String createPath(String path) {
    return _serverURL + path;
  }

  setSessionId(String sessionIid) {
    _sessionId = sessionIid;
  }

  Future<OdooResponse> getSessionInfo() async {
    var url = createPath("/web/session/get_session_info");
    return await callRequest(url, createPayload({}));
  }

  Future<OdooResponse> destroy() async {
    var url = createPath("/web/session/destroy");
    final res = await callRequest(url, createPayload({}));
    cookie = '';
    return res;
  }

  // Authenticate user
  Future<dynamic> authenticate(String username, String password) async {
    final path = createPath("/web/session/authenticate");
    final params = {
      "db": 'riviera-migracao',
      "login": username,
      "password": password,
      "context": {}
    };
    final response = await callDbRequest(path, createPayload(params));

    final data = response.body;
    if (data["error"] != null) {
      throw ("invalid username or password");
    }

    return response.body['result'];
  }

  Future<OdooResponse> read(String model, List<int> ids, List<String> fields,
      {dynamic kwargs, Map? context}) async {
    return await callKW(model, "read", [ids, fields],
        kwargs: kwargs, context: context);
  }

  Future<OdooResponse> searchRead(
      String model, List domain, List<String> fields,
      {int offset = 0, int limit = 0, String order = ""}) async {
    var url = createPath("/web/dataset/search_read");
    var params = {
      "context": getContext(),
      "domain": domain,
      "fields": fields,
      "limit": limit,
      "model": model,
      "offset": offset,
      "sort": order
    };
    return await callRequest(url, createPayload(params));
  }

  // Call any model method with arguments
  Future<OdooResponse> callKW(String model, String method, List args,
      {dynamic kwargs, Map? context}) async {
    kwargs = kwargs == null ? {} : kwargs;
    context = context == null ? {} : context;
    var url = createPath("/web/dataset/call_kw/" + model + "/" + method);
    var params = {
      "model": model,
      "method": method,
      "args": args,
      "kwargs": kwargs,
      "context": context
    };
    return await callRequest(url, createPayload(params));
  }

  // Create new record for model
  Future<OdooResponse> create(String model, Map values) async {
    return await callKW(model, "create", [values]);
  }

  // Write record with ids and values
  // atualizar
  Future<OdooResponse> write(String model, List<int> ids, Map values) async {
    return await callKW(model, "write", [ids, values]);
  }

  // Remove record from system
  // deletar
  Future<OdooResponse> unlink(String model, List<int> ids) async {
    return await callKW(model, "unlink", [ids]);
  }

  // Call json controller
  Future<OdooResponse> callController(String path, Map params) async {
    return await callRequest(createPath(path), createPayload(params));
  }

  String getSessionId() {
    return _sessionId!;
  }

  // connect to odoo and set version and databases
  Future<OdooVersion> connect() async {
    OdooVersion odooVersion = await getVersionInfo();
    return odooVersion;
  }

  // get version of odoo
  Future<OdooVersion> getVersionInfo() async {
    var url = createPath("/web/webclient/version_info");
    final response = await callRequest(url, createPayload({}));
    version = OdooVersion().parse(response);
    return version;
  }

  Future getDatabases() async {
    var serverVersionNumber = await getVersionInfo();

    if (serverVersionNumber.getMajorVersion() == null) {
      version = await getVersionInfo();
    }
    String url = getServerURL();
    var params = {};
    // if (serverVersionNumber != null) {
    if (serverVersionNumber.getMajorVersion() == 9) {
      url = createPath("/jsonrpc");
      params["method"] = "list";
      params["service"] = "db";
      params["args"] = [];
    } else if (serverVersionNumber.getMajorVersion() >= 10) {
      url = createPath("/web/database/list");
      params["context"] = {};
    } else {
      url = createPath("/web/database/get_list");
      params["context"] = {};
      // }
    }
    final response = await callDbRequest(url, createPayload(params));
    return response;
  }

  String getServerURL() {
    return _serverURL;
  }

  Map createPayload(Map params) {
    return {
      "id": Uuid().v1(),
      "jsonrpc": "2.0",
      "method": "call",
      "params": params,
    };
  }

  Map getContext() {
    return {"lang": "en_US", "tz": "Europe/Brussels", "uid": _uid};
  }

  Future<OdooResponse> callRequest(String url, Map payload) async {
    final response = await callDbRequest(url, payload);
    OdooResponse odooResponse =
        new OdooResponse(response.body, response.statusCode);

    if (odooResponse.hasError()) {
      if (odooResponse.getErrorMessage() == 'Session expired') {
        final prefs = await SharedPreferences.getInstance();
        await prefs.clear();
        Get.snackbar(
          'Sessão expirou!',
          'Faça login novamente.',
          colorText: Colors.white,
          backgroundColor: Colors.red,
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(10),
        );
        await Future.delayed(Duration(seconds: 2));
        Get.offAllNamed(Routes.LOGIN);
      }
      throw odooResponse.getErrorMessage().toString();
    }

    return odooResponse;
  }

  Future callDbRequest(String url, Map payload) async {
    var body = json.encode(payload);
    _headers["Content-type"] = "application/json; charset=UTF-8";
    _headers["Cookie"] = cookie;
    print("------------------------------------------->>>>");
    print("REQUEST: $url\n");
    print("BODY:\n $body\n");
    print("HEADERS.:");
    _headers.forEach((key, String? value) {
      print(key + ':' + (value ?? '') + '\n');
    });
    print("------------------------------------------->>>>");
    final response = await post(url, body, headers: _headers);

    if (response.body == null) {
      throw 'Odoo Conection error Url';
    } else {
      _updateCookies(response);
      print("<<<<============================================");
      print("RESPONSE: ${response.body}");
      print("<<<<============================================");

      return response;
    }
  }

  _updateCookies(response) async {
    String? rawCookie = response.headers['set-cookie'];
    if (rawCookie != null) {
      _headers['Cookie'] = rawCookie;
      cookie = rawCookie;
    }
  }

  Future check() {
    var url = createPath("/web/session/check");
    final res = callDbRequest(url, createPayload({}));
    return res;
  }

  Future<OdooResponse> hasRight(String model, List right) {
    var url = createPath("/web/dataset/call_kw");
    var params = {
      "model": model,
      "method": "has_group",
      "args": right,
      "kwargs": {},
      "context": getContext()
    };
    final res = callRequest(url, createPayload(params));
    return res;
  }
}

class Constants {
  static const String UUID = "uuid";
  static const String SESSION_ID = "session_id";
  static const String USER_PREF = "UserPrefs";
  static const String ODOO_URL = "odooUrl";
  static const String SESSION = "session";
  static const String PERSON_ID = "person_id";
}
