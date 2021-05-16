import 'package:app1/Services/crudUser.dart';
import 'package:flutter/material.dart';


class Users extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Users List: "),
      ),body: UsersList(),
      //bottomNavigationBar: Text("Hello"),
    );
  }
}