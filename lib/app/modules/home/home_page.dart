import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:water_meassurement/app/shared/models/water_consumption_model.dart';

import 'home_controller.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _controller = Get.put(HomeController());
  // final LoginController _loginController = Get.find();
  var valueChoose;

  @override
  void initState() {
    super.initState();
    _controller.currentWaterConsumption.date =
        DateFormat('yyyy-MM-dd').format(DateTime.now());
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
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Obx(() {
                          return Text(
                            _controller.format.format(_controller.date.value!),
                            style: TextStyle(fontWeight: FontWeight.bold),
                          );
                        }),
                      ),
                      Expanded(
                        child: ElevatedButton(
                          child: Text('Alterar Data'),
                          onPressed: () async {
                            final currentDate = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate:
                                  DateTime.now().subtract(Duration(days: 30)),
                              lastDate: DateTime.now(),
                            );
                            if (currentDate != null) {
                              _controller.date.value = currentDate;
                              _controller.currentWaterConsumption.date =
                                  DateFormat('yyyy-MM-dd').format(currentDate);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
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
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          decoration:
                              InputDecoration(labelText: 'Última leitura'),
                        ),
                      ),
                      SizedBox(width: 50),
                      Expanded(
                        child: TextFormField(
                          onChanged: (value) {
                            _controller.currentWaterConsumption.lastRead =
                                double.parse(value);
                            _controller.currentWaterConsumption.consumption =
                                double.parse(value);
                          },
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          decoration:
                              InputDecoration(labelText: 'Leitura atual'),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                DropdownButton(
                  isExpanded: true,
                  hint: Text('Selecionar Área'),
                  onChanged: (newValue) {
                    setState(() {
                      valueChoose = newValue;
                    });
                  },
                  items: [
                    DropdownMenuItem(
                      value: 'Oi',
                      child: Text('18B 14'),
                    ),
                    DropdownMenuItem(
                      value: 'Tchau',
                      child: Text('18C 64'),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  child: ElevatedButton(
                    child: Text('Salvar Medição'),
                    onPressed: () async {
                      await _controller
                          .saveWaterConsumption(WaterConsumptionModel());
                      // await _controller.readWaterConsumption();
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
