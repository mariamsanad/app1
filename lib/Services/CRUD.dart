import 'dart:async';
import 'package:app1/Components/loading.dart';
import 'package:app1/Screens/Elements.dart';
import 'package:app1/Screens/CovidReports.dart';
import 'package:app1/Screens/Position.dart';
import 'package:app1/Screens/Profile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'User.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;

checkRole() async {
  if (FirebaseAuth.instance.currentUser == null) return 'nouser';
  String userid = FirebaseAuth.instance.currentUser.uid;

  var v = await users.doc(userid).get().then((value) {
    return value.data()['role'];
  }).onError((error, stackTrace) {
    return error;
  });

  return v;
}

CollectionReference users = FirebaseFirestore.instance.collection('users');
CollectionReference positions =
    FirebaseFirestore.instance.collection('positions');
CollectionReference companies =
    FirebaseFirestore.instance.collection('companies');
CollectionReference doctors = FirebaseFirestore.instance.collection('doctors');
CollectionReference companiescov =
    FirebaseFirestore.instance.collection('companycovid');
CollectionReference poscov =
    FirebaseFirestore.instance.collection('positioncovid');
CollectionReference records2 = FirebaseFirestore.instance.collection('records');
CollectionReference messages =
    FirebaseFirestore.instance.collection('messages');
CollectionReference chats = FirebaseFirestore.instance.collection('chats');
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

updateDoctorProfile(cid, name, phone) async {
  await doctors
      .doc(cid)
      .update({'name': name, 'phone': phone})
      .then((value) => print("Doctor Updated"))
      .catchError((error) => print("Failed to update doctor: $error"));
  return users
      .doc(cid)
      .update({'user_name': name, 'phone': phone})
      .then((value) => print("User Updated"))
      .catchError((error) => print("Failed to update user: $error"));
}

updateSupervisorProfile(cid, uid, name, phone, type) async {
  await companies
      .doc(cid)
      .collection('supervisors')
      .doc(uid)
      .update({'name': name, 'phone': phone, 'position': type})
      .then((value) => print("Supervisor Updated"))
      .catchError((error) => print("Failed to update supervisor: $error"));
  return users
      .doc(uid)
      .update({'user_name': name, 'phone': phone})
      .then((value) => print("User Updated"))
      .catchError((error) => print("Failed to update user: $error"));
}

updateUserProfile(userid, name, phone, vac, work, cid, sid, pos) async {
  await companies
      .doc(cid)
      .collection('supervisors')
      .doc(sid)
      .collection(pos)
      .doc(userid)
      .update({'name': name, 'phone': phone})
      .then((value) => print("User Updated"))
      .catchError((error) => print("Failed to update user: $error"));
  return users
      .doc(userid)
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
      if (documentSnapshot.exists &&
          documentSnapshot.data()['company_id'] != null) {
        print('cid is ' + documentSnapshot.data()['company_id'].toString());
        return documentSnapshot.data()['company_id'];
      } else if (documentSnapshot.data()['company_id'] == null) {
        return false;
      } else {
        return false;
      }
    });

