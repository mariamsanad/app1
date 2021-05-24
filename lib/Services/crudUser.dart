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
import 'package:syncfusion_flutter_charts/charts.dart';
import 'User.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;

checkRole() async {
  if (FirebaseAuth.instance.currentUser == null) return 'nouser';
  String userid = FirebaseAuth.instance.currentUser.uid;

  var v = await users
      .doc(userid)
      .get()
      .then((value) {
    return value.data()['role'];
  }).onError((error, stackTrace) {
    return error;
  });

  return v;
}
CollectionReference users = FirebaseFirestore.instance.collection('users');
CollectionReference positions =
    FirebaseFirestore.instance.collection('positions');
CollectionReference pos =
FirebaseFirestore.instance.collection('pos');

CollectionReference companies =
    FirebaseFirestore.instance.collection('companies');
CollectionReference companiescov =
FirebaseFirestore.instance.collection('companycovid');
CollectionReference records2 =
FirebaseFirestore.instance.collection('records');
CollectionReference messages = FirebaseFirestore.instance.collection('messages');
CollectionReference chats =FirebaseFirestore.instance.collection('chats');
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



updateSupervisorProfile(cid,uid, name, phone, type) async {
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

updateUserProfile(userid, name, phone, vac, work,cid,sid,pos)  async {
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
      if (documentSnapshot.exists) {
        print('cid is '+documentSnapshot.data()['company_id'].toString());
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

  Future register(String email, String pass, String type,String uname,phone) async {
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

class _UsersForSState extends State<UsersForS> {
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return isLoading?Loading():StreamBuilder<QuerySnapshot>(
      stream: companies
          .doc(this.widget.cid)
          .collection('supervisors')
          .doc(this.widget.sid)
          .collection(this.widget.pos)
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
              return DataRow(onSelectChanged: (b) {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          Profile(document.id,this.widget.cid,this.widget.sid,this.widget.pos),
                    ));

              }, cells: [
                DataCell(Text(document.data()['name'].toString()),showEditIcon: true),
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
                    DataCell(Text(document.data()['name'].toString()),showEditIcon:true),
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
                    ),

                    ),
                    DataCell(FlatButton(
                      child: Icon(Icons.delete,color: Colors.red,),
                      onPressed: () async {
                        showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.all(Radius.circular(32.0))),
                                contentPadding: EdgeInsets.only(top: 10.0),
                                actions: [
                                  ElevatedButton(
                                    child: Text('Delete Company'),
                                    onPressed: () async {
                                      await deleteCompany(document.data()['company_id'].toString()).then((value){
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            duration: const Duration(seconds: 5),
                                            content: Text('Company deleted successfully'),
                                            backgroundColor: Colors.orangeAccent,
                                            behavior: SnackBarBehavior.floating,
                                            shape: StadiumBorder(),
                                          ),
                                        );
                                        Navigator.of(context).pop();
                                      }
                                      );
                                    },
                                  ),
                                ],
                                content: Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: Text('Are you sure you want to delete this company '+document.data()['name']),
                                ) ,

                              );
                            });
                      }
                    ),

                    ),
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
                            DataCell(Text(document.data()['name'].toString()),showEditIcon: true),
                            DataCell(Text(document.data()['phone'].toString())),
                            DataCell(Text(document.data()['position'])),
                            DataCell(TextButton(
                              child: Text('See Positions'),
                              onPressed: (){
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            Positions(document.id.toString())));
                              },
                            )),
                            DataCell(FlatButton(
                              child: Icon(Icons.delete,color:Colors.red),
                                onPressed:(){
                                  showDialog(
                                      context: context,
                                      builder: (context) {
                                        return AlertDialog(
                                          shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.all(Radius.circular(32.0))),
                                          contentPadding: EdgeInsets.only(top: 10.0),
                                          actions: [
                                            ElevatedButton(
                                              child: Text('Delete Supervisor'),
                                              onPressed: () async {
                                                await deleteSupervisor(cid,document.id.toString()).then((value){
                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                    SnackBar(
                                                      duration: const Duration(seconds: 5),
                                                      content: Text('Supervisor deleted successfully'),
                                                      backgroundColor: Colors.orangeAccent,
                                                      behavior: SnackBarBehavior.floating,
                                                      shape: StadiumBorder(),
                                                    ),
                                                  );
                                                  Navigator.of(context).pop();
                                                }
                                                );
                                              },
                                            ),
                                          ],
                                          content: Padding(
                                            padding: const EdgeInsets.all(10.0),
                                            child: Text('Are you sure you want to delete the supervisor '+document.data()['name']),
                                          ) ,

                                        );
                                      });
                                }
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

