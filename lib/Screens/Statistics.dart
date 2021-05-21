import 'package:app1/Components/loading.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'dart:convert';
import '../Components/countrydetails.dart';
import 'package:country_list_pick/country_list_pick.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class Statistics extends StatefulWidget {

  @override
  _StatisticsState createState() => _StatisticsState();
}

class DeathRec{
  final deaths;
  final date;
  DeathRec(this.date, this.deaths);
}

class _StatisticsState extends State<Statistics> {


  bool con = false;

  final _formKey = GlobalKey<FormState>();
  final ScrollController _scrollController = ScrollController();
  FocusNode? myFocusNode;
  List _cities = ["bahrain", "oman"];
  String _currentCity = "bahrain";


  @override
  void dispose() {

    myFocusNode!.dispose();
    super.dispose();
  }

  void initState() {
    super.initState();
    // Start listening to changes.
    myFocusNode = FocusNode();


  }
  Future getForC(String c) async {
    var url = "https://api.covid19api.com/country/"+c;
    var response = await http.get(url);
    var responsebody = jsonDecode(response.body);
    return responsebody;
  }

  void changedDropDownItem(String selectedCity){

    print("Selected city $selectedCity , we are going to refresh ui");
    setState(() {
      _currentCity = selectedCity;
    });
  }


