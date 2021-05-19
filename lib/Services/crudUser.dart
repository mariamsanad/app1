import 'package:app1/Components/loading.dart';
import 'package:app1/Screens/Companies.dart';
import 'package:app1/Screens/Position.dart';
import 'package:app1/Screens/Profile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:intl/intl.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'User.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;

checkRole() async {
  if (FirebaseAuth.instance.currentUser == null) return 'nouser';
  String userid = FirebaseAuth.instance.currentUser.uid;

  var v = await FirebaseFirestore.instance
      .collection('users')
      .doc(userid)
      .get()
      .then((value) {
    return value.data()['role'];
  }).onError((error, stackTrace) {
    return error;
  });

  return v;
}
/*
getCompanyName(cid) async {
  var v = await companies.doc(cid).get().then((value) {
    return value.data()['name'];
  }).onError((error, stackTrace){return error;});
  return v;
}*/

CollectionReference users = FirebaseFirestore.instance.collection('users');
CollectionReference positions =
    FirebaseFirestore.instance.collection('positions');
CollectionReference companies =
    FirebaseFirestore.instance.collection('companies');
CollectionReference records =
    FirebaseFirestore.instance.collection('covidrecords');

FirebaseApp secondaryApp = Firebase.app('SecondaryApp');
FirebaseAuth _auth2 = FirebaseAuth.instanceFor(app: secondaryApp);

updateProfile(userid, name, phone, vac, work) async {
  await _auth.currentUser
      .updateProfile(displayName: name, photoURL: _auth.currentUser.photoURL)
      .onError((error, stackTrace) {
    return error;
  });

  return users
      .doc(userid)
      .update({'user_name': name, 'phone': phone, 'vac': vac, 'work': work})
      .then((value) => print("User Updated"))
      .catchError((error) => print("Failed to update user: $error"));
}

updateCompanyProfile(cid, name, phone, type) async {
  await companies
      .doc(cid)
      .update({'name': name, 'phone': phone, 'type': type})
      .then((value) => print("Company Updated"))
      .catchError((error) => print("Failed to update company: $error"));
  return users
      .doc(cid)
      .update({'user_name': name, 'phone': phone})
      .then((value) => print("User Updated"))
      .catchError((error) => print("Failed to update user: $error"));
}

getUser(String userId) async =>
    users.doc(userId).get().then((DocumentSnapshot documentSnapshot) {
      if (documentSnapshot.exists) {
        return documentSnapshot;
      } else {
        return 'there is no user with this id!';
      }
    });

getCompanyid(String userId) async =>
    users.doc(userId).get().then((DocumentSnapshot documentSnapshot) {
      if (documentSnapshot.exists) {
        return documentSnapshot.data()['company_id'];
      } else {
        return 'there is no user with this id!';
      }
    });

Future<String> getSuperid(userId) async =>
    users.doc(userId).get().then((DocumentSnapshot documentSnapshot) {
      if (documentSnapshot.exists) {
        return documentSnapshot.data()['supervisor_id'];
      } else {
        return 'there is no user with this id!';
      }
    });

class Auth {
  Stream<user> get suser {
    return _auth.authStateChanges().map((User user) => _userfromfb(user)!);
  }

  user? _userfromfb(User user1) {
    return user1 != null ? user(user1.uid, user1.email) : null;
  }

  Future register(String email, String pass, String type) async {
    final User user = (await _auth.createUserWithEmailAndPassword(
      email: email,
      password: pass,
    ))
        .user;

    addUser(user.uid, user.displayName, email, type, '', false, 'home');

    return _userfromfb(user);
  }

  Future signInNormal(String email, String pass) async {
    final User user = (await _auth.signInWithEmailAndPassword(
      email: email,
      password: pass,
    ))
        .user;

    return _userfromfb(user);
  }

  Future signInNormal1(String email, String pass) async {
    final User user = (await _auth2.signInWithEmailAndPassword(
      email: email,
      password: pass,
    ))
        .user;

    return _userfromfb(user);
  }

  Future<bool> userExists(String username) async =>
      (await users.where("email", isEqualTo: username).get()).docs.length > 0;

