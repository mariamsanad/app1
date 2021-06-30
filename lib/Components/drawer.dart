import 'package:app1/Screens/Companies.dart';
import 'package:app1/Services/crudUser.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'loading.dart';

class MyDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: checkRole(),
        builder: (context, AsyncSnapshot snapshot) {
          return FutureBuilder(
          future: getUserNameA(),
          builder: (context, s) {
          if (!s.hasData) {
             return Loading();
            }
          return Drawer(
              child: ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                child: (FirebaseAuth.instance.currentUser == null ||
                        FirebaseAuth.instance.currentUser.photoURL == null)
                    ? null
                    :(FirebaseAuth.instance.currentUser == null )?Padding(
                  padding: const EdgeInsets.all(7.0),
                  child: Text('Welcome '+s.data.toString()),
                ): /*(FirebaseAuth.instance.currentUser != null && FirebaseAuth.instance.currentUser.photoURL != null)? */ Row(
                        children: [
                          Column(
                            children: [
                              ClipRRect(
                                //borderRadius: BorderRadius.circular(30.0),
                                child: Image.network(
                                  FirebaseAuth.instance.currentUser.photoURL,
                                  alignment: AlignmentDirectional.bottomStart,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(3.0),
                                child: Text('Welcome '+s.data.toString()),
                              )
                            ],
                          ),
                        ],
                      ),/*Text('Welcome '+getUserName(id))*/
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                ),
              ),
              Container(
                child: snapshot.data != 'nouser'
                    ? null
                    : ListTile(
                        title: Text("Sign in"),
                        leading: Image.asset(
                          "assets/images/user.png",
                          width: 40,
                          height: 40,
                        ),
                        onTap: () {
                          Navigator.of(context).pushNamed("login");
                        },
                      ),
              ),
              Container(
                child: snapshot.data != 'admin'
                    ? null
                    : ListTile(
                        title: Text("All Companies & Supervisors"),
                        leading: Image.asset(
                          "assets/images/company.png",
                          width: 40,
                          height: 40,
                        ),
                        onTap: () {
                          Navigator.of(context).pushNamed("companies");
                        },
                      ),
              ),
              Container(
                child: snapshot.data != 'admin'
                    ? null
                    : ListTile(
                        title: Text("View All Users"),
                        leading: Image.asset(
                          "assets/images/teamwork.png",
                          width: 40,
                          height: 40,
                        ),
                        onTap: () {
                          Navigator.of(context).pushNamed("users");
                        },
                      ),
              ),
              Container(
                child: snapshot.data != 'admin'
                    ? null
                    : ListTile(
                        title: Text("Doctors"),
                        leading: Image.asset(
                          "assets/images/doctor.png",
                          width: 40,
                          height: 40,
                        ),
                        onTap: () {
                          Navigator.of(context).pushNamed("doctoradd");
                        },
                      ),
              ),
              Container(
                child: snapshot.data == 'nouser'
                    ? null
                    : ListTile(
                  title: Text("My Covid Records"),
                  leading: Image.asset(
                    "assets/images/covid-test.png",
                    width: 40,
                    height: 40,
                  ),
                  onTap: () {
                    Navigator.of(context).pushNamed("reportforuser");
                  },
                ),
              ),
              Container(
                child: snapshot.data != 'admin'
                    ? null
                    : ListTile(
                  title: Text("Admin Covid Records"),
                  leading: Image.asset(
                    "assets/images/chart.png",
                    width: 40,
                    height: 40,
                  ),
                  onTap: () {
                    Navigator.of(context).pushNamed("admincovedrec");
                  },
                ),
              ),
              Container(
                child: snapshot.data != 'company'
                    ? null
                    : ListTile(
                  title: Text("Company Covid Records"),
                  leading: Image.asset(
                    "assets/images/chart.png",
                    width: 40,
                    height: 40,
                  ),
                  onTap: () {
                    Navigator.of(context).pushNamed("companycovedrec");
                  },
                ),
              ),
              Container(
                child: snapshot.data != 'supervisor'
                    ? null
                    : ListTile(
                  title: Text("Supervisor Covid Records"),
                  leading: Image.asset(
                    "assets/images/chart.png",
                    width: 40,
                    height: 40,
                  ),
                  onTap: () {
                    Navigator.of(context).pushNamed("supercovedrec");
                  },
                ),
              ),
              Container(
                child: snapshot.data == 'nouser'
                    ? null
                    : ListTile(
                        title: Text("Profile"),
                        leading: Image.asset(
                          "assets/images/profile.png",
                          width: 40,
                          height: 40,
                        ),
                        onTap: () {
                          Navigator.of(context).pushNamed("profile");
                        },
                      ),
              ),
              Container(
                child: snapshot.data != 'doctor'
                    ? null
                    : ListTile(
                        title: Text("New Questions"),
                        leading: Image.asset(
                          "assets/images/chat.png",
                          width: 40,
                          height: 40,
                        ),
                        onTap: () {
                          Navigator.of(context).pushNamed("viewquestions");
                        },
                      ),
              ),
              Container(
                child: snapshot.data != 'doctor'
                    ? null
                    : ListTile(
                        title: Text("Questions History"),
                        leading: Image.asset(
                          "assets/images/chat.png",
                          width: 40,
                          height: 40,
                        ),
                        onTap: () {
                          Navigator.of(context).pushNamed("chathistory");
                        },
                      ),
              ),
              Container(
                child: snapshot.data == 'nouser' || snapshot.data == 'doctor'
                    ? null
                    : ListTile(
                        title: Text("Ask a Doctor"),
                        leading: Image.asset(
                          "assets/images/chat.png",
                          width: 40,
                          height: 40,
                        ),
                        onTap: () {
                          Navigator.of(context).pushNamed("chatroom");
                          createChat(FirebaseAuth.instance.currentUser.uid);
                        },
                      ),
              ),
              Container(
                child: snapshot.data != 'nouser'
                    ? null
                    : ListTile(
                        enabled: FirebaseAuth.instance.currentUser == null,
                        title: Text("Register"),
                        leading: Image.asset(
                          "assets/images/document.png",
                          width: 40,
                          height: 40,
                        ),
                        onTap: () {
                          Navigator.of(context).pushNamed("register");
                        },
                      ),
              ),
              Container(
                child: snapshot.data != 'company'
                    ? null
                    : ListTile(
                        title: Text("Supervisors"),
                        leading: Image.asset(
                          "assets/images/supervisor2.png",
                          width: 40,
                          height: 40,
                        ),
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => Supervisors(
                                    FirebaseAuth.instance.currentUser.uid),
                              ));
                        },
                      ),
              ),
              Container(
                child: snapshot.data == 'nouser'
                    ? null
                    : ListTile(
                  title: Text("Record My Situation"),
                  leading: Image.asset(
                    "assets/images/situation.png",
                    width: 40,
                    height: 40,
                  ),
                  onTap: () {
                    Navigator.of(context).pushNamed('recordsit');
                  },
                ),
              ),
              Container(
                child: snapshot.data != 'supervisor'
                    ? null
                    : ListTile(
                        title: Text("Record Users"),
                        leading: Image.asset(
                          "assets/images/userdata.png",
                          width: 40,
                          height: 40,
                        ),
                        onTap: () {
                          Navigator.of(context).pushNamed('position');
                        },
                      ),
              ),
            ],
          ));
        });
  }
    );}

}