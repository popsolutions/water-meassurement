import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:searchfield/searchfield.dart';
import 'package:water_meassurement/app/modules/auth/auth_controller.dart';
import 'package:water_meassurement/app/modules/profile/profile_page.dart';
import 'package:water_meassurement/app/shared/models/water_consumption_model.dart';
import 'home_controller.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final HomeController _controller = Get.find();
  final AuthController auth = Get.find();
  final pc = PageController(initialPage: 0).obs;

  @override
  void dispose() {
    super.dispose();
    pc.value.dispose();
    _controller.landEC.dispose();
    _controller.currentReadEC.dispose();
    _controller.lastReadEC.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Nova Leitura'),
        backgroundColor: Theme.of(context).colorScheme.secondary,
        centerTitle: true,
      ),
      body: PageView(
        controller: pc.value,
        children: [
          Container(
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: SingleChildScrollView(
                physics: BouncingScrollPhysics(),
                child: Column(
                  children: [
                    Obx(() {
                      return SearchField(
                        controller: _controller.landEC,
                        suggestions: _controller.waterConsumptions
                            .map(
                                (WaterConsumptionModel wc) => '${wc.landName!}')
                            .toList(),
                        hint: "Selecione um Terreno",
                        searchStyle: TextStyle(
                          fontSize: 18,
                          color: Colors.black.withOpacity(0.8),
                        ),
                        searchInputDecoration: InputDecoration(
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.black.withOpacity(0.8),
                            ),
                          ),
                          border: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.red),
                          ),
                        ),
                        maxSuggestionsInViewPort: 5,
                        itemHeight: 50,
                        onTap: (value) {
                          _controller.currentWaterConsumption = _controller
                              .waterConsumptions
                              .firstWhere((wc) => wc.landName == value);

                          setState(() {
                            _controller.lastReadEC.text = _controller
                                .currentWaterConsumption.lastRead
                                .toString();
                          });
                        },
                      );
                    }),
                    SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black),
                      ),
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
                    Container(
                      width: double.infinity,
                      child: ElevatedButton(
                        child: Text('Salvar medição'),
                        onPressed: () async {
                          if (_controller.currentReadEC.text.trim() != '' &&
                              _controller.landEC.text.trim() != '') {
                            await _controller.saveWaterConsumptionOdoo(context);
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
                    SizedBox(height: 50),
                    Obx(() {
                      return Visibility(
                        visible: _controller.isLoading.value,
                        child: CircularProgressIndicator(
                          color: Theme.of(context).primaryColor,
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
          ),
          ProfilePage(),
        ],
      ),
    );
  }
}