  Future signInWithGoogle() async {
    try {
      UserCredential userCredential;

      final GoogleSignInAccount googleUser = await GoogleSignIn().signIn();
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final OAuthCredential googleAuthCredential =
          GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      userCredential = await _auth.signInWithCredential(googleAuthCredential);

      final user = userCredential.user;

      if (await userExists(userCredential.user.email) != true) {
        addUser(user.uid, user.displayName, user.email, 'normal',
            user.phoneNumber, false, 'home');
      }

      return _userfromfb(user);
    } on FirebaseAuthException catch (e) {
      return e;
    }
  }

  Future ResetPassword(String email) async {
    try {
      return await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      return e.toString();
    }
  }

  Future signout() async {
    try {
      return await _auth.signOut();
    } catch (e) {
      return e.toString();
    }
  }
}

Future<void> addUser(id, nome, name, type, phone, vac, workfrom) {
  // Call the user's CollectionReference to add a new user
  return users
      .doc(id)
      .set({
        'user_id': id,
        'email': name,
        'user_name': nome,
        'type': type,
        'role': 'user',
        'phone': phone,
        'vac': vac,
        'work': workfrom
      })
      .then((value) => print("User Added"))
      .catchError((error) => print("Failed to add user: $error"));
}

class UsersList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: users.snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return Text('Something went wrong,you may be not authenticated');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Loading();
        }

        return snapshot.hasData
            ? SizedBox(
                width: double.infinity,
                child: DataTable(
                  showCheckboxColumn: false,
                  sortColumnIndex: 0,
                  sortAscending: true,
                  columns: [
                    DataColumn(
                      label: Text(
                        'Name',
                        style: TextStyle(fontStyle: FontStyle.italic),
                      ),
                    ),
                    DataColumn(
                      numeric: true,
                      label: Text(
                        'Phone',
                        style: TextStyle(fontStyle: FontStyle.italic),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Type',
                        style: TextStyle(fontStyle: FontStyle.italic),
                      ),
                    ),
                  ],
                  rows: snapshot.data!.docs.map((DocumentSnapshot document) {
                    return DataRow(
                        onSelectChanged: (b) {

                        },
                        cells: [
                          DataCell(
                              Text(document.data()['user_name'].toString())),
                          DataCell(Text(document.data()['phone'].toString())),
                          /*TextButton(onPressed: (){
                      Navigator.of(context).pushNamed('reset');
                    }, child: Text('Forgot password?'))*/
                          DataCell(document.data()['type'] != 'supervisor'?Text(document.data()['type']):TextButton(child: Text(document.data()['type'],style: TextStyle(color: Colors.green),),onPressed: (){
                            if (document.data()['type'] == 'supervisor') {
                              showDialog(
                                  context: context,
                                  builder: (context) =>
                                      StreamBuilder<DocumentSnapshot>(
                                          stream: companies
                                              .doc(document.data()['company_id'])
                                              .snapshots(),
                                          builder: (context, snapshot) {
                                            return AlertDialog(
                                              content: snapshot.hasData
                                                  ? Text('Company: ' +
                                                  snapshot.data!['name'])
                                                  : Loading(),
                                              actions: [
                                                FlatButton(
                                                    onPressed: () {
                                                      Navigator.pop(context);
                                                    },
                                                    child: Text("OK"))
                                              ],
                                            );
                                          }));
                            }

                          },)),
                        ]);
                  }).toList(),
                ),
              )
            : Container(
                child: Text('No Supervisors found'),
              );
      },
    );
  }
}

class UsersForS extends StatefulWidget {
  @override
  _UsersForSState createState() => _UsersForSState();
  final sid, cid, pos;

  UsersForS(this.sid, this.cid, this.pos);
}

class _UsersForSState extends State<UsersForS> {
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return /*isLoading?SpinKitSquareCircle(
      color: Colors.blue.withOpacity(0.6),
      size: 50.0,
    ):*/
        StreamBuilder<QuerySnapshot>(
      stream: companies
          .doc(this.widget.cid)
          .collection('supervisors')
          .doc(this.widget.sid)
          .collection(this.widget.pos)
          .snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return Text('Something went wrong,you may be not authenticated');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Loading();
        }