  var _showing = 'all';
  late ZoomPanBehavior _zoomPanBehavior;

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(
        title: Text("explore"),
      ),
      body: Column(
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
                Container(
                      //padding:EdgeInsets.all(20),
                      //height:200,
                      alignment: Alignment.center,
                      child: Card(
                          elevation: 5,
                          color: Colors.orangeAccent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50),
                          ),
                          child:Padding(
                            padding: EdgeInsets.all(5),
                            child:SizedBox(
                              width:250,
                              child:CountryListPick(
                                initialSelection: 'BH',
                                theme:  CountryTheme(
                                  //initialSelection: 'Bahrain',
                                  isShowFlag: true,
                                  isShowTitle: true,
                                  isShowCode: false,
                                  isDownIcon: true,
                                  showEnglishName: true,
                                ),
                                onChanged: (CountryCode? code) {
                                  changedDropDownItem(code!.code!);

                                },
                              ),
                            ),
                          )
                      )
                  ),
                  dosom(),
                  Card(
                      //elevation: 5,
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child:Padding(
                        padding: EdgeInsets.only(top: 5,left: 15,right: 5,bottom: 5),
                        child:SizedBox(
                          width:300,
                          child:DropdownButton(
                            dropdownColor: Colors.amberAccent.withOpacity(0.5),
                              value: _showing,
                              items: [
                                DropdownMenuItem(
                                  child: Text("Last Year",style: TextStyle(fontWeight: FontWeight.w900),),
                                  value: 'year',
                                ),
                                DropdownMenuItem(
                                  child: Text("Last Month",style: TextStyle(fontWeight: FontWeight.w900),),
                                  value: 'month',
                                ),
                                DropdownMenuItem(
                                    child: Text("Last Week",style: TextStyle(fontWeight: FontWeight.w900),),
                                    value: 'week'
                                ),
                                DropdownMenuItem(
                                    child: Text('All Data',style: TextStyle(fontWeight: FontWeight.w900),),
                                    value: 'all'
                                )
                              ],
                              onChanged: (value) {
                                print('changed');
                                setState(() {
                                  print('changed');
                                  _showing = value as String;
                                });
                              })
                        ),
                      )
                  ),
                  FutureBuilder(
                    future: getForC(_currentCity),
                    builder: (BuildContext context, AsyncSnapshot snapshot){

                      final List <DeathRec> deathRec = [];
                      final List <DeathRec> activeRec = [];
                      final List <DeathRec> confirmedRec = [];
                      if (snapshot.hasData){
                        if(snapshot.data.length>0){

                          if(_showing=='week'){
                            for(int i=snapshot.data.length-7;i<snapshot.data.length;i++){
                              if(i!=0)
                                deathRec.add(new DeathRec(DateFormat('d-MMM-yy').format(DateTime.parse(snapshot.data[i]['Date'])),(snapshot.data[i]['Deaths']-snapshot.data[i-1]['Deaths']) ));
                              else
                                deathRec.add(new DeathRec(DateFormat('d-MMM-yy').format(DateTime.parse(snapshot.data[i]['Date'])),snapshot.data[i]['Deaths'] ));
                            }
                            for(int i=snapshot.data.length-7;i<snapshot.data.length;i++){
                              if(i!=0)
                                confirmedRec.add(new DeathRec(DateFormat('d-MMM-yy').format(DateTime.parse(snapshot.data[i]['Date'])),(snapshot.data[i]['Confirmed']-snapshot.data[i-1]['Confirmed']) ));
                              else
                                confirmedRec.add(new DeathRec(DateFormat('d-MMM-yy').format(DateTime.parse(snapshot.data[i]['Date'])),snapshot.data[i]['Confirmed'] ));
                            }

                            for(int i=snapshot.data.length-7;i<snapshot.data.length;i++){
                              if(i==410)
                                activeRec.add(new DeathRec(DateFormat('d-MMM-yy').format(DateTime.parse(snapshot.data[i]['Date'])),snapshot.data[i-1]['Active'] ));
                              else
                                activeRec.add(new DeathRec(DateFormat('d-MMM-yy').format(DateTime.parse(snapshot.data[i]['Date'])),snapshot.data[i]['Active'] ));
                            }

                          }else if(_showing=='year'){

                            for(int i=snapshot.data.length-365;i<snapshot.data.length;i++){
                              if(i!=0)
                                deathRec.add(new DeathRec(DateFormat('d-MMM-yy').format(DateTime.parse(snapshot.data[i]['Date'])),(snapshot.data[i]['Deaths']-snapshot.data[i-1]['Deaths']) ));
                              else
                                deathRec.add(new DeathRec(DateFormat('d-MMM-yy').format(DateTime.parse(snapshot.data[i]['Date'])),snapshot.data[i]['Deaths'] ));
                            }

                            for(int i=snapshot.data.length-365;i<snapshot.data.length;i++){
                              if(i!=0)
                                confirmedRec.add(new DeathRec(DateFormat('d-MMM-yy').format(DateTime.parse(snapshot.data[i]['Date'])),(snapshot.data[i]['Confirmed']-snapshot.data[i-1]['Confirmed']) ));
                              else
                                confirmedRec.add(new DeathRec(DateFormat('d-MMM-yy').format(DateTime.parse(snapshot.data[i]['Date'])),snapshot.data[i]['Confirmed'] ));
                            }

                            for(int i=snapshot.data.length-365;i<snapshot.data.length;i++){
                              if(i==410)
                                activeRec.add(new DeathRec(DateFormat('d-MMM-yy').format(DateTime.parse(snapshot.data[i]['Date'])),snapshot.data[i-1]['Active'] ));
                              else
                                activeRec.add(new DeathRec(DateFormat('d-MMM-yy').format(DateTime.parse(snapshot.data[i]['Date'])),snapshot.data[i]['Active'] ));
                            }


                          }else if(_showing=='month'){
                            for(int i=snapshot.data.length-30;i<snapshot.data.length;i++){
                              if(i!=0)
                                deathRec.add(new DeathRec(DateFormat('d-MMM-yy').format(DateTime.parse(snapshot.data[i]['Date'])),(snapshot.data[i]['Deaths']-snapshot.data[i-1]['Deaths']) ));
                              else
                                deathRec.add(new DeathRec(DateFormat('d-MMM-yy').format(DateTime.parse(snapshot.data[i]['Date'])),snapshot.data[i]['Deaths'] ));
                            }

                            for(int i=snapshot.data.length-30;i<snapshot.data.length;i++){
                              if(i!=0)
                                confirmedRec.add(new DeathRec(DateFormat('d-MMM-yy').format(DateTime.parse(snapshot.data[i]['Date'])),(snapshot.data[i]['Confirmed']-snapshot.data[i-1]['Confirmed']) ));
                              else
                                confirmedRec.add(new DeathRec(DateFormat('d-MMM-yy').format(DateTime.parse(snapshot.data[i]['Date'])),snapshot.data[i]['Confirmed'] ));
                            }

                            for(int i=snapshot.data.length-30;i<snapshot.data.length;i++){
                              if(i==410)
                                activeRec.add(new DeathRec(DateFormat('d-MMM-yy').format(DateTime.parse(snapshot.data[i]['Date'])),snapshot.data[i-1]['Active'] ));
                              else
                                activeRec.add(new DeathRec(DateFormat('d-MMM-yy').format(DateTime.parse(snapshot.data[i]['Date'])),snapshot.data[i]['Active'] ));
                            }
                          }else{
                            for(int i=0;i<snapshot.data.length;i++){
                              if(i!=0)
                                deathRec.add(new DeathRec(DateFormat('d-MMM-yy').format(DateTime.parse(snapshot.data[i]['Date'])),(snapshot.data[i]['Deaths']-snapshot.data[i-1]['Deaths']) ));
                              else
                                deathRec.add(new DeathRec(DateFormat('d-MMM-yy').format(DateTime.parse(snapshot.data[i]['Date'])),snapshot.data[i]['Deaths'] ));
                            }

                            for(int i=0;i<snapshot.data.length;i++){
                              if(i!=0)
                                confirmedRec.add(new DeathRec(DateFormat('d-MMM-yy').format(DateTime.parse(snapshot.data[i]['Date'])),(snapshot.data[i]['Confirmed']-snapshot.data[i-1]['Confirmed']) ));
                              else
                                confirmedRec.add(new DeathRec(DateFormat('d-MMM-yy').format(DateTime.parse(snapshot.data[i]['Date'])),snapshot.data[i]['Confirmed'] ));
                            }

                            for(int i=0;i<snapshot.data.length;i++){
                              if(i==410)
                                activeRec.add(new DeathRec(DateFormat('d-MMM-yy').format(DateTime.parse(snapshot.data[i]['Date'])),snapshot.data[i-1]['Active'] ));
                              else
                                activeRec.add(new DeathRec(DateFormat('d-MMM-yy').format(DateTime.parse(snapshot.data[i]['Date'])),snapshot.data[i]['Active'] ));
                            }
                          }

                          return Expanded(
                            child:  SfCartesianChart(
                              trackballBehavior: TrackballBehavior(
                                  markerSettings: TrackballMarkerSettings(
                                      markerVisibility: TrackballVisibilityMode.visible),
                                  enable: true,
                                  tooltipSettings: InteractiveTooltip(
                                      enable: true,
                                      color: Colors.green,
                                      format: 'point.x : point.y',
                                  )
                              ),
                                zoomPanBehavior:  ZoomPanBehavior(
                                  enablePinching: true,
                                  zoomMode: ZoomMode.x,
                                  enablePanning: true,
                                ),
                              // backgroundColor: Colors.white,

                                primaryXAxis: CategoryAxis(),
                                title: ChartTitle(text: 'Chart'), //Chart title.
                                legend: Legend(isVisible: true), // Enables the legend.
                                tooltipBehavior: TooltipBehavior(enable: true), // Enables the tooltip.
                                series: <LineSeries<DeathRec, String>>[
                                  LineSeries<DeathRec, String>(
                                      name: 'Deaths',
                                      dataSource: deathRec,
                                      xValueMapper: (DeathRec sales, _) => sales.date,
                                      yValueMapper: (DeathRec sales, _) => sales.deaths,
                                      //dataLabelSettings: DataLabelSettings(isVisible: true) // Enables the data label.
                                  ),
                                  LineSeries<DeathRec, String>(
                                      name: 'Active',
                                      dataSource: activeRec,
                                      xValueMapper: (DeathRec sales, _) => sales.date,
                                      yValueMapper: (DeathRec sales, _) => sales.deaths,
                                      // dataLabelSettings: DataLabelSettings(isVisible: true) // Enables the data label.
                                  ),
                                  LineSeries<DeathRec, String>(
                                      name: 'Confirmed',
                                      dataSource: confirmedRec,
                                      xValueMapper: (DeathRec sales, _) => sales.date,
                                      yValueMapper: (DeathRec sales, _) => sales.deaths,
                                       // dataLabelSettings: DataLabelSettings(isVisible: true) // Enables the data label.
                                  ),

                                ]
                            )
                          );


                        }else{
                          return Expanded(
                              child: Center(child: Text("There is no data for this country", style: TextStyle(fontSize: 20, color: Colors.red,fontWeight: FontWeight.bold),))
                          );
                        }

                      }
                      return Center(child: Loading());

                    },
                  )

                ],
              ),
    );
  }

  FutureBuilder dosom(){
  return FutureBuilder(
  future: getForC(_currentCity),
  builder: (BuildContext context, AsyncSnapshot snapshot){

  if (snapshot.hasData){
    if(snapshot.data.length>0){

      return Cdetails(date: snapshot.data[snapshot.data.length-1]['Date'],code: snapshot.data[snapshot.data.length-1]['CountryCode'], confirmed :(snapshot.data[snapshot.data.length-1]['Confirmed']-snapshot.data[snapshot.data.length-3]['Confirmed']), deaths: (snapshot.data[snapshot.data.length-1]['Deaths']-snapshot.data[snapshot.data.length-3]['Deaths']),recoverd:(snapshot.data[snapshot.data.length-1]['Recovered']-snapshot.data[snapshot.data.length-3]['Recovered']), active:snapshot.data[snapshot.data.length-1]['Active'],country:snapshot.data[snapshot.data.length-1]['Country'] ,);



    }else{
      return Expanded(
          child: Center(child: Text("There is no data for this country", style: TextStyle(fontSize: 20, color: Colors.red,fontWeight: FontWeight.bold),))
      );
    }

  }
   return Center(child: Loading());

  },
  );
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

}


