import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'home_controller.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _controller = Get.put(HomeController());
  var valueChoose;

  @override
  void initState() {
    super.initState();
    _controller.currentWaterConsumption.date =
        _controller.format.format(DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
    // final auth = Provider.of<AuthController>(context, listen: false);

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
                DropdownButton(
                  isExpanded: true,
                  hint: Text('Selecionar Terreno'),
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
                      // await _controller.saveWaterConsumption(
                      //     _controller.currentWaterConsumption);
                      // await _controller.readWaterConsumption();
                      await _controller.getLands();
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