        return new ListView(
          children: snapshot.data!.docs.map((DocumentSnapshot document) {
            return new ListTile(
              title: new Text('Name: ' + document.data()['name'].toString()),
              subtitle: new Text('Email: ' +
                  document.data()['email'].toString() +
                  '\nphone: ' +
                  document.data()['phone'].toString() +
                  '\ntype: ' +
                  document.data()['type']),
              trailing: new Text(document.id.toString()),
            );
          }).toList(),
        );
      },
    );
  }
}

class CompaniesList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: companies.snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return Text('Something went wrong, you may be not authenticated');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: Loading());
        }

        return SizedBox(
          width: double.infinity,
          child: DataTable(
            showCheckboxColumn: false,
            sortColumnIndex: 0,
            sortAscending: true,
            columns: [
              DataColumn(
                label: Text(
                  'Name',
                  style: TextStyle(fontStyle: FontStyle.italic),
                ),
              ),
              /* DataColumn(
                numeric: true,
                label: Text(
                  'Phone',
                  style: TextStyle(fontStyle: FontStyle.italic),
                ),
              ),*/
              DataColumn(
                label: Text(
                  'Type',
                  style: TextStyle(fontStyle: FontStyle.italic),
                ),
              ),
              DataColumn(
                label: Text(
                  'Supervisors',
                  style: TextStyle(fontStyle: FontStyle.italic),
                ),
              ),
            ],
            rows: snapshot.data!.docs.map((DocumentSnapshot document) {
              return DataRow(
                  onSelectChanged: (b) {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              CompanyProfile(document.data()['company_id']),
                        ));
                  },
                  cells: [
                    DataCell(Text(document.data()['name'].toString())),
                    /*DataCell(Text(document.data()['phone'].toString())),*/
                    DataCell(Text(document.data()['type'])),
                    DataCell(ElevatedButton(
                      child: Text('Show List'),
                      onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Supervisors(
                                document.data()['company_id'].toString()),
                          )),
                    )),
                  ]);
            }).toList(),
          ),
        );
      },
    );
  }
}

class SupervisorsList extends StatelessWidget {
  final cid;
  SupervisorsList(this.cid);
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: companies.doc(cid).collection('supervisors').snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return Text('Something went wrong,you may be not authenticated');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: Loading());
        }

        return snapshot.hasData
            ? SizedBox(
                width: double.infinity,
                child: DataTable(
                  showCheckboxColumn: false,
                  sortColumnIndex: 0,
                  sortAscending: true,
                  columns: [
                    DataColumn(
                      label: Text(
                        'Name',
                        style: TextStyle(fontStyle: FontStyle.italic),
                      ),
                    ),
                    DataColumn(
                      numeric: true,
                      label: Text(
                        'Phone',
                        style: TextStyle(fontStyle: FontStyle.italic),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Type',
                        style: TextStyle(fontStyle: FontStyle.italic),
                      ),
                    ),
                  ],
                  rows: snapshot.data!.docs.map((DocumentSnapshot document) {
                    return DataRow(
                        onSelectChanged: (b) {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      Positions(document.id.toString())));
                        },
                        cells: [
                          DataCell(Text(document.data()['name'].toString())),
                          DataCell(Text(document.data()['phone'].toString())),
                          DataCell(Text(document.data()['position'])),
                        ]);
                  }).toList(),
                ),
              )
            : Container(
                child: Text('No Supervisors found'),
              );
      },
    );
  }
}

Future<void> addCompany(name, type, address, cpr, email, phone) async {
  final UserCredential userCredential =
      await _auth2.createUserWithEmailAndPassword(email: email, password: cpr);
  users
      .doc(userCredential.user.uid)
      .set({
        'company_id': userCredential.user.uid,
        'email': email,
        'user_name': name,
        'phone': phone,
        'type': 'company',
        'role': 'company',
      })
      .then((value) => print("User Added"))
      .catchError((error) => print("Failed to add user: $error"));

  return companies
      .doc(userCredential.user.uid)
      .set({
        'name': name,
        'company_id': userCredential.user.uid,
        'email': email,
        'type': type,
        'phone': phone
      })
      .then((value) => print("Company Added Succesfully"))
      .catchError((error) => print("Failed to add company: $error"));
}

