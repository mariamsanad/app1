import 'package:app1/Services/CRUD.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SuperCovidReports extends StatefulWidget {
  @override
  _SuperCovidReportsState createState() => _SuperCovidReportsState();
}

class _SuperCovidReportsState extends State<SuperCovidReports> {
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
        body: FutureBuilder(
            future: getCompanyid(FirebaseAuth.instance.currentUser.uid),
            builder: (context, snapshot) {
              return TabBarView(
                children: [
                  SingleChildScrollView(
                    child: SupervisorsListForCovCom(
                        FirebaseAuth.instance.currentUser.uid),
                  )
                ],
              );
            }),
      ),
      // SuperCovRec(),
      //bottomNavigationBar: Text("Hello"),
    );
  }
}