getPosition(String userId) async =>
    users.doc(userId).get().then((DocumentSnapshot documentSnapshot) {
      if (documentSnapshot.exists && documentSnapshot.data()['type'] != null) {
        print('type is ' + documentSnapshot.data()['type'].toString());
        return documentSnapshot.data()['type'];
      } else if (documentSnapshot.data()['company_id'] == null) {
        return false;
      } else {
        return false;
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

  Future register(
      String email, String pass, String type, String uname, phone) async {
    final User user = (await _auth.createUserWithEmailAndPassword(
      email: email,
      password: pass,
    ))
        .user;

    addUser(user.uid, uname, email, type, phone, false, 'home');

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
        'work': workfrom,
        'infected': false
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
                    return DataRow(onSelectChanged: (b) {}, cells: [
                      DataCell(Text(document.data()['user_name'].toString())),
                      DataCell(Text(document.data()['phone'].toString())),
                      /*TextButton(onPressed: (){
                      Navigator.of(context).pushNamed('reset');
                    }, child: Text('Forgot password?'))*/
                      DataCell(document.data()['type'] != 'supervisor'
                          ? Text(document.data()['type'])
                          : TextButton(
                              child: Text(
                                document.data()['type'],
                                style: TextStyle(color: Colors.green),
                              ),
                              onPressed: () {
                                if (document.data()['type'] == 'supervisor') {
                                  showDialog(
                                      context: context,
                                      builder: (context) => StreamBuilder<
                                              DocumentSnapshot>(
                                          stream: companies
                                              .doc(
                                                  document.data()['company_id'])
                                              .snapshots(),
                                          builder: (context, snapshot) {
                                            return AlertDialog(
                                              content: snapshot.hasData
                                                  ? Text('Company: ' +
                                                      snapshot.data!['name'])
                                                  : Loading(),
                                              actions: [
                                                TextButton(
                                                    onPressed: () {
                                                      Navigator.pop(context);
                                                    },
                                                    child: Text("OK"))
                                              ],
                                            );
                                          }));
                                }
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

class UsersForS extends StatefulWidget {
  @override
  _UsersForSState createState() => _UsersForSState();
  final sid, cid, pos;

  UsersForS(this.sid, this.cid, this.pos);
}

getu(sid, cid, pos) async {
  return await FirebaseFirestore.instance
      .collection('companies/${cid}/supervisors/${sid}/${pos}');
}

class _UsersForSState extends State<UsersForS> {
  bool isLoading = false;

  var u;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection(
              'companies/${this.widget.cid}/supervisors/${this.widget.sid}/${this.widget.pos}')
          .snapshots(includeMetadataChanges: true),
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
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => Profile(
                                    document.id,
                                    this.widget.cid,
                                    this.widget.sid,
                                    this.widget.pos),
                              ));
                        },
                        cells: [
                          DataCell(Text(document.data()['name'].toString()),
                              showEditIcon: true),
                          DataCell(Text(document.data()['phone'].toString())),
                          /*TextButton(onPressed: (){
                      Navigator.of(context).pushNamed('reset');
                    }, child: Text('Forgot password?'))*/
                          DataCell(document.data()['type'] != 'supervisor'
                              ? Text(document.data()['type'])
                              : TextButton(
                                  child: Text(
                                    document.data()['type'],
                                    style: TextStyle(color: Colors.green),
                                  ),
                                  onPressed: () {
                                    if (document.data()['type'] ==
                                        'supervisor') {
                                      showDialog(
                                          context: context,
                                          builder: (context) =>
                                              StreamBuilder<DocumentSnapshot>(
                                                  stream: companies
                                                      .doc(document
                                                          .data()['company_id'])
                                                      .snapshots(),
                                                  builder: (context, snapshot) {
                                                    return AlertDialog(
                                                      content: snapshot.hasData
                                                          ? Text('Company: ' +
                                                              snapshot.data![
                                                                  'name'])
                                                          : Loading(),
                                                      actions: [
                                                        TextButton(
                                                            onPressed: () {
                                                              Navigator.pop(
                                                                  context);
                                                            },
                                                            child: Text("OK"))
                                                      ],
                                                    );
                                                  }));
                                    }
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

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            showCheckboxColumn: false,
            // sortColumnIndex: 0,
            // sortAscending: true,
            columns: [
              DataColumn(
                tooltip: 'The name of company',
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
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              CompanyProfile(document.data()['company_id']),
                        ));
                  },
                  cells: [
                    DataCell(Text(document.data()['name'].toString()),
                        showEditIcon: true),
                    /*DataCell(Text(document.data()['phone'].toString())),*/
                    DataCell(Text(document.data()['type'])),
                    DataCell(
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            primary: Color(0xffa45c6c)),
                        child: Text('Show List'),
                        onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Supervisors(
                                  document.data()['company_id'].toString()),
                            )),
                      ),
                    ),
                    DataCell(
                      TextButton(
                          child: Icon(
                            Icons.delete,
                            color: Colors.red,
                          ),
                          onPressed: () async {
                            showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(32.0))),
                                    contentPadding: EdgeInsets.only(top: 10.0),
                                    actions: [
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                            primary: Color(0xffa45c6c)),
                                        child: Text('Delete Company'),
                                        onPressed: () async {
                                          await deleteCompany(document
                                                  .data()['company_id']
                                                  .toString())
                                              .then((value) {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                duration:
                                                    const Duration(seconds: 5),
                                                content: Text(
                                                    'Company deleted successfully'),
                                                backgroundColor:
                                                    Colors.orangeAccent,
                                                behavior:
                                                    SnackBarBehavior.floating,
                                                shape: StadiumBorder(),
                                              ),
                                            );
                                            Navigator.of(context).pop();
                                          });
                                        },
                                      ),
                                    ],
                                    content: Padding(
                                      padding: const EdgeInsets.all(10.0),
                                      child: Text(
                                          'Are you sure you want to delete this company ' +
                                              document.data()['name']),
                                    ),
                                  );
                                });
                          }),
                    ),
                  ]);
            }).toList(),
          ),
        );
      },
    );
  }
}

