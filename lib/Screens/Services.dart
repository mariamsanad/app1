import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:app1/Services/CompanyCRUD.dart';

class Services extends StatefulWidget {
  @override
  _ServicesState createState() => _ServicesState();
}

class _ServicesState extends State<Services> {
  @override
  Widget build(BuildContext context) {
    return AddUser("mariam123", "Mariam", 50);
  }
}
