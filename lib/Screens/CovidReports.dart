import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class CovidReportUser extends StatefulWidget {
  @override
  _CovidReportUserState createState() => _CovidReportUserState();
}

class _CovidReportUserState extends State<CovidReportUser> {
  var _showing = 'all';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('My graph'),) ,
      body: Center(
        child: Container(
          child: SingleChildScrollView(
            child: Column(
              children: [
                DropdownButton(
                    // dropdownColor: Colors.amberAccent.withOpacity(0.5),
                    value: _showing,
                    items: [
                      DropdownMenuItem(
                        child: Text(
                          "Last Year",
                          style: TextStyle(fontWeight: FontWeight.w900),
                        ),
                        value: 'year',
                      ),
                      DropdownMenuItem(
                        child: Text(
                          "Last Month",
                          style: TextStyle(fontWeight: FontWeight.w900),
                        ),
                        value: 'month',
                      ),
                      DropdownMenuItem(
                          child: Text(
                            "Last Week",
                            style: TextStyle(fontWeight: FontWeight.w900),
                          ),
                          value: 'week'),
                      DropdownMenuItem(
                          child: Text(
                            'All Data',
                            style: TextStyle(fontWeight: FontWeight.w900),
                          ),
                          value: 'all')
                    ],
                    onChanged: (value) {
                      print('changed');
                      setState(() {
                        print('changed');
                        _showing = value as String;
                      });
                    }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
