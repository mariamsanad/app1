import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class Loading extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      //color: Color(0xAEB6BF).withOpacity(0.5),
      child: Center(
          child: SpinKitSquareCircle(
            color: Theme.of(context).primaryColor.withOpacity(0.6),
            size: 50.0,
          )
      ),
    );
  }
}