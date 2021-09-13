import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:water_meassurement/app/modules/auth/auth_controller.dart';
import 'package:water_meassurement/app/modules/home/home_controller.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with AutomaticKeepAliveClientMixin<ProfilePage> {
  late AuthController auth;
  final HomeController _controller = Get.find();
  Uint8List? photo;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    auth = Provider.of<AuthController>(context, listen: false);
    // photo = await File(auth.currentUser.image!).readAsBytes();
    photo = Base64Codec().decode(auth.currentUser.image!);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            GestureDetector(
              onTap: () async {
                await showModalBottomSheet(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(20),
                      topLeft: Radius.circular(20),
                    ),
                  ),
                  context: context,
                  builder: (_) {
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          margin: EdgeInsets.only(
                            top: 20,
                            bottom: 10,
                          ),
                          height: 3,
                          width: 60,
                        ),
                        Container(
                          width: Get.width * .5,
                          child: ElevatedButton.icon(
                            icon: Icon(Icons.camera_alt),
                            label: Text('Tire uma foto.'),
                            onPressed: () async {
                              final ImagePicker _picker = ImagePicker();
                              final XFile? image = await _picker.pickImage(
                                source: ImageSource.camera,
                              );
                              if (image != null) {
                                photo = await File(image.path).readAsBytes();
                                setState(() {});
                                auth.currentUser.image = base64Encode(
                                    File(image.path).readAsBytesSync());
                                await auth.sendImage(); //TODO: ERRO AO ENVIAR
                                Get.back();
                              }
                              Get.back();
                            },
                          ),
                        ),
                        Container(
                          width: Get.width * .5,
                          child: ElevatedButton.icon(
                            icon: Icon(Icons.attach_file_outlined),
                            label: Text('Escolha um arquivo'),
                            onPressed: () async {
                              final ImagePicker _picker = ImagePicker();
                              final XFile? image = await _picker.pickImage(
                                source: ImageSource.gallery,
                              );
                              if (image != null) {
                                photo = await File(image.path).readAsBytes();
                                setState(() {});
                                // auth.currentUser.image =
                                //     await File(image.path).readAsBytes();
                                // await auth.sendImage(); //TODO: ERRO AO ENVIAR
                                Get.back();
                              }
                              Get.back();
                            },
                          ),
                        ),
                        SizedBox(height: 10),
                      ],
                    );
                  },
                );
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(100),
                child: (photo == null)
                    ? CircleAvatar(
                        backgroundColor: Colors.grey,
                        radius: 100,
                        child: Icon(
                          Icons.person,
                          size: 150,
                          color: Colors.white,
                        ),
                      )
                    : Image.memory(
                        photo!,
                        fit: BoxFit.cover,
                        width: 200,
                        height: 200,
                      ),
              ),
            ),
            SizedBox(height: 30),
            TextFormField(
              enabled: false,
              initialValue: auth.currentUser.name,
            ),
            SizedBox(height: 20),
            TextFormField(
              initialValue: auth.currentUser.username,
              enabled: false,
            ),
            SizedBox(height: 30),
            Container(
              width: double.infinity,
              child: ElevatedButton(
                child: Text('Sair'),
                style: ElevatedButton.styleFrom(
                  primary: Colors.redAccent[400],
                ),
                onPressed: () async {
                  await _controller.logout();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
