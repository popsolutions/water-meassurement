import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:searchfield/searchfield.dart';
import 'package:water_meassurement/app/modules/profile/profile_page.dart';
import 'package:water_meassurement/app/shared/models/water_consumption_model.dart';
import 'home_controller.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with AutomaticKeepAliveClientMixin<HomePage> {
  final HomeController _controller = Get.find();
  final pc = PageController(initialPage: 0);

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
                                  .firstWhere((wc) => wc.landName == value);

                              setState(() {
                                _controller.lastReadEC.text = _controller
                                    .currentWaterConsumption.lastRead
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
                      Container(
                        width: double.infinity,
                        child: ElevatedButton(
                          child: Text('Salvar medição'),
                          onPressed: () async {
                            if (_controller.currentReadEC.text
                                    .trim()
                                    .isNotEmpty &&
                                _controller.landEC.text.trim().isNotEmpty) {
                              await _controller
                                  .saveWaterConsumptionOdoo(context);
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
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
