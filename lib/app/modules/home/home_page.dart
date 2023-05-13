import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
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
  AuthController auth = Get.find();

  final pc = PageController(initialPage: 0);
  Uint8List? photo;

  @override
  void initState() {
    super.initState();
    _controller.processListSendsWaterConsumptionOdoo();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    auth = Provider.of<AuthController>(context, listen: false);
  }

  @override
  void dispose() {
    super.dispose();
    pc.dispose();
    _controller.landEC.dispose();
    _controller.currentReadEC.dispose();
    _controller.lastReadEC.dispose();
  }

  TextEditingController _textFieldController = TextEditingController();
  bool _showPasswordDialogCancel = false;

  _showPasswordDialog() async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Senha para liberação'),
            content: TextFormField(
              //not sure if i need this
              controller: _textFieldController,
              decoration: InputDecoration(hintText: 'Senha'),
              maxLength: 15,
              obscureText: true,
              validator: (String? value) {
                if (value!.isEmpty) {
                  return 'Informe a senha';
                }
                //maybe not necessary for toString()

                return null;
              },
            ),
            actions: [
              FlatButton(
                child: Text('Cancelar'),
                onPressed: () {
                  _showPasswordDialogCancel = true;
                  Navigator.pop(context);
                }
              ),
              FlatButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
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
          leading:
            auth.loginIsOnline ?
              Icon(Icons.wifi, color: Colors.blue):
              Icon(Icons.wifi_off, color: Colors.orange),
          actions: [
            Obx(() {
              return _controller.index.value == 0
                  ? IconButton(
                      icon: Icon(
                        Icons.sync,
                      ),
                      onPressed: () async {
                        if (auth.loginIsOffline){
                          LibComp.showMessage(context, 'Opss', 'Você fez o login offline. Para sincronizar é preciso fazer o login quando o App estiver Online.');
                        } else {
                          _controller.processListSendsWaterConsumptionOdoo();
                        }
                      },
                    )
                  :
                   _controller.isLoading.value?
                   Row(
                     children: [
                       Center(
                         child: Container(
                           width: 16,
                           height: 16,
                             child: CircularProgressIndicator.adaptive()
                         ),
                       ),
                       Container(
                         width: 16,
                       )
                     ],
                   ):

                   IconButton(
                      icon: Icon(
                        Icons.update,
                      ),
                      onPressed: () async {
                            if (auth.loginIsOffline) {
                              LibComp.showMessage(context, 'Opss',
                                  'Você fez o login offline. Para sincronizar é preciso fazer o login quando o App estiver Online.');
                            } else {
                              _textFieldController.text = '';
                              _showPasswordDialogCancel = false;
                              await _showPasswordDialog();

                              if (_showPasswordDialogCancel)
                                return;

                              if (_textFieldController.text != 'rivi'){
                                LibComp.showMessage(context, 'Aviso', 'Senha inválida.');
                                return;
                              }

                              _controller.isLoading.value = true;
                              try {
                                try {
                                  await _controller.setAmount();

                                  if (_controller.amountToSend > 0) {
                                    if (!(await LibComp.showQuestion(context, 'Confirmação?',
                                        'Existem ${_controller.amountToSend.toString()} leituras que não foram enviadas. Se você continuar elas serão perdidas. Deseja relamente continuar?'))) {
                                      LibComp.showMessage(context, 'Aviso', 'Operação de atualização cancelada pelo Usuário.');
                                      throw 'Operação cancelada pelo usuário';
                                      //to.melhorias- Quando excluir leituras não enviadas, poderia armazenar no odoo em algum lugar estes dados
                                    }
                                  }
                                  await _controller.clearWaterConsumptionsDao();
                                  await _controller.loginSaveWaterConsumptionsDB(true);
                                  await _controller.getWaterConsumptionsDB();
                                  await _controller.setAmount();
                                } finally {
                                  _controller.isLoading.value = false;
                                }

                                Get.snackbar(
                                  'Operação Concluída',
                                  'Os dados foram atualizados com sucesso',
                                  colorText: Colors.white,
                                  backgroundColor: Colors.green,
                                  snackPosition: SnackPosition.BOTTOM,
                                  margin: const EdgeInsets.all(10),
                                );
                              } catch (e) {
                                LibComp.showMessage(context, 'Opss', 'Falha ao baixar as leituras para este mês:\n${e.toString()}');
                              }
                            }
                          },
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
                                _controller.lastReadEC.text = (_controller
                                    .currentWaterConsumption.lastRead ?? 0)
                                    .toStringAsFixed(0);
                                if (_controller
                                        .currentWaterConsumption.currentRead ==
                                    0)
                                  _controller.currentReadEC.clear();
                                else
                                  _controller.currentReadEC.text = (_controller
                                      .currentWaterConsumption.currentRead ?? 0)
                                      .toStringAsFixed(0);
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
                            imageQuality: 20
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
                                    _controller.landEC.text) &&
                                (int.parse(_controller.currentReadEC.text == '' ? '0' :_controller.currentReadEC.text) < 100000)) {
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
                              String mensagem = 'Preencha todos os campos';

                              if ((int.parse(_controller.currentReadEC.text == '' ? '0' :_controller.currentReadEC.text)) >= 100000)
                                mensagem = 'Leitura atual tem que ser inferior a 100.000';

                              Get.snackbar(
                                'Falha ao Salvar',
                                mensagem,
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
