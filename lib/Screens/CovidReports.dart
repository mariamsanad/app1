import 'package:app1/Components/loading.dart';
import 'package:app1/Services/User.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:app1/Services/crudUser.dart';
import 'package:intl/intl.dart';
import 'package:connectivity/connectivity.dart';

class DeathRec {
  var deaths;
  var date;
  DeathRec(this.date, this.deaths);
}



class CovidReportUser extends StatefulWidget {
  @override
  var companyid, sid, position;

  CovidReportUser(this.sid, this.position);

  _CovidReportUserState createState() => _CovidReportUserState();
}

class _CovidReportUserState extends State<CovidReportUser> {
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
            children: [RecordForUser(FirebaseAuth.instance.currentUser.uid)],
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

class AdminCovRec extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        FutureBuilder(
            future: getCDate(),
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              var a = [];
              if (!snapshot.hasData || snapshot.data.isEmpty) {

                return Loading();
              }
              a = snapshot.data;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,

                children: [
                  SizedBox(
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
                          label: Text(
                            'Number of Cases',
                            style: TextStyle(fontStyle: FontStyle.italic),
                          ),
                        ),
                      ],
                      rows: a.map((document) {
                        return DataRow(
                            onSelectChanged: (b) {
                              showModalBottomSheet(
                                  context: context,
                                  builder: (context) {
                                    return Column(
                                      children: [
                                        TextButton(
                                            onPressed: () {
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          showDailyRadialGraph(
                                                              document.date)));
                                            },
                                            child: Text('See Symptoms Graph')),
                                        DataTable(
                                          showCheckboxColumn: false,
                                          columns: [
                                            DataColumn(
                                              // numeric: true,
                                              label: Text(
                                                'User name',
                                                style: TextStyle(
                                                    fontStyle: FontStyle.italic,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ),
                                          ],
                                          rows: document.rec.map<DataRow>((ex) {
                                            return DataRow(
                                                onSelectChanged: (b) {
                                                  var c = true;
                                                  var infected = ex['infected'],
                                                      head = ex['headache'],
                                                      fever = ex['fever'],
                                                      cough = ex['cough'];
                                                  if (!cough && !head && !fever)
                                                    c = false;
                                                  // if (ex['type'] == 'supervisor') {
                                                  !infected
                                                      ? null
                                                      : showDialog(
                                                          context: context,
                                                          builder:
                                                              (context) =>
                                                                  AlertDialog(
                                                                    shape: RoundedRectangleBorder(
                                                                        borderRadius:
                                                                            BorderRadius.all(Radius.circular(32.0))),
                                                                    content:
                                                                        /*ex.hasData
                                                             ? */
                                                                        SingleChildScrollView(
                                                                      child:
                                                                          Column(
                                                                        mainAxisSize:
                                                                            MainAxisSize.min,
                                                                        children: [
                                                                          !c
                                                                              ? Text(
                                                                                  'No Symptoms',
                                                                                  style: TextStyle(fontWeight: FontWeight.bold),
                                                                                )
                                                                              : Text(
                                                                                  'Symptoms',
                                                                                  style: TextStyle(fontWeight: FontWeight.bold),
                                                                                ),
                                                                          head
                                                                              ? Tooltip(
                                                                                  message: 'Headache',
                                                                                  child: ListTile(
                                                                                    title: InkWell(
                                                                                      child: Image.asset(
                                                                                        "assets/images/head.png",
                                                                                        width: 100,
                                                                                        height: 100,
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                )
                                                                              : Container(),
                                                                          fever
                                                                              ? Tooltip(
                                                                                  message: 'Fever',
                                                                                  child: ListTile(
                                                                                    title: InkWell(
                                                                                      child: Image.asset(
                                                                                        "assets/images/fever.png",
                                                                                        width: 100,
                                                                                        height: 100,
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                )
                                                                              : Container(),
                                                                          cough
                                                                              ? Tooltip(
                                                                                  message: 'Cough',
                                                                                  child: ListTile(
                                                                                    title: InkWell(
                                                                                      child: Image.asset(
                                                                                        "assets/images/caugh.png",
                                                                                        width: 100,
                                                                                        height: 100,
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                )
                                                                              : Container(),
                                                                        ],
                                                                      ),
                                                                    )
                                                                    /* : Loading(),*/,
                                                                    actions: [
                                                                      FlatButton(
                                                                          onPressed:
                                                                              () {
                                                                            Navigator.pop(context);
                                                                          },
                                                                          child:
                                                                              Text("OK"))
                                                                    ],
                                                                  ));
                                                },
                                                cells: [
                                                  DataCell(
                                                    Text(
                                                      ex['name'],
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                  ),
                                                ]);
                                          }).toList(),
                                        ),
                                      ],
                                    );
                                  });
                            },
                            cells: [
                              DataCell(Text(
                                DateFormat('d-MMM-yy')
                                    .format(DateTime.parse(document.date)),
                                style: TextStyle(fontWeight: FontWeight.bold),
                              )),
                              DataCell(
                                Text(
                                  document.rec.length.toString(),
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              )
                              // DataCell(Text(/*document.*/'jdc')),
                              // DataCell(),
                            ]);
                      }).toList(),
                    ),
                  ),
                ],
              );
            })
      ],
    );
  }
}

class CompanyCovRec extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          FutureBuilder(
              future: getCCom(),
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                var a = [];
                if (!snapshot.hasData || snapshot.data.isEmpty) {

                  return Loading();
                }
                //CIRCULAR INDIC\ATOR
                a = snapshot.data;

                return Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          showCheckboxColumn: false,
                          sortColumnIndex: 0,
                          sortAscending: true,
                          columns: [
                            DataColumn(
                              label: Text(
                                'Company Name',
                                style: TextStyle(fontStyle: FontStyle.italic),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'Number of Cases',
                                style: TextStyle(fontStyle: FontStyle.italic),
                              ),
                            ),
                          ],
                          rows: a.map((document) {
                            return DataRow(cells: [
                              DataCell(FutureBuilder(
                                  future: getUserName(document.date),
                                  builder: (context, snapshot) {
                                    if (!snapshot.hasData) {
                                      return Loading();
                                    }
                                    return Text(
                                      snapshot.data.toString(),
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    );
                                  })),
                              DataCell(
                                Text(
                                  document.rec.toString(),
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              )
                              // DataCell(Text(/*document.*/'jdc')),
                              // DataCell(),
                            ]);
                          }).toList(),
                        ),
                      ),
                    ),
                  ],
                );
              })
        ],
      ),
    );
  }
}

