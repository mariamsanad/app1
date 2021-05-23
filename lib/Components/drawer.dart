import 'package:app1/Services/crudUser.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MyDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: checkRole(),
      builder: (context,AsyncSnapshot snapshot) {
        print(snapshot.data);
        return Drawer(
          child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    DrawerHeader(
                      child: (FirebaseAuth.instance.currentUser == null ||
                              FirebaseAuth.instance.currentUser.photoURL == null)
                          ? null
                          : ClipRRect(
                              //borderRadius: BorderRadius.circular(30.0),
                              child: Image.network(
                                FirebaseAuth.instance.currentUser.photoURL,
                                alignment: AlignmentDirectional.bottomStart,
                              ),
                            ),
                      decoration: BoxDecoration(
                        color: Colors.cyan,
                      ),
                    ),
                    Container(
                      child: snapshot.data!='nouser'?null:ListTile(
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
                      child: snapshot.data!='admin'?null:ListTile(
                        title: Text("Companies"),
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
                      child: ListTile(
                        title: Text("My Graph"),
                        leading: Image.asset(
                          "assets/images/company.png",
                          width: 40,
                          height: 40,
                        ),
                        onTap: () {
                          Navigator.of(context).pushNamed("reportforuser");
                        },
                      ),
                    ),
                    Container(
                      child: ListTile(
                        title: Text("Admin Covid Records"),
                        leading: Image.asset(
                          "assets/images/fever.png",
                          width: 40,
                          height: 40,
                        ),
                        onTap: () {
                          Navigator.of(context).pushNamed("admincovedrec");
                        },
                      ),
                    ),
                    Container(
                      child: snapshot.data=='nouser'?null:ListTile(
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
                      child: snapshot.data!='nouser'?null:ListTile(
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
                      child: snapshot.data!='admin'?null:ListTile(
                        title: Text("Add a Company"),
                        leading: Image.asset(
                          "assets/images/company.png",
                          width: 40,
                          height: 40,
                        ),
                        onTap: () {
                          Navigator.of(context).pushNamed("companyadd");
                        },
                      ),
                    ),
                    Container(
                      child: (/*snapshot.data!='admin' && */snapshot.data!='company')?null:ListTile(
                        title: Text("Add a Supervisor"),
                        leading: Image.asset(
                          "assets/images/supervisor2.png",
                          width: 40,
                          height: 40,
                        ),
                        onTap: () {
                          Navigator.of(context).pushNamed("supervisoradd");
                        },
                      ),
                    ),
                    Container(
                      child: snapshot.data!='company'?null:ListTile(
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
                                builder: (context) => SupervisorsList(
                                    FirebaseAuth.instance.currentUser.uid),
                              ));
                        },
                      ),
                    ),
                    Container(
                      child: ListTile(
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
                      child: snapshot.data!='supervisor'?null:ListTile(
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
      }
    );
  }
}
