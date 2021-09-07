import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:water_meassurement/app/shared/models/land_model.dart';

import 'home_controller.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final HomeController _controller = Get.find();
  var valueChoose;

  @override
  void initState() {
    super.initState();
    _controller.currentWaterConsumption.date =
        _controller.format.format(DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Water Consumption'),
        centerTitle: true,
      ),
      body: Container(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            child: Column(
              children: [
                // Obx(() {
                //   return DropdownButton(
                //     value: valueChoose,
                //     isExpanded: true,
                //     hint: Text('Selecionar Terreno'),
                //     onChanged: (newValue) {
                //       setState(() {
                //         valueChoose = newValue;
                //       });
                //     },
                //     items: _controller.lands.map((LandModel land) {
                //       return DropdownMenuItem(
                //         value: land.id,
                //         child: Text(land.name!),
                //         onTap: () {
                //           _controller.currentWaterConsumption.landId = land.id;
                //         },
                //       );
                //     }).toList(),
                //   );
                // }),
                DropdownSearch<String>(
                  mode: Mode.BOTTOM_SHEET,
                  items: _controller.lands
                      .map((LandModel land) => land.name!)
                      .toList(),
                  label: "Selecione um Terreno",
                  // onChanged: (LandModel? land) {
                  //   _controller.currentWaterConsumption.landId = land!.id;
                  // },
                ),
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
                      // await _controller.saveWaterConsumption()
                      print(_controller.currentWaterConsumption.toJson());
                      // await _controller.readWaterConsumption();
                      // await _controller.getLands();
                      // print(_controller.currentWaterConsumption.toJson());
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
