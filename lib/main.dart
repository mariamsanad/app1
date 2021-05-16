import 'Screens/Companies.dart';
import 'Screens/Position.dart';
import 'Screens/Profile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'Screens/Login.dart';
import 'Screens/AddCompany.dart';
import 'Screens/News.dart';
import 'Screens/RecordMySituation.dart';
import 'Screens/Services.dart';
import 'Screens/Statistics.dart';
import 'Screens/AddSupervisor.dart';
import 'package:flutter/material.dart';
import 'Home.dart';
import 'Screens/Register.dart';
import 'Screens/users.dart';
import 'Screens/Details.dart';
import 'Screens/testgraph.dart';
import 'package:firebase_core/firebase_core.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
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
              home: Home(),
              routes: {
                'news': (context) {
                  return News();
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
                  return Profile(FirebaseAuth.instance.currentUser.uid);
                },
                'register': (context) {
                  return Register();
                },
                'services': (context) {
                  return Services();
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
                }
             },
            ));
  }
}

class OldMain extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Covid-19',
      home: Home(),
      routes: {
        'services': (context) {
          return Services();
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
        "statistics": (context) {
          return Statistics();
        },
        "graph": (context) {
          return BarChartSample1();
        }
      },
    );
  }
}