import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import './Components/drawer.dart';
import 'Services/crudUser.dart';


//final GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();

class Home extends StatelessWidget {

  final Auth _auth = Auth();
  //final FirebaseAuth _auth = FirebaseAuth.instance;
  @override
  Widget build(BuildContext context) {
    // final active_user = Provider.of<user>(context);
    //print(active_user);
    return StreamBuilder(
        stream: _auth.suser,
        builder: (context, AsyncSnapshot snapshot) {
          print(snapshot.data);
          return Scaffold(
            //key: scaffoldKey,
              drawer: MyDrawer(),
              appBar: AppBar(
                /* backgroundColor: Colors.cyan,*/
                title: Text("Covid-19"),
                actions: [
                  Container(
                    child: FirebaseAuth.instance.currentUser==null?null:FlatButton(onPressed: ()async{
                      await _auth.signout().then((value) => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        backgroundColor: Colors.green,
                        content: Text('Signed out successfully'),
                      )));

                    }, child: Text("Logout")),
                  )
                ],
              ),
              body: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    /*Center(
                    child: Image.asset('assets/images/download.jpg'),
                  ),*/
                    /*Container(
                    padding: EdgeInsets.all(10),
                    child: Text("Services: ", style: TextStyle(fontSize:30 , color: Colors.cyan),),
                  ),*/
                    Container(
                      padding: EdgeInsets.only(top: 30),
                      height: 150,
                      child: ListView(
                        scrollDirection: Axis.horizontal ,
                        children: [
                          /* InkWell(
                          child:Container(
                            height: 150,
                            width: 150,
                            child: ListTile(
                              title: Image.asset("assets/images/teamwork.png", width: 80, height: 80,),
                              subtitle: Text("Users", textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.w700),),
                            ),) ,
                          onTap: (){
                            Navigator.of(context).pushNamed("users");
                          },
                        ),*/InkWell(
                            child:  Container(
                              height: 150,
                              width: 150,
                              child: ListTile(
                                title: Image.asset("assets/images/graph.png",width: 80, height: 80, ),
                                subtitle: Text("Statistics", textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.w700),),
                              ),), onTap: (){
                            Navigator.of(context).pushNamed("statistics");
                          },
                          ), InkWell(
                            child:  Container(
                              height: 100,
                              width: 150,
                              child: ListTile(
                                title: Image.asset("assets/images/news.png",width: 80, height: 80, ),
                                subtitle: Text("News", textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.w700)),
                              ),),onTap: (){
                            Navigator.of(context).pushNamed("news");
                          },
                          ), InkWell(
                            child: Container(
                              height: 150,
                              width: 150,
                              child: ListTile(
                                title: Image.asset("assets/images/calendar.png",width: 80, height: 80, ),
                                subtitle: Text("My Situation", textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.w700),),
                              ),),onTap: (){},
                          ),
                        ] ,
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.all(15.0),
                      // padding: EdgeInsets.all(15),
                      height: 350,
                      decoration: BoxDecoration(
                        // border: Border.all(),
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                        /*color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 5,
                          blurRadius: 7,
                          offset: Offset(0, 3), // changes position of shadow
                        ),
                      ],*/
                      ),
                      /* decoration: BoxDecoration(
                        // border: Border.all(),
                        borderRadius: BorderRadius.all(Radius.circular(20))
                    ),*/
                      // width: 150,
                      child: PageView(
                        children: <Widget>[
                          Container(
                            margin: const EdgeInsets.only(top: 15,right: 8,left: 8,bottom: 18),
                            decoration: BoxDecoration(
                              // border: Border.all(),
                              borderRadius: BorderRadius.all(Radius.circular(20)),
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.5),
                                  spreadRadius: 5,
                                  blurRadius: 7,
                                  offset: Offset(0, 3), // changes position of shadow
                                ),
                              ],
                            ),

                          ),
                          Container(
                            margin: const EdgeInsets.only(top: 15,right: 8,left: 8,bottom: 18),
                            decoration: BoxDecoration(
                              // border: Border.all(),
                              borderRadius: BorderRadius.all(Radius.circular(20)),
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.5),
                                  spreadRadius: 5,
                                  blurRadius: 7,
                                  offset: Offset(0, 3), // changes position of shadow
                                ),
                              ],
                            ),

                          ),
                          Container(
                            margin: const EdgeInsets.only(top: 15,right: 8,left: 8,bottom: 18),
                            decoration: BoxDecoration(
                              // border: Border.all(),
                              borderRadius: BorderRadius.all(Radius.circular(20)),
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.5),
                                  spreadRadius: 5,
                                  blurRadius: 7,
                                  offset: Offset(0, 3), // changes position of shadow
                                ),
                              ],
                            ),
                            child: Column(

                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              )
          );
        }
    );
  }
}

