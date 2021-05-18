import 'package:app1/Components/loading.dart';
import 'package:app1/Screens/Companies.dart';
import 'package:app1/Screens/Position.dart';
import 'package:app1/Screens/Profile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
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

updateProfile(userid, name, phone) async {
  await _auth.currentUser
      .updateProfile(displayName: name, photoURL: _auth.currentUser.photoURL)
      .onError((error, stackTrace) {
    return error;
  });

  return users
      .doc(userid)
      .update({'user_name': name, 'phone': phone})
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

    addUser(user.uid, user.displayName, email, type, '');

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
        addUser(
            user.uid, user.displayName, user.email, 'normal', user.phoneNumber);
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

Future<void> addUser(id, nome, name, type, phone) {
  // Call the user's CollectionReference to add a new user
  return users
      .doc(id)
      .set({
        'user_id': id,
        'email': name,
        'user_name': nome,
        'type': type,
        'role': 'user',
        'phone': phone
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
                        },
                        cells: [
                          DataCell(
                              Text(document.data()['user_name'].toString())),
                          DataCell(Text(document.data()['phone'].toString())),
                          DataCell(Text(document.data()['type'])),
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
        'role': 'company'
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
    String phone, String position) async {
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
        'role': 'supervisor'
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
    String email, String pass, String phone, String position) async {
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
        'role': user
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

Future<void> addCovidRecord(id, date, cough, headache, fever,infected) {
  CollectionReference rec = users.doc(id).collection("covidrecord");
  return rec
      .doc(date.toString())
      .set({
        'cough': cough,
        'headache': headache,
        'fever': fever,
        'infected':infected
      })
      .then((value) => print("Record Added"))
      .catchError((error) => print("Failed to add record: $error"));
}

getCovidRecord(date, id) {
  users
      .doc(id)
      .collection('covidrecords')
      .doc(date.toString())
      .get()
      .then((value) {
    print(value);
  });
}