Future addSupervisor(String companyid, String name, String email, String pass,
    String phone, String position, vac, workfrom) async {
  final UserCredential userCredential =
      await _auth2.createUserWithEmailAndPassword(email: email, password: pass);

  users
      .doc(userCredential.user.uid)
      .set({
        'user_id': userCredential.user.uid,
        'email': email,
        'user_name': name,
        'phone': phone,
        'type': 'supervisor',
        'company_id': companyid,
        'role': 'supervisor',
        'vac': vac,
        'work': workfrom
      })
      .then((value) => print("User Added"))
      .catchError((error) => print("Failed to add user: $error"));

  CollectionReference rec = companies.doc(companyid).collection("supervisors");

  return rec
      .doc(userCredential.user.uid)
      .set({
        'name': name,
        'email': email,
        'position': position,
        'phone': phone,
        'company_id': companyid
      })
      .then((value) => print("Supervisor Added Succesfully"))
      .catchError((error) => print("Failed to add supervisor: $error"));
}

Future addPosition(id, name) {
  return positions
      .doc(id)
      .collection('poses')
      .doc(name)
      .set({
        'position': name,
      })
      .then((value) => print("Position Added"))
      .catchError((error) => print("Failed to add position: $error"));
}

Future deletePosition(uid, id) {
  return positions.doc(uid).collection('poses').doc(id).delete();
}

Future UserAdd1(String companyid, String supervisorid, String name,
    String email, String pass, String phone, String position, vac) async {
  final UserCredential userCredential =
      await _auth2.createUserWithEmailAndPassword(
    email: email,
    password: pass,
  );

  users
      .doc(userCredential.user.uid)
      .set({
        'user_id': userCredential.user.uid,
        'email': userCredential.user.email,
        'user_name': name,
        'phone': phone,
        'type': position,
        'company_id': companyid,
        'supervisor_id': supervisorid,
        'role': user,
        'vac': vac
      })
      .then((value) => print("User Added"))
      .catchError((error) => print("Failed to add user: $error"));

  CollectionReference rec = companies
      .doc(companyid)
      .collection('supervisors')
      .doc(supervisorid)
      .collection(position);
  CollectionReference rec1 = positions
      .doc(supervisorid)
      .collection('poses')
      .doc(position)
      .collection('users');

  rec
      .doc(userCredential.user.uid)
      .set({'name': name, 'email': email, 'type': position, 'phone': phone})
      .then((value) => print("User Added Succesfully"))
      .catchError((error) => print("Failed to add user: $error"));

  return rec1
      .doc(userCredential.user.uid)
      .set({
        'id': userCredential.user.uid,
      })
      .then((value) => print("User Added to position Succesfully"))
      .catchError((error) => print("Failed to add user to position: $error"));
}

Future<void> addCovidRecord(id, date, cough, headache, fever, infected) {
  CollectionReference rec = users.doc(id).collection("covidrecord");
  return rec
      .doc(date.toString())
      .set({
        'cough': cough,
        'headache': headache,
        'fever': fever,
        'infected': infected
      })
      .then((value) => print("Record Added"))
      .catchError((error) => print("Failed to add record: $error"));
}

class DeathRec {
  final deaths;
  final date;
  DeathRec(this.date, this.deaths);
}

getCovidRecord(id) {
  var arr = [];
  var val = users
      .doc(id)
      .collection('covidrecord')
      .get()
      .then((QuerySnapshot snapshot) {
    snapshot.docs.forEach((element) {
      print(element.data().toString());
      arr.add({element.id, element.data()});
    });
    return snapshot;
  });
  return val;
}

getDate(d) {
  var m = users
      .doc(FirebaseAuth.instance.currentUser.uid)
      .collection('covidrecord')
      .doc(d.toString())
      .get()
      .then((value) {
    if (value.exists)
      return value;
    else
      return false;
  });
  return m;
}