Future addPosition(id, name) async {

  await pos
      .doc(name)
      .set({
    'position': name,
  })
      .then((value) => print("Position Added"))
      .catchError((error) => print("Failed to add position: $error"));

  await positions.doc(id).set({
    'id':id
  });
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
  try{
    await companies.doc(uid).delete();
    return users.doc(uid).delete();
  }on FirebaseFirestore catch(err){
    return err;
  }
}
Future deleteSupervisor(cid,uid) async {
  try{
    await companies.doc(cid).collection('supervisors').doc(uid).delete();
    return users.doc(uid).delete();
  }on FirebaseFirestore catch(err){
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
        'vac': vac
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
  
  CollectionReference rec2 = pos
      .doc(position)
      .collection('users');
  
  rec
      .doc(userCredential.user.uid)
      .set({'name': name, 'email': email, 'type': position, 'phone': phone})
      .then((value) => print("User Added Succesfully"))
      .catchError((error) => print("Failed to add user: $error"));

  await rec2
      .doc(userCredential.user.uid)
      .set({
    'id': userCredential.user.uid,
  })
      .then((value) => print("User Added to position Succesfully"))
      .catchError((error) => print("Failed to add user to position: $error"));
  
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
  var i = await getUserName(id).then((v){
    return v;
  });

/*  var n = await getCompanyid(id).then((v){
    companiescov.doc(v).collection('recs').doc(id).set({
      'name':i,
      'cough': cough,
      'headache': headache,
      'fever': fever,
      'infected': infected
    })
        .then((value) => print("Record Added"))
        .catchError((error) => print("Failed to add record: $error"));
    return v;
  });*/

  await rec
      .doc(date.toString())
      .set({
        'name':i,
        'cough': cough,
        'headache': headache,
        'fever': fever,
        'infected': infected
      })
      .then((value) => print("Record Added"))
      .catchError((error) => print("Failed to add record: $error"));
 
  await records2.doc(date.toString()).set({
   'date':date.toString()
 });
  /*await records2.doc(date.toString()).collection('recs').doc(id).set({
    'id':id
  });*/
 return records2
      .doc(date.toString())
      .collection('recs')
      .doc(id)
      .set({
        'name':i,
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

getUserName(id) async{
  var val = await users
      .doc(id)
      .get()
      .then((DocumentSnapshot snapshot) {
    return snapshot.data()['user_name'];
  });
  return val;
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

Future deleteRecord(uid, id) async {
  await  records2.doc(id).collection('recs').doc(uid).delete();
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

getC() async {
  var arr=[];
  //Companies
  QuerySnapshot querySnapshot = await companies.get();
  var list = querySnapshot.docs;
  var list1,list2,list3,list4,list5,list6;
  for(int i=0;i<list.length;i++){
    //Supervisors of each company
    QuerySnapshot querySnapshot1 = await companies.doc(list[i].id).collection('supervisors').get();
    list1 = querySnapshot1.docs;
    // arr.add(list1);
    for(int j=0;j<list1.length;j++){
      //get positions
      QuerySnapshot querySnapshot2 = await positions.doc(list1[j].id).collection('poses').get();
      list2 = querySnapshot2.docs;
      for(int k=0;k<list2.length;k++){
        //get all users
        QuerySnapshot querySnapshot3 = await companies.doc(list[i].id).collection('supervisors').doc(list1[j].id).collection(list2[k].id).get();
        list3 = querySnapshot3.docs;

        //all covid records(by date)
        // QuerySnapshot querySnapshot4 = await companies.doc(list[i].id).collection('records').get();
        // list4 = querySnapshot4.docs;
        // arr.add(list3);
        for(int m=0;m<list4.length;m++) {
          // QuerySnapshot querySnapshot5 = await companies.doc(list[i].id).collection('records').doc(list4[m].id).collection('recs').get();
          // list5 = querySnapshot5.docs;
          for(int n=0;n<list5.length;n++) {
            // QuerySnapshot querySnapshot6 = await companies.doc(list[i].id).collection('records').doc(list4[m].id).collection('recs').doc().get();
            // list6 = querySnapshot6.docs;


          }

        }
      }

    }
  }
  return arr;
}

getCCompany() async {
  var arr=[];
  //Get Supervisors under company
  QuerySnapshot querySnapshot = await companies.get();
  var list = querySnapshot.docs;
  var list1,list2,list3;

  for(int i=0;i<list.length;i++){
    QuerySnapshot querySnapshot1 = await companies.doc(list[i].id).collection('supervisors').get();
    list1 = querySnapshot1.docs;
    
    var r = new covrec(date:list[i].id , rec:[]);
    
    for(int j=0;j<list1.length;j++){
      //get positions
      DocumentSnapshot querySnapshot2 = await positions.doc(list[i].id).collection('poses').doc(list1[j].id).get();
      list2 = querySnapshot2.data();
      
      for(int m=0;m<list2.length;m++){
        QuerySnapshot querySnapshot3 = await companies.doc(list[i].id).collection('supervisors').doc(list1[j].id).collection(list2[m].id).get();
        list3 = querySnapshot3.docs;
        if(list2['infected']==true)
          r.rec.add(list2);
        
      }
    }
    arr.add(r);
  }

  return arr;
}



getCEachPos(superid) async {
  superid='BDnEzlvN8ye4LK5r5kcSNCFJrj02';
  var arr=[];
  //get positions for the sid
  QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('/positions/${superid}/poses').get();
  var list = querySnapshot.docs;
  var list1,list2,list3;
  print('start');

  for(int i=0;i<list.length;i++){
    // date : position
    var r = new covrec(date:list[i].id , rec:[]);
    //get users for each ..
    QuerySnapshot querySnapshot1 = await FirebaseFirestore.instance.collection('/positions/${superid}/poses/${list[i].id}/users').get();
    list1 = querySnapshot1.docs;
    for(int j=0;j<list1.length;j++){
      print(list1);
      QuerySnapshot querySnapshot2 = await users.doc(list1[j].id).collection('covidrecord').get();
      list2 = querySnapshot2.docs;
      for(int k=0;k<list2.length;k++){
        DocumentSnapshot querySnapshot3 = await users.doc('${list1[j].id}/users/${list1[j].id}/covidrecord/${list2[k].id}').get();
        list3 = querySnapshot3.data();
        // print(list2);
        if(list3['infected']==true)
          r.rec.add(list3);
      }

    }
    arr.add(r);
  }
  print('end');

// print(arr);
  return arr;
}

getEachCom(id) async {
  var arr=[];
  //Get Supervisors under company
  QuerySnapshot querySnapshot = await companies.doc(id).collection('supervisors').get();
  var list = querySnapshot.docs;
  var list1,list2,list3;

  for(int i=0;i<list.length;i++){
    // DocumentSnapshot querySnapshot1 = await companies.doc(id).collection('supervisors').doc(list[i].id).get();
    // QuerySnapshot querySnapshot2 = await companies.doc(id).collection('supervisors').doc(list[i].id).col;
    // arr.add(list1);

    QuerySnapshot querySnapshot1 = await positions.doc(list[i].id).collection('poses').get();
    list1 = querySnapshot1.docs;
    //date is the position
    var r = new covrec(date:list[i].id , rec:[]);

    for(int j=0;j<list1.length;j++){
      //get positions
      DocumentSnapshot querySnapshot2 = await positions.doc(list[i].id).collection('poses').doc(list1[j].id).get();
      list2 = querySnapshot2.data();
      DocumentSnapshot querySnapshot3 = await users.doc(list1[j].id).get();
      list3 = querySnapshot3.data();

      if(list2['infected']==true)
        r.rec.add(list2);
    }
    arr.add(r);
  }

  return arr;
}
getCPos(){
  records2.get().then((querySnapshot) {
    querySnapshot.docs.forEach((result) {
      var list = querySnapshot.docs;
      var list1,list2;

      records2.doc(result.id)
          .collection("recs")
          .get()
          .then((querySnapshot) {

        querySnapshot.docs.forEach((result) {
          print(result.data());
        });
        
      });
    });
  });
}

getCEachDate() async {
  var arr=[];
  //get dates
  QuerySnapshot querySnapshot = await records2.get();
  var list = querySnapshot.docs;
  var list1,list2;

  // print('start');
  for(int i=0;i<list.length;i++){
    //Records of each date
    // print(list[i].id);
    QuerySnapshot querySnapshot1 = await records2.doc(list[i].id).collection('recs').get();
    list1 = querySnapshot1.docs;
    // arr.add(list1);
    var r = new covrec(date:list[i].id , rec:[]);
    for(int j=0;j<list1.length;j++){
      DocumentSnapshot querySnapshot2 = await records2.doc('${list[i].id}/recs/${list1[j].id}').get();
      list2 = querySnapshot2.data();
      // print(list2);
      if(list2['infected']==true)
        r.rec.add(list2);
    }
      arr.add(r);
  }
  // print('end');

// print(arr);
  return arr;
}
Future addMessage(message,date) async {
  CollectionReference messages =chats.doc(FirebaseAuth.instance.currentUser.uid).collection("messages");
  return messages.doc().set({
    'userid': FirebaseAuth.instance.currentUser.uid,
    'date': date,
    'message': message,

  })
      .then((value) => print("Message sent"))
      .catchError((error) => print("Failed to send message: $error"));
}
Future addReply(userid,message,date) async {
  CollectionReference messages =chats.doc(userid).collection("messages");
  return messages.doc().set({
    'userid': FirebaseAuth.instance.currentUser.uid,
    'date': date,
    'message': message,
  })
      .then((value) => print("Message sent"))
      .catchError((error) => print("Failed to send message: $error"));
}
Future createChat(username) async {
  return chats.doc(FirebaseAuth.instance.currentUser.uid).set({
    'userid': FirebaseAuth.instance.currentUser.uid,
    'isRead': 'false',
    'drid': 'tHhZ73APULbOaF43qTx8IpVqDCi2',
  })
      .then((value) => print("Message sent"))
      .catchError((error) => print("Failed to send message: $error"));
}

class covrec{
 final date,rec;
 covrec({this.date, this.rec});
}

class DateRec{
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
      builder: (BuildContext context, AsyncSnapshot snapshot){

        final List <DateRec> dateRec = [];
        final List <DateRec> headRec = [];
        final List <DateRec> feverRec = [];
        final List <DateRec> caughRec = [];


        if (snapshot.hasData){
          if(snapshot.data.length>0){

            for(int i=0;i<snapshot.data.length;i++){
              var count = snapshot.data[i].rec.where((c)=>c['headache']==true).toList().length;
              // headRec.add(new DateRec(count, 'Headache'));
              var count1 = snapshot.data[i].rec.where((c)=>c['fever']==true).toList().length;
              var count2 = snapshot.data[i].rec.where((c)=>c['cough']==true).toList().length;
              headRec.add(new DateRec(count, DateFormat('d-MMM-yy').format(DateTime.parse(snapshot.data[i].date))));
              feverRec.add(new DateRec(count1, DateFormat('d-MMM-yy').format(DateTime.parse(snapshot.data[i].date))));
              caughRec.add(new DateRec(count2, DateFormat('d-MMM-yy').format(DateTime.parse(snapshot.data[i].date))));
              dateRec.add(new DateRec(snapshot.data[i].rec.length/*-(count1+count+count2)*/, DateFormat('d-MMM-yy').format(DateTime.parse(snapshot.data[i].date))));

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
                    )
                ),
                zoomPanBehavior:  ZoomPanBehavior(
                  enablePinching: true,
                  zoomMode: ZoomMode.x,
                  enablePanning: true,
                ),
                // backgroundColor: Colors.white,

                primaryXAxis: CategoryAxis(),
                title: ChartTitle(text: 'Chart'), //Chart title.
                legend: Legend(isVisible: true), // Enables the legend.
                tooltipBehavior: TooltipBehavior(enable: true), // Enables the tooltip.
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
                ]
            );


          }else{
            return Expanded(
                child: Center(child: Text("There is no data for this country", style: TextStyle(fontSize: 20, color: Colors.red,fontWeight: FontWeight.bold),))
            );
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

class mrec{
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
    _tooltipBehavior = TooltipBehavior(
        enable: true);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Graph for '+this.widget.date.toString()),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: records2.doc(this.widget.date).collection('recs').snapshots(),
        builder: (BuildContext context, AsyncSnapshot snapshot){
          print(this.widget.date);

          // print(snapshot.data);

          var dateRec=0;
          var headRec=0;
          var feverRec=0;
          var caughRec=0;

          if (!snapshot.hasData){
            //print(snapshot.data);
            return Loading();
          }

          if (snapshot.hasData){
            snapshot.data.docs.forEach((v){
              if(v.data()['fever'])
                feverRec++;
              if(v.data()['cough'])
                caughRec++;
              if(v.data()['headache'])
                headRec++;
              else
                dateRec++;
              print(v.data());
            });
            // print('c= '+caughRec.toString()+' f = '+feverRec.toString()+' h= '+headRec.toString()+' d = '+dateRec.toString());

            final List<mrec> chartData = [
              mrec(feverRec,'Fever',Color(0xffFCD570)),
              mrec(caughRec,'Cough',Color(0xffFB88DB)),
              mrec( headRec,'Headache',Color(0xff84DC77)),
              mrec( dateRec,'None',Color(0xffA0C5FD))
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
              pointColorMapper: (mrec data, _) => data.col
          )
          ]
          );


              SfCartesianChart(
          series: <ChartSeries>[
          // Renders bar chart
          BarSeries<mrec, num>(
          dataSource: chartData,
          xValueMapper: (mrec sales, _) => sales.name ,
          yValueMapper: (mrec sales, _) => sales.num
          )
          ]
          );

            /*  SfCircularChart(
                tooltipBehavior: _tooltipBehavior,
                legend: Legend(isVisible: true),
                series: <CircularSeries>[
                  // Renders radial bar chart
                  RadialBarSeries<DateRec, String>(
                    dataSource: chartData,
                    xValueMapper: (DateRec data, _) => data.date,
                    yValueMapper: (DateRec data, _) => data.cases,
                cornerStyle: CornerStyle.bothCurve,
                      dataLabelSettings: DataLabelSettings(
                        // Renders the data label
                          isVisible: true
                      )
                  )
                ]
            );*/
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
