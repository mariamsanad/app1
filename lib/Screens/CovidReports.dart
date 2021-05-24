import 'package:app1/Components/loading.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:app1/Services/crudUser.dart';
import 'package:intl/intl.dart';
import 'package:connectivity/connectivity.dart';

import 'Companies.dart';
import 'Profile.dart';

class DeathRec {
  var deaths;
  var date;
  DeathRec(this.date, this.deaths);
}

/*getChartData() async {
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

  *//* return <ChartSeries>[
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
  ]*//*
}*/

class CovidReportUser extends StatefulWidget {
  @override
  var companyid, sid, position;

  CovidReportUser(this.sid, this.position);

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
                print('the data is '+snapshot.data.toString());
                return Loading();
              }
                a = snapshot.data;

              return Column(
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
                                            child: Text('See Graph')),
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
                                                                              ? Text('No Symptoms')
                                                                              : Container(),
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

              return Text(a.toString());
              // return Loading();
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
                      print('doto'+snapshot.data.toString());
                      return Loading();
                    }
                    print('doto'+snapshot.data[0].toString());
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
                                                                      document
                                                                          .date)));
                                                    },
                                                    child: Text('See Graph')),
                                                DataTable(
                                                  showCheckboxColumn: false,
                                                  columns: [
                                                    DataColumn(
                                                      // numeric: true,
                                                      label: Text(
                                                        'User name',
                                                        style: TextStyle(
                                                            fontStyle:
                                                                FontStyle.italic,
                                                            fontWeight:
                                                                FontWeight.bold),
                                                      ),
                                                    ),
                                                  ],
                                                  rows: document.rec
                                                      .map<DataRow>((ex) {
                                                    return DataRow(
                                                        onSelectChanged: (b) {
                                                          var c = true;
                                                          var infected =
                                                                  ex['infected'],
                                                              head = ex['headache'],
                                                              fever = ex['fever'],
                                                              cough = ex['cough'];
                                                          if (!cough &&
                                                              !head &&
                                                              !fever) c = false;
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
                                                                                  !c ? Text('No Symptoms') : Container(),
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
                                                                                  onPressed: () {
                                                                                    Navigator.pop(context);
                                                                                  },
                                                                                  child: Text("OK"))
                                                                            ],
                                                                          ));
                                                        },
                                                        cells: [
                                                          DataCell(
                                                            Text(
                                                              ex['name'],
                                                              style: TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold),
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
                                       document.date.toString(),
                                        style:
                                            TextStyle(fontWeight: FontWeight.bold),
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
                            ),
                          ),
                        ),
                      ],
                    );

                    return Text(a.toString());
                    // return Loading();
                  })
            ],
          ),
        );
  }
}
class SuperCovRec extends StatelessWidget {
  final sid;