class RecordForUser extends StatefulWidget {
  @override
  _RecordForUserState createState() => _RecordForUserState();
  final uid;

  RecordForUser(this.uid);
}

class _RecordForUserState extends State<RecordForUser> {
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return /*isLoading?SpinKitSquareCircle(
      color: Colors.blue.withOpacity(0.6),
      size: 50.0,
    ):*/
        StreamBuilder<QuerySnapshot>(
      stream: users.doc(this.widget.uid).collection('covidrecord').snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return Text('Something went wrong,you may be not authenticated');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Loading();
        }

        return snapshot.hasData
            ? SizedBox(
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
                      numeric: true,
                      label: Text(
                        'Infected',
                        style: TextStyle(fontStyle: FontStyle.italic),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Delete',
                        style: TextStyle(fontStyle: FontStyle.italic),
                      ),
                    ),
                  ],
                  rows: snapshot.data!.docs.map((DocumentSnapshot document) {
                    return DataRow(
                        onSelectChanged: (b) {
                          var c = true;
                          var infected = document.data()['infected'],
                              head = document.data()['headache'],
                              fever = document.data()['fever'],
                              cough = document.data()['cough'];
                          if (!cough && !head && !fever) c = false;
                          // if (document.data()['type'] == 'supervisor') {
                          !document.data()['infected']
                              ? null
                              : showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                        shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(32.0))),
                                        content: snapshot.hasData
                                            ? SingleChildScrollView(
                                                child: Column(
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
                                                                child:
                                                                    Image.asset(
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
                                                                child:
                                                                    Image.asset(
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
                                                                child:
                                                                    Image.asset(
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
                                            : Loading(),
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
                          DataCell(Text(DateFormat('d-MMM-yy')
                              .format(DateTime.parse(document.id)))),
                          document.data()['infected']
                              ? DataCell(Text(
                                  'Covid',
                                  style: TextStyle(
                                      color: Colors.red,
                                      fontWeight: FontWeight.bold),
                                ))
                              : DataCell(Center(
                                  child: Text(
                                  'No Covid',
                                  style: TextStyle(
                                      color: Colors.green,
                                      fontWeight: FontWeight.bold),
                                ))),
                          DataCell(FlatButton(
                            child: Icon(
                              Icons.delete,
                              color: Colors.red,
                            ),
                            onPressed: () {
                              showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                        shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(32.0))),
                                        contentPadding:
                                            EdgeInsets.only(top: 10.0),
                                        actions: [
                                          ElevatedButton(
                                            child: Text('Delete Covid Record'),
                                            onPressed: () async {
                                              await deleteRecord(
                                                      FirebaseAuth.instance
                                                          .currentUser.uid,
                                                      document.id)
                                                  .then((value) {
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  SnackBar(
                                                    duration: const Duration(
                                                        seconds: 5),
                                                    content: Text(
                                                        'Record deleted successfully'),
                                                    backgroundColor:
                                                        Colors.orangeAccent,
                                                    behavior: SnackBarBehavior
                                                        .floating,
                                                    shape: StadiumBorder(),
                                                  ),
                                                );
                                                Navigator.of(context).pop();
                                              });
                                            },
                                          ),
                                        ],
                                        content: Padding(
                                          padding: const EdgeInsets.all(30.0),
                                          child: Text(
                                            'Are you sure you want to delete the record at  ' +
                                                DateFormat('EEEE, d-MMM-yyyy')
                                                    .format(DateTime.parse(
                                                        document.id)),
                                          ),
                                        ));
                                  });
                            },
                          )),
                        ]);
                  }).toList(),
                ),
              )
            : Container(
                child: Text('No Supervisors found'),
              );
      },
    );
  }
}

Future deleteRecord(uid, id) {
  return users.doc(uid).collection('covidrecord').doc(id).delete();
}

Future getCovidForS(sid) async {
  var cid = await getCompanyid(sid).then((val) {
    companies.doc(val).collection('supervisors').doc(sid).get().then((value) {
      print('sid is ' + value.data()['company_id'].toString());
      return value.data();
    });
  }) /*.catchError((err){
    return err;
  })*/
      ;

  return cid;
}
