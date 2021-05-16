import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Cdetails extends StatelessWidget {

  final code;
  final confirmed;
  final deaths;
  final recoverd;
  final active;
  final date;
  final country;


  Cdetails({this.date,this.code, this.confirmed, this.deaths, this.recoverd, this.active, this.country});


  @override
  Widget build(BuildContext context) {
    DateTime d = DateTime.parse(this.date);
    return Card(
              child: Row(
                children: [
                  /*Expanded(flex:1, child: Image.asset("assets/images/chatbot.png")),*/
                  Expanded(flex:2, child: Container(
                    alignment: Alignment.topLeft,
                    height: 160,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          margin: EdgeInsets.only(top:10, bottom:10),
                          child: Center(
                            child: Text(country.toString(),
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800,color: Colors.red), textAlign: TextAlign.center),
                          ),),
                        Row(
                          children: [
                            Expanded(child: Row(
                              children: [
                                Text("Active cases ",
                                  style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold,fontSize: 20),),
                                Text(active.toString(),
                                  style: TextStyle(color: Colors.green,fontWeight: FontWeight.bold,fontSize: 15),)
                              ],
                            ),

                            ),
                            Expanded(child: Row(
                              children: [
                                Text("Deaths ",
                                  style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold,fontSize: 20)),
                                Text(this.deaths.toString(),
                                  style: TextStyle(color: Colors.red,fontWeight: FontWeight.bold,fontSize: 15),),
                              ],
                            ),

                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Expanded(child: Row(
                              children: [
                                Text('Confirmed '+'\t',
                                  style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold,fontSize: 20),),
                                Text(confirmed.toString(),
                                  style: TextStyle(color: Colors.green,fontWeight: FontWeight.bold,fontSize: 15),)
                              ],
                            ),

                            ),
                            Expanded(child: Row(
                              children: [
                                Text("Recovered ",
                                    style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold,fontSize: 20)),
                                Text(this.recoverd.toString(),
                                  style: TextStyle(color: Colors.green,fontWeight: FontWeight.bold,fontSize: 15),),
                              ],
                            ),

                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Expanded(child: Row(
                              children: [
                                Text("Last Updated Date ",
                                  style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold,fontSize: 20)),
                                Text(DateFormat('EEEE, d-MMM-yyyy').format(d),
                                  style: TextStyle(color: Colors.red,fontWeight: FontWeight.bold,fontSize: 15))

                              ],
                            ),

                            )
                          ],
                        ),

                      ],
                    ),
                  ),)
                ],
              ));

        // Container(child: Image.asset('assets/images/corona.png',width: 180,height: 120,),padding: EdgeInsets.only(left: 300,top: 80),)
    //   ],
    // );
  }
}
