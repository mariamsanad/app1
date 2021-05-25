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

              child: Container(
                height: 200,
                child: Row(
                  children: [
                    Expanded(/*flex:2,*/ child: Container(
                      alignment: Alignment.topLeft,
                      height: 200,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            // margin: EdgeInsets.only(top:10, bottom:10),
                            child: Center(
                              child: Text(country.toString(),
                                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800,color: Colors.red,fontFamily: 'Mariam'), textAlign: TextAlign.center),
                            ),),
                          Row(
                            children: [
                              Expanded(child: Row(
                                children: [
                                  Text("Active cases:"+ "\t",
                                    style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold,fontSize: 20,fontFamily: 'Mariam'),),
                                  Text(active.toString(),
                                    style: TextStyle(color: Colors.green,fontWeight: FontWeight.bold,fontSize: 15,fontFamily: 'Mariam'),)
                                ],
                              ),

                              ),
                              Expanded(child: Row(
                                children: [
                                  Text("Deaths:",
                                    style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold,fontSize: 20,fontFamily: 'Mariam')),
                                  Text(this.deaths.toString(),
                                    style: TextStyle(color: Colors.red,fontWeight: FontWeight.bold,fontSize: 15,fontFamily: 'Mariam'),),
                                ],
                              ),

                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Expanded(child: Row(
                                children: [
                                  Text("\n"+'Confirmed: '+'\t',
                                    style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold,fontSize: 20,fontFamily: 'Mariam'),),
                                  Text("\n"+ confirmed.toString(),
                                    style: TextStyle(color: Colors.green,fontWeight: FontWeight.bold,fontSize: 15,fontFamily: 'Mariam'),)
                                ],
                              ),

                              ),
                              Expanded(child: Row(
                                children: [
                                  Text("\n"+"Recovered: ",
                                      style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold,fontSize: 20,fontFamily: 'Mariam')),
                                  Text("\n"+ this.recoverd.toString() ,
                                    style: TextStyle(color: Colors.green,fontWeight: FontWeight.bold,fontSize: 15,fontFamily: 'Mariam'),),
                                ],
                              ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Expanded(child: Row(
                                children: [
                                  Text("\n\t" +"Last Updated Date: ",
                                    style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold,fontSize: 20,fontFamily: 'Mariam')),
                                  Text("\n"+DateFormat('EEEE, d-MMM-yyyy').format(d),
                                    style: TextStyle(color: Colors.red,fontWeight: FontWeight.bold,fontSize: 15,fontFamily: 'Mariam'))

                                ],
                              ),

                              )
                            ],
                          ),

                        ],
                      ),
                    ),)
                  ],
                ),
              ));

  }
}
