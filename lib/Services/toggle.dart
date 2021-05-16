import 'package:app1/Screens/Login.dart';
import 'package:app1/Screens/Register.dart';
import 'package:flutter/material.dart';
class Toggle extends StatefulWidget {
  @override
  _ToggleState createState() => _ToggleState();
}


class _ToggleState extends State<Toggle> {

  void togg(){
    setState(() {
      showState = !showState;
    });
  }


  bool showState = true;

  @override
  Widget build(BuildContext context) {
    if(showState){
      return SignIn(togg);
    }else{
      return Register();
    };
  }
}
