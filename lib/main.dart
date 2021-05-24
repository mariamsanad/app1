import 'Screens/AdminCovidReports.dart';
import 'package:app1/Screens/viewQuestions.dart';

import 'Screens/Companies.dart';
import 'Screens/Position.dart';
import 'Screens/Profile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'Screens/Login.dart';
import 'Screens/AddCompany.dart';
import 'Screens/News.dart';
import 'Screens/RecordMySituation.dart';
import 'Screens/Statistics.dart';
import 'Screens/AddSupervisor.dart';
import 'package:flutter/material.dart';
import 'Home.dart';
import 'Screens/ChatRoom.dart';
import 'Screens/viewQuestions.dart';
import 'Screens/Register.dart';
import 'Screens/users.dart';
import 'Screens/Details.dart';
import 'Screens/CovidReports.dart';
import 'package:firebase_core/firebase_core.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
 /*await Firebase.initializeApp(name: "SecondaryApp",options: const FirebaseOptions(
      appId: '1:138993678832:android:dac004f23f9fc1b63e0535',
      apiKey: 'AIzaSyCHgubmnroKE7goN9-TTnavGtvn2xyXh2M',
      messagingSenderId: '138993678832',
      projectId: 'covid-19senior'
  ) );*/
  return runApp(MyApp());
}

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    final FirebaseAuth _auth = FirebaseAuth.instance;
    return StreamProvider.value(
      value: _auth.authStateChanges(),
      child: MaterialApp(
              debugShowCheckedModeBanner: false,
              title: 'Covid-19',
        theme: ThemeData(
          // Define the default brightness and colors.
          // brightness: Brightness.dark,
          primaryColor: Color(0xffe45b5e),
          accentColor: Color(0xfffeb493),
          buttonColor:  Color(0xfffeb493),

          // Define the default font family.
          // fontFamily: 'Arial',

          // Define the default TextTheme. Use this to specify the default
          // text styling for headlines, titles, bodies of text, and more.
          textTheme: TextTheme(
            headline1: TextStyle(fontSize: 72.0, fontWeight: FontWeight.bold),
            headline6: TextStyle(fontSize: 36.0, fontStyle: FontStyle.italic),
            bodyText2: TextStyle(fontSize: 14.0, fontFamily: 'Hind'),
          ),
        ),
              home: Home(),
              routes: {
                'news': (context) {
                  return News();
                },
                'admincovedrec': (context) {
                  return AdminCovidReports();
                },
                'situation': (context) {
                  return RecordCovid();
                },
                'reportforuser': (context) {
                  return CovidReportUser(FirebaseAuth.instance.currentUser.uid.toString(),'teacher');
                },
                'companies': (context) {
                  return Companies();
                },
                'position': (context) {
                  return Positions(FirebaseAuth.instance.currentUser.uid);
                },
                'recordsit': (context) {
                  return RecordCovid();
                },
                'companyadd': (context) {
                  return CompanyAdd();
                },
                'profile': (context) {
                  return Profile(FirebaseAuth.instance.currentUser.uid,null,null,null);
                },
                'register': (context) {
                  return Register();
                },
                'login': (context) {
                  return SignIn(null);
                },
                'homepage': (context) {
                  return Home();
                },
                "users": (context) {
                  return Users();
                },
                "usersdetails": (context) {
                  return UsersDetails();
                },
                "reset": (context) {
                  return ForgotPass();
                },
                "statistics": (context) {
                  return Statistics();
                },
                "supervisoradd": (context) {
                  return SupervisorAdd(FirebaseAuth.instance.currentUser.uid);
                },
                "chatroom": (context) {
                  return ChatRoom(FirebaseAuth.instance.currentUser.uid);
                },
                "viewquestions": (context) {
                  return ViewQuestions(FirebaseAuth.instance.currentUser.uid);
                },
             },
            ));
  }
}

