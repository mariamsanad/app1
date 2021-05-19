import 'package:app1/Components/loading.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:app1/Services/crudUser.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:connectivity/connectivity.dart';

class DeathRec {
  var deaths;
  var date;
  DeathRec(this.date, this.deaths);
}

getChartData() async {
  var array = [];
  var c =
      await getCovidRecord(FirebaseAuth.instance.currentUser.uid).then((val) {
    for (int i = 0; i < val.length; i++) {
      if (val[i][1]['infected'] == true) {
        print(val[i]);
      }
      // array.add(val[i]);
    }
    return array;
  });
  return array;

  /* return <ChartSeries>[
    StackedColumnSeries<ChartData, String>(
        dataSource: chartData,
        xValueMapper: (ChartData sales, _) => sales.x,
        yValueMapper: (ChartData sales, _) => sales.y1
    ),
    StackedColumnSeries<ChartData, String>(
        dataSource: chartData,
        xValueMapper: (ChartData sales, _) => sales.x,
        yValueMapper: (ChartData sales, _) => sales.y2
    ),
    StackedColumnSeries<ChartData,String>(
        dataSource: chartData,
        xValueMapper: (ChartData sales, _) => sales.x,
        yValueMapper: (ChartData sales, _) => sales.y3
    ),
    StackedColumnSeries<ChartData, String>(
        dataSource: chartData,
        xValueMapper: (ChartData sales, _) => sales.x,
        yValueMapper: (ChartData sales, _) => sales.y4
    )
  ]*/
}

class CovidReportUser extends StatefulWidget {
  @override
  var companyid,sid;


  CovidReportUser(this.sid);

  _CovidReportUserState createState() => _CovidReportUserState();
}

class _CovidReportUserState extends State<CovidReportUser> {
  var _showing = 'all';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getCompanyid(this.widget.sid).then((c){
      setState(() {
        this.widget.companyid = c;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My situation'),
        actions: [
          FlatButton(onPressed: (){
            Navigator.of(context).pushNamed('situation');
          }, child: Icon(Icons.add))
        ],
      ),
      body: Container(
        child: SingleChildScrollView(
          child: Column(children: [
            StreamBuilder<DocumentSnapshot>(
                stream: companies.doc(this.widget.companyid).collection('supervisors').doc(this.widget.sid).snapshots(),
    builder: (context,  snapshot) {
                  if (snapshot.hasData)
                    return Text('The data is '+snapshot.data!.toString());
                  else
                    return Text('No data');
    }),
            RecordForUser(FirebaseAuth.instance.currentUser.uid)
          ], ),
        ),
      ),
    );
  }
}

Future<String> checkConn() async {
  var connectivityResult = await (Connectivity().checkConnectivity());
  if (connectivityResult == ConnectivityResult.mobile) {
    return "I am connected to a mobile network.";
  } else if (connectivityResult == ConnectivityResult.wifi) {
    return "I am connected to a wifi network.";
  } else {
    return "No internet Connection";
  }
}
