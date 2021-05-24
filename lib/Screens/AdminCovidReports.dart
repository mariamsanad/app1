import 'package:flutter/material.dart';

import 'CovidReports.dart';

class AdminCovidReports extends StatefulWidget {
  @override
  _AdminCovidReportsState createState() => _AdminCovidReportsState();
}

class _AdminCovidReportsState extends State<AdminCovidReports> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          bottom: TabBar(
            tabs: [
              Tab(text: 'Date',),
              Tab(text: 'Companies',),
              Tab(text: 'Positions'),
            ],
          ),
          title: Text('Reports'),
        ),
        body: TabBarView(
          children: [
            SingleChildScrollView(child: AdminCovRec()),
            SingleChildScrollView(child: CompanyCovRec()),
            SingleChildScrollView(child: CompanyCovRec()),
          ],
        ),
      ),
    // AdminCovRec(),
      //bottomNavigationBar: Text("Hello"),
    );
  }
}
