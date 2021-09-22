import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:searchfield/searchfield.dart';
import 'package:water_meassurement/app/modules/auth/auth_controller.dart';
import 'package:water_meassurement/app/modules/profile/profile_page.dart';
import 'package:water_meassurement/app/shared/libcomp.dart';
import 'package:water_meassurement/app/shared/models/water_consumption_model.dart';
import 'home_controller.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with AutomaticKeepAliveClientMixin<HomePage> {
  final HomeController _controller = Get.find();
  final AuthController auth = Get.find();

  final pc = PageController(initialPage: 0);
  Uint8List? photo;

  @override
  void initState() {
    super.initState();
    _controller.processListSendsWaterConsumptionOdoo();
  }

  @override
  void dispose() {
    super.dispose();
    pc.dispose();
    _controller.landEC.dispose();
    _controller.currentReadEC.dispose();
    _controller.lastReadEC.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return GestureDetector(
      onTap: () {
        FocusScopeNode().unfocus();
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Obx(() {
            return Text(_controller.titleAppBar[_controller.index.value]);
          }),
          backgroundColor: Theme.of(context).colorScheme.secondary,
          centerTitle: true,
          actions: [
            Obx(() {
              return Visibility(
                visible: _controller.index.value == 0,
                child: IconButton(
                  icon: Icon(
                    Icons.sync,
                  ),
                  onPressed: () async {
                    _controller.processListSendsWaterConsumptionOdoo();
                  },
                ),
              );
            })
          ],
        ),
        body: PageView(
          controller: pc,
          onPageChanged: (int page) {
            _controller.index.value = page;
          },
          children: [
            Container(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: SingleChildScrollView(
                  physics: BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      Obx(() {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: SearchField(
                            controller: _controller.landEC,
                            suggestions: _controller.waterConsumptions
                                .map((WaterConsumptionModel wc) =>
                                    '${wc.landName!}')
                                .toList(),
                            hint: "Selecione um Terreno",
                            searchStyle: TextStyle(
                              fontSize: 18,
                              color: Colors.black.withOpacity(0.8),
                            ),
                            maxSuggestionsInViewPort: 5,
                            itemHeight: 50,
                            onTap: (value) {
                              _controller.currentWaterConsumption = _controller
                                  .waterConsumptions
                                  .firstWhere((wc) =>
                                      wc.landName ==
                                      value); //.t. tratar null import 'package:collection/collection.dart'; firstWhereOrElseNull

                              setState(() {
                                _controller.lastReadEC.text = _controller
                                    .currentWaterConsumption.lastRead
                                    .toString();
                                if (_controller
                                        .currentWaterConsumption.currentRead ==
                                    0)
                                  _controller.currentReadEC.clear();
                                else
                                  _controller.currentReadEC.text = _controller
                                      .currentWaterConsumption.currentRead
                                      .toString();
                              });
                            },
                          ),
                        );
                      }),
                      SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _controller.lastReadEC,
                                enabled: false,
                                decoration: InputDecoration(
                                  labelText: 'Última leitura',
                                ),
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly
                                ],
                              ),
                            ),
                            SizedBox(width: 15),
                            Expanded(
                              child: TextFormField(
                                controller: _controller.currentReadEC,
                                decoration: InputDecoration(
                                  labelText: 'Leitura atual',
                                ),
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly
                                ],
                                onChanged: (value) {
                                  _controller.currentWaterConsumption
                                      .currentRead = double.parse(value);
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 10),
                      GestureDetector(
                        onTap: () async {
                          final ImagePicker _picker = ImagePicker();
                          final XFile? image = await _picker.pickImage(
                            source: ImageSource.camera,
                          );
                          if (image != null) {
                            photo = await File(image.path).readAsBytes();
                            _controller.currentWaterConsumption.photo =
                                base64Encode(
                                    File(image.path).readAsBytesSync());
                            setState(() {});
                          }
                        },
                        child: Container(
                          width: 150,
                          height: 200,
                          decoration: BoxDecoration(
                            color: Color(0xFFF0F5F7),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: photo == null
                              ? Center(
                                  child: Text(
                                  'Tire uma foto',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontFamily: 'Roboto',
                                    fontWeight: FontWeight.w600,
                                  ),
                                ))
                              : Image.memory(photo!, fit: BoxFit.cover),
                        ),
                      ),
                      SizedBox(height: 10),
                      Container(
                        height: 50,
                        width: double.infinity,
                        child: ElevatedButton(
                          child: Text('Salvar medição',
                              style: TextStyle(fontSize: 20)),
                          onPressed: () async {
                            if (_controller.currentReadEC.text
                                    .trim()
                                    .isNotEmpty &&
                                _controller.landEC.text.trim().isNotEmpty &&
                                (_controller
                                        .currentWaterConsumption.currentRead! >
                                    0) &&
                                (_controller.currentWaterConsumption.landName ==
                                    _controller.landEC.text)) {
                              try {
                                _controller
                                        .currentWaterConsumption.currentRead =
                                    double.parse(
                                        _controller.currentReadEC.text);
                                await _controller
                                    .saveWaterConsumptionDao(context);
                                _controller.currentReadEC.clear();
                                _controller.lastReadEC.clear();
                                _controller.landEC.clear();
                                setState(() {
                                  photo = null;
                                });
                              } catch (e) {
                                LibComp.showMessage(context,
                                    'Falha ao efetuar leitura', e.toString());
                              }
                            } else {
                              Get.snackbar(
                                'Falha ao Salvar',
                                'Preencha todos os campos',
                                colorText: Colors.white,
                                backgroundColor: Colors.red,
                                snackPosition: SnackPosition.BOTTOM,
                                margin: const EdgeInsets.all(10),
                              );
                            }
                          },
                        ),
                      ),
                      SizedBox(height: 20),
                      Obx(() {
                        return Visibility(
                          visible: _controller.isLoading.value,
                          child: CircularProgressIndicator(
                            color: Theme.of(context).primaryColor,
                          ),
                        );
                      }),
                      Obx(() {
                        return Container(
                          width: double.infinity,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    'Ler: ',
                                    style: TextStyle(fontSize: 15),
                                  ),
                                  Text(
                                    _controller.amountToRead.string,
                                    style: TextStyle(
                                      color: Colors.green,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              Spacer(),
                              Row(
                                children: [
                                  Text(
                                    'A Enviar: ',
                                    style: TextStyle(fontSize: 15),
                                  ),
                                  Text(
                                    _controller.amountToSend.string,
                                    style: TextStyle(
                                      color: Colors.red,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              Spacer(),
                              Row(
                                children: [
                                  Text(
                                    'Enviadas: ',
                                    style: TextStyle(fontSize: 15),
                                  ),
                                  Text(
                                    _controller.amountSend.string,
                                    style: TextStyle(
                                      color: Colors.blueAccent,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              )
                            ],
                          ),
                        );
                      })
                    ],
                  ),
                ),
              ),
            ),
            ProfilePage(),
          ],
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
