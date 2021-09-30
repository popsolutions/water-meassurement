import 'package:flutter_test/flutter_test.dart';

void main() {
  bool isInit = false;

  Future<void> initLogin() async {
    // LoginServiceImpl login = LoginServiceImpl(Odoo());
    // // LoginDto loginDto = LoginDto('support@popsolutions.co', '1ND1C0p4c1f1c0');
    // LoginDto loginDto = LoginDto('mateus.2006@gmail.com', 'mateus');
    //
    // currentLoginResult = await login.login(loginDto);
    // currentUser =
    // await userServiceImpl.getUserFromLoginResult(currentLoginResult);
    // globalcurrentUser = currentUser;
  }

  Future<void> init() async {
    if (isInit) return;

    await initLogin();

    isInit = true;
  }

  setUp(() {
    print('test Start');
  });

  setUpAll(() async {
    await init();
    print('Start all');
  });

  tearDown(() {
    print('test end');
  });

  tearDownAll(() {
    print('End All');
  });


  test('service.test', () async {

  });
}