  SuperCovRec(this.sid);

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
                  print('doto'+snapshot.data.toString());
                  return Loading();
                }
                print('doto'+snapshot.data[0].toString());
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
                                                                  document
                                                                      .date)));
                                                },
                                                child: Text('See Graph')),
                                            DataTable(
                                              showCheckboxColumn: false,
                                              columns: [
                                                DataColumn(
                                                  // numeric: true,
                                                  label: Text(
                                                    'User name',
                                                    style: TextStyle(
                                                        fontStyle:
                                                        FontStyle.italic,
                                                        fontWeight:
                                                        FontWeight.bold),
                                                  ),
                                                ),
                                              ],
                                              rows: document.rec
                                                  .map<DataRow>((ex) {
                                                return DataRow(
                                                    onSelectChanged: (b) {
                                                      var c = true;
                                                      var infected =
                                                      ex['infected'],
                                                          head = ex['headache'],
                                                          fever = ex['fever'],
                                                          cough = ex['cough'];
                                                      if (!cough &&
                                                          !head &&
                                                          !fever) c = false;
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
                                                                      !c ? Text('No Symptoms') : Container(),
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
                                                                      onPressed: () {
                                                                        Navigator.pop(context);
                                                                      },
                                                                      child: Text("OK"))
                                                                ],
                                                              ));
                                                    },
                                                    cells: [
                                                      DataCell(
                                                        Text(
                                                          ex['name'],
                                                          style: TextStyle(
                                                              fontWeight:
                                                              FontWeight
                                                                  .bold),
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
                                    document.date.toString(),
                                    style:
                                    TextStyle(fontWeight: FontWeight.bold),
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
                        ),
                      ),
                    ),
                  ],
                );

                return Text(a.toString());
                // return Loading();
              })
        ],
      ),
    );
  }
}
// class SupervisorCovRec extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         FutureBuilder(
//             future: getCEachPos('bj'),
//             builder: (BuildContext context, AsyncSnapshot snapshot) {
//               var a = [];
//               if (!snapshot.hasData || snapshot.data.isEmpty) {
//                 //print(snapshot.data);
//                 return Loading();
//               }
//               //CIRCULAR INDIC\ATOR
//               else
//                 for (int i = 0; i < snapshot.data.length; i++) {
//                   a.add(snapshot.data[i]);
//                   // print(snapshot.data[i].toString());
//                 }
//
//               return Column(
//                 children: [
//                   SizedBox(
//                     width: double.infinity,
//                     child: DataTable(
//                       showCheckboxColumn: false,
//                       sortColumnIndex: 0,
//                       sortAscending: true,
//                       columns: [
//                         DataColumn(
//                           label: Text(
//                             'Date',
//                             style: TextStyle(fontStyle: FontStyle.italic),
//                           ),
//                         ),
//                         DataColumn(
//                           label: Text(
//                             'Number of Cases',
//                             style: TextStyle(fontStyle: FontStyle.italic),
//                           ),
//                         ),
//                       ],
//                       rows: a.map((document) {
//                         return DataRow(
//                             onSelectChanged: (b) {
//                               showModalBottomSheet(
//                                   context: context,
//                                   builder: (context) {
//                                     return Column(
//                                       children: [
//                                         TextButton(
//                                             onPressed: () {
//                                               Navigator.push(
//                                                   context,
//                                                   MaterialPageRoute(
//                                                       builder: (context) =>
//                                                           showDailyRadialGraph(
//                                                               document.date)));
//                                             },
//                                             child: Text('See Graph')),
//                                         DataTable(
//                                           showCheckboxColumn: false,
//                                           columns: [
//                                             DataColumn(
//                                               // numeric: true,
//                                               label: Text(
//                                                 'User name',
//                                                 style: TextStyle(
//                                                     fontStyle: FontStyle.italic,
//                                                     fontWeight:
//                                                     FontWeight.bold),
//                                               ),
//                                             ),
//                                           ],
//                                           rows: document.rec.map<DataRow>((ex) {
//                                             return DataRow(
//                                                 onSelectChanged: (b) {
//                                                   var c = true;
//
//                                                   var infected = ex['infected'],
//                                                       head = ex['headache'],
//                                                       fever = ex['fever'],
//                                                       cough = ex['cough'];
//                                                   if (!cough && !head && !fever)
//                                                     c = false;
//                                                   // if (ex['type'] == 'supervisor') {
//                                                   !infected
//                                                       ? null
//                                                       : showDialog(
//                                                       context: context,
//                                                       builder:
//                                                           (context) =>
//                                                           AlertDialog(
//                                                             shape: RoundedRectangleBorder(
//                                                                 borderRadius:
//                                                                 BorderRadius.all(Radius.circular(32.0))),
//                                                             content:
//                                                             /*ex.hasData
//                                                              ? */
//                                                             SingleChildScrollView(
//                                                               child:
//                                                               Column(
//                                                                 mainAxisSize:
//                                                                 MainAxisSize.min,
//                                                                 children: [
//                                                                   !c
//                                                                       ? Text('No Symptoms')
//                                                                       : Container(),
//                                                                   head
//                                                                       ? Tooltip(
//                                                                     message: 'Headache',
//                                                                     child: ListTile(
//                                                                       title: InkWell(
//                                                                         child: Image.asset(
//                                                                           "assets/images/head.png",
//                                                                           width: 100,
//                                                                           height: 100,
//                                                                         ),
//                                                                       ),
//                                                                     ),
//                                                                   )
//                                                                       : Container(),
//                                                                   fever
//                                                                       ? Tooltip(
//                                                                     message: 'Fever',
//                                                                     child: ListTile(
//                                                                       title: InkWell(
//                                                                         child: Image.asset(
//                                                                           "assets/images/fever.png",
//                                                                           width: 100,
//                                                                           height: 100,
//                                                                         ),
//                                                                       ),
//                                                                     ),
//                                                                   )
//                                                                       : Container(),
//                                                                   cough
//                                                                       ? Tooltip(
//                                                                     message: 'Cough',
//                                                                     child: ListTile(
//                                                                       title: InkWell(
//                                                                         child: Image.asset(
//                                                                           "assets/images/caugh.png",
//                                                                           width: 100,
//                                                                           height: 100,
//                                                                         ),
//                                                                       ),
//                                                                     ),
//                                                                   )
//                                                                       : Container(),
//                                                                 ],
//                                                               ),
//                                                             )
//                                                             /* : Loading(),*/,
//                                                             actions: [
//                                                               FlatButton(
//                                                                   onPressed:
//                                                                       () {
//                                                                     Navigator.pop(context);
//                                                                   },
//                                                                   child:
//                                                                   Text("OK"))
//                                                             ],
//                                                           ));
//                                                 },
//                                                 cells: [
//                                                   DataCell(
//                                                     Text(
//                                                       ex['name'],
//                                                       style: TextStyle(
//                                                           fontWeight:
//                                                           FontWeight.bold),
//                                                     ),
//                                                   ),
//                                                 ]);
//                                           }).toList(),
//                                         ),
//                                       ],
//                                     );
//                                   });
//                             },
//                             cells: [
//                               DataCell(Text(document.date,
//                                 style: TextStyle(fontWeight: FontWeight.bold),
//                               )),
//                               DataCell(
//                                 Text(
//                                   document.rec.length.toString('jn'),
//                                   style: TextStyle(fontWeight: FontWeight.bold),
//                                 ),
//                               )
//                               // DataCell(Text(/*document.*/'jdc')),
//                               // DataCell(),
//                             ]);
//                       }).toList(),
//                     ),
//                   ),
//                 ],
//               );
//
//               return Text(a.toString());
//               // return Loading();
//             })
//       ],
//     );
//   }
// }
