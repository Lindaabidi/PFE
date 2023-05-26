import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:syncfusion_flutter_gauges/gauges.dart';

class Temps extends StatefulWidget {
  @override
  _TempsState createState() => _TempsState();
}

class _TempsState extends State<Temps> {
  static const String apiUrl = 'http://192.168.1.12/crud/display.php';

  Future<List<dynamic>> getData() async {
    final response =
    await http.get(Uri.parse('http://192.168.1.12/crud/display.php?table=temps'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load data from API');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: FutureBuilder<List<dynamic>>(
        future: getData(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Items(list: snapshot.data!);
          } else if (snapshot.hasError) {
            return Center(child: Text('${snapshot.error}'));
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}

class Items extends StatelessWidget {
  final List<dynamic> list;
  const Items({required this.list});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      //itemCount: list.length,
      itemBuilder: (context, index) {
        List<Widget> widgets = [];
        Map<String, dynamic> row = list[index];
        row.forEach((key, value) {
          widgets.add(
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(key,
                    style:  TextStyle(
                      fontSize: 20,
                      // fontWeight: FontWeight.bold,
                    ),
                  ),
                   SizedBox(height: 5),

                  SfRadialGauge(
                    axes: <RadialAxis>[
                      RadialAxis(
                        minimum: 0,
                        maximum: 1000,
                        showLabels: true,
                        showTicks: true,
                        axisLineStyle: const AxisLineStyle(
                          thickness: 0.2,
                          cornerStyle: CornerStyle.bothCurve,
                          color: Color.fromARGB(30, 0, 169, 181),
                          thicknessUnit: GaugeSizeUnit.factor,

                        ),
                        pointers:  <GaugePointer>[
                          RangePointer(
                            value: double.parse(value.toString()),

                            width: 0.2,
                            sizeUnit: GaugeSizeUnit.factor,
                            enableAnimation: true,
                            animationDuration: 1000,
                            animationType: AnimationType.easeOutBack,
                            cornerStyle: CornerStyle.bothCurve,
                            color: Color.fromARGB(255, 0, 169, 181),

                          )

                        ],
                      )
                    ],
                  ),

                ],
              ),
            ),
          );
        });
        return Row(
          children: widgets,
        );

      },
    );
  }
}