class DoctorsList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: doctors.snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return Text('Something went wrong, you may be not authenticated');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: Loading());
        }

        return SizedBox(
          width: double.infinity,
          child: SingleChildScrollView(
            child: DataTable(
              showCheckboxColumn: false,
              // sortColumnIndex: 0,
              // sortAscending: true,
              columns: [
                DataColumn(
                  tooltip: 'The name of doctor',
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
                    'Delete',
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
                            builder: (context) => DoctorProfile(document.id),
                          ));
                    },
                    cells: [
                      DataCell(Text(document.data()['name'].toString()),
                          showEditIcon: true),
                      /*DataCell(Text(document.data()['phone'].toString())),*/
                      DataCell(
                        TextButton(
                            child: Icon(
                              Icons.delete,
                              color: Colors.red,
                            ),
                            onPressed: () async {
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
                                          style: ElevatedButton.styleFrom(
                                              primary: Color(0xffa45c6c)),
                                          child: Text('Delete Doctor'),
                                          onPressed: () async {
                                            await deleteDoctor(
                                                    document.id.toString())
                                                .then((value) {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                SnackBar(
                                                  duration: const Duration(
                                                      seconds: 5),
                                                  content: Text(
                                                      'Doctor deleted successfully'),
                                                  backgroundColor:
                                                      Colors.orangeAccent,
                                                  behavior:
                                                      SnackBarBehavior.floating,
                                                  shape: StadiumBorder(),
                                                ),
                                              );
                                              Navigator.of(context).pop();
                                            });
                                          },
                                        ),
                                      ],
                                      content: Padding(
                                        padding: const EdgeInsets.all(10.0),
                                        child: Text(
                                            'Are you sure you want to delete this doctor ' +
                                                document.data()['name']),
                                      ),
                                    );
                                  });
                            }),
                      ),
                    ]);
              }).toList(),
            ),
          ),
        );
      },
    );
  }
}

class CompaniesListForCov extends StatelessWidget {
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

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DataTable(
                showCheckboxColumn: false,
                // sortColumnIndex: 0,
                // sortAscending: true,
                columns: [
                  DataColumn(
                    tooltip: 'The name of company',
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
                      /* onSelectChanged: (b) {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  CompanyProfile(document.data()['company_id']),
                            ));
                      },*/
                      cells: [
                        DataCell(
                          Text(document
                              .data()['name']
                              .toString()), /*showEditIcon:true*/
                        ),
                        /*DataCell(Text(document.data()['phone'].toString())),*/
                        DataCell(Text(document.data()['type'])),
                        DataCell(
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                primary: Color(0xffa45c6c)),
                            child: Text('Show List'),
                            onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => SupervisorsListForCov(
                                      document.data()['company_id'].toString()),
                                )),
                          ),
                        ),
                      ]);
                }).toList(),
              ),
            ],
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
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
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
                      DataColumn(
                        label: Text(
                          'Delete',
                          style: TextStyle(fontStyle: FontStyle.italic),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'Positions',
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
                                      SupervisorProfile(document.id),
                                ));
                          },
                          cells: [
                            DataCell(Text(document.data()['name'].toString()),
                                showEditIcon: true),
                            DataCell(Text(document.data()['phone'].toString())),
                            DataCell(Text(document.data()['position'])),
                            DataCell(TextButton(
                              child: Text('See Positions'),
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            Positions(document.id.toString())));
                              },
                            )),
                            DataCell(TextButton(
                                child: Icon(Icons.delete, color: Colors.red),
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
                                              style: ElevatedButton.styleFrom(
                                                  primary: Color(0xffa45c6c)),
                                              child: Text('Delete Supervisor'),
                                              onPressed: () async {
                                                await deleteSupervisor(cid,
                                                        document.id.toString())
                                                    .then((value) {
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                    SnackBar(
                                                      duration: const Duration(
                                                          seconds: 5),
                                                      content: Text(
                                                          'Supervisor deleted successfully'),
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
                                            padding: const EdgeInsets.all(10.0),
                                            child: Text(
                                                'Are you sure you want to delete the supervisor ' +
                                                    document.data()['name']),
                                          ),
                                        );
                                      });
                                })),
                          ]);
                    }).toList(),
                  ),
                ),
              )
            : Container(
                child: Text('No Supervisors found'),
              );
      },
    );
  }
}

