import 'package:flutter/material.dart';

import 'KPI.dart';
import 'Temps.dart';



class Dashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(


      body: Column(
        children: [
          Expanded(
            child: Container(
              //height: 300,
              child: KPI(),
            ),
          ),
          Expanded(
            child: Container(
              //height: 200,
              child:Temps(),
            ),
          ),
        ],
      ),
    );
  }
}