class SuperCovRec extends StatelessWidget {
  final cid, sid;
  SuperCovRec(this.cid, this.sid);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cases for each Position'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            FutureBuilder(
                future: getCPos(cid, sid),
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  var a = [];
                  if (!snapshot.hasData || snapshot.data.isEmpty) {
                    return Loading();
                  }
                  //CIRCULAR INDIC\ATOR
                  a = snapshot.data;

                  return Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: DataTable(
                              showCheckboxColumn: false,
                              sortColumnIndex: 0,
                              sortAscending: true,
                              columns: [
                                DataColumn(
                                  label: Text(
                                    'Date',
                                    style:
                                        TextStyle(fontStyle: FontStyle.italic),
                                  ),
                                ),
                                DataColumn(
                                  label: Text(
                                    'Number of Cases',
                                    style:
                                        TextStyle(fontStyle: FontStyle.italic),
                                  ),
                                ),
                              ],
                              rows: a.map((document) {
                                return DataRow(
                                    onSelectChanged: (b) {
                                      showModalBottomSheet(
                                          context: context,
                                          builder: (context) {
                                            return StreamBuilder<QuerySnapshot>(
                                                stream: poscov
                                                    .doc(document.date
                                                        .toString())
                                                    .collection('infected')
                                                    .snapshots(),
                                                builder: (BuildContext context,
                                                    AsyncSnapshot<QuerySnapshot>
                                                        snapshot1) {
                                                return DataTable(
                                                  columns: [DataColumn(
                                                    label: Text(
                                                      'Name',
                                                      style: TextStyle(fontStyle: FontStyle.italic),
                                                    ),
                                                  ),],
                                                  rows: snapshot1.data!.docs.map((document){
                                                    return DataRow(
                                                   /*     onSelectChanged: (b) {

                                                          var c = true;
                                                          var infected = ex['infected'],
                                                              head = ex['headache'],
                                                              fever = ex['fever'],
                                                              cough = ex['cough'];
                                                          if (!cough && !head && !fever)
                                                            c = false;
                                                          // if (ex['type'] == 'supervisor') {
                                                          !infected
                                                              ? null
                                                              : showDialog(
                                                              context: context,
                                                              builder:
                                                                  (context) =>
                                                                  AlertDialog(
                                                                    shape: RoundedRectangleBorder(
                                                                        borderRadius:
                                                                        BorderRadius.all(Radius.circular(32.0))),
                                                                    content:
                                                                    *//*ex.hasData
                                                             ? *//*
                                                                    SingleChildScrollView(
                                                                      child:
                                                                      Column(
                                                                        mainAxisSize:
                                                                        MainAxisSize.min,
                                                                        children: [
                                                                          !c
                                                                              ? Text(
                                                                            'No Symptoms',
                                                                            style: TextStyle(fontWeight: FontWeight.bold),
                                                                          )
                                                                              : Text(
                                                                            'Symptoms',
                                                                            style: TextStyle(fontWeight: FontWeight.bold),
                                                                          ),
                                                                          head
                                                                              ? Tooltip(
                                                                            message: 'Headache',
                                                                            child: ListTile(
                                                                              title: InkWell(
                                                                                child: Image.asset(
                                                                                  "assets/images/head.png",
                                                                                  width: 100,
                                                                                  height: 100,
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          )
                                                                              : Container(),
                                                                          fever
                                                                              ? Tooltip(
                                                                            message: 'Fever',
                                                                            child: ListTile(
                                                                              title: InkWell(
                                                                                child: Image.asset(
                                                                                  "assets/images/fever.png",
                                                                                  width: 100,
                                                                                  height: 100,
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          )
                                                                              : Container(),
                                                                          cough
                                                                              ? Tooltip(
                                                                            message: 'Cough',
                                                                            child: ListTile(
                                                                              title: InkWell(
                                                                                child: Image.asset(
                                                                                  "assets/images/caugh.png",
                                                                                  width: 100,
                                                                                  height: 100,
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          )
                                                                              : Container(),
                                                                        ],
                                                                      ),
                                                                    )
                                                                    *//* : Loading(),*//*,
                                                                    actions: [
                                                                      FlatButton(
                                                                          onPressed:
                                                                              () {
                                                                            Navigator.pop(context);
                                                                          },
                                                                          child:
                                                                          Text("OK"))
                                                                    ],
                                                                  ));
                                                        }*/
                                                        cells:[DataCell(StreamBuilder<DocumentSnapshot>(
                                                      stream: users.doc(document.id).snapshots(),
                                                      builder: (context, snapshot) {
                                                        if(snapshot.data!.data()['infected']==true){
                                                          return Text(snapshot.data!.data()['user_name']);
                                                        }
                                                       else{
                                                         return Container();
                                                        }
                                                      }
                                                    ))] );
                                                  }).toList(),
                                                  
                                                );


                                                });

                                          });
                                    },
                                    cells: [
                                      DataCell(Text(
                                        document.date.toString(),
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      )),
                                      DataCell(
                                        Text(
                                          document.rec.toString(),
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                      )
                                      // DataCell(Text(/*document.*/'jdc')),
                                      // DataCell(),
                                    ]);
                              }).toList(),
                            )),
                      ),
                    ],
                  );
                })
          ],
        ),
      ),
    );
  }
}
class SuperCovRecCom extends StatelessWidget {
  final cid, sid;
  SuperCovRecCom(this.cid, this.sid);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        child: Column(
          children: [
            FutureBuilder(
                future: getCPos(cid, sid),
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  var a = [];
                  if (!snapshot.hasData || snapshot.data.isEmpty) {
                    return Loading();
                  }
                  //CIRCULAR INDIC\ATOR
                  a = snapshot.data;

                  return Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: DataTable(
                              showCheckboxColumn: false,
                              sortColumnIndex: 0,
                              sortAscending: true,
                              columns: [
                                DataColumn(
                                  label: Text(
                                    'Date',
                                    style:
                                    TextStyle(fontStyle: FontStyle.italic),
                                  ),
                                ),
                                DataColumn(
                                  label: Text(
                                    'Number of Cases',
                                    style:
                                    TextStyle(fontStyle: FontStyle.italic),
                                  ),
                                ),
                              ],
                              rows: a.map((document) {
                                return DataRow(
                                    onSelectChanged: (b) {
                                      showModalBottomSheet(
                                          context: context,
                                          builder: (context) {
                                            return StreamBuilder<QuerySnapshot>(
                                                stream: poscov
                                                    .doc(document.date
                                                    .toString())
                                                    .collection('infected')
                                                    .snapshots(),
                                                builder: (BuildContext context,
                                                    AsyncSnapshot<QuerySnapshot>
                                                    snapshot1) {
                                                  return DataTable(
                                                    columns: [DataColumn(
                                                      label: Text(
                                                        'Name',
                                                        style: TextStyle(fontStyle: FontStyle.italic),
                                                      ),
                                                    ),],
                                                    rows: snapshot1.data!.docs.map((document){
                                                      return DataRow(
                                                        /*     onSelectChanged: (b) {

                                                          var c = true;
                                                          var infected = ex['infected'],
                                                              head = ex['headache'],
                                                              fever = ex['fever'],
                                                              cough = ex['cough'];
                                                          if (!cough && !head && !fever)
                                                            c = false;
                                                          // if (ex['type'] == 'supervisor') {
                                                          !infected
                                                              ? null
                                                              : showDialog(
                                                              context: context,
                                                              builder:
                                                                  (context) =>
                                                                  AlertDialog(
                                                                    shape: RoundedRectangleBorder(
                                                                        borderRadius:
                                                                        BorderRadius.all(Radius.circular(32.0))),
                                                                    content:
                                                                    *//*ex.hasData
                                                             ? *//*
                                                                    SingleChildScrollView(
                                                                      child:
                                                                      Column(
                                                                        mainAxisSize:
                                                                        MainAxisSize.min,
                                                                        children: [
                                                                          !c
                                                                              ? Text(
                                                                            'No Symptoms',
                                                                            style: TextStyle(fontWeight: FontWeight.bold),
                                                                          )
                                                                              : Text(
                                                                            'Symptoms',
                                                                            style: TextStyle(fontWeight: FontWeight.bold),
                                                                          ),
                                                                          head
                                                                              ? Tooltip(
                                                                            message: 'Headache',
                                                                            child: ListTile(
                                                                              title: InkWell(
                                                                                child: Image.asset(
                                                                                  "assets/images/head.png",
                                                                                  width: 100,
                                                                                  height: 100,
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          )
                                                                              : Container(),
                                                                          fever
                                                                              ? Tooltip(
                                                                            message: 'Fever',
                                                                            child: ListTile(
                                                                              title: InkWell(
                                                                                child: Image.asset(
                                                                                  "assets/images/fever.png",
                                                                                  width: 100,
                                                                                  height: 100,
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          )
                                                                              : Container(),
                                                                          cough
                                                                              ? Tooltip(
                                                                            message: 'Cough',
                                                                            child: ListTile(
                                                                              title: InkWell(
                                                                                child: Image.asset(
                                                                                  "assets/images/caugh.png",
                                                                                  width: 100,
                                                                                  height: 100,
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          )
                                                                              : Container(),
                                                                        ],
                                                                      ),
                                                                    )
                                                                    *//* : Loading(),*//*,
                                                                    actions: [
                                                                      FlatButton(
                                                                          onPressed:
                                                                              () {
                                                                            Navigator.pop(context);
                                                                          },
                                                                          child:
                                                                          Text("OK"))
                                                                    ],
                                                                  ));
                                                        }*/
                                                          cells:[DataCell(StreamBuilder<DocumentSnapshot>(
                                                              stream: users.doc(document.id).snapshots(),
                                                              builder: (context, snapshot) {
                                                                if(snapshot.data!.data()['infected']==true){
                                                                  return Text(snapshot.data!.data()['user_name']);
                                                                }
                                                                else{
                                                                  return Container();
                                                                }
                                                              }
                                                          ))] );
                                                    }).toList(),

                                                  );
                                                });

                                          });
                                    },
                                    cells: [
                                      DataCell(Text(
                                        document.date.toString(),
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      )),
                                      DataCell(
                                        Text(
                                          document.rec.toString(),
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                      )
                                      // DataCell(Text(/*document.*/'jdc')),
                                      // DataCell(),
                                    ]);
                              }).toList(),
                            )),
                      ),
                    ],
                  );
                })
          ],
        ),
      );
  }
}
