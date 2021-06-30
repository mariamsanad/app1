import 'package:app1/Services/CRUD.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';


class CompanyCovidReports extends StatefulWidget {
  @override
  _CompanyCovidReportsState createState() => _CompanyCovidReportsState();
}

class _CompanyCovidReportsState extends State<CompanyCovidReports> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 1,
      child: Scaffold(
        appBar: AppBar(
          bottom: TabBar(
            tabs: [
              Tab(text: 'All'),
            ],
          ),
          title: Text('Reports'),
        ),
        body: TabBarView(
          children: [
            // SingleChildScrollView(child: CompanyCovRec()),
            SingleChildScrollView(child: SupervisorsListForCovCom(FirebaseAuth.instance.currentUser.uid),)
          ],
        ),
      ),
      // CompanyCovRec(),
      //bottomNavigationBar: Text("Hello"),
    );
  }
}