class SupervisorsListForCov extends StatelessWidget {
  final cid;
  SupervisorsListForCov(this.cid);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Supervisors'),
      ),
      body: StreamBuilder<QuerySnapshot>(
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
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
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
                          label: Text(
                            'Type',
                            style: TextStyle(fontStyle: FontStyle.italic),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'Positions',
                            style: TextStyle(fontStyle: FontStyle.italic),
                          ),
                        ),
                      ],
                      rows:
                          snapshot.data!.docs.map((DocumentSnapshot document) {
                        return DataRow(
                            /* onSelectChanged: (b) {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        SupervisorProfile(document.id),
                                  ));
                            },*/
                            cells: [
                              DataCell(Text(document.data()['name'].toString()),
                                  showEditIcon: true),
                              DataCell(Text(document.data()['position'])),
                              DataCell(TextButton(
                                child: Text('See Positions'),
                                onPressed: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => SuperCovRec(
                                              this.cid,
                                              document.id.toString())));
                                },
                              )),
                            ]);
                      }).toList(),
                    ),
                  ),
                )
              : Container(
                  child: Text('No Supervisors found'),
                );
        },
      ),
    );
  }
}

class SupervisorsListForCovCom extends StatelessWidget {
  final cid;
  SupervisorsListForCovCom(this.cid);
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
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
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
                        label: Text(
                          'Type',
                          style: TextStyle(fontStyle: FontStyle.italic),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'Positions',
                          style: TextStyle(fontStyle: FontStyle.italic),
                        ),
                      ),
                    ],
                    rows: snapshot.data!.docs.map((DocumentSnapshot document) {
                      return DataRow(
                          /* onSelectChanged: (b) {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        SupervisorProfile(document.id),
                                  ));
                            },*/
                          cells: [
                            DataCell(Text(document.data()['name'].toString()),
                                showEditIcon: true),
                            DataCell(Text(document.data()['position'])),
                            DataCell(TextButton(
                              child: Text('See Positions'),
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => SuperCovRec(
                                            this.cid, document.id.toString())));
                              },
                            )),
                          ]);
                    }).toList(),
                  ),
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
        'infected': false
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

