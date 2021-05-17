import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:app1/Services/crudUser.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';

class RecordCovid extends StatefulWidget {
  @override
  _RecordCovidState createState() => _RecordCovidState();
}

class _RecordCovidState extends State<RecordCovid> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final CalendarController _CController = CalendarController();
  final TextEditingController _eventController = TextEditingController();
  late SharedPreferences prefs;
  Map<DateTime, List<dynamic>> _events = {};
  List<dynamic> _selectedEvents = [];
  var _selectedDate;

  initPref() async {
    prefs = await SharedPreferences.getInstance();
    setState(() {
      _events = Map<DateTime, List<dynamic>>.from(
          decodeMap(json.decode(prefs.getString("events") ?? "{}")));
    });
  }

  Map<DateTime, dynamic> decodeMap(Map<String, dynamic> map) {
    Map<DateTime, dynamic> newMap = {};
    map.forEach((key, value) {
      newMap[DateTime.parse(key)] = map[key];
    });
    return newMap;
  }

  Map<String, dynamic> encodeMap(Map<DateTime, dynamic> map) {
    Map<String, dynamic> newMap = {};
    map.forEach((key, value) {
      newMap[key.toString()] = map[key];
    });
    return newMap;
  }

  void initState() {
    super.initState();
    _selectedEvents = [];
    initPref();
    _events = {};
  }

  bool _C = false;
  var _cimage = 'caugh-bw.png';
  bool _H = false;
  var _himage = 'head-bw.png';
  bool  _F = false;
  var _fimage = 'fever-bw.png';

  DateTime start = DateTime.now();
  DateTime end = DateTime.now();

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
                              formatButtonTextStyle: TextStyle(color: Colors.white),
                              formatButtonShowsNext: false),
                          builders: CalendarBuilders(
                            selectedDayBuilder: (context, date, events) =>
                                Container(
                                    margin: EdgeInsets.all(4.0),
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                        color: Theme.of(context).primaryColor,
                                        //shape: BoxShape.circle
                                        borderRadius: BorderRadius.circular(10.0)),
                                    child: Text(date.day.toString())),
                            todayDayBuilder: (context, date, events) => Container(
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
                              _selectedDate = date;
                              _selectedEvents = events;
                            });
                          },
                        ),
                        FutureBuilder(
                          future: getCovidRecord(_selectedDate,FirebaseAuth.instance.currentUser.uid),
                          builder: (context, snapshot) {
                            return SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                              children: [
                               Container(
                                    height: 150,
                                    width: 150,
                                    child: ListTile(
                                      title: InkWell(child: Image.asset('assets/images/'+_cimage, width: 80, height: 80,),onTap: (){
                                        _C = !_C;
                                        setState(() {
                                          if(_C)
                                            _cimage = 'caugh.png';
                                          else
                                            _cimage = 'caugh-bw.png';
                                        });
                                      },),
                                      subtitle: Text("Caugh", textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.w700),),
                                    ),),
                                Container(
                                  height: 150,
                                  width: 150,
                                  child: ListTile(
                                    title: InkWell(child: Image.asset('assets/images/'+_himage, width: 80, height: 80,),onTap: (){
                                      _H = !_H;
                                      setState(() {
                                        if(_H)
                                          _himage = 'head.png';
                                        else
                                          _himage = 'head-bw.png';
                                      });
                                    },),
                                    subtitle: Text("Headache", textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.w700),),
                                  ),),
                                Container(
                                  height: 150,
                                  width: 150,
                                  child: ListTile(
                                    title: InkWell(child: Image.asset('assets/images/'+_fimage, width: 80, height: 80,),onTap: (){
                                      _F = !_F;
                                      setState(() {
                                        if(_F)
                                          _fimage = 'fever.png';
                                        else
                                          _fimage = 'fever-bw.png';
                                      });
                                    },),
                                    subtitle: Text("Fever", textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.w700),),
                                  ),),
                              ],
                              ),
                            );
                          }
                        ),
                      ],
                    ),
                   /* Row(
                      children: [
                        SizedBox(
                          height: 20,
                        ),
                        ElevatedButton(
                          onPressed: () => _selectDate1(context),
                          child: Text("Select the Starting date"),
                        )
                      ],
                    ),*/
                    ..._selectedEvents.map((e) => ListTile(
                          title: Text(e),
                        )),
                    Container(
                      padding: const EdgeInsets.only(top: 16),
                      alignment: Alignment.center,
                      child: ElevatedButton(
                        child: Text('Record'),
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            var id = FirebaseAuth.instance.currentUser.uid;
                           // await addCovidRecord(id, _C, _H, _F, start, end);
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          _showEventForm();
        },
      ),
    );
  }

  _showEventForm() {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              content: TextField(
                controller: _eventController,
              ),
              actions: [
                FlatButton(
                    onPressed: () {
                      if (_eventController.text.isEmpty) return;
                      if (_events[_CController.selectedDay] != null) {
                        _events[_CController.selectedDay]!
                            .add(_eventController.text);
                      } else {
                        _events[_CController.selectedDay] = [
                          _eventController.text
                        ];
                      }
                      prefs.setString(
                          "events", json.encode(encodeMap(_events)));
                      _eventController.clear();
                      Navigator.pop(context);
                    },
                    child: Text("Save"))
              ],
            ));
    setState(() {
      _selectedEvents = _events[_CController.selectedDay]!;
    });
  }

  _selectDate1(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: start,
      firstDate: DateTime(2000),
      lastDate: DateTime(2025),
      //initialEntryMode: DatePickerEntryMode.input
    );

    if (picked != null && picked != start)
      setState(() {
        start = picked;
      });
  }

  _selectDate2(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: end,
      firstDate: DateTime(2000),
      lastDate: DateTime(2025),
    );

    if (picked != null && picked != end)
      setState(() {
        end = picked;
      });
  }
}
