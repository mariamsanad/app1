// ignore: import_of_legacy_library_into_null_safe
import 'package:cloud_firestore/cloud_firestore.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:app1/Services/CRUD.dart';
import 'package:shared_preferences/shared_preferences.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:table_calendar/table_calendar.dart';

class RecordCovid extends StatefulWidget {
  @override
  _RecordCovidState createState() => _RecordCovidState();
}

class _RecordCovidState extends State<RecordCovid> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final CalendarController _CController = CalendarController();
  late SharedPreferences prefs;
  Map<DateTime, List<dynamic>> _events = {};
  List<dynamic> _selectedEvents = [];
  var _selectedDate = DateTime.now();
  var userid = FirebaseAuth.instance.currentUser.uid;
  var covid = false;


  void initState() {
    super.initState();
    _selectedEvents = [];
    // initPref();
    _events = {};
  }

  bool canselect = true;

  bool _C = false;
  var _cimage = 'caugh-bw.png';
  bool _H = false;
  var _himage = 'head-bw.png';
  bool _F = false;
  var _fimage = 'fever-bw.png';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Record My Situation"),
      ),
      body: Form(
          key: _formKey,
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      alignment: Alignment.center,
                      child: const Text(
                        'Record Situation',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Column(
                      children: [
                        TableCalendar(
                          events: _events,
                          calendarController: _CController,
                          calendarStyle: CalendarStyle(
                            todayColor: Colors.orange,
                            selectedColor: Theme.of(context).primaryColor,
                            todayStyle: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18.0,
                                color: Colors.white),
                          ),
                          headerStyle: HeaderStyle(
                              centerHeaderTitle: true,
                              formatButtonDecoration: BoxDecoration(
                                  color: Colors.orange,
                                  borderRadius: BorderRadius.circular(20.0)),
                              formatButtonTextStyle:
                                  TextStyle(color: Colors.white),
                              formatButtonShowsNext: false),
                          builders: CalendarBuilders(
                            selectedDayBuilder: (context, date, events) =>
                                Container(
                                    margin: EdgeInsets.all(4.0),
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                        color: Theme.of(context).primaryColor,
                                        //shape: BoxShape.circle
                                        borderRadius:
                                            BorderRadius.circular(10.0)),
                                    child: Text(date.day.toString())),
                            todayDayBuilder: (context, date, events) =>
                                Container(
                              margin: EdgeInsets.all(4.0),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                  color: Colors.pinkAccent,
                                  //shape: BoxShape.circle
                                  borderRadius: BorderRadius.circular(10.0)),
                              child: Text(
                                date.day.toString(),
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                          startDay: DateTime.utc(2010, 10, 16),
                          endDay: DateTime.utc(2030, 3, 14),
                          initialSelectedDay: DateTime.now(),
                          onDaySelected: (DateTime date, List<dynamic> events,
                              List<dynamic> evev) {

                            setState(() {
                              if(DateTime.now().isBefore(date))
                                canselect=false;
                              else
                                canselect = true;
                              _selectedDate = date;
                              _selectedEvents = events;
                            });
                          },
                        ),
                        Column(
                          children: [
                            Container(
                              child: StreamBuilder<DocumentSnapshot>(
                                  stream: users
                                      .doc(userid)
                                      .collection('covidrecord')
                                      .doc(_selectedDate.toString())
                                      .snapshots(),
                                  builder: (context, snapshot) {
                                    if(!snapshot.hasData){
                                      return Text('snapshot has no data');
                                    }
                                    if(snapshot.data!.data()==null||snapshot.data!.data()==null){
                                      _C = false;
                                      _H = false;
                                      _F = false;
                                    }else{
                                      _C = snapshot.data!.data()['cough'];
                                      _H = snapshot.data!.data()['headache'];
                                      _F = snapshot.data!.data()['fever'];
                                    }

                                    !_C
                                        ? _cimage = 'caugh-bw.png'
                                        : _cimage = 'caugh.png';
                                    !_H
                                        ? _himage = 'head-bw.png'
                                        : _himage = 'head.png';
                                    !_F
                                        ? _fimage = 'fever-bw.png'
                                        : _fimage = 'fever.png';

                                    print(_C);

                                    return canselect?Column(
                                      children: [
                                        Container(
                                            child: ElevatedButton(
                                              style: ElevatedButton.styleFrom(primary: Color(0xffa45c6c)),
                                          child: !covid
                                              ? Text('not infected')
                                              : Text('infected'),
                                          onPressed: () {
                                            if(!covid){
                                              addCovidRecord(
                                                  userid,
                                                  _selectedDate,
                                                  false,
                                                  false,
                                                  false,
                                                  false);
/*
                                              var s = json.encode({'cough':false,'head':false,'fever':false,'infected':false});

                                              prefs.setString(_selectedDate.toString(), s);*/
                                            }

                                            setState(() {
                                              covid = !covid;
                                            });
                                          },
                                        )),
                                        covid
                                            ? Text('Thank you, please be safe!')
                                            : Container(
                                                child: SingleChildScrollView(
                                                  scrollDirection:
                                                      Axis.horizontal,
                                                  child: Row(
                                                    children: [
                                                      Container(
                                                        height: 150,
                                                        width: 150,
                                                        child: ListTile(
                                                          title: InkWell(
                                                            child: Image.asset(
                                                              'assets/images/' +
                                                                  _cimage,
                                                              width: 80,
                                                              height: 80,
                                                            ),
                                                            onTap: () {
                                                              _C = !_C;
                                                              setState(() {
                                                                if (_C)
                                                                  _cimage =
                                                                  'caugh.png';
                                                                else
                                                                  _cimage =
                                                                  'caugh-bw.png';
                                                              });

                                                              addCovidRecord(
                                                                  userid,
                                                                  _selectedDate,
                                                                  _C,
                                                                  _H,
                                                                  _F,
                                                                  true);

                                                            },
                                                          ),
                                                          subtitle: Text(
                                                            "Caugh",
                                                            textAlign: TextAlign
                                                                .center,
                                                            style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w700),
                                                          ),
                                                        ),
                                                      ),
                                                      Container(
                                                        height: 150,
                                                        width: 150,
                                                        child: ListTile(
                                                          title: InkWell(
                                                            child: Image.asset(
                                                              'assets/images/' +
                                                                  _himage,
                                                              width: 80,
                                                              height: 80,
                                                            ),
                                                            onTap: () {
                                                              _H = !_H;

                                                              setState(() {
                                                                if (_H)
                                                                  _himage =
                                                                  'head.png';
                                                                else
                                                                  _himage =
                                                                  'head-bw.png';
                                                              });

                                                              addCovidRecord(
                                                                  userid,
                                                                  _selectedDate,
                                                                  _C,
                                                                  _H,
                                                                  _F,
                                                                  true);

                                                            },
                                                          ),
                                                          subtitle: Text(
                                                            "Headache",
                                                            textAlign: TextAlign
                                                                .center,
                                                            style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w700),
                                                          ),
                                                        ),
                                                      ),
                                                      Container(
                                                        height: 150,
                                                        width: 150,
                                                        child: ListTile(
                                                          title: InkWell(
                                                            child: Image.asset(
                                                              'assets/images/' +
                                                                  _fimage,
                                                              width: 80,
                                                              height: 80,
                                                            ),
                                                            onTap: () {
                                                              _F = !_F;
                                                              setState(() {
                                                                if (_F)
                                                                  _himage =
                                                                  'fever.png';
                                                                else
                                                                  _himage =
                                                                  'fever-bw.png';
                                                              });
                                                              addCovidRecord(
                                                                  userid,
                                                                  _selectedDate,
                                                                  _C,
                                                                  _H,
                                                                  _F,
                                                                  true);

                                                            },
                                                          ),
                                                          subtitle: Text(
                                                            "Fever",
                                                            textAlign: TextAlign
                                                                .center,
                                                            style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w700),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                      ],
                                    ):Container();
                                  }),
                            ),
                          ],
                        )
                      ],
                    ),
                    ..._selectedEvents.map((e) => ListTile(
                          title: Text(e),
                        )),
                  ],
                ),
              ),
            ),
          )),
    );
  }
}
