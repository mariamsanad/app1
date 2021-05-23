import 'package:flutter/material.dart';

import 'CovidReports.dart';

class AdminCovidReports extends StatefulWidget {
  @override
  _AdminCovidReportsState createState() => _AdminCovidReportsState();
}

class _AdminCovidReportsState extends State<AdminCovidReports> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Covid Reports For Admin:"),
      ),body: AdminCovRec(),
      //bottomNavigationBar: Text("Hello"),
    );
  }
}
