import 'dart:math';

import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;



class KPI extends StatefulWidget {
  @override
  _KPIState createState() => _KPIState();
}

class _KPIState extends State<KPI> {
  static const String apiUrl = 'http://192.168.1.12/crud/lister.php';

  Future<List<dynamic>> getData() async {
    final response = await http.get(Uri.parse('http://192.168.1.12/crud/lister.php?table=kpi'));
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
      itemCount: list.length,
      itemBuilder: (context, index) {
        Map<String, dynamic> row = list[index];
        List<Map<String, dynamic>> data = [];
        row.forEach((key, value) {
          if (key != 'id') {
            data.add({
              'name': key,
              'value': value,
            });
          }
        });
        return Card(
          child: Padding(
            padding:  EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [

                 SizedBox(height: 30,width: 400,),

                SfCircularChart(
                  title: ChartTitle(
                      text:'KPI',
                      textStyle: TextStyle(fontSize: 24.0)
                  ),

                  legend: Legend(
                    isVisible: true,
                    textStyle: TextStyle(
                      // color: Colors.black,
                      fontSize: 14,
                      //fontWeight: FontWeight.bold,
                    ),
                  ),
                  //height:300,

                  series: <CircularSeries>[
                    PieSeries<Map<String, dynamic>, String>(
                      dataSource: data,
                      pointColorMapper: (data, _) => getRandomColor(),
                      xValueMapper: (data, _) => data['name'],
                      yValueMapper: (data, _) => data['value'],
                      // radiusFactor: 0.8,

                      dataLabelMapper: (data, _) => '${data['value'].toStringAsFixed(2)}%',
                      dataLabelSettings:  DataLabelSettings(
                        isVisible: true,
                        textStyle: TextStyle(
                          color: Colors.white,
                          fontSize: 18.0,
                        ),
                      ),
                      //animationDuration: 1000,
                      // animationType: AnimationType.easeOutBack,
                    )
                  ],
                ),

              ],
            ),
          ),
        );
      },
    );
  }

  Color getRandomColor() {
    Random random = Random();
    return Color.fromARGB(
      255,
      random.nextInt(256),
      random.nextInt(256),
      random.nextInt(256),
    );
  }
}


