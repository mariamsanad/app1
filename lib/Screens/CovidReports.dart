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
  var companyid, sid,position;

  CovidReportUser(this.sid,this.position);

  _CovidReportUserState createState() => _CovidReportUserState();
}

class _CovidReportUserState extends State<CovidReportUser> {
  var _showing = 'all';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getCompanyid(this.widget.sid).then((c) {
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
          FlatButton(
              onPressed: () {
                Navigator.of(context).pushNamed('situation');
              },
              child: Icon(Icons.add))
        ],
      ),
      body: Container(
        child: SingleChildScrollView(
          child: Column(
            children: [
             FutureBuilder(future: getCEachDate(),builder: (BuildContext context, AsyncSnapshot snapshot){
               var a =[];
               if (!snapshot.hasData || snapshot.data.isEmpty){
                 //print(snapshot.data);
                 return Loading();
               }
               //CIRCULAR INDIC\ATOR
               else
               for(int i=0;i<snapshot.data.length;i++){
                 a.add(snapshot.data[i]);
                 print(snapshot.data[i].toString());
               }

               return SizedBox(
                 width: double.infinity,
                 child: DataTable(
                   showCheckboxColumn: false,
                   sortColumnIndex: 0,
                   sortAscending: true,
                   columns: [
                     DataColumn(
                       label: Text(
                         'Date',
                         style: TextStyle(fontStyle: FontStyle.italic),
                       ),
                     ),
                     DataColumn(
                       numeric: true,
                       label: Text(
                         'See List',
                         style: TextStyle(fontStyle: FontStyle.italic),
                       ),
                     ),
                     /*DataColumn(
                       label: Text(
                         'Delete',
                         style: TextStyle(fontStyle: FontStyle.italic),
                       ),
                     ),*/
                   ],
                   rows: a.map((document) {
                     return DataRow(
                       onSelectChanged: (b){
                         showModalBottomSheet(
                             context: context,
                             builder: (context) {
                               return DataTable(columns: [DataColumn(
                                 numeric: true,
                                 label: Text(
                                   'User name',
                                   style: TextStyle(fontStyle: FontStyle.italic),
                                 ),
                               ),DataColumn(
                                 numeric: true,
                                 label: Text(
                                   'infected',
                                   style: TextStyle(fontStyle: FontStyle.italic),
                                 ),
                               ),], rows: [
                                 DataRow(cells: cells)
                               ]);
                             });
                       },
                         cells: [
                           DataCell(Text(DateFormat('d-MMM-yy')
                               .format(DateTime.parse(document.date)))),
                           DataCell(Text(/*document.rec.*/'jdc')),
                           // DataCell(),
                         ]);
                   }).toList(),
                 ),
               );

               return Text(a.toString());
               // return Loading();
             }),
              RecordForUser(FirebaseAuth.instance.currentUser.uid)
            ],
          ),
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
