import 'package:app1/Screens/AddCompany.dart';
import 'package:app1/Screens/AddSupervisor.dart';
import 'package:app1/Screens/AddDoctor.dart';
import 'package:app1/Services/CRUD.dart';
import 'package:flutter/material.dart';

import 'AddUser.dart';


class Companies extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Companies List: "),
        actions: [
          TextButton(onPressed: (){
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) =>CompanyAdd()),
            );
          }, child: Icon(Icons.add))
        ],
      ),body: CompaniesList(),
      //bottomNavigationBar: Text("Hello"),
    );
  }
}

class Doctors extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Doctors List: "),
        actions: [
          TextButton(onPressed: (){
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) =>DoctorAdd()),
            );
          }, child: Icon(Icons.add))
        ],
      ),body: DoctorsList(),
      //bottomNavigationBar: Text("Hello"),
    );
  }
}

class UsersForSuper extends StatefulWidget {
  @override
  _UsersForSuperState createState() => _UsersForSuperState();
  final supervisor_id,position;
  String companyid='';
  UsersForSuper(this.supervisor_id,this.position);
}

class _UsersForSuperState extends State<UsersForSuper> {
 @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getCompanyid(this.widget.supervisor_id).then((c){
      setState(() {
        this.widget.companyid = c;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
  //bool isLoading = false;
    return Scaffold(
      appBar: AppBar(
        title: Text('Users in '+ this.widget.position+' List: '),
        actions: [
          TextButton(onPressed: (){
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => UserAdd(pos:this.widget.position,sid:this.widget.supervisor_id)),
            );
          }, child: Icon(Icons.add))
        ],
      ),body: UsersForS(this.widget.supervisor_id,this.widget.companyid,this.widget.position),
      //bottomNavigationBar: Text("Hello"),
    );
  }
}

class Supervisors extends StatefulWidget {

  final company_id;

  Supervisors(this.company_id);

  @override
  _SupervisorsState createState() => _SupervisorsState();
}

class _SupervisorsState extends State<Supervisors> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Supervisors List: '),
        actions: [
          TextButton(onPressed: (){
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SupervisorAdd(this.widget.company_id)),
            );
          }, child: Icon(Icons.add))
        ],
      ),body: SupervisorsList(this.widget.company_id),
      //bottomNavigationBar: Text("Hello"),
    );
  }
}
