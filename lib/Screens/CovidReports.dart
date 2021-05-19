import 'package:app1/Components/loading.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:app1/Services/crudUser.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:connectivity/connectivity.dart';


class DeathRec{
  var deaths;
  var date;
  DeathRec(this.date, this.deaths);
}

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
                FutureBuilder(
                    future: checkConn(),
                    builder: (BuildContext context, AsyncSnapshot snapshot){
                      if(snapshot.hasData){
                        if(snapshot.data =="I am connected to a wifi network."||snapshot.data =="I am connected to a mobile network."){
                          return Visibility(visible: false,child: Text(snapshot.data));
                        }
                        return Text(snapshot.data);
                      }else{
                        return Text("An error ocured");
                      }
                    }
                ),
                RecordForUser(FirebaseAuth.instance.currentUser.uid)
              ],
            ),
          ),
        ),
      ),
    );
  }
}
Future<String> checkConn() async{
  var connectivityResult = await (Connectivity().checkConnectivity());
  if (connectivityResult == ConnectivityResult.mobile) {
    return "I am connected to a mobile network.";

  } else if (connectivityResult == ConnectivityResult.wifi) {

    return "I am connected to a wifi network.";
  }else{
    return "No internet Connection";
  }
}