import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:searchfield/searchfield.dart';
import 'package:water_meassurement/app/modules/auth/auth_controller.dart';
import 'package:water_meassurement/app/shared/models/land_model.dart';
import 'home_controller.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final HomeController _controller = Get.find();
  final AuthController auth = Get.find();

  @override
  void initState() {
    super.initState();
    _controller.currentWaterConsumption.readerId = Provider.of<AuthController>(
      context,
      listen: false,
    ).currentUser.partnerId;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Water Consumption'),
        backgroundColor: Theme.of(context).colorScheme.secondary,
        centerTitle: true,
      ),
      body: Container(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            child: Column(
              children: [
                Obx(() {
                  return SearchField(
                    suggestions: _controller.lands
                        .map((LandModel land) =>
                            '${land.name!} (ID: ${land.id!})')
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
                    onTap: (x) {
                      _controller.currentWaterConsumption.landId =
                          int.parse(x!.split(' ').last.replaceAll(')', ''));
                    },
                  );
                }),

                // Obx(() {
                // return DropdownSearch(
                //   mode: Mode.MENU,
                //   items: _controller.lands
                //       .map((LandModel land) => land.name!)
                //       .toList(),
                //   label: "Selecione um Terreno",
                //   onChanged: (land) {
                //     // _controller.currentWaterConsumption.landId = land!.id;
                //   },
                // );
                // }),
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
                          decoration: InputDecoration(
                            labelText: 'Leitura atual',
                          ),
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          onChanged: (value) {
                            _controller.currentWaterConsumption.currentRead =
                                double.parse(value);
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
                    child: Text('Salvar Medição'),
                    onPressed: () async {
                      _controller.isLoading.value = true;
                      await _controller.saveWaterConsumption();
                      _controller.isLoading.value = false;

                      print(_controller.currentWaterConsumption.toJson());
                      print(Provider.of<AuthController>(
                        context,
                        listen: false,
                      ).currentUser.toJson());
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
    );
  }
}