Future<void> addDoctor(name, type, address, cpr, email, phone) async {
  final UserCredential userCredential =
      await _auth2.createUserWithEmailAndPassword(email: email, password: cpr);
  users
      .doc(userCredential.user.uid)
      .set({
        // 'company_id': userCredential.user.uid,
        'email': email,
        'user_name': name,
        'phone': phone,
        'type': 'doctor',
        'role': 'doctor',
        'infected': false
      })
      .then((value) => print("User Added"))
      .catchError((error) => print("Failed to add user: $error"));

  return doctors
      .doc(userCredential.user.uid)
      .set({
        'name': name,
        // 'company_id': userCredential.user.uid,
        'email': email,
        'type': type,
        'phone': phone
      })
      .then((value) => print("Doctor Added Succesfully"))
      .catchError((error) => print("Failed to add Doctor: $error"));
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
        'work': workfrom,
        'infected': false
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

Future addPosition(id, name) async {
  await poscov
      .doc(name)
      .set({'position': name, 'count': 0})
      .then((value) => print("Position Added"))
      .catchError((error) => print("Failed to add position: $error"));

  await positions.doc(id).set({'id': id, 'count': 0});
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

Future deletePosition(uid, id) async {
  return positions.doc(uid).collection('poses').doc(id).delete();
}

Future deleteCompany(uid) async {
  try {
    await companies.doc(uid).delete();
    return users.doc(uid).delete();
  } on FirebaseFirestore catch (err) {
    return err;
  }
}

Future deleteDoctor(uid) async {
  try {
    await doctors.doc(uid).delete();
    return users.doc(uid).delete();
  } on FirebaseFirestore catch (err) {
    return err;
  }
}

Future deleteSupervisor(cid, uid) async {
  try {
    await companies.doc(cid).collection('supervisors').doc(uid).delete();
    return users.doc(uid).delete();
  } on FirebaseFirestore catch (err) {
    return err;
  }
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
        'role': 'user',
        'vac': vac,
        'infected': false
      })
      .then((value) => print("User Added"))
      .catchError((error) => print("Failed to add user1: $error"));

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

Future<void> addCovidRecord(id, date, cough, headache, fever, infected) async {
  CollectionReference rec = users.doc(id).collection("covidrecord");
  var i = await getUserName(id).then((v) {
    return v;
  });
  await users.doc(id).update({'infected': infected});

  var n = getCompanyid(id).then((v) async {
    if (v != false) {
      if (infected) {
        companiescov.doc(v).collection('recs').doc(id).get().then((b) async {
          if (b.exists) {
            await getPosition(id).then((v) async {
              await getUserName(id).then((n) async {
                await poscov
                    .doc(v)
                    .collection('infected')
                    .doc(id)
                    .set({'id': id, 'name': n});
              });

              // await pos.doc(v).update({'count':FieldValue.increment(1)});
            });
          } else {
            await poscov.doc(v).update({'count': FieldValue.increment(1)});
          }
        });
      } else {
        companiescov.doc(v).collection('recs').doc(id).get().then((b) async {
          if (b.exists) {
            await getPosition(id).then((v) async {
              await poscov.doc(v).update({'count': FieldValue.increment(-1)});
              await poscov.doc(v).collection('infected').doc(id).delete();
              // await pos.doc(v).update({'count':FieldValue.increment(-1)});
              await companiescov.doc(v).collection('recs').doc(id).delete();
            });
          }
        });
      }

      await companiescov.doc(v).set({id: v});
      await companiescov
          .doc(v)
          .collection('recs')
          .doc(id)
          .set({
            'name': i,
            'cough': cough,
            'headache': headache,
            'fever': fever,
            'infected': infected
          })
          .then((value) => print("Record Added"))
          .catchError((error) => print("Failed to add record: $error"));

      return v;
    }
  });

  await rec
      .doc(date.toString())
      .set({
        'name': i,
        'cough': cough,
        'headache': headache,
        'fever': fever,
        'infected': infected
      })
      .then((value) => print("Record Added"))
      .catchError((error) => print("Failed to add record: $error"));

  await records2.doc(date.toString()).set({'date': date.toString()});
  /*await records2.doc(date.toString()).collection('recs').doc(id).set({
    'id':id
  });*/
  return records2
      .doc(date.toString())
      .collection('recs')
      .doc(id)
      .set({
        'name': i,
        'id': id,
        'cough': cough,
        'headache': headache,
        'fever': fever,
        'infected': infected
      })
      .then((value) => print("Record Added"))
      .catchError((error) => print("Failed to add record: $error"));
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

getUserName(id) async {
  var val = await users.doc(id).get().then((DocumentSnapshot snapshot) {
    if (snapshot.exists) {
      return snapshot.data()['user_name'];
    }
    return false;
  });
  return val;
}

getUserNameA() async {
  var u = FirebaseAuth.instance.currentUser;
  if (u != null) {
    var val = await users.doc(u.uid).get().then((DocumentSnapshot snapshot) {
      if (snapshot.exists) {
        return snapshot.data()['user_name'];
      }
    });
    return val;
  } else {
    return false;
  }
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
                                                        : Text('Symptoms'),
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
                                          TextButton(
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
                          DataCell(TextButton(
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
                                            style: ElevatedButton.styleFrom(
                                                primary: Color(0xffa45c6c)),
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

Future deleteRecord(uid, id) async {
  await records2.doc(id).collection('recs').doc(uid).delete();
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

getCEachPos(superid) async {
  superid = 'BDnEzlvN8ye4LK5r5kcSNCFJrj02';
  var arr = [];
  //get positions for the sid
  QuerySnapshot querySnapshot = await FirebaseFirestore.instance
      .collection('/positions/${superid}/poses')
      .get();
  var list = querySnapshot.docs;
  var list1, list2, list3;
  print('start');

  for (int i = 0; i < list.length; i++) {
    // date : position
    var r = new covrec(date: list[i].id, rec: []);
    //get users for each ..
    QuerySnapshot querySnapshot1 = await FirebaseFirestore.instance
        .collection('/positions/${superid}/poses/${list[i].id}/users')
        .get();
    list1 = querySnapshot1.docs;
    for (int j = 0; j < list1.length; j++) {
      print(list1);
      QuerySnapshot querySnapshot2 =
          await users.doc(list1[j].id).collection('covidrecord').get();
      list2 = querySnapshot2.docs;
      for (int k = 0; k < list2.length; k++) {
        DocumentSnapshot querySnapshot3 = await users
            .doc(
                '${list1[j].id}/users/${list1[j].id}/covidrecord/${list2[k].id}')
            .get();
        list3 = querySnapshot3.data();
        // print(list2);
        if (list3['infected'] == true) r.rec.add(list3);
      }
    }
    arr.add(r);
  }
  print('end');

// print(arr);
  return arr;
}

getCDate() async {
  var arr = [];
  //dates
  await records2.get().then((querySnapshot) async {
    print('start');

    for (var recs in querySnapshot.docs) {
      var r = new covrec(date: recs.id, rec: []);
      await records2
          .doc(recs.id)
          .collection("recs")
          .get()
          .then((querySnapshot1) {
        for (var date in querySnapshot1.docs) {
          if (date.data()['infected'] == true) {
            print(date.data());
            r.rec.add(date.data());
          }
        }
        arr.add(r);
      });
    }
  });

  return arr;
}

getCCom() async {
  var arr = [];
  //dates
  var n = await companiescov.get().then((querySnapshot) async {
    print('Hello');

    for (var company in querySnapshot.docs) {
      print(company.id);
      await companiescov
          .doc(company.id)
          .collection("recs")
          .get()
          .then((querySnapshot1) async {
        //await getUserName(company.id).then((com){
        arr.add(new covrec(date: company.id, rec: querySnapshot1.docs.length));
        // });
      });
    }
    print('end');
    print('date is ' + arr[0].date.toString());
    return arr;
  });
  return n;
  // return arr;
}

getCPos(cid, superid) async {
  var arr = [];
  //dates
  var n = await positions
      .doc(superid)
      .collection('poses')
      .get()
      .then((querySnapshot) async {
    for (var posi in querySnapshot.docs) {
      await poscov.doc(posi.id).get().then((value) {
        arr.add(new covrec(date: posi.id, rec: value.data()['count']));
      });
    }
    return arr;
  });
  return n;
  // return arr;
}

getCEachDate() async {
  var arr = [];
  //get dates
  QuerySnapshot querySnapshot = await records2.get();
  var list = querySnapshot.docs;
  var list1, list2;

  // print('start');
  for (int i = 0; i < list.length; i++) {
    //Records of each date
    // print(list[i].id);
    QuerySnapshot querySnapshot1 =
        await records2.doc(list[i].id).collection('recs').get();
    list1 = querySnapshot1.docs;
    // arr.add(list1);
    var r = new covrec(date: list[i].id, rec: []);
    for (int j = 0; j < list1.length; j++) {
      DocumentSnapshot querySnapshot2 =
          await records2.doc('${list[i].id}/recs/${list1[j].id}').get();
      list2 = querySnapshot2.data();
      // print(list2);
      if (list2['infected'] == true) r.rec.add(list2);
    }
    arr.add(r);
  }
  // print('end');

// print(arr);
  return arr;
}

class covrec {
  final date, rec;
  covrec({this.date, this.rec});
}

class DateRec {
  final cases;
  final date;
  DateRec(this.cases, this.date);
}

class DateCovGraph extends StatefulWidget {
  @override
  _DateCovGraphState createState() => _DateCovGraphState();
}

class _DateCovGraphState extends State<DateCovGraph> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getCEachDate(),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        final List<DateRec> dateRec = [];
        final List<DateRec> headRec = [];
        final List<DateRec> feverRec = [];
        final List<DateRec> caughRec = [];

        if (snapshot.hasData) {
          if (snapshot.data.length > 0) {
            for (int i = 0; i < snapshot.data.length; i++) {
              var count = snapshot.data[i].rec
                  .where((c) => c['headache'] == true)
                  .toList()
                  .length;
              // headRec.add(new DateRec(count, 'Headache'));
              var count1 = snapshot.data[i].rec
                  .where((c) => c['fever'] == true)
                  .toList()
                  .length;
              var count2 = snapshot.data[i].rec
                  .where((c) => c['cough'] == true)
                  .toList()
                  .length;
              headRec.add(new DateRec(
                  count,
                  DateFormat('d-MMM-yy')
                      .format(DateTime.parse(snapshot.data[i].date))));
              feverRec.add(new DateRec(
                  count1,
                  DateFormat('d-MMM-yy')
                      .format(DateTime.parse(snapshot.data[i].date))));
              caughRec.add(new DateRec(
                  count2,
                  DateFormat('d-MMM-yy')
                      .format(DateTime.parse(snapshot.data[i].date))));
              dateRec.add(new DateRec(
                  snapshot.data[i].rec.length /*-(count1+count+count2)*/,
                  DateFormat('d-MMM-yy')
                      .format(DateTime.parse(snapshot.data[i].date))));
            }

            return /*SfCircularChart(
                series: <CircularSeries>[
                  // Renders radial bar chart
                  RadialBarSeries<DateRec, String>(
                      dataSource: headRec,
                      xValueMapper: (DateRec data, _) => data.date,
                      yValueMapper: (DateRec data, _) => data.cases,
                  )
                ]
            );*/

                /*  SfCartesianChart(
        primaryXAxis: CategoryAxis(),
        series: <ChartSeries>[
        StackedBar100Series<DateRec, String>(
        dataSource: dateRec,
        xValueMapper: (DateRec sales, _) => sales.date,
        yValueMapper: (DateRec sales, _) => sales.cases
        ),
        StackedBar100Series<DateRec, String>(
        dataSource: headRec,
        xValueMapper: (DateRec sales, _) => sales.date,
        yValueMapper: (DateRec sales, _) => sales.cases
        ),
          StackedBar100Series<DateRec, String>(
              dataSource: feverRec,
              xValueMapper: (DateRec sales, _) => sales.date,
              yValueMapper: (DateRec sales, _) => sales.cases
          ),

        ]
        );*/

                SfCartesianChart(
                    trackballBehavior: TrackballBehavior(
                        markerSettings: TrackballMarkerSettings(
                            markerVisibility: TrackballVisibilityMode.visible),
                        enable: true,
                        tooltipSettings: InteractiveTooltip(
                          enable: true,
                          color: Colors.red,
                          format: 'point.x : point.y',
                        )),
                    zoomPanBehavior: ZoomPanBehavior(
                      enablePinching: true,
                      zoomMode: ZoomMode.x,
                      enablePanning: true,
                    ),
                    // backgroundColor: Colors.white,

                    primaryXAxis: CategoryAxis(),
                    title: ChartTitle(text: 'Chart'), //Chart title.
                    legend: Legend(isVisible: true), // Enables the legend.
                    tooltipBehavior:
                        TooltipBehavior(enable: true), // Enables the tooltip.
                    series: <AreaSeries<DateRec, String>>[
                  AreaSeries<DateRec, String>(
                    name: 'Cases',
                    dataSource: dateRec,
                    xValueMapper: (DateRec sales, _) => sales.date,
                    yValueMapper: (DateRec sales, _) => sales.cases,
                    //dataLabelSettings: DataLabelSettings(isVisible: true) // Enables the data label.
                  ),
                  AreaSeries<DateRec, String>(
                    name: 'Headache',
                    dataSource: headRec,
                    xValueMapper: (DateRec sales, _) => sales.date,
                    yValueMapper: (DateRec sales, _) => sales.cases,
                    // gradient: gradientColors
                    //dataLabelSettings: DataLabelSettings(isVisible: true) // Enables the data label.
                  ),
                  AreaSeries<DateRec, String>(
                    name: 'Fever',
                    dataSource: feverRec,
                    xValueMapper: (DateRec sales, _) => sales.date,
                    yValueMapper: (DateRec sales, _) => sales.cases,
                    // gradient: gradientColors
                    //dataLabelSettings: DataLabelSettings(isVisible: true) // Enables the data label.
                  ),
                  AreaSeries<DateRec, String>(
                    name: 'Cough',
                    dataSource: caughRec,
                    xValueMapper: (DateRec sales, _) => sales.date,
                    yValueMapper: (DateRec sales, _) => sales.cases,
                    // gradient: gradientColors
                    //dataLabelSettings: DataLabelSettings(isVisible: true) // Enables the data label.
                  ),
                ]);
          } else {
            return Expanded(
                child: Center(
                    child: Text(
              "There is no data for this country",
              style: TextStyle(
                  fontSize: 20, color: Colors.red, fontWeight: FontWeight.bold),
            )));
          }
        }
        return Center(child: Loading());
      },
    );
  }
}

class showDailyRadialGraph extends StatefulWidget {
  final date;
  @override
  _showDailyRadialGraphState createState() => _showDailyRadialGraphState();

  showDailyRadialGraph(this.date);
}

class mrec {
  final int num;
  final name;
  final col;

  mrec(this.num, this.name, this.col);
}

class _showDailyRadialGraphState extends State<showDailyRadialGraph> {
  late TooltipBehavior _tooltipBehavior;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _tooltipBehavior = TooltipBehavior(enable: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Graph for ' + this.widget.date.toString()),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: records2.doc(this.widget.date).collection('recs').snapshots(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          print(this.widget.date);

          var dateRec = 0;
          var headRec = 0;
          var feverRec = 0;
          var caughRec = 0;

          if (!snapshot.hasData) {
            return Loading();
          }

          if (snapshot.hasData) {
            snapshot.data.docs.forEach((v) {
              if (v.data()['fever']) feverRec++;
              if (v.data()['cough']) caughRec++;
              if (v.data()['headache'])
                headRec++;
              else
                dateRec++;
              print(v.data());
            });

            final List<mrec> chartData = [
              mrec(feverRec, 'Fever', Color(0xff048c74)),
              mrec(caughRec, 'Cough', Color(0xffa45c6c)),
              mrec(headRec, 'Headache', Color(0xfffc747c)),
              mrec(dateRec, 'None', Color(0xffA0C5FD))
            ];

            return SfCartesianChart(
                tooltipBehavior: _tooltipBehavior,
                primaryXAxis: CategoryAxis(),
                series: <ChartSeries>[
                  // Renders column chart
                  ColumnSeries<mrec, String>(
                      dataSource: chartData,
                      xValueMapper: (mrec sales, _) => sales.name,
                      yValueMapper: (mrec sales, _) => sales.num,
                      pointColorMapper: (mrec data, _) => data.col)
                ]);
          }
          return Center(child: Loading());
        },
      ),
    );
  }
}
/*

class RecsEachCompany extends StatefulWidget {
  @override
  _RecsEachCompanyState createState() => _RecsEachCompanyState();
}

class _RecsEachCompanyState extends State<RecsEachCompany> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Companies Cov'),
      ),
      body:  FutureBuilder(
          future: getEachCom(id),
          builder: (context, snapshot) {
            return DataTable(
              showCheckboxColumn: false,
              columns: [
              DataColumn(label:Text('Name'))
            ], rows: snapshot.data!.docs.map((DocumentSnapshot document) {
              return DataRow(onSelectChanged: (b) {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          RecsEachCompany(),
                    ));
              }, cells: [
                DataCell(Text(document.data()['name'].toString())),
              ]);
            }).toList(),);
          }
      ),
    );
  }
}
*/

Future addMessage(message, date) async {
  CollectionReference messages =
      chats.doc(FirebaseAuth.instance.currentUser.uid).collection("messages");
  return messages
      .doc()
      .set({
        'userid': FirebaseAuth.instance.currentUser.uid,
        'date': date,
        'message': message,
      })
      .then((value) => print("Message sent"))
      .catchError((error) => print("Failed to send message: $error"));
}

Future addReply(userid, message, date) async {
  CollectionReference messages = chats.doc(userid).collection("messages");
  return messages
      .doc()
      .set({
        'userid': FirebaseAuth.instance.currentUser.uid,
        'date': date,
        'message': message,
      })
      .then((value) => print("Message sent"))
      .catchError((error) => print("Failed to send message: $error"));
}

Future createChat(userid) async {
  return chats
      .doc(FirebaseAuth.instance.currentUser.uid)
      .set({
        'userid': FirebaseAuth.instance.currentUser.uid,
        'isRead': 'false',
        'drid': ''
      })
      .then((value) => print("Message sent"))
      .catchError((error) => print("Failed to send message: $error"));
}

Future updateChat(userid) async {
  return chats
      .doc(userid)
      .update({
        'isRead': 'true',
        'drid': FirebaseAuth.instance.currentUser.uid,
      })
      .then((value) => print("Message sent"))
      .catchError((error) => print("Failed to send message: $error"));
}